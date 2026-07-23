{ config, pkgs, ... }:

{
  virtualisation.podman.enable = true;
  virtualisation.podman.dockerCompat = true;
  virtualisation.podman.autoPrune.enable = true;
  virtualisation.podman.autoPrune.dates = "monthly";
  environment.systemPackages = with pkgs; [
    podman-compose
  ];
}
