{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/impermanence-zfs.nix
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

  # Use systemd in initrd (required for boot.initrd.systemd.services)
  boot.initrd.systemd.enable = true;

  # ZFS encrypted pool — passphrase entered at boot
  boot.zfs.requestEncryptionCredentials = true;

  # LUKS swap — unlocked via keyfile on ZFS persist
  boot.initrd.luks.devices."swap" = {
    device = "/dev/disk/by-uuid/39c1ad40-2bb8-41ec-9658-6ce0fcb70902";
    keyFile = "/nix/persist/swap.key";
    keyFileSize = 4096;
  };

  # ZFS impermanence: rollback root to blank snapshot on each boot
  # Uses systemd initrd service (required with systemd stage 1)
  boot.initrd.systemd.services.rollback = {
    description = "Rollback ZFS root to blank snapshot";
    wantedBy = [ "initrd.target" ];
    after = [ "zfs-import-rpool.service" ];
    before = [ "sysroot.mount" ];
    path = [ pkgs.zfs ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      zfs rollback -r rpool/root@blank
    '';
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "26.05";
}
