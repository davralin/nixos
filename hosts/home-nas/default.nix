{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/secrets/nullmailer.nix
      ../../modules/ansible.nix
      ../../modules/auto-update.nix
      ../../modules/backup-k8s.nix
      ../../modules/common.nix
      ../../modules/docker.nix
      ../../modules/docker-adguard.nix
      ../../modules/docker-garage.nix
      ../../modules/garbage-collect.nix
      ../../modules/impermanence-root.nix
      ../../modules/libvirtd.nix
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
  # zpool create -O compression=on -O mountpoint=none -O xattr=sa -O acltype=posixacl -o ashift=12 home-nas mirror /dev/disk/by-id/xxx /dev/disk/by-id/xxx
  # zfs set com.sun:auto-snapshot=true home-nas
  # zfs create -o mountpoint=legacy home-nas/local
  boot.kernelParams = [ "zfs.zfs_arc_max=9663676416" ];

  # Configure a bridge for libvirtd
  networking.useDHCP = false;
  services.resolved.enable = false;
  systemd.network = {
    enable = true;
    netdevs."br0" = {
      netdevConfig = {
        Name = "br0";
        Kind = "bridge";
        MACAddress = "c8:ff:bf:00:d2:dc";
      };
    };
    networks."10-enp2s0" = {
      matchConfig.Name = "enp2s0";
      networkConfig.Bridge = "br0";
    };
    networks."20-br0" = {
      matchConfig.Name = "br0";
      networkConfig.DHCP = "ipv4";
      dhcpV4Config.UseDNS = true;
    };
  };

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
  system.stateVersion = "25.11"; # Did you read the comment?

}
