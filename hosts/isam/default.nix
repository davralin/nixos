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

  # ZFS data pool — auto-import; pool hostId has been fixed to match isam (66cb2f3d)
  boot.zfs.extraPools = [ "rpool" ];
  # Key is at keylocation=file:///nix/persist/zfs.key on the encrypted ext4 /nix
  # NixOS ZFS infrastructure loads it automatically when /nix is mounted

  # Serial console for VM — ttyS0 last = preferred for input (LUKS passphrase reads from it)
  boot.kernelParams = [ "console=tty1" "console=ttyS0,115200n8" ];

  # Hibernation — swap is on LVM-on-LUKS (/dev/mapper/base-swap, ~10G > 8G RAM)
  # boot.resumeDevice alone doesn't suppress nohibernate for dm paths; must disable protectKernelImage
  boot.resumeDevice = "/dev/mapper/base-swap";
  security.protectKernelImage = false;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "26.05";
}
