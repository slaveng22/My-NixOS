{ pkgs, ... }:

let
  gtkgreetSession = pkgs.writeShellScript "start-gtkgreet" ''
    export HOME="/var/lib/greeter"
    export XDG_DATA_DIRS="${pkgs.everforest-gtk-theme}/share:${pkgs.bibata-cursors}/share:/run/current-system/sw/share"
    export GTK_THEME="Everforest-Dark-B"
    export XCURSOR_THEME="Bibata-Modern-Classic"
    export XCURSOR_SIZE="24"
    export XCURSOR_PATH="${pkgs.bibata-cursors}/share/icons"
    exec ${pkgs.cage}/bin/cage -s -- ${pkgs.gtkgreet}/bin/gtkgreet -c "${pkgs.niri}/bin/niri --session"
  '';
in {
  programs.niri.enable = true;
  programs.xwayland.enable = true;

  systemd.tmpfiles.rules = [
    "d /var/lib/greeter 0700 greeter greeter -"
    "d /var/lib/greeter/.icons 0700 greeter greeter -"
    "L /var/lib/greeter/.icons/Bibata-Modern-Classic - - - - ${pkgs.bibata-cursors}/share/icons/Bibata-Modern-Classic"
  ];

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${gtkgreetSession}";
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
    everforest-gtk-theme
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
