{ pkgs, unstable, ... }:

{
  imports = [
    ./apps.nix
    ./shell.nix
    ./terminal.nix
    ./editor.nix
    ./zellij.nix
  ];

  home.username = "slaven";
  home.homeDirectory = "/home/slaven";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
}
