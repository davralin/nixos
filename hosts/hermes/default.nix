{ config, pkgs, inputs, modulesPath, ... }:

{
  imports = [
    inputs.disko.nixosModules.disko
    (modulesPath + "/profiles/qemu-guest.nix")
    ../../modules/common.nix
    ../../modules/impermanence-root.nix
    ../../modules/locale.nix
    ../../modules/mikr.nix
    ../../modules/ssh.nix
    ../../modules/sudo.nix
    ../../modules/unfree.nix
    ../../modules/garbage-collect.nix
    ../../modules/auto-update.nix
    ../../modules/node-exporter.nix
    ../../modules/signal-cli.nix
  ];

  # Disko disk layout
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/vda";
        imageSize = "5G";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@persist" = {
                    mountpoint = "/nix/persist";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [ "compress=zstd" ];
                  };
                  "@tmp" = {
                    mountpoint = "/tmp";
                    mountOptions = [ "compress=zstd" ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  # Mark /nix/persist as needed for boot (required by impermanence)
  fileSystems."/nix/persist".neededForBoot = true;

  # Use systemd initrd
  boot.initrd.systemd.enable = true;

  # Btrfs rollback: wipe / on every boot via systemd initrd service
  # Uses partition label set by disko (disk-main-root)
  # Uses btrfs subvolume delete --recursive to handle nested subvolumes
  boot.initrd.systemd.services.rollback = {
    description = "Rollback btrfs root subvolume";
    wantedBy = [ "initrd.target" ];
    after = [ "dev-disk-by\\x2dpartlabel-disk\\x2dmain\\x2droot.device" ];
    before = [ "sysroot.mount" ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /mnt
      mount -t btrfs -o subvol=/ /dev/disk/by-partlabel/disk-main-root /mnt

      # btrfs subvolume delete --recursive handles nested subvolumes automatically
      btrfs subvolume delete --recursive /mnt/@ 2>/dev/null || true
      btrfs subvolume delete --recursive /mnt/@tmp 2>/dev/null || true

      btrfs subvolume create /mnt/@
      btrfs subvolume create /mnt/@tmp

      umount /mnt
    '';
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Serial console for KubeVirt (virtio-serial / ttyS0)
  boot.kernelParams = [ "console=ttyS0,115200n8" ];

  # QEMU guest agent
  services.qemuGuest.enable = true;

  # zram swap for build memory safety
  zramSwap.enable = true;
  zramSwap.memoryPercent = 50;

  users.users.hermes = {
    isSystemUser = true;
    group = "hermes";
    home = "/nix/persist/hermes";
    createHome = true;
  };

  users.groups.hermes = {};

  systemd.services.hermes-agent = {
    description = "Hermes AI Agent";
    after = [ "network-online.target" "signal-cli.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    environment = {
      HERMES_HOME = "/nix/persist/hermes";
      HERMES_DASHBOARD = "1";
      SEARXNG_URL = "http://searxng.searxng.svc.cluster.local:8080";
      SIGNAL_HTTP_URL = "http://127.0.0.1:8080";
      HASS_URL = "https://home.ralin.org";
    };
    serviceConfig = {
      ExecStart = "${inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/hermes gateway run";
      User = "hermes";
      Group = "hermes";
      Restart = "on-failure";
      RestartSec = 10;
      EnvironmentFile = "-/nix/persist/secrets/hermes-env";
    };
  };

  networking.hostName = "hermes";

  system.stateVersion = "26.05";
}
