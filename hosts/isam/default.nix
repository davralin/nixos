{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/impermanence-root.nix
    ../../modules/locale.nix
    ../../modules/mikr.nix
    ../../modules/openzfs.nix
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

  # ZFS data pool — auto-import with force (to handle hostid mismatches from ISO usage)
  boot.zfs.extraPools = [ "rpool" ];
  boot.zfs.forceImportAll = true;
  # Key is at keylocation=file:///nix/persist/zfs.key on the encrypted ext4 /nix
  # NixOS ZFS infrastructure loads it automatically when /nix is mounted

  # Serial console for VM — ttyS0 last = preferred for input (LUKS passphrase reads from it)
  boot.kernelParams = [ "console=tty1" "console=ttyS0,115200n8" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "26.05";
}
