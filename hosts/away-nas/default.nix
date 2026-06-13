{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/secrets/away-nas.nix
      ../../modules/secrets/nullmailer.nix
      ../../modules/acme.nix
      ../../modules/ansible.nix
      ../../modules/auto-update.nix
      ../../modules/backup-k8s.nix
      ../../modules/common.nix
      ../../modules/docker.nix
      ../../modules/docker-adguard.nix
      ../../modules/docker-immich.nix
      ../../modules/garbage-collect.nix
      ../../modules/haproxy.nix
      ../../modules/impermanence-root.nix
      ../../modules/locale.nix
      ../../modules/mikr.nix
      ../../modules/node-exporter.nix
      ../../modules/openzfs.nix
      ../../modules/physical.nix
      ../../modules/rclone-backup.nix
      ../../modules/rsnapshot.nix
      ../../modules/samba.nix
      ../../modules/ssh.nix
      ../../modules/tailscale.nix
      ../../modules/sudo.nix
      ../../modules/unfree.nix
    ];

  # ZFS-config:
  # zpool create -O compression=on -O mountpoint=none -O xattr=sa -O acltype=posixacl -o ashift=12 away-nas /dev/disk/by-id/xxx
  # zfs set com.sun:auto-snapshot=true away-nas
  # zfs create -o mountpoint=legacy away-nas/coldstorage
  # zfs create -o mountpoint=legacy away-nas/local
  # zfs create -o mountpoint=legacy away-nas/remote

  # open firewall for node-exporter
  services.prometheus.exporters.node.openFirewall = true;

  # Bootloader.
  # Use the systemd-boot EFI boot loader.
  boot.kernelParams = [ "zfs.zfs_arc_max=4831838208" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "away-nas";
    hostId = "3f784bad"; # for OpenZFS
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
