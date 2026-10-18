{ pkgs, unstable, ... }:

{
  programs.claude-nix = {
    enable = true;

    editorMode = "vim";
    theme = "dark";
    model = "claude-sonnet-4-6";
    effortLevel = "medium";

    globalClaudeMd = ''
      # NixOS Config

      NixOS flake, Wayland-only (Niri compositor). No X11, no GNOME/KDE.

      ## Structure
      - `modules/system/` — system-level config (packages, display)
      - `modules/home/`   — home-manager modules (one file per concern)
      - `dotfiles/`       — raw config files via xdg.configFile

      ## Conventions
      - Modules take `{ pkgs, unstable, ... }` — `unstable` is nixpkgs-unstable
      - New home modules go in `modules/home/`, imported in `default.nix`
      - Prefer `programs.<name>.enable` over manual installs when available

      ## Environment
      - Shell: fish | Editor: neovim (vi keybindings) | Multiplexer: tmux
      - Color theme: Everforest dark medium
      - Wayland only — no X11 tools

      ## Rebuild
      - Dry run:  `nixos-rebuild dry-build --flake .#`
      - Apply:    `sudo nixos-rebuild switch --flake .#`
      - Syntax:   `nix-instantiate --parse <file>`
      - Check:    `nix flake check`
    '';

    extraPermissions = {
      allow = [
        "Bash(git log:*)"
        "Bash(git diff:*)"
        "Bash(git status:*)"
        "Bash(git show:*)"
        "Bash(git commit:*)"
        "Bash(nix flake show:*)"
        "Bash(nix flake metadata:*)"
        "Bash(nix-instantiate --parse *)"
        "Bash(nixos-rebuild dry-build *)"
        "Bash(systemctl status *)"
      ];
      deny = [
        "Bash(git push:*)"
      ];
    };

    mcpServers = {
      nixos = {
        command = "${unstable.mcp-nixos}/bin/mcp-nixos";
        args = [];
      };
    };

    extraHooks = {
      PreToolUse = [
        {
          matcher = "Bash";
          hooks = [
            {
              type = "command";
              command = toString (pkgs.writeShellScript "guard-nixos-rebuild" ''
                input=$(cat)
                cmd=$(echo "$input" | ${pkgs.jq}/bin/jq -r '.tool_input.command // empty' 2>/dev/null)
                if echo "$cmd" | grep -qE 'nixos-rebuild (switch|boot)'; then
                  echo "Verify first with: nixos-rebuild dry-build --flake .#" >&2
                  echo "Then re-run if output looks correct." >&2
                  exit 2
                fi
              '');
            }
          ];
        }
      ];
    };
  };
}
