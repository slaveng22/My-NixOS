{ pkgs, ... }:

{
  home.packages = [ pkgs.mako ];

  xdg.configFile."mako/config".text = ''
    background-color=#2d353b
    text-color=#d3c6aa
    border-color=#a7c080
    border-radius=6
    border-size=2
    default-timeout=5000
    font=JetBrainsMono Nerd Font 11
    max-visible=5
    padding=10
    margin=10
    width=320

    [urgency=low]
    border-color=#7fbbb3

    [urgency=high]
    border-color=#e67e80
    default-timeout=0
  '';
}
