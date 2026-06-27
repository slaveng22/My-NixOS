{ pkgs, ... }:

{
  programs.niri.enable = true;
  programs.xwayland.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.cage}/bin/cage -s -- ${pkgs.gtkgreet}/bin/gtkgreet";
        user = "greeter";
      };
    };
  };

  security.pam.services.gtklock = { };
  security.polkit.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config = {
      niri.default = [ "gtk" ];
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

  services.upower.enable = true;

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    wlogout
    networkmanagerapplet
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
