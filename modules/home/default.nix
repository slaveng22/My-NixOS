{ pkgs, unstable, ... }:

{
  imports = [
    ./apps.nix
    ./shell.nix
    ./terminal.nix
    ./editor.nix
    ./btop.nix
    ./niri.nix
    ./waybar.nix
    ./mako.nix
    ./battery-notify.nix
  ];

  home.username = "slaven";
  home.homeDirectory = "/home/slaven";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
}
