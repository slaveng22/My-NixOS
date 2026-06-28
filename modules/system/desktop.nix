{ pkgs, ... }:

let
  gtkgreetSession = pkgs.writeShellScript "start-gtkgreet" ''
    export HOME="/var/lib/greeter"
    export XDG_DATA_DIRS="${pkgs.everforest-gtk-theme}/share:${pkgs.bibata-cursors}/share:/run/current-system/sw/share"
    export GTK_THEME="Everforest-Dark-B"
    export XCURSOR_THEME="Bibata-Modern-Classic"
    export XCURSOR_SIZE="24"
    export XCURSOR_PATH="${pkgs.bibata-cursors}/share/icons"
    exec ${pkgs.cage}/bin/cage -s -- ${pkgs.gtkgreet}/bin/gtkgreet \
      -b ${../../images/backgrounds/nixos-corner.png} \
      -c "${pkgs.niri}/bin/niri --session"
  '';
in {
  programs.niri.enable = true;
  programs.xwayland.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

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
  services.gvfs.enable = true;

  programs.firefox.enable = true;

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [ thunar-archive-plugin ];
  };

  environment.systemPackages = with pkgs; [
    file-roller
    everforest-gtk-theme
    wlogout
    networkmanagerapplet
    fuzzel
    gtklock
    gtklock-userinfo-module
    gtklock-powerbar-module
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
