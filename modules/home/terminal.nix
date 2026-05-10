{ ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        size = 19.0;
        normal = { family = "JetBrainsMono Nerd Font"; style = "Regular"; };
        bold   = { family = "JetBrainsMono Nerd Font"; style = "Bold"; };
        italic = { family = "JetBrainsMono Nerd Font"; style = "Thin Italic"; };
      };
      window = {
        dynamic_padding = true;
        opacity = 0.95;
        dimensions = { columns = 93; lines = 25; };
        padding = { x = 10; y = 10; };
      };
      cursor.style = { shape = "Beam"; blinking = "On"; };
      colors = {
        primary = { background = "#2d353b"; foreground = "#d3c6aa"; };
        cursor  = { text = "#2d353b"; cursor = "#d3c6aa"; };
        selection = { text = "#d3c6aa"; background = "#503946"; };
        normal = {
          black   = "#475258"; red     = "#e67e80"; green   = "#a7c080";
          yellow  = "#dbbc7f"; blue    = "#7fbbb3"; magenta = "#d699b6";
          cyan    = "#83c092"; white   = "#d3c6aa";
        };
        bright = {
          black   = "#475258"; red     = "#e67e80"; green   = "#a7c080";
          yellow  = "#dbbc7f"; blue    = "#7fbbb3"; magenta = "#d699b6";
          cyan    = "#83c092"; white   = "#d3c6aa";
        };
      };
    };
  };
}
