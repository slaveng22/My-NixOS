{ pkgs, ... }:

{
  # oh-my-posh theme
  xdg.configFile."oh-my-posh/emodipt.omp.json".source = ../../dotfiles/oh-my-posh/emodipt.omp.json;

  # fastfetch config
  xdg.configFile."fastfetch/config.jsonc".source = ../../dotfiles/fastfetch/config.jsonc;
  xdg.configFile."fastfetch/RPandaASCII.txt".source = ../../dotfiles/fastfetch/RPandaASCII.txt;

  programs.bash = {
    enable = true;

    historyControl = [ "ignoreboth" ];
    historySize = 1000;
    historyFileSize = 2000;

    shellOptions = [ "histappend" "checkwinsize" ];

    sessionVariables = {
      EDITOR = "nvim";
      LESS = "-FRX";
      PROMPT_COMMAND = "history -a; history -c; history -r; $PROMPT_COMMAND";
    };

    shellAliases = {
      ll     = "ls -alF";
      la     = "ls -A";
      l      = "ls -CF";
      ".."   = "cd ..";
      "..."  = "cd ../..";
      please = "sudo $(history -p !!)";
      copy   = "wl-copy";
      paste  = "wl-paste";
      rm     = "trash-put";
      bat    = "bat --color=always";
      cfzf   = "fzf --preview='bat --color=always {}'";
      yz     = "yazi_cd";
    };

    initExtra = ''
      export PATH="$HOME/.local/bin:$PATH"

      # cd with ls
      cd() { builtin cd "$@" && ls --color=auto; }

      # FZF history search → Ctrl+R
      __fzf_history_search() {
        local selected
        selected=$(HISTTIMEFORMAT= history | tac | fzf --tac --no-sort --height=40% --reverse --exact --preview="echo {}")
        if [ -n "$selected" ]; then
          selected="''${selected#*[0-9]  }"
          printf "%s" "$selected" | wl-copy
          READLINE_LINE="$selected"
          READLINE_POINT=''${#READLINE_LINE}
        fi
      }
      bind -x '"\C-r": __fzf_history_search'

      # Yazi with cd-on-exit
      yazi_cd() {
        local tmp
        tmp=$(mktemp)
        yazi "$@" --cwd-file="$tmp"
        if [ -s "$tmp" ]; then
          builtin cd "$(cat "$tmp")" && ls --color=auto
        fi
        command rm -f "$tmp"
      }

      # Zellij session picker
      zj() {
        local session
        session=$(zellij list-sessions -ns | fzf --prompt="Pick session: " --height=40%)
        [ -n "$session" ] && zellij attach "$session"
      }

      # oh-my-posh prompt
      eval "$(oh-my-posh init bash --config ~/.config/oh-my-posh/emodipt.omp.json)"
    '';
  };
}
