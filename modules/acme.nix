{ config, pkgs, ... }:

{
  security.acme = {
    acceptTerms = true;
    defaults.email = "manual.says.this.is.not.needed@nixos.org";
    defaults.dnsProvider = "cloudflare";
    defaults.environmentFile = "/var/lib/acme/api-tokens";
  };
}
