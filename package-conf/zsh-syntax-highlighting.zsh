# -*- mode: sh; coding: utf-8 -*-
### zsh-syntax-highlighting
## https://github.com/zsh-users/zsh-syntax-highlighting
if [[ $(echotc Co) == 256 ]]
then
  package-install github zsh-users/zsh-syntax-highlighting
  source $(package-directory zsh-users/zsh-syntax-highlighting)/zsh-syntax-highlighting.zsh

  ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=130'
  ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=130'
  ZSH_HIGHLIGHT_STYLES[path]='none'
  ZSH_HIGHLIGHT_STYLES[globbing]='fg=69'

  # for key (alias builtin function command)
  # do
  #   ZSH_HIGHLIGHT_STYLES[$key]='fg=green'
  # done
fi
