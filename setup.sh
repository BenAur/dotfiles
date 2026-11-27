#!/usr/bin/env bash
# Stows the kanata and emacs config packages into $HOME.
# Creates/updates:
#   ~/.config/kanata/config.kbd (symlink into this repo)
#   ~/.config/emacs/init.el     (symlink into this repo)
set -euo pipefail

if ! command -v stow >/dev/null 2>&1; then
  echo "error: GNU stow is not installed (apt install stow)" >&2
  exit 1
fi

cd "$(dirname "$0")"

# stow refuses to overwrite existing real files; back the current one up
CFG="${HOME}/.config/kanata/config.kbd"
if [ -e "$CFG" ] && [ ! -L "$CFG" ]; then
  cp "$CFG" "${CFG}.bak"
  rm "$CFG"
  echo "Backed up existing config to ${CFG}.bak"
fi

INIT="${HOME}/.config/emacs/init.el"
if [ -e "$INIT" ] && [ ! -L "$INIT" ]; then
  cp "$INIT" "${INIT}.bak"
  rm "$INIT"
  echo "Backed up existing config to ${INIT}.bak"
fi

# --restow: removes then re-applies symlinks, safe to run repeatedly
stow --restow --dir="$(pwd)" --target="$HOME" kanata emacs

echo "Stowed: ${CFG} -> $(readlink -f "$CFG")"
echo "Stowed: ${INIT} -> $(readlink -f "$INIT")"
echo "Apply kanata with: sudo systemctl restart kanata"
