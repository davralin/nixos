{ config, pkgs, wowRealmAddress, ... }:

let
  serverDir = "/srv/wow";
  clientDir = "/srv/wow-client";
  backupDir = "/srv/wow-backups";
  buildComplete = "${serverDir}/.docker-build-complete";
  compose = "${config.virtualisation.docker.package}/bin/docker compose";

  backupScript = pkgs.writeShellScript "wow-backup" ''
    set -euo pipefail
    export PATH=${pkgs.lib.makeBinPath (with pkgs; [ coreutils findutils git gnutar gzip ])}:$PATH

    mkdir -p ${backupDir}
    backup="${backupDir}/$(date -u +%Y%m%dT%H%M%SZ)"
    mkdir -p "$backup"
    trap 'rm -rf "$backup"' ERR

    cd ${serverDir}

    ${compose} up -d ac-database

    {
      echo "timestamp=$(date -u --iso-8601=seconds)"
      echo "server_commit=$(git -C ${serverDir} rev-parse HEAD 2>/dev/null || true)"
      echo "playerbots_commit=$(git -C ${serverDir}/modules/mod-playerbots rev-parse HEAD 2>/dev/null || true)"
    } > "$backup/metadata.txt"

    ${compose} config > "$backup/docker-compose.config.yml"
    tar -C ${serverDir} -czf "$backup/config.tar.gz" docker-compose.override.yml env/dist/etc
    ${compose} exec -T ac-database mysqldump -uroot -ppassword \
      --single-transaction --routines --triggers \
      --databases acore_auth acore_characters acore_world acore_playerbots \
      | gzip -9 > "$backup/databases.sql.gz"

    ls -1dt ${backupDir}/*/ 2>/dev/null | tail -n +9 | xargs -r rm -rf
    trap - ERR
  '';
in
{
  networking.firewall.allowedTCPPorts = [ 80 3724 8085 ];

  zramSwap.enable = true;
  zramSwap.memoryPercent = 50;

  virtualisation.docker.extraPackages = with pkgs; [
    docker-buildx
  ];

  environment.systemPackages = with pkgs; [
    unzip
  ];

  environment.persistence."/nix/persist".directories = [
    serverDir
    clientDir
    backupDir
    "/var/lib/docker"
  ];

  systemd.tmpfiles.rules = [
    "d ${serverDir} 0755 root root -"
    "d ${clientDir} 0755 root root -"
    "d ${backupDir} 0755 root root -"
  ];

  services.nginx = {
    enable = true;
    virtualHosts."_default_" = {
      default = true;
      root = clientDir;
      locations."/" = {
        extraConfig = ''
          autoindex on;
        '';
      };
    };
  };

  systemd.services.wow-prepare = {
    description = "Prepare AzerothCore WotLK playerbots checkout";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = with pkgs; [ git ];
    script = ''
      set -eu

      if [ ! -d ${serverDir}/.git ]; then
        git clone --branch Playerbot https://github.com/mod-playerbots/azerothcore-wotlk.git ${serverDir}
      fi

      if [ ! -d ${serverDir}/modules/mod-playerbots/.git ]; then
        mkdir -p ${serverDir}/modules
        git clone --branch master https://github.com/mod-playerbots/mod-playerbots.git ${serverDir}/modules/mod-playerbots
      fi

      cat > ${serverDir}/docker-compose.override.yml <<'EOF'
      services:
        ac-worldserver:
          environment:
            AC_PLAYERBOTS_UPDATES_ENABLE_DATABASES: "1"
            AC_AI_PLAYERBOT_RANDOM_BOT_AUTOLOGIN: "1"
            AC_AI_PLAYERBOT_MIN_RANDOM_BOTS: "1600"
            AC_AI_PLAYERBOT_MAX_RANDOM_BOTS: "2000"
          volumes:
            - ./modules:/azerothcore/modules:ro
          ports:
            - "8085:8085"
        ac-authserver:
          ports:
            - "3724:3724"
      EOF
    '';
  };

  systemd.services.wow-build = {
    description = "Build AzerothCore WotLK playerbots Docker images";
    after = [ "docker.service" "wow-prepare.service" ];
    wants = [ "docker.service" "wow-prepare.service" ];
    serviceConfig = {
      Type = "oneshot";
      WorkingDirectory = serverDir;
      TimeoutStartSec = "8h";
    };
    environment = {
      COMPOSE_DOCKER_CLI_BUILD = "1";
      DOCKER_BUILDKIT = "1";
    };
    script = ''
      rm -f ${buildComplete}
      ${compose} build
      touch ${buildComplete}
    '';
  };

  systemd.services.wow = {
    description = "AzerothCore WotLK playerbots";
    after = [ "docker.service" "network-online.target" "wow-prepare.service" ];
    wants = [ "docker.service" "network-online.target" "wow-prepare.service" ];
    wantedBy = [ "multi-user.target" ];
    unitConfig.ConditionPathExists = buildComplete;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = serverDir;
      TimeoutStartSec = "10min";
    };
    script = ''
      mkdir -p env/dist/etc/modules env/dist/logs
      if [ -f env/dist/etc/modules/playerbots.conf.dist ] && [ ! -f env/dist/etc/modules/playerbots.conf ]; then
        cp env/dist/etc/modules/playerbots.conf.dist env/dist/etc/modules/playerbots.conf
      fi
      chown -R 1000:1000 env/dist/etc env/dist/logs
      ${compose} up -d --no-build

      for _ in $(seq 1 60); do
        realms="$(${compose} exec -T ac-database mysql -N -uroot -ppassword acore_auth \
          -e "SELECT COUNT(*) FROM realmlist WHERE id = 1;" 2>/dev/null || true)"
        if [ "$realms" = "1" ]; then
          break
        fi
        sleep 2
      done

      ${compose} exec -T ac-database mysql -uroot -ppassword acore_auth \
        -e "UPDATE realmlist SET address = '${wowRealmAddress}', flag = 0 WHERE id = 1;"
      ${compose} restart ac-authserver
    '';
    preStop = ''
      ${compose} down
    '';
  };

  systemd.services.wow-backup = {
    description = "Back up AzerothCore WotLK databases and config";
    after = [ "docker.service" "wow-prepare.service" ];
    wants = [ "docker.service" "wow-prepare.service" ];
    serviceConfig = {
      Type = "oneshot";
      WorkingDirectory = serverDir;
      TimeoutStartSec = "30min";
      ExecStart = backupScript;
    };
  };

  systemd.services.wow-weekly-rebuild = {
    description = "Weekly backup, update, and rebuild for AzerothCore WotLK";
    after = [ "docker.service" "network-online.target" "wow-prepare.service" ];
    wants = [ "docker.service" "network-online.target" "wow-prepare.service" ];
    serviceConfig = {
      Type = "oneshot";
      WorkingDirectory = serverDir;
      TimeoutStartSec = "8h";
    };
    environment = {
      COMPOSE_DOCKER_CLI_BUILD = "1";
      DOCKER_BUILDKIT = "1";
    };
    path = with pkgs; [ coreutils git systemd ];
    script = ''
      set -euo pipefail

      ${backupScript}

      ${compose} down

      git -C ${serverDir} fetch origin Playerbot
      git -C ${serverDir} checkout Playerbot
      git -C ${serverDir} pull --ff-only origin Playerbot

      git -C ${serverDir}/modules/mod-playerbots fetch origin master
      git -C ${serverDir}/modules/mod-playerbots checkout master
      git -C ${serverDir}/modules/mod-playerbots pull --ff-only origin master

      rm -f ${buildComplete}
      ${compose} build
      touch ${buildComplete}

      systemctl restart wow.service
      ${compose} ps
    '';
  };

  systemd.timers.wow-weekly-rebuild = {
    description = "Weekly AzerothCore WotLK backup, update, and rebuild";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Sun 04:00";
      Persistent = true;
      RandomizedDelaySec = "30min";
    };
  };
}
