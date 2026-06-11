{ config, pkgs, ... }:

{
  # Add zfs-support
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  services.zfs.autoSnapshot.enable = true;
  services.zfs.autoSnapshot.flags = "-p --utc";
  services.zfs.autoScrub.enable = true;
}
