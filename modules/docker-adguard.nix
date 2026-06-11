{ config, pkgs, ... }:

{
  systemd.services.docker-adguard = {
    description = "Docker AdGuard";
    serviceConfig = {
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f /opt/adguard/docker-compose.yml up";
      Restart = "on-failure";
    };
    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket"];
  };
}