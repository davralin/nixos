{ config, pkgs, ... }:

{
  # Automatic host-maintenance.
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    flake = "/nix/persist/nixos";
  };
  nix.settings.auto-optimise-store = true;

  # Automate git pull of nixos repo
  systemd.timers."git-pull-nixos" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      Unit = "git-pull-nixos.service";
    };
  };

  systemd.services."git-pull-nixos" = {
    script = ''
      set -eu
      cd /nix/persist/nixos
      ${pkgs.git}/bin/git pull --rebase
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
