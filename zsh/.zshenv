if [[ -z "$ZDOTDIR" ]]; then
  # このファイルが置かれているディレクトリをZDOTDIRに設定
  function {
    export ZDOTDIR="${*:A:h}"
  } "${(%):-%N}"
fi

[ -f $ZDOTDIR/zshenv ] && source $ZDOTDIR/zshenv
