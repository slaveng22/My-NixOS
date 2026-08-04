{ pkgs, unstable, ... }:

let
  gruvbox-gtk-theme-patched = pkgs.gruvbox-gtk-theme.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      find $out/share/themes -name "gtk.css" -path "*/gtk-3.0/*" \
        -exec sed -i '/border-spacing/d' {} +
    '';
  });
in
{
  gtk = {
    enable = true;
    theme = {
      name = "Gruvbox-Dark";
      package = gruvbox-gtk-theme-patched;
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

  programs.fuzzel = {
    enable = true;
    settings = {
      main = { font = "JetBrainsMono Nerd Font:size=12"; };
      border = { width = 2; };
      colors = { border = "a7c080ff"; selection = "a7c08040"; };
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
    libnotify
    unstable.obsidian
    lazygit
    nodejs
    unzip
    yazi
    claude-code
    bemoji
    imv
    zathura
  ];
}
