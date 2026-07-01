{ pkgs, ... }:

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
      '{"text":"󱄅","tooltip":"\($host)\nCPU: \($cpu)\nKernel: \($kernel)\nUptime: \($uptime)\nRAM: \($mem)\nDisk: \($disk)"}'
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
      modules-right = [ "tray" "bluetooth" "network" "pulseaudio" "battery" "custom/power" "clock" ];

      "custom/nix" = {
        exec = "${nix-sysinfo}/bin/nix-sysinfo";
        return-type = "json";
        interval = 30;
        format = "{}";
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

      bluetooth = {
        format = "󰂯";
        format-connected = "󰂱";
        format-disabled = "󰂲";
        tooltip-format = "Bluetooth off";
        tooltip-format-connected = "{device_alias}\n{device_battery_percentage}%";
        tooltip-format-enumerate-connected = "{device_alias}";
        on-click = "bluetoothctl power $(bluetoothctl show | grep -q 'Powered: yes' && echo off || echo on)";
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
    '';
  };
}
