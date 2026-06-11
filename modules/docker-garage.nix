{ config, pkgs, ... }:

{
  programs.bash.shellAliases = {
    garage = "alias garage='docker exec -ti garage-garage-1 /garage -c /opt/garage/garage.toml'";
  };

  systemd.services.docker-garage = {
    description = "Docker garage";
    serviceConfig = {
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f /opt/garage/docker-compose.yml up";
      Restart = "on-failure";
    };
    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket"];
  };
}