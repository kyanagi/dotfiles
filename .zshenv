if [[ -z "$ZDOTDIR" ]]; then
  export ZDOTDIR=$HOME/.zsh.d
fi

[ -f $ZDOTDIR/zshenv ] && source $ZDOTDIR/zshenv
