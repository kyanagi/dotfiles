# -*- mode: sh; coding: utf-8 -*-
### zsh-manydots-magic
## https://github.com/knu/zsh-manydots-magic
package-install github knu/zsh-manydots-magic
fpath=(
  $(package-directory knu/zsh-manydots-magic)(N-/)
  $fpath
)
autoload -Uz manydots-magic
manydots-magic
