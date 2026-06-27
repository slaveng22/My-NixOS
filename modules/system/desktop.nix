{ pkgs, ... }:

{
  programs.niri.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --remember-session --sessions /run/current-system/sw/share/wayland-sessions --cmd niri";
        user = "greeter";
      };
    };
  };

  security.pam.services.gtklock = { };
  security.polkit.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "gtk";
  };

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.printing.enable = false;

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    waybar
    mako
    fuzzel
    gtklock
    swayidle
    grim
    slurp
    swappy
    cliphist
    brightnessctl
    polkit_gnome
  ];
}
