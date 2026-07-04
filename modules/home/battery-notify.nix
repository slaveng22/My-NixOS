{ pkgs, ... }:

let
  notifySend = "${pkgs.libnotify}/bin/notify-send";

  batteryScript = pkgs.writeShellScript "battery-notify" ''
    BAT=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || cat /sys/class/power_supply/BAT1/capacity 2>/dev/null)
    STATUS=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || cat /sys/class/power_supply/BAT1/status 2>/dev/null)

    [ -z "$BAT" ] && exit 0
    [ "$STATUS" = "Charging" ] && exit 0

    if [ "$BAT" -le 5 ]; then
      ${notifySend} -u critical "Battery Critical" "Battery at ''${BAT}% — plug in now!"
    elif [ "$BAT" -le 15 ]; then
      ${notifySend} -u normal "Battery Low" "Battery at ''${BAT}%"
    fi
  '';
in
{
  systemd.user.services.battery-notify = {
    Unit.Description = "Battery level notification";
    Service = {
      Type = "oneshot";
      ExecStart = "${batteryScript}";
      Environment = "DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus";
    };
  };

  systemd.user.timers.battery-notify = {
    Unit.Description = "Battery notification timer";
    Timer = {
      OnBootSec = "1min";
      OnUnitActiveSec = "1min";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
