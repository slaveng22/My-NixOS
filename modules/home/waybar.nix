{ lib, pkgs, ... }:

let
nix-sysinfo = pkgs.writeShellScriptBin "nix-sysinfo" ''
    host=$(${pkgs.coreutils}/bin/uname -n)
    kernel=$(${pkgs.coreutils}/bin/uname -r)
    uptime=$(${pkgs.procps}/bin/uptime -p | ${pkgs.gnused}/bin/sed 's/up //')
    mem=$(${pkgs.procps}/bin/free -h | ${pkgs.gawk}/bin/awk '/^Mem:/ {print $3 " / " $2}')
    disk=$(${pkgs.coreutils}/bin/df -h / | ${pkgs.gawk}/bin/awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')
    cpu=$(${pkgs.gawk}/bin/awk -F': ' '/model name/ {print $2; exit}' /proc/cpuinfo)
    ${pkgs.jq}/bin/jq -cn \
      --arg host "$host" --arg cpu "$cpu" --arg kernel "$kernel" \
      --arg uptime "$uptime" --arg mem "$mem" --arg disk "$disk" \
      '{"text":" 󱄅 ","tooltip":"\($host)\nCPU: \($cpu)\nKernel: \($kernel)\nUptime: \($uptime)\nRAM: \($mem)\nDisk: \($disk)"}'
  '';

python-astral = pkgs.python3.withPackages (ps: [ ps.astral ]);

nightlight-cache-update = pkgs.writeShellScriptBin "nightlight-cache-update" ''
  mkdir -p "$HOME/.cache"
  ${python-astral}/bin/python3 -c "
from astral import LocationInfo
from astral.sun import sun
import datetime
from zoneinfo import ZoneInfo
city = LocationInfo('Belgrade', 'Serbia', 'Europe/Belgrade', 44.8167, 20.4667)
s = sun(city.observer, date=datetime.date.today(), tzinfo=ZoneInfo('Europe/Belgrade'))
print(s['sunrise'].strftime('%H%M'))
print(s['sunset'].strftime('%H%M'))
" > "$HOME/.cache/nightlight-times"
'';

nightlight-status = pkgs.writeShellScriptBin "nightlight-status" ''
  if ${pkgs.procps}/bin/pgrep -x wlsunset > /dev/null; then
    CACHE="$HOME/.cache/nightlight-times"
    [ -f "$CACHE" ] || ${nightlight-cache-update}/bin/nightlight-cache-update
    SUNRISE=$(${pkgs.coreutils}/bin/head -1 "$CACHE")
    SUNSET=$(${pkgs.coreutils}/bin/sed -n '2p' "$CACHE")
    NOW=$(${pkgs.coreutils}/bin/date +%H%M)
    if [ "$NOW" -lt "$SUNRISE" ] || [ "$NOW" -gt "$SUNSET" ]; then
      echo '{"text":"󰖔","class":"night","tooltip":"Night light on"}'
    else
      echo '{"text":"󰖙","class":"day","tooltip":"Night light on"}'
    fi
  else
    echo '{"text":"󰖙","class":"day","tooltip":"Night light off (manual)"}'
  fi
'';

nightlight-toggle = pkgs.writeShellScriptBin "nightlight-toggle" ''
  if ${pkgs.procps}/bin/pgrep -x wlsunset > /dev/null; then
    ${pkgs.systemd}/bin/systemctl --user stop wlsunset
  else
    ${pkgs.systemd}/bin/systemctl --user start wlsunset
  fi
  ${pkgs.procps}/bin/pkill -RTMIN+9 waybar
'';

mic-status = pkgs.writeShellScriptBin "mic-status" ''
  mute=$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | ${pkgs.gnugrep}/bin/grep -o '\[MUTED\]')
  if [ -n "$mute" ]; then
    echo '{"text":"󰍭","class":"muted","tooltip":"Mic muted"}'
  else
    echo '{"text":"󰍬","class":"active","tooltip":"Mic active"}'
  fi
'';
in

