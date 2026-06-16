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

  # Btrfs rollback: wipe / on every boot by deleting and recreating the @ subvolume
  boot.initrd.supportedFilesystems = [ "btrfs" ];
  boot.initrd.postDeviceCommands = pkgs.lib.mkAfter ''
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

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Serial console for KubeVirt (virtio-serial / ttyS0)
  boot.kernelParams = [ "console=ttyS0,115200n8" ];

  # QEMU guest agent
  services.qemuGuest.enable = true;

  networking.hostName = "hermes";

  system.stateVersion = "26.05";
}
