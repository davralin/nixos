{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/impermanence-root.nix
    ../../modules/locale.nix
    ../../modules/mikr.nix
    ../../modules/ssh.nix
    ../../modules/sudo.nix
    ../../modules/unfree.nix
    ../../modules/auto-update.nix
    ../../modules/garbage-collect.nix
  ];

  networking.hostName = "isam";
  networking.hostId = "66cb2f3d";

  # LUKS2 container — single passphrase unlocks the LVM VG
  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-partlabel/cryptroot";
    allowDiscards = true;
  };

  # ZFS data pool — auto-import, key loaded by systemd service below
  boot.zfs.extraPools = [ "rpool" ];

  # Load ZFS encryption key from keyfile on encrypted ext4 /nix
  # Runs after ZFS pool is imported, before datasets are mounted
  systemd.services.zfs-load-key = {
    description = "Load ZFS encryption keys";
    after = [ "zfs-import.target" ];
    before = [ "zfs-mount.service" ];
    wantedBy = [ "zfs-mount.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${config.boot.zfs.package}/bin/zfs load-key -r -a";
    };
  };

  # Serial console for VM — LUKS prompt visible over serial
  boot.kernelParams = [ "console=ttyS0,115200n8" "console=tty1" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "26.05";
}
