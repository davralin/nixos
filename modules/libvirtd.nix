{ config, pkgs, ... }:

{
  virtualisation.libvirtd.enable = true;

  environment.systemPackages = with pkgs; [
    OVMF
    virt-manager
  ];
}
