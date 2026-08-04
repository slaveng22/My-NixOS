{ ... }:

{
  services.mako = {
    enable = true;
    settings = {
      background-color = "#2d353b";
      text-color = "#d3c6aa";
      border-color = "#a7c080";
      border-radius = 6;
      border-size = 2;
      default-timeout = 5000;
      font = "JetBrainsMono Nerd Font 11";
      max-visible = 5;
      padding = "10";
      margin = "10";
      width = 320;

      "urgency=low" = {
        border-color = "#a7c080";
      };
      "urgency=normal" = {
        border-color = "#dbbc7f";
        default-timeout = 5000;
      };
      "urgency=high" = {
        border-color = "#e67e80";
        default-timeout = 0;
      };
    };
  };
}
