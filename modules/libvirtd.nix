{ config, pkgs, ... }:

{
  virtualisation.libvirtd = {
    enable = true;
    onShutdown = "shutdown";
    shutdownTimeout = 600;
  };

  environment.systemPackages = with pkgs; [
    OVMF
    virt-manager
  ];
}
