{ ... }:

{
  programs.waybar = {
    enable = true;

    settings = [{
      layer = "top";
      position = "top";
      height = 32;
      spacing = 4;

      modules-left = [ "niri/workspaces" "niri/window" ];
      modules-center = [ "clock" ];
      modules-right = [ "network" "wireplumber" "backlight" "battery" "tray" ];

      "niri/workspaces" = {
        format = "{index}";
        on-click = "activate";
      };

      "niri/window" = {
        max-length = 60;
      };

      clock = {
        format = " {:%H:%M}";
        format-alt = " {:%Y-%m-%d}";
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      };

      battery = {
        states = { warning = 30; critical = 15; };
        format = "{icon} {capacity}%";
        format-charging = " {capacity}%";
        format-plugged = " {capacity}%";
        format-icons = [ "" "" "" "" "" ];
      };

      backlight = {
        format = "{icon} {percent}%";
        format-icons = [ "" "" ];
        on-scroll-up = "brightnessctl set 5%+";
        on-scroll-down = "brightnessctl set 5%-";
      };

      network = {
        format-wifi = " {signalStrength}%";
        format-ethernet = " {ipaddr}";
        format-disconnected = "⚠ Disconnected";
        tooltip-format-wifi = "{essid} ({signalStrength}%) via {gwaddr}";
      };

      wireplumber = {
        format = "{icon} {volume}%";
        format-muted = " muted";
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        format-icons = [ "" "" "" ];
      };

      tray = {
        spacing = 8;
      };
    }];

    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background: #2d353b;
        color: #d3c6aa;
        border-bottom: 2px solid #343f44;
      }

      .modules-left, .modules-center, .modules-right {
        padding: 0 4px;
      }

      #workspaces button {
        padding: 2px 10px;
        color: #7a8478;
        background: transparent;
        border-bottom: 2px solid transparent;
      }

      #workspaces button.active {
        color: #a7c080;
        border-bottom: 2px solid #a7c080;
      }

      #workspaces button:hover {
        color: #d3c6aa;
        background: #3d484d;
      }

      #window {
        color: #d3c6aa;
        padding: 0 8px;
      }

      #clock {
        color: #7fbbb3;
        padding: 0 12px;
        font-weight: bold;
      }

      #battery {
        color: #a7c080;
        padding: 0 8px;
      }

      #battery.warning {
        color: #dbbc7f;
      }

      #battery.critical {
        color: #e67e80;
      }

      #battery.charging {
        color: #83c092;
      }

      #backlight {
        color: #dbbc7f;
        padding: 0 8px;
      }

      #network {
        color: #7fbbb3;
        padding: 0 8px;
      }

      #network.disconnected {
        color: #e67e80;
      }

      #wireplumber {
        color: #d699b6;
        padding: 0 8px;
      }

      #wireplumber.muted {
        color: #475258;
      }

      #tray {
        padding: 0 8px;
      }

      #tray > .passive {
        -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
        background-color: #e67e80;
      }
    '';
  };
}
