{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [
      inputs.disko.nixosModules.disko
      ./disko.nix
      ./hardware-configuration.nix
      ../../modules/secrets/nullmailer.nix
      ../../modules/ansible.nix
      ../../modules/auto-update.nix
      ../../modules/backup-k8s.nix
      ../../modules/common.nix
      ../../modules/garbage-collect.nix
      ../../modules/impermanence-root.nix
      ../../modules/locale.nix
      ../../modules/mikr.nix
      ../../modules/node-exporter.nix
      ../../modules/openzfs.nix
      ../../modules/physical.nix
      ../../modules/rclone-backup.nix
      ../../modules/rsnapshot.nix
      ../../modules/ssh.nix
      ../../modules/sudo.nix
      ../../modules/unfree.nix
    ];

  # ZFS-config:
  # zpool create \
  #   -o ashift=12 \
  #   -o autotrim=on \
  #   -O encryption=aes-256-gcm \
  #   -O keyformat=raw \
  #   -O keylocation=file:///nix/persist/keys/zfs.key \
  #   -O acltype=posixacl \
  #   -O xattr=sa \
  #   -O dnodesize=auto \
  #   -O compression=lz4 \
  #   -O normalization=formD \
  #   -O relatime=on \
  #   -O canmount=off \
  #   -O mountpoint=none \
  #   home-nas raidz1 \
  #   /dev/disk/by-id/xxx \
  #   /dev/disk/by-id/xxx \
  #   /dev/disk/by-id/xxx \
  #   /dev/disk/by-id/xxx
  # zfs set com.sun:auto-snapshot=true home-nas
  # zfs create -o mountpoint=legacy home-nas/local
  boot.kernelParams = [ "zfs.zfs_arc_max=2147483648" ];

  # Allow on all one interfaces
  services.prometheus.exporters.node.openFirewall = true;

  # Bootloader.
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "home-nas";
    hostId = "3f784dab"; # for OpenZFS
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

}
