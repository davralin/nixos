{ config, pkgs, ... }:

{
  # Enable haproxy
  services.haproxy = {
	  enable = true;
	};

  networking.firewall.allowedTCPPorts = [ 443 ];

}
