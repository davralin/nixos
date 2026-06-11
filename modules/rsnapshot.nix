{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    rsnapshot
  ];
}
