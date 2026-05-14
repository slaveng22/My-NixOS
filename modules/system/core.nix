{ pkgs, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Garbage collector
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Allow running regular Linux libraries on NixOS
  programs.nix-ld.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.tlp.enable = true;
  services.power-profiles-daemon.enable = false;

  environment.systemPackages = with pkgs; [
    fzf
    ripgrep
    wl-clipboard
    bat
    trash-cli
    nmap
    tealdeer
    fastfetch
    python3
    neovide
    mpv
    onlyoffice-desktopeditors
    transmission_4-gtk
    thunderbird
    signal-desktop
  ];

  environment.sessionVariables = {
    TERMINAL = "alacritty";
  };
}
