{ pkgs, unstable, ... }:

let
signal-desktop-wayland = pkgs.symlinkJoin {
  name = "signal-desktop";
  paths = [ unstable.signal-desktop ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/signal-desktop \
      --add-flags "--ozone-platform=wayland --enable-features=UseOzonePlatform,WaylandWindowDecorations"
  '';
};
screenshot-area = pkgs.writeShellScriptBin "screenshot-area" ''
    ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.swappy}/bin/swappy -f -
  '';
  cliphist-pick = pkgs.writeShellScriptBin "cliphist-pick" ''
    ${pkgs.cliphist}/bin/cliphist list | ${pkgs.fuzzel}/bin/fuzzel --dmenu | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy
  '';
  wf-record-toggle = pkgs.writeShellScriptBin "wf-record-toggle" ''
    mkdir -p "$HOME/Videos/Recordings"
    if ${pkgs.procps}/bin/pgrep -x wf-recorder > /dev/null; then
      ${pkgs.procps}/bin/pkill -SIGINT wf-recorder
      ${pkgs.libnotify}/bin/notify-send "Recording stopped" "Saved to ~/Videos/Recordings"
    else
      ${pkgs.libnotify}/bin/notify-send "Recording started"
      ${pkgs.wf-recorder}/bin/wf-recorder \
        -f "$HOME/Videos/Recordings/$(date +%Y-%m-%d_%H-%M-%S).mp4"
    fi
  '';
