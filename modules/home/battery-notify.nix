{ pkgs, ... }:

let
  sleep = "${pkgs.coreutils}/bin/sleep";
  cat = "${pkgs.coreutils}/bin/cat";
  notifySend = "${pkgs.libnotify}/bin/notify-send";
  systemctl = "${pkgs.systemd}/bin/systemctl";

  batteryScript = pkgs.writeShellScript "battery-notify" ''
    max_bat=80
    seconds=30

    last_notified_bat=""
    last_status=""

    while true; do
      cur_bat=$(${cat} /sys/class/power_supply/BAT0/capacity 2>/dev/null || ${cat} /sys/class/power_supply/BAT1/capacity 2>/dev/null)
      status=$(${cat} /sys/class/power_supply/BAT0/status 2>/dev/null || ${cat} /sys/class/power_supply/BAT1/status 2>/dev/null)

      if [ "$status" != "$last_status" ]; then
        last_notified_bat=""
        last_status="$status"
      fi

      if [ "$status" = "Discharging" ]; then
        if [ "$cur_bat" -le 3 ]; then
          threshold=3
          if [ "$last_notified_bat" != "$threshold" ]; then
            ${notifySend} -u critical "Critical Battery" "Battery at $cur_bat% — suspending now"
            last_notified_bat="$threshold"
            ${sleep} 3
            ${systemctl} suspend
          fi
        elif [ "$cur_bat" -le 5 ]; then
          threshold=5
          if [ "$last_notified_bat" != "$threshold" ]; then
            ${notifySend} -u critical "Critical Battery" "Battery at $cur_bat% — plug in charger NOW"
            last_notified_bat="$threshold"
          fi
        elif [ "$cur_bat" -le 10 ]; then
          threshold=10
          if [ "$last_notified_bat" != "$threshold" ]; then
            ${notifySend} -u critical "Low Battery" "Battery at $cur_bat% — plug in charger"
            last_notified_bat="$threshold"
          fi
        elif [ "$cur_bat" -le 15 ]; then
          threshold=15
          if [ "$last_notified_bat" != "$threshold" ]; then
            ${notifySend} -u normal "Low Battery" "Battery at $cur_bat%"
            last_notified_bat="$threshold"
          fi
        elif [ "$cur_bat" -le 20 ]; then
          threshold=20
          if [ "$last_notified_bat" != "$threshold" ]; then
            ${notifySend} -u low "Battery Warning" "Battery at $cur_bat%"
            last_notified_bat="$threshold"
          fi
        fi
      elif [ "$status" = "Charging" ] && [ "$cur_bat" -ge "$max_bat" ]; then
        threshold=$(( cur_bat / 5 * 5 ))
        if [ "$last_notified_bat" != "$threshold" ]; then
          ${notifySend} -u normal "Battery Charged" "Battery at $cur_bat% — unplug charger"
          last_notified_bat="$threshold"
        fi
      fi

      ${sleep} "$seconds"
    done
  '';
in
{
  systemd.user.services.battery-notify = {
    Unit = {
      Description = "Battery level notification daemon";
      After = [ "default.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${batteryScript}";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
