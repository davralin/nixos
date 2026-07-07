{ config, pkgs, ... }:

{
  users.users.signal-cli = {
    isSystemUser = true;
    group = "signal-cli";
    home = "/nix/persist/signal-cli";
    createHome = true;
  };

  users.groups.signal-cli = {};

  systemd.services.signal-cli = {
    description = "Signal CLI Daemon";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      export SIGNAL_ACCOUNT=$(cat /nix/persist/secrets/signal-account)
      exec ${pkgs.signal-cli}/bin/signal-cli \
        --config /nix/persist/signal-cli \
        --account "$SIGNAL_ACCOUNT" \
        daemon --http 0.0.0.0:8080
    '';
    serviceConfig = {
      User = "signal-cli";
      Group = "signal-cli";
      Restart = "on-failure";
      RestartSec = 10;
    };
  };
}