{
  home.packages = [ pkgs.calcure nix-sysinfo ];

  xdg.configFile."calcure/config.ini".text = ''
    [Colors]
    color_background = -1
    color_separator = 0
    color_calendar_border = 0
  '';

  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = [{
      layer = "top";
      position = "top";
      height = 38;
      spacing = 0;
      margin-top = 6;
      margin-left = 8;
      margin-right = 8;

      modules-left = [ "custom/nix" "niri/workspaces" ];
      modules-center = [ "niri/window" ];
      modules-right = [ "tray" "custom/nightlight" "bluetooth" "network" "pulseaudio" "custom/mic" "battery" "custom/power" "clock" ];

      "custom/nix" = {
        exec = "${nix-sysinfo}/bin/nix-sysinfo";
        return-type = "json";
        interval = 60;
        format = "{}";
        on-click = "${pkgs.niri}/bin/niri msg action toggle-overview";
      };

      "niri/workspaces" = {
        format = "{value}";
      };

      "niri/window" = {
        format = "{title}";
        rewrite = {
          "(.*) — Mozilla Firefox" = " $1";
        };
      };

      tray = {
        spacing = 8;
      };

      "custom/nightlight" = {
        exec = "${nightlight-status}/bin/nightlight-status";
        return-type = "json";
        interval = 60;
        on-click = "${nightlight-toggle}/bin/nightlight-toggle";
        signal = 9;
      };

      bluetooth = {
        format = "󰂯";
        format-connected = "󰂱";
        format-disabled = "󰂲";
        format-disconnected = "󰂯";
        tooltip-format = "Bluetooth on";
        tooltip-format-disconnected = "Bluetooth on";
        tooltip-format-connected = "{device_alias}\n{device_battery_percentage}%";
        tooltip-format-enumerate-connected = "{device_alias}";
        on-click = "${pkgs.bluez}/bin/bluetoothctl power $(${pkgs.bluez}/bin/bluetoothctl show | grep -q 'Powered: yes' && echo off || echo on)";
        on-click-right = "${pkgs.alacritty}/bin/alacritty -T bluetuith -e ${pkgs.bluetuith}/bin/bluetuith";
      };

      network = {
        format-wifi = "{icon}";
        format-ethernet = "󰈀";
        format-disconnected = "󰖪";
        format-icons = [ "󰤯" "󰤟" "󰤢" "󰤥" "󰤨" ];
        tooltip-format-wifi = "{essid}\n{ipaddr}\nSignal: {signalStrength}%";
        tooltip-format-ethernet = "{ifname}: {ipaddr}";
        tooltip-format-disconnected = "Disconnected";
        on-click-right = "${pkgs.alacritty}/bin/alacritty -T nmtui -e nmtui";
      };

      pulseaudio = {
        format = "{icon}";
        format-muted = "󰝟";
        format-icons = {
          default = [ "󰕿" "󰖀" "󰕾" ];
        };
        tooltip-format = "{volume}%\n{desc}";
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        on-click-right = "${pkgs.alacritty}/bin/alacritty -T pulsemixer -e ${pkgs.pulsemixer}/bin/pulsemixer";
      };

      "custom/mic" = {
        exec = "${mic-status}/bin/mic-status";
        return-type = "json";
        interval = 2;
        signal = 10;
        on-click = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle && ${pkgs.procps}/bin/pkill -RTMIN+10 waybar";
      };

      battery = {
        bat = "BAT0";
        states = { critical = 5; low = 30; medium = 60; };
        format = "󱊣";
        format-medium = "󱊢";
        format-low = "󱊡";
        format-critical = "󰂎";
        format-charging = "󱊦";
        format-charging-medium = "󱊥";
        format-charging-low = "󱊤";
        format-charging-critical = "󰢟";
        format-plugged = "󱊦";
        tooltip-format = "{capacity}%\n{timeTo}";
        tooltip-format-charging = "{capacity}%\n{timeTo}";
        tooltip-format-plugged = "{capacity}%\nPlugged in";
      };

      clock = {
        format = " {:%H:%M}";
        tooltip-format = "<big>{:%A, %d %B %Y}</big>\n<tt>{calendar}</tt>";
        on-click-right = "${pkgs.alacritty}/bin/alacritty -T calcure -e ${pkgs.calcure}/bin/calcure";
      };

      "custom/power" = {
        format = "⏻";
        on-click = "${pkgs.wlogout}/bin/wlogout";
        tooltip = false;
      };
    }];

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
        border: none;
        border-radius: 0;
        padding: 0;
        margin: 0;
        min-height: 0;
      }

      window#waybar {
        background-color: #2d353b;
        color: #d3c6aa;
        border: 2px solid #a7c080;
        border-radius: 10px;
      }

      #custom-nix {
        color: #7fbbb3;
        font-size: 16px;
        padding: 0 8px 0 12px;
      }

      #workspaces {
        padding: 0 4px;
      }

      #workspaces button {
        color: rgba(122, 132, 120, 0.7);
        padding: 4px 10px;
        background: transparent;
        border: 1px solid rgba(122, 132, 120, 0.25);
        border-radius: 4px;
        margin: 4px 2px;
        box-shadow: none;
        transition: all 0.15s ease;
      }

      #workspaces button.active {
        color: #a7c080;
        background: rgba(167, 192, 128, 0.15);
        border: 1px solid rgba(167, 192, 128, 0.6);
        border-radius: 4px;
      }

      #workspaces button:hover {
        color: #d3c6aa;
        background: rgba(211, 198, 170, 0.08);
        border: 1px solid rgba(211, 198, 170, 0.3);
      }

      #window {
        color: #d3c6aa;
        padding: 0 12px;
      }

      #clock {
        color: #7fbbb3;
        font-weight: bold;
        padding: 0 10px;
        margin: 4px 12px 4px 4px;
      }

      #battery {
        color: #a7c080;
        padding: 0 8px;
        margin: 4px 4px;
      }

      #battery.charging, #battery.plugged {
        color: #a7c080;
      }

      #battery.low:not(.charging):not(.plugged) {
        color: #e6d890;
      }

      #battery.critical:not(.charging):not(.plugged) {
        color: #e67e80;
        animation: blink 1s ease-in-out infinite alternate;
      }

      @keyframes blink {
        from { opacity: 1; }
        to { opacity: 0.2; }
      }

      #bluetooth {
        color: #7fbbb3;
        padding: 0 8px;
        margin: 4px 4px;
      }

      #bluetooth.disabled {
        color: #7a8478;
      }

      #bluetooth.disconnected {
        color: #7fbbb3;
      }

      #network {
        color: #83c092;
        padding: 0 8px;
        margin: 4px 4px;
      }

      #pulseaudio {
        color: #d699b6;
        padding: 0 8px;
        margin: 4px 4px;
      }

      #pulseaudio.muted {
        color: #7a8478;
      }

      #tray {
        padding: 0 8px;
        margin: 4px 4px;
      }

      #custom-power {
        color: #e67e80;
        padding: 0 10px;
        margin: 4px 4px;
      }

      #custom-power:hover {
        background: #3d484d;
      }

      #custom-mic {
        padding: 0 8px;
        margin: 4px 4px;
        font-size: 15px;
      }

      #custom-mic.active {
        color: #e67e80;
      }

      #custom-mic.muted {
        color: #7a8478;
      }

      #custom-nightlight {
        padding: 0 8px;
        margin: 4px 4px;
        font-size: 15px;
      }

      #custom-nightlight.day {
        color: #dbbc7f;
      }

      #custom-nightlight.night {
        color: #7a8478;
      }
    '';
  };

  systemd.user.targets.niri-session = {
    Unit.Description = "Niri Compositor Session";
  };

  systemd.user.services.waybar = {
    Unit = {
      After = lib.mkForce [ "niri-session.target" ];
      PartOf = lib.mkForce [ "niri-session.target" "tray.target" ];
      StartLimitBurst = 5;
      StartLimitIntervalSec = "120s";
    };
    Service.RestartSec = "5s";
    Install.WantedBy = lib.mkForce [ "niri-session.target" "tray.target" ];
  };

  systemd.user.services.nightlight-cache = {
    Unit.Description = "Update nightlight sunrise/sunset cache";
    Service = {
      Type = "oneshot";
      ExecStart = "${nightlight-cache-update}/bin/nightlight-cache-update";
    };
  };

  systemd.user.timers.nightlight-cache = {
    Unit.Description = "Daily nightlight cache refresh";
    Timer = {
      OnCalendar = "daily";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  systemd.user.services.mako = {
    Unit = {
      Description = "Mako notification daemon";
      PartOf = [ "niri-session.target" ];
      After = [ "niri-session.target" ];
    };
    Install.WantedBy = [ "niri-session.target" ];
    Service = {
      ExecStart = "${pkgs.mako}/bin/mako";
      Restart = "on-failure";
    };
  };

  systemd.user.services.wlsunset = {
    Unit = {
      Description = "Night light";
      PartOf = [ "niri-session.target" ];
      After = [ "niri-session.target" ];
    };
    Install.WantedBy = [ "niri-session.target" ];
    Service = {
      ExecStart = "${pkgs.wlsunset}/bin/wlsunset -l 44.8 -L 20.5";
      Restart = "on-failure";
    };
  };

  systemd.user.services.swayidle = {
    Unit = {
      Description = "Idle manager";
      PartOf = [ "niri-session.target" ];
      After = [ "niri-session.target" ];
    };
    Install.WantedBy = [ "niri-session.target" ];
    Service = {
      ExecStart = "${pkgs.swayidle}/bin/swayidle -w timeout 600 ${pkgs.gtklock}/bin/gtklock timeout 1200 'niri msg action power-off-monitors' timeout 1800 'systemctl suspend' before-sleep ${pkgs.gtklock}/bin/gtklock";
      Restart = "on-failure";
    };
  };

  systemd.user.services.polkit-gnome-agent = {
    Unit = {
      Description = "GNOME Polkit authentication agent";
      PartOf = [ "niri-session.target" ];
      After = [ "niri-session.target" ];
    };
    Install.WantedBy = [ "niri-session.target" ];
    Service = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
    };
  };

  systemd.user.services.cliphist = {
    Unit = {
      Description = "Clipboard history";
      PartOf = [ "niri-session.target" ];
      After = [ "niri-session.target" ];
    };
    Install.WantedBy = [ "niri-session.target" ];
    Service = {
      ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";
      Restart = "on-failure";
    };
  };

  systemd.user.services.swaybg = {
    Unit = {
      Description = "Wallpaper";
      PartOf = [ "niri-session.target" ];
      After = [ "niri-session.target" ];
    };
    Install.WantedBy = [ "niri-session.target" ];
    Service = {
      ExecStart = "${pkgs.swaybg}/bin/swaybg -i ${../../images/backgrounds/sesija-jezero.jpg} -m fill";
      Restart = "on-failure";
    };
  };

  systemd.user.services.gnome-keyring = {
    Unit = {
      Description = "GNOME Keyring daemon";
      PartOf = [ "niri-session.target" ];
      After = [ "niri-session.target" ];
    };
    Install.WantedBy = [ "niri-session.target" ];
    Service = {
      ExecStart = "${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --foreground --components=secrets";
      Restart = "on-failure";
    };
  };
}
