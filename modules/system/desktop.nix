{ pkgs, ... }:

{
  services.xserver.enable = true;
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;
  services.gnome.gnome-browser-connector.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = false;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.firefox.enable = true;

  services.xserver.excludePackages = with pkgs; [ xterm ];

  environment.gnome.excludePackages = with pkgs; [
    epiphany
    gnome-music
    gnome-tour
    simple-scan
    gnome-console
    gnome-weather
    gnome-maps
    showtime
    decibels
    gnome-system-monitor
    gnome-text-editor
  ];

  environment.systemPackages = with pkgs; [
    gnome-tweaks
    gruvbox-gtk-theme
    gruvbox-plus-icons
    everforest-gtk-theme
    bibata-cursors
    gnomeExtensions.paperwm
    gnomeExtensions.auto-move-windows
    gnomeExtensions.caffeine
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.gsconnect
    gnomeExtensions.media-controls
    gnomeExtensions.appindicator
    gnomeExtensions.space-bar
    gnomeExtensions.logo-menu
  ];
}
