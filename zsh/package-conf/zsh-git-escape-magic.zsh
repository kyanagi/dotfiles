# -*- mode: sh; coding: utf-8 -*-
### zsh-git-escape-magic
## https://github.com/knu/zsh-git-escape-magic
package-install github knu/zsh-git-escape-magic
fpath=(
  $(package-directory knu/zsh-git-escape-magic)(N-/)
  $fpath
)
autoload -Uz git-escape-magic
git-escape-magic
