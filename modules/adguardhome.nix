{ ... }:

{
  services.adguardhome.enable = true;

  systemd.services.adguardhome.serviceConfig.StateDirectoryMode = "0700";
}
