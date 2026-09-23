{ pkgs, ... }:

{
  programs.niri.enable = true;
  programs.xwayland.enable = true;

  hardware.bluetooth.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --sessions /run/current-system/sw/share/wayland-sessions/ --asterisks --power-shutdown 'systemctl poweroff' --power-reboot 'systemctl reboot'";
        user = "greeter";
      };
    };
  };

  security.pam.services.hyprlock = { };
  security.pam.services.greetd.enableGnomeKeyring = true;
  security.polkit.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (
        subject.user === "greeter" &&
        (
          action.id === "org.freedesktop.login1.power-off" ||
          action.id === "org.freedesktop.login1.reboot" ||
          action.id === "org.freedesktop.login1.suspend" ||
          action.id === "org.freedesktop.login1.hibernate"
        )
      ) {
        return polkit.Result.YES;
      }
    });
  '';

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-gnome ];
    config = {
      niri = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
      };
      common.default = "gtk";
    };
  };

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.upower = {
    enable = true;
    percentageLow = 19;
    percentageCritical = 7;
    percentageAction = 5;
  };
  services.gvfs.enable = true;

  programs.firefox = {
    enable = true;
    preferences = {
      "media.ffmpeg.vaapi.enabled" = true;
      "media.hardware-video-decoding.force-enabled" = true;
      "media.ffvpx.enabled" = false;
      "media.navigator.mediadatadecoder-vpx-enabled" = true;
      "media.av1.enabled" = true;
      "gfx.webrender.all" = true;
      "gfx.webrender.compositor.force-enabled" = true;
      "layers.acceleration.force-enabled" = true;
      "gfx.x11-egl.force-enabled" = false;
      "network.http.http3.enabled" = true;
      "network.prefetch-next" = true;
      "browser.cache.disk.enable" = false;
      "browser.cache.memory.enable" = true;
    };
  };

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [ thunar-archive-plugin ];
  };

  environment.systemPackages = with pkgs; [
    file-roller
    everforest-gtk-theme
    wlogout
    bluetuith
    fuzzel
    swayidle
    grim
    slurp
    swappy
    cliphist
    wf-recorder
    brightnessctl
    polkit_gnome
  ];
}
