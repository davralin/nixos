{ config, pkgs, lib, ... }:

let
  certName = builtins.head (builtins.attrNames config.security.acme.certs);
  certDir = config.security.acme.certs.${certName}.directory;
in

{
  services.dockerRegistry = {
    enable = true;
    listenAddress = "10.0.1.1";
    port = 5001;
    storagePath = "/opt/local/dockercache/dockerhub";
    enableDelete = true;
    extraConfig = {
      http.tls = {
        certificate = "${certDir}/cert.pem";
        key = "${certDir}/key.pem";
      };
      proxy = {
        remoteurl = "https://registry-1.docker.io";
      };
    };
  };

  systemd.services.docker-registry.serviceConfig = {
    Restart = "on-failure";
    RestartSec = "5s";
  };
}
