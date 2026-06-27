{ pkgs, ... }:

let
  gtkgreetStyle = pkgs.writeText "gtkgreet.css" ''
    window {
      background-color: #2d353b;
      color: #d3c6aa;
    }
    entry, button, combobox > * > * {
      background-color: #3d484d;
      color: #d3c6aa;
      border: 1px solid #475258;
      border-radius: 4px;
    }
    button:hover {
      background-color: #475258;
    }
  '';
in {
  programs.niri.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.cage}/bin/cage -s -- ${pkgs.greetd.gtkgreet}/bin/gtkgreet -l -s ${gtkgreetStyle}";
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
