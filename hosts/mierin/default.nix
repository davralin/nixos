{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/secrets/mierin.nix
      ../../modules/secrets/nullmailer.nix
      ../../modules/acme.nix
      ../../modules/ansible.nix
      ../../modules/auto-update.nix
      ../../modules/common.nix
      ../../modules/garbage-collect.nix
      ../../modules/impermanence-root.nix
      ../../modules/locale.nix
      ../../modules/mikr.nix
      ../../modules/node-exporter.nix
      ../../modules/physical.nix
      ../../modules/docker-registry-cache.nix
      ../../modules/router.nix
      ../../modules/ssh.nix
      ../../modules/sudo.nix
      ../../modules/unfree.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "Mierin";
  networking.useDHCP = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
