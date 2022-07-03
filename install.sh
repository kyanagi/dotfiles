#!/bin/bash

set -eu

repo="git@github.com:kyanagi/dotfiles.git"
dirname="dotfiles"
xdg_config_home="~/.config"

echo -n "A directory \`$dirname' will be created in the current directory. OK? (y/N): "
read -r resp
if [[ "$resp" != "y" ]]; then
  echo "Installation canceled."
  exit 1
fi

exit

git clone "$repo" "$dirname"
cd "$dirname"

ln -s zsh/.zshenv ~/.zshenv

mkdir -p "$xdg_config_home"
for d in git tig; do
  ln -s "$d" "$xdg_config_home"
done

echo "Installation finished."
