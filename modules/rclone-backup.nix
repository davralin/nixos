{ config, pkgs, ... }:

{
  # Run rclone-backup daily
  systemd.timers."rclone-daily-backup" = {
    wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        Unit = "rclone-daily-backup.service";
      };
  };

  systemd.services."rclone-daily-backup" = {
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      ExecStart = "/opt/local/backup.sh";
    };
  };
}