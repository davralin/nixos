{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/profiles/qemu-guest.nix")
    ];

  boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ahci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" "dm_mod" ];
  boot.initrd.kernelModules = [ "8250" ];
  boot.initrd.services.lvm.enable = true;
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=2G" "mode=755" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-id/dm-name-base--nix";
    fsType = "ext4";
    neededForBoot = true;
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-id/dm-name-base--home";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/ESP";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  swapDevices = [
    { device = "/dev/disk/by-id/dm-name-base--swap"; }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
