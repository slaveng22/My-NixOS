{ pkgs, ... }:

{
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
    bitwarden-desktop
    obsidian
    oh-my-posh
    discord
    lazygit
    nodejs
    unzip
    yazi
  ];
}
