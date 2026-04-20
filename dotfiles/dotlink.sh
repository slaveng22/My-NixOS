#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Script Name:     dotlink.sh
#
# Description:
#   Symlinks dotfiles/config dirs from repo to $HOME and ~/.config,
#   moving any existing files/dirs into ~/Dotfiles_Old_BAK first.
#
#   Usage:
#     ./dotlink.sh --setup     # Backup & link dotfiles/config dirs
#     ./dotlink.sh --remove    # Remove symlinks (keeps backups)
#     ./dotlink.sh --dry-run   # Preview actions without making changes
#
#   Backup:
#     Existing files/directories are moved into:
#       ~/Dotfiles_Old_BAK/backup_YYYYMMDD_HHMMSS
#
# Requirements:
#   - Bash shell
#   - Dotfiles repo in the same directory as this script
#
# Author:         slaven
# -----------------------------------------------------------------------------
#
DOT_FILES=$(pwd)
CONFIG_DIR="$HOME/.config"
HOME_DIR="$HOME"
BACKUP_DIR="$HOME/Dotfiles_Old_BAK/backup_$(date +%Y%m%d_%H%M%S)"

print_usage() {
  echo "Usage: $0 [--setup | --remove | --dry-run]"
  exit 1
}

if [ $# -ne 1 ]; then
  print_usage
fi

ACTION="$1"

# Create backup directory (only if not dry-run)
if [ "$ACTION" != "--dry-run" ]; then
  mkdir -p "$BACKUP_DIR"
fi

# Top-level dotfiles to link (source → destination)
declare -A DOTFILE_MAP=(
  [bashrc]="$HOME_DIR/.bashrc"
  [gitconfig]="$HOME_DIR/.gitconfig"
)

backup_item() {
  local path="$1"
  local name
  name=$(basename "$path")

  if [ -e "$path" ] && [ ! -L "$path" ]; then
    if [ "$ACTION" = "--dry-run" ]; then
      echo "Would move existing $path → $BACKUP_DIR/$name"
    else
      mv "$path" "$BACKUP_DIR/$name"
      echo "Moved existing $path → $BACKUP_DIR/$name"
    fi
  fi
}

link_config_dirs() {
  for dir in "$DOT_FILES"/*/; do
    dirname=$(basename "$dir")
    target="$CONFIG_DIR/$dirname"

    backup_item "$target"

    if [ "$ACTION" = "--dry-run" ]; then
      echo "Would link $dir → $target"
    else
      ln -sfn "$dir" "$target"
      echo "Linked $dirname → $target"
    fi
  done
}

link_dotfiles() {
  for src in "${!DOTFILE_MAP[@]}"; do
    src_path="$DOT_FILES/$src"
    dest_path="${DOTFILE_MAP[$src]}"

    if [ -e "$src_path" ]; then
      backup_item "$dest_path"
      if [ "$ACTION" = "--dry-run" ]; then
        echo "Would link $src_path → $dest_path"
      else
        ln -sfn "$src_path" "$dest_path"
        echo "Linked $src → $dest_path"
      fi
    else
      echo "Skipped missing file: $src_path"
    fi
  done
}

remove_config_dirs() {
  for dir in "$DOT_FILES"/*/; do
    dirname=$(basename "$dir")
    target="$CONFIG_DIR/$dirname"
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$dir" ]; then
      if [ "$ACTION" = "--dry-run" ]; then
        echo "Would remove symlink $target"
      else
        rm "$target"
        echo "Removed symlink $target"
      fi
    else
      echo "Skipped $target (not a matching symlink)"
    fi
  done
}

remove_dotfiles() {
  for src in "${!DOTFILE_MAP[@]}"; do
    src_path="$DOT_FILES/$src"
    dest_path="${DOTFILE_MAP[$src]}"
    if [ -L "$dest_path" ] && [ "$(readlink "$dest_path")" = "$src_path" ]; then
      if [ "$ACTION" = "--dry-run" ]; then
        echo "Would remove symlink $dest_path"
      else
        rm "$dest_path"
        echo "Removed symlink $dest_path"
      fi
    else
      echo "Skipped $dest_path (not a matching symlink)"
    fi
  done
}

case "$ACTION" in
--setup)
  link_config_dirs
  link_dotfiles
  ;;
--remove)
  remove_config_dirs
  remove_dotfiles
  ;;
--dry-run)
  echo "Dry run: previewing actions"
  echo "--- Config directories ---"
  link_config_dirs
  echo "--- Dotfiles ---"
  link_dotfiles
  echo "--- Config directory removals ---"
  remove_config_dirs
  echo "--- Dotfile removals ---"
  remove_dotfiles
  ;;
*)
  print_usage
  ;;
esac
