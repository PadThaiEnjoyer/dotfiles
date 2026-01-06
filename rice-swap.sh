#!/bin/bash
# Path to your dotfiles
DOTFILES="$HOME/.dotfiles"
cd "$DOTFILES"

CURRENT=$1
NEXT=$2

# Remove the old rice links
stow -D "$CURRENT"
# Apply the new rice links
stow "$NEXT"

sudo systemctl restart sddm
#hyprctl dispatch exit
