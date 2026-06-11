{ config, pkgs, ... }:

{
  # Add samba, open firewall
  # Config goes elsewhere
  services = {
    samba = {
      enable = true;
      openFirewall = true;
      winbindd.enable = false;
      nmbd.enable = false;
    };
    samba-wsdd = {
    # This enables autodiscovery on windows since SMB1 (and thus netbios) support was discontinued
      enable = true;
      openFirewall = true;
    };
  };
}