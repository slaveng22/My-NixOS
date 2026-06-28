{ pkgs, ... }:

{
  home.packages = [ pkgs.playerctl ];

  programs.waybar = {
    enable = true;

    settings = [{
      layer = "top";
      position = "top";
      height = 32;
      spacing = 0;

      modules-left = [ "niri/workspaces" ];
      modules-center = [ "mpris" ];
      modules-right = [ "tray" "pulseaudio" "battery" "clock" "custom/power" ];

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
        tooltip-format = "{:%A, %d %B %Y}";
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
        border-bottom: 2px solid #343f44;
      }

      #workspaces {
        padding: 0 4px;
      }

      #workspaces button {
        color: #7a8478;
        padding: 2px 10px;
        background: transparent;
        border-bottom: 2px solid transparent;
        border-radius: 0;
        box-shadow: none;
      }

      #workspaces button.active {
        color: #a7c080;
        border-bottom: 2px solid #a7c080;
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
        border: 1px solid #a7c080;
        border-radius: 6px;
      }

      #battery {
        color: #a7c080;
        padding: 0 8px;
        margin: 4px 4px;
        border: 1px solid #a7c080;
        border-radius: 6px;
      }

      #battery.charging {
        color: #a7c080;
      }

      #battery.warning:not(.charging) {
        color: #e69875;
      }

      #battery.critical:not(.charging) {
        color: #e67e80;
        border-color: #e67e80;
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
        border: 1px solid #a7c080;
        border-radius: 6px;
      }

      #pulseaudio.muted {
        color: #7a8478;
      }

      #tray {
        padding: 0 8px;
        margin: 4px 4px;
        border: 1px solid #a7c080;
        border-radius: 6px;
      }

      #custom-power {
        color: #e67e80;
        padding: 0 10px;
        margin: 4px 4px;
        border: 1px solid #e67e80;
        border-radius: 6px;
      }

      #custom-power:hover {
        background: #3d484d;
      }
    '';
  };
}
