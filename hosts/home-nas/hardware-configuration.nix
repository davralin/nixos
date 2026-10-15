# Hardware-specific configuration for the UGREEN DXP4800 Plus.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" "iTCO_wdt" "it87_wdt" ];
  boot.extraModulePackages = [ ];
  boot.extraModprobeConfig = ''
    # The DXP4800 Plus BIOS watchdog is provided by the IT8613 Super I/O.
    options it87_wdt timeout=180
  '';

  # Use the BIOS watchdog through systemd PID 1. The Intel PCH watchdog does
  # not feed the separate BIOS timer.
  systemd.settings.Manager = {
    WatchdogDevice = "/dev/watchdog2";
    RuntimeWatchdogSec = "60s";
    RebootWatchdogSec = "10min";
  };

  fileSystems."/" =
    { device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "mode=755" "size=2G" ];
    };

  fileSystems."/opt/local" = {
    device = "home-nas/local";
    fsType = "zfs";
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp1s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp4s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
