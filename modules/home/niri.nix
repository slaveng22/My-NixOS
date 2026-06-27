{ pkgs, ... }:

let
  screenshot-area = pkgs.writeShellScriptBin "screenshot-area" ''
    ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.swappy}/bin/swappy -f -
  '';
  cliphist-pick = pkgs.writeShellScriptBin "cliphist-pick" ''
    ${pkgs.cliphist}/bin/cliphist list | ${pkgs.fuzzel}/bin/fuzzel --dmenu | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy
  '';
in {
  home.packages = [ screenshot-area cliphist-pick ];

  xdg.configFile."niri/config.kdl".text = ''
    input {
      keyboard {
        xkb {
          layout "us"
        }
      }

      touchpad {
        tap
        natural-scroll
      }

      focus-follows-mouse
    }

    output "eDP-1" {
      scale 1.0
    }

    layout {
      gaps 8

      default-column-width { proportion 0.5; }

      focus-ring {
        width 2
        active-color "#a7c080"
        inactive-color "#475258"
      }

      border {
        off
      }
    }

    environment {
      NIXOS_OZONE_WL "1"
      MOZ_ENABLE_WAYLAND "1"
      QT_QPA_PLATFORM "wayland"
      QT_WAYLAND_DISABLE_WINDOWDECORATION "1"
      XDG_CURRENT_DESKTOP "niri"
    }

    prefer-no-csd

    screenshot-path "~/Pictures/Screenshots/%Y-%m-%d %H-%M-%S.png"

    spawn-at-startup "${pkgs.mako}/bin/mako"
    spawn-at-startup "${pkgs.waybar}/bin/waybar"
    spawn-at-startup "${pkgs.swayidle}/bin/swayidle" "-w" "timeout" "300" "${pkgs.gtklock}/bin/gtklock" "timeout" "600" "niri msg action power-off-monitors" "before-sleep" "${pkgs.gtklock}/bin/gtklock"
    spawn-at-startup "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
    spawn-at-startup "${pkgs.wl-clipboard}/bin/wl-paste" "--watch" "${pkgs.cliphist}/bin/cliphist" "store"

    window-rule {
      match app-id="swappy"
      open-floating true
    }

    binds {
      // Apps
      Mod+Return { spawn "${pkgs.alacritty}/bin/alacritty"; }
      Mod+Space { spawn "${pkgs.fuzzel}/bin/fuzzel"; }
      Mod+L { spawn "${pkgs.gtklock}/bin/gtklock"; }
      Mod+V { spawn "${cliphist-pick}/bin/cliphist-pick"; }

      // Screenshots
      Print { screenshot; }
      Shift+Print { screenshot-screen; }
      Alt+Print { screenshot-window; }
      Mod+Shift+S { spawn "${screenshot-area}/bin/screenshot-area"; }

      // Volume
      XF86AudioRaiseVolume { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"; }
      XF86AudioLowerVolume { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
      XF86AudioMute { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
      XF86AudioMicMute { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }

      // Brightness
      XF86MonBrightnessUp { spawn "${pkgs.brightnessctl}/bin/brightnessctl" "set" "5%+"; }
      XF86MonBrightnessDown { spawn "${pkgs.brightnessctl}/bin/brightnessctl" "set" "5%-"; }

      // Window management
      Mod+Q { close-window; }
      Mod+Left { focus-column-left; }
      Mod+Right { focus-column-right; }
      Mod+Up { focus-window-up; }
      Mod+Down { focus-window-down; }
      Mod+Shift+Left { move-column-left; }
      Mod+Shift+Right { move-column-right; }
      Mod+Shift+Up { move-window-up; }
      Mod+Shift+Down { move-window-down; }
      Mod+Home { focus-column-first; }
      Mod+End { focus-column-last; }
      Mod+Shift+Home { move-column-to-first; }
      Mod+Shift+End { move-column-to-last; }

      // Column sizing
      Mod+Minus { set-column-width "-10%"; }
      Mod+Equal { set-column-width "+10%"; }
      Mod+Shift+Minus { set-window-height "-10%"; }
      Mod+Shift+Equal { set-window-height "+10%"; }
      Mod+F { maximize-column; }
      Mod+Shift+F { fullscreen-window; }
      Mod+C { center-column; }

      // Workspaces
      Mod+1 { focus-workspace 1; }
      Mod+2 { focus-workspace 2; }
      Mod+3 { focus-workspace 3; }
      Mod+4 { focus-workspace 4; }
      Mod+5 { focus-workspace 5; }
      Mod+Shift+1 { move-window-to-workspace 1; }
      Mod+Shift+2 { move-window-to-workspace 2; }
      Mod+Shift+3 { move-window-to-workspace 3; }
      Mod+Shift+4 { move-window-to-workspace 4; }
      Mod+Shift+5 { move-window-to-workspace 5; }

      // Niri controls
      Mod+Shift+E { quit; }
      Mod+Shift+P { power-off-monitors; }
    }
  '';
}
