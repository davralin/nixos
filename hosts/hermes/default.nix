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
  boot.initrd.systemd.services.rollback = {
    description = "Rollback btrfs root subvolume";
    wantedBy = [ "initrd.target" ];
    after = [ "dev-vda2.device" ];
    before = [ "sysroot.mount" ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /mnt
      mount -t btrfs -o subvol=/ /dev/vda2 /mnt

      # Delete nested subvolumes under @ first (bottom-up)
      btrfs subvolume list -o /mnt/@ | awk '{print $NF}' | while read subvol; do
        btrfs subvolume delete "/mnt/$subvol" || true
      done

      # Delete @ itself and recreate fresh
      btrfs subvolume delete /mnt/@
      btrfs subvolume create /mnt/@

      umount /mnt
    '';
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Serial console for KubeVirt (virtio-serial / ttyS0)
  boot.kernelParams = [ "console=ttyS0,115200n8" ];

  # QEMU guest agent
  services.qemuGuest.enable = true;

  networking.hostName = "hermes";

  system.stateVersion = "26.05";
}
