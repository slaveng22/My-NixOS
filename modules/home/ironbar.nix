{ pkgs, ... }:

{
  home.packages = [ pkgs.ironbar ];

  xdg.configFile."ironbar/config.toml".text = ''
    [bar]
    position = "top"
    height = 32
    anchor_to_edges = true

    [[bar.start]]
    type = "workspaces"

    [[bar.center]]
    type = "focused"
    show_title = false

    [[bar.end]]
    type = "tray"

    [[bar.end]]
    type = "volume"

    [[bar.end]]
    type = "battery"

    [[bar.end]]
    type = "clock"
    format = " %H:%M"
  '';

  xdg.configFile."ironbar/style.css".text = ''
    * {
      font-family: "JetBrainsMono Nerd Font";
      font-size: 13px;
    }

    .bar {
      background-color: #2d353b;
      color: #d3c6aa;
      border-bottom: 2px solid #343f44;
    }

    .workspaces {
      padding: 0 4px;
    }

    .workspaces .item {
      color: #7a8478;
      padding: 2px 10px;
      background: transparent;
      border-bottom: 2px solid transparent;
    }

    .workspaces .item.active,
    .workspaces .item.focused {
      color: #a7c080;
      border-bottom: 2px solid #a7c080;
    }

    .workspaces .item:hover {
      color: #d3c6aa;
      background: #3d484d;
    }

    .focused label {
      padding: 0 8px;
    }

    .clock {
      border: 1px solid #a7c080;
      border-radius: 6px;
      margin: 4px 4px;
    }

    .clock label {
      color: #7fbbb3;
      font-weight: bold;
      padding: 0 10px;
    }

    .battery {
      color: #a7c080;
      padding: 0 8px;
      border: 1px solid #a7c080;
      border-radius: 6px;
      margin: 4px 4px;
    }

    .volume {
      color: #d699b6;
      padding: 0 8px;
      border: 1px solid #a7c080;
      border-radius: 6px;
      margin: 4px 4px;
    }

    .tray {
      border: 1px solid #a7c080;
      border-radius: 6px;
      padding: 0 8px;
      margin: 4px 4px;
    }

    .network-manager {
      color: #7fbbb3;
      padding: 0 8px;
    }
  '';
}
