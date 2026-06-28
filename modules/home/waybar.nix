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
  home.packages = [ pkgs.playerctl nix-sysinfo ];

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
      modules-center = [ "mpris" ];
      modules-right = [ "tray" "pulseaudio" "battery" "clock" "custom/power" ];

      "custom/nix" = {
        exec = "${nix-sysinfo}/bin/nix-sysinfo";
        return-type = "json";
        interval = 30;
        format = "{}";
      };

      "niri/workspaces" = {
        format = "{value}";
      };

      mpris = {
        format = "{player_icon} {status_icon} {title}";
        player-icons = {
          default = "";
          spotify = "";
          firefox = "󰈹";
          chromium = "";
        };
        status-icons = {
          playing = "▶";
          paused = "⏸";
        };
        max-length = 50;
        on-click = "playerctl play-pause";
      };

      tray = {
        spacing = 8;
      };

      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "󰝟 muted";
        format-icons = {
          default = [ "󰕿" "󰖀" "󰕾" ];
        };
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      };

      battery = {
        bat = "BAT0";
        format = "{icon} {capacity}%";
        format-charging = "󰂄 {capacity}%";
        format-plugged = "󰚥 {capacity}%";
        format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
        states = { warning = 20; critical = 10; };
      };

      clock = {
        format = " {:%H:%M}";
        tooltip-format = "<big>{:%A, %d %B %Y}</big>\n<tt>{calendar}</tt>";
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
        color: #7a8478;
        padding: 2px 10px;
        background: transparent;
        border: 1px solid transparent;
        border-radius: 6px;
        box-shadow: none;
      }

      #workspaces button.active {
        color: #a7c080;
        background: rgba(167, 192, 128, 0.15);
        border: 1px solid #a7c080;
        border-radius: 6px;
      }

      #workspaces button:hover {
        color: #d3c6aa;
        background: #3d484d;
        border-bottom: 2px solid transparent;
      }

      #mpris {
        color: #a7c080;
        padding: 0 8px;
      }

      #clock {
        color: #7fbbb3;
        font-weight: bold;
        padding: 0 10px;
        margin: 4px 4px;
      }

      #battery {
        color: #a7c080;
        padding: 0 8px;
        margin: 4px 4px;
      }

      #battery.charging {
        color: #a7c080;
      }

      #battery.warning:not(.charging) {
        color: #e69875;
      }

      #battery.critical:not(.charging) {
        color: #e67e80;
        animation: blink 1s ease-in-out infinite alternate;
      }

      @keyframes blink {
        from { opacity: 1; }
        to { opacity: 0.2; }
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
        margin: 4px 12px 4px 4px;
      }

      #custom-power:hover {
        background: #3d484d;
      }
    '';
  };
}
