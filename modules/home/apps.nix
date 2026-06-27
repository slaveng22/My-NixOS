{ pkgs, unstable, ... }:

{
  gtk = {
    enable = true;
    theme = {
      name = "Gruvbox-Dark";
      package = pkgs.gruvbox-gtk-theme;
    };
    iconTheme = {
      name = "Gruvbox-Plus-Dark";
      package = pkgs.gruvbox-plus-icons;
    };
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "slaveng22";
      user.email = "117160808+slaveng22@users.noreply.github.com";
      push.default = "current";
      pull.rebase = true;
      tag.forceSignAnnotated = true;
      init.defaultBranch = "main";
      merge.tool = "nvimdiff";
      gpg.format = "ssh";
      user.signingkey = "~/.ssh/id_ed25519";
    };
  };

  xdg.configFile."yazi/theme.toml".source = ../../dotfiles/yazi/theme.toml;

  home.packages = with pkgs; [
    unstable.obsidian
    (pkgs.symlinkJoin {
      name = "signal-desktop";
      paths = [ unstable.signal-desktop ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/signal-desktop \
          --add-flags "--ozone-platform=wayland --enable-features=UseOzonePlatform,WaylandWindowDecorations"
      '';
    })
    oh-my-posh
    lazygit
    nodejs
    unzip
    yazi
    pkgs.xfce.thunar
    claude-code
  ];
}
