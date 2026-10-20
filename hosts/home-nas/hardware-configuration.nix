# Hardware-specific configuration for the UGREEN DXP4800 Plus.
{ config, lib, pkgs, modulesPath, ... }:

let
  ledctl = "${pkgs.ugreen-leds-cli}/bin/ugreen_leds_cli";
  smartctl = "${pkgs.smartmontools}/bin/smartctl";
  zpool = "${pkgs.zfs}/bin/zpool";
in
{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" "iTCO_wdt" "it87_wdt" "i2c-dev" ];
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

  environment.systemPackages = [ pkgs.i2c-tools pkgs.ugreen-leds-cli ];

  # Verified against the physical front panel on 2026-10-13. Keep future
  # health/activity logic bound to these stable SATA paths rather than /dev/sdX.
  # bay 1: disk1, ata-1; bay 2: disk2, ata-2
  # bay 3: disk3, ata-3; bay 4: disk4, ata-4
  systemd.services.ugreen-leds-initialize = {
    description = "Initialize UGREEN front-panel LEDs";
    after = [ "systemd-modules-load.service" ];
    wants = [ "systemd-modules-load.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      ${ledctl} power -on -color 0 96 255 -brightness 180
      ${ledctl} netdev -on -color 0 220 255 -brightness 180
      ${ledctl} disk1 disk2 disk3 disk4 -on -color 255 255 255 -brightness 180
    '';
  };

  systemd.services.ugreen-leds-health = {
    description = "Update UGREEN disk LEDs from ZFS and SMART health";
    after = [ "zfs.target" "ugreen-leds-initialize.service" ];
    wants = [ "zfs.target" "ugreen-leds-initialize.service" ];

    serviceConfig.Type = "oneshot";

    script = ''
      set -u

      status_file="$(mktemp)"
      trap 'rm -f "$status_file"' EXIT

      # Match each bay against every imported pool rather than a specific pool
      # or vdev, so pool layout changes do not require an LED config change.
      if ! ${zpool} status -P -L > "$status_file"; then
        echo "Unable to read ZFS health; marking all bays as degraded"
        for led in disk1 disk2 disk3 disk4; do
          ${ledctl} "$led" -on -color 255 0 0 -brightness 255 -blink 600 600
        done
        exit 0
      fi

      set_green() {
        ${ledctl} "$1" -on -color 0 255 0 -brightness 180
      }

      set_amber() {
        ${ledctl} "$1" -on -color 255 160 0 -brightness 255 -blink 800 800
      }

      set_red() {
        ${ledctl} "$1" -on -color 255 0 0 -brightness 255 -blink 600 600
      }

      check_bay() {
        led="$1"
        path="$2"

        if [ ! -e "$path" ]; then
          echo "$led: no disk at $path"
          ${ledctl} "$led" -off
          return
        fi

        device="$(${pkgs.coreutils}/bin/readlink -f "$path")"
        vdev_state=""
        vdev_read=""
        vdev_write=""
        vdev_checksum=""

        while read -r name state read_errors write_errors checksum_errors; do
          case "$name" in
            "$device"[0-9]*)
              vdev_state="$state"
              vdev_read="$read_errors"
              vdev_write="$write_errors"
              vdev_checksum="$checksum_errors"
              break
              ;;
          esac
        done < <(${pkgs.gawk}/bin/awk '$1 ~ "^/dev/" { print $1, $2, $3, $4, $5 }' "$status_file")

        if [ -z "$vdev_state" ] || [ "$vdev_state" != "ONLINE" ]; then
          echo "$led: ZFS vdev is missing or not ONLINE"
          set_red "$led"
          return
        fi

        if [ "$vdev_read" != "0" ] || [ "$vdev_write" != "0" ] || [ "$vdev_checksum" != "0" ]; then
          echo "$led: ZFS vdev has recorded errors"
          set_amber "$led"
          return
        fi

        ${smartctl} -a -q silent -n standby "$path" > /dev/null 2>&1
        smart_status=$?

        if (( smart_status & (8 | 16) )); then
          echo "$led: SMART reports a current failure"
          set_red "$led"
        elif (( smart_status != 0 )); then
          echo "$led: SMART reports a warning or could not be read"
          set_amber "$led"
        else
          set_green "$led"
        fi
      }

      check_bay disk1 /dev/disk/by-path/pci-0000:03:00.0-ata-1
      check_bay disk2 /dev/disk/by-path/pci-0000:03:00.0-ata-2
      check_bay disk3 /dev/disk/by-path/pci-0000:03:00.0-ata-3
      check_bay disk4 /dev/disk/by-path/pci-0000:03:00.0-ata-4
    '';
  };

  systemd.timers.ugreen-leds-health = {
    description = "Run UGREEN disk LED health check hourly";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "1h";
      Persistent = true;
    };
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
