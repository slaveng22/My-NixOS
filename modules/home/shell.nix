{ pkgs, ... }:
{
  xdg.configFile."fastfetch/config.jsonc".source = ../../dotfiles/fastfetch/config.jsonc;

  programs.tmux = {
    enable = true;
    mouse = true;
    terminal = "tmux-256color";
    historyLimit = 10000;
    prefix = "C-Space";

    plugins = [
      pkgs.tmuxPlugins.resurrect
      {
        plugin = pkgs.tmuxPlugins.continuum;
        extraConfig = "set -g @continuum-save-interval '5'";
      }
    ];

    extraConfig = ''
      set-hook -g client-detached "run-shell '${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/save.sh'"

      # True color
      set -ag terminal-overrides ",xterm-256color:RGB"
      set -s escape-time 0
      set -g base-index 1
      set -g pane-base-index 1
      set -g renumber-windows on

      # Split panes
      bind -n M-+ split-window -h -c "#{pane_current_path}"
      bind -n M-- split-window -v -c "#{pane_current_path}"

      # Navigate panes
      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R
      # Alt+M → move pane mode (arrows to swap, Escape to exit)
      bind -n M-m switch-client -T move_table
      bind -T move_table Up     { swap-pane -U; switch-client -T move_table }
      bind -T move_table Down   { swap-pane -D; switch-client -T move_table }
      bind -T move_table Left   { swap-pane -U; switch-client -T move_table }
      bind -T move_table Right  { swap-pane -D; switch-client -T move_table }
      bind -T move_table Escape switch-client -T root

      # Alt+Q then W → close pane
      bind -n M-q switch-client -T quit_table
      bind -T quit_table w kill-pane
      bind -T quit_table Escape switch-client -T root

      # Alt+R → resize mode (keep pressing arrows, Escape to exit)
      bind -n M-r switch-client -T resize_table
      bind -T resize_table Up    { resize-pane -U 2; switch-client -T resize_table }
      bind -T resize_table Down  { resize-pane -D 2; switch-client -T resize_table }
      bind -T resize_table Left  { resize-pane -L 2; switch-client -T resize_table }
      bind -T resize_table Right { resize-pane -R 2; switch-client -T resize_table }
      bind -T resize_table Escape switch-client -T root

      # Alt+O → session prefix
      bind -n M-o switch-client -T session_table
      bind -T session_table d detach-client
      bind -T session_table s choose-session
      bind -T session_table r command-prompt "rename-session '%%'"

      # Pane borders
      set -g pane-border-style        "fg=#4B5263"
      set -g pane-active-border-style "fg=#A7C080"

      # Status bar
      set -g status-style                 "bg=#2D353B,fg=#D3C6AA"
      set -g status-left                  " [#S] "
      set -g status-left-style            "fg=#A7C080,bold"
      set -g status-right                 " %H:%M "
      set -g status-right-style           "fg=#E5C07B"
      set -g status-justify               left
      set -g window-status-format         " #I:#W "
      set -g window-status-current-format " #I:#W "
      set -g window-status-style          "fg=#7A8478"
      set -g window-status-current-style  "fg=#A7C080,bold"
    '';
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      format = "$time$username$directory$git_branch$status$character";
      add_newline = false;

      time = {
        disabled = false;
        format = "[\\[$time\\]](fg:#E5C07B)";
        time_format = "%H:%M:%S";
      };

      username = {
        show_always = false;
        format = "[  ]($style)";
        style_root = "fg:#B5B50D";
        style_user = "fg:#B5B50D";
      };

      directory = {
        format = "[ 󰉋 $path]($style)";
        style = "fg:#A7C080";
        truncation_length = 1;
        truncate_to_repo = false;
        truncation_symbol = "";
      };

      git_branch = {
        format = "[ 󰊢 $branch ]($style)";
        style = "fg:#F3C267";
        symbol = "";
      };

      git_status = {
        disabled = true;
      };

      status = {
        disabled = false;
        format = "[x$common_meaning ]($style)";
        style = "fg:#C94A16";
      };

      character = {
        success_symbol = "[❯ ](fg:#E06C75)";
        error_symbol = "[❯ ](fg:#E06C75)";
      };
    };
  };

  programs.fish = {
    enable = true;

    shellAliases = {
      ll    = "ls -alF";
      la    = "ls -A";
      l     = "ls -CF";
      copy  = "wl-copy";
      paste = "wl-paste";
      rm    = "trash-put";
      bat   = "bat --color=always";
      cfzf  = "fzf --preview='bat --color=always {}'";
      yz    = "yazi_cd";
    };

    shellInit = ''
      set -gx EDITOR nvim
      set -gx LESS -FRX
      fish_add_path $HOME/.local/bin
      set -g fish_greeting
    '';

    functions = {
      ".."    = { body = "builtin cd .."; };
      "..."   = { body = "builtin cd ../.."; };
      please  = { body = "eval sudo $history[1]"; };

      cd = {
        body = ''
          builtin cd $argv
          and ls --color=auto
        '';
      };

      yazi_cd = {
        body = ''
          set tmp (mktemp)
          yazi $argv --cwd-file=$tmp
          if test -s $tmp
            builtin cd (cat $tmp)
            and ls --color=auto
          end
          command rm -f $tmp
        '';
      };

      tm = {
        body = ''
          if not tmux list-sessions >/dev/null 2>&1
            tmux new-session -d -s main
            tmux run-shell '${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/restore.sh'
            tmux attach-session -t main
          else
            set session (tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --prompt="Pick session: " --height=40%)
            if test -n "$session"
              tmux attach-session -t $session
            end
          end
        '';
      };
    };
  };
}