in {
  home.packages = [ screenshot-area cliphist-pick wf-record-toggle signal-desktop-wayland ];

  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    gtk.enable = true;
  };

  xdg.configFile."wlogout/style.css".text = ''
    * {
        background-image: none;
        box-shadow: none;
    }

    window {
        background-color: rgba(45, 53, 59, 0.9);
    }

    button {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 16px;
        border-radius: 8px;
        border: 2px solid transparent;
        color: #d3c6aa;
        background-color: #323d43;
        margin: 8px;
        padding: 30px 20px;
        min-width: 120px;
        min-height: 90px;
    }

    button:hover {
        background-color: #3c4841;
        border-color: #a7c080;
        color: #a7c080;
    }

    button:active {
        background-color: #475258;
        border-color: #a7c080;
    }

    #lock {
        background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/lock.png"));
        background-repeat: no-repeat;
        background-position: center;
        background-size: 40%;
    }

    #logout {
        background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/logout.png"));
        background-repeat: no-repeat;
        background-position: center;
        background-size: 40%;
    }

    #suspend {
        background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/suspend.png"));
        background-repeat: no-repeat;
        background-position: center;
        background-size: 40%;
    }

    #hibernate {
        background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/hibernate.png"));
        background-repeat: no-repeat;
        background-position: center;
        background-size: 40%;
    }

    #reboot {
        background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/reboot.png"));
        background-repeat: no-repeat;
        background-position: center;
        background-size: 40%;
    }

    #shutdown {
        background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/shutdown.png"));
        background-repeat: no-repeat;
        background-position: center;
        background-size: 40%;
    }
  '';

  xdg.configFile."wlogout/layout".text = ''
    {
        "label" : "lock",
        "action" : "${pkgs.gtklock}/bin/gtklock",
        "text" : "",
        "keybind" : "l"
    }
    {
        "label" : "logout",
        "action" : "loginctl terminate-user $USER",
        "text" : "",
        "keybind" : "e"
    }
    {
        "label" : "suspend",
        "action" : "systemctl suspend",
        "text" : "",
        "keybind" : "u"
    }
    {
        "label" : "hibernate",
        "action" : "systemctl hibernate",
        "text" : "",
        "keybind" : "h"
    }
    {
        "label" : "reboot",
        "action" : "systemctl reboot",
        "text" : "",
        "keybind" : "r"
    }
    {
        "label" : "shutdown",
        "action" : "systemctl poweroff",
        "text" : "",
        "keybind" : "s"
    }
  '';

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
      gaps 16

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
      LIBVA_DRIVER_NAME "iHD"
    }

    hotkey-overlay {
      skip-at-startup
    }

    gestures {
      hot-corners {
        off
      }
    }

    cursor {
      xcursor-theme "Bibata-Modern-Classic"
      xcursor-size 24
    }

    prefer-no-csd

    spawn-at-startup "sh" "-c" "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DISPLAY && systemctl --user start graphical-session.target"
    spawn-at-startup "sh" "-c" "while true; do ${pkgs.waybar}/bin/waybar; sleep 1; done"
    spawn-at-startup "${pkgs.gnome-keyring}/bin/gnome-keyring-daemon" "--start" "--components=secrets"
    spawn-at-startup "${pkgs.mako}/bin/mako"
    spawn-at-startup "${signal-desktop-wayland}/bin/signal-desktop" "--start-in-tray"
    spawn-at-startup "${pkgs.swayidle}/bin/swayidle" "-w" "timeout" "600" "${pkgs.gtklock}/bin/gtklock" "timeout" "1200" "niri msg action power-off-monitors" "timeout" "1800" "systemctl suspend" "before-sleep" "${pkgs.gtklock}/bin/gtklock"
    spawn-at-startup "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
    spawn-at-startup "${pkgs.wl-clipboard}/bin/wl-paste" "--watch" "${pkgs.cliphist}/bin/cliphist" "store"
    spawn-at-startup "${pkgs.swaybg}/bin/swaybg" "-i" "${../../images/backgrounds/sesija-jezero.jpg}" "-m" "fill"
    overview {
      backdrop-color "#141810"
    }
    window-rule {
      geometry-corner-radius 12
      clip-to-geometry true
    }

    window-rule {
      match title="floating-term"
      open-floating true
      default-column-width { fixed 900; }
      min-height 300
    }

    window-rule {
      match app-id="swappy"
      open-floating true
    }

    window-rule {
      match title="pulsemixer"
      open-floating true
    }

    window-rule {
      match title="nmtui"
      open-floating true
    }

    window-rule {
      match title="calcure"
      open-floating true
    }

    window-rule {
      match title="bluetuith"
      open-floating true
      min-width 1400
      default-floating-position x=-350 y=50 relative-to="top"
    }

    window-rule {
      match app-id=r#"firefox"#
      open-fullscreen false
    }

    window-rule {
      match app-id=r#"^(libreoffice|soffice).*"#
      open-fullscreen false
    }




    binds {
      // Apps
      Mod+Return { spawn "${pkgs.alacritty}/bin/alacritty"; }
      Mod+T { spawn "${pkgs.alacritty}/bin/alacritty" "--title" "floating-term"; }
      Mod+Space { spawn "${pkgs.fuzzel}/bin/fuzzel"; }
      Mod+O { toggle-overview; }
      Mod+V { spawn "${cliphist-pick}/bin/cliphist-pick"; }
      Mod+Shift+Semicolon { spawn "${pkgs.bemoji}/bin/bemoji"; }

      // Screenshots
      Print { spawn "${screenshot-area}/bin/screenshot-area"; }
      Mod+Shift+S { spawn "${screenshot-area}/bin/screenshot-area"; }


      // Volume
      XF86AudioRaiseVolume { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"; }
      XF86AudioLowerVolume { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
      XF86AudioMute { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
      XF86AudioMicMute { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }

      // Screen recording
      Mod+R { spawn "${wf-record-toggle}/bin/wf-record-toggle"; }

      // Brightness
      XF86MonBrightnessUp { spawn "${pkgs.brightnessctl}/bin/brightnessctl" "set" "5%+"; }
      XF86MonBrightnessDown { spawn "${pkgs.brightnessctl}/bin/brightnessctl" "set" "5%-"; }

      // Window management
      Mod+Left { focus-column-left; }
      Mod+Right { focus-column-right; }
      Mod+Up { focus-window-up; }
      Mod+Down { focus-window-down; }
      Mod+H { focus-column-left; }
      Mod+L { focus-column-right; }
      Mod+K { focus-window-up; }
      Mod+J { focus-window-down; }
      Mod+Shift+Left { move-column-left; }
      Mod+Shift+Right { move-column-right; }
      Mod+Shift+Up { move-window-up; }
      Mod+Shift+Down { move-window-down; }
      Mod+Shift+H { move-column-left; }
      Mod+Shift+L { move-column-right; }
      Mod+Shift+K { move-window-up; }
      Mod+Shift+J { move-window-down; }
      Mod+Home { focus-column-first; }
      Mod+End { focus-column-last; }
      Mod+Shift+Home { move-column-to-first; }
      Mod+Shift+End { move-column-to-last; }

      // Column sizing
      Mod+Minus { set-column-width "-10%"; }
      Mod+Equal { set-column-width "+10%"; }
      Mod+Shift+Minus { set-window-height "-10%"; }
      Mod+Shift+Equal { set-window-height "+10%"; }
      Mod+M { maximize-column; }
      Mod+F { toggle-window-floating; }
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
      Mod+Shift+W { spawn "${pkgs.wlogout}/bin/wlogout"; }
      Mod+Shift+Q { close-window; }
      Mod+Shift+P { power-off-monitors; }
    }
  '';

  services.poweralertd.enable = true;

  home.file.".face".source = ../../images/profile/redpanda.png;

  xdg.configFile."gtklock/config.ini".text = ''
    [main]
    background=${../../images/backgrounds/nixos-corner.png}
    modules=${pkgs.gtklock-userinfo-module}/lib/gtklock/userinfo-module.so;${pkgs.gtklock-powerbar-module}/lib/gtklock/powerbar-module.so
  '';
}
