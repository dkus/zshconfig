#!/usr/bin/env bash
# Exit on error (-e), unset variable use (-u), and pipeline failure (pipefail).
set -euo pipefail

# Resolve absolute path to this repository directory.
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Target ZDOTDIR location used by .zshenv.
target_dir="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
# Timestamp suffix for backup file/folder names.
backup_suffix="$(date +%Y%m%d-%H%M%S)"

# Ensure parent config directory exists.
mkdir -p "${target_dir%/zsh}"

# If repo is not already located at target path, link it there.
if [[ "$repo_dir" != "$target_dir" ]]; then
  # Backup existing non-symlink target directory before replacing.
  if [[ -e "$target_dir" && ! -L "$target_dir" ]]; then
    mv "$target_dir" "${target_dir}.backup-${backup_suffix}"
  fi
  # Force-create/update symlink from target path to repo path.
  ln -sfn "$repo_dir" "$target_dir"
fi

# Sync submodule URL config with .gitmodules.
git -C "$repo_dir" submodule sync --recursive
# Initialize and update all submodules.
git -C "$repo_dir" submodule update --init --recursive

# Backup existing ~/.zshenv before replacing.
if [[ -f "$HOME/.zshenv" ]]; then
  cp "$HOME/.zshenv" "$HOME/.zshenv.backup-${backup_suffix}"
fi

# Install repository .zshenv to user home with read/write owner perms.
install -m 644 "$repo_dir/.zshenv" "$HOME/.zshenv"

# Print install summary.
echo "Installed zsh config."
# Print resolved zdotdir path.
echo "ZDOTDIR: $target_dir"
# Print note about ~/.zshenv replacement and backup behavior.
echo "~/.zshenv updated (backup created if it existed)."
