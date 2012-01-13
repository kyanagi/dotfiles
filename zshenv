# -*- mode: sh; coding: utf-8 -*-

### zsh起動時に設定ファイルが読まれる順番
## 1: /etc/zshenv
## 2: ~/.zshenv
## 3: /etc/zprofile  もしログインシェルなら
## 4: ~/.zprofile    もしログインシェルなら
## 5: /etc/zshrc     もし対話的シェルなら
## 6: ~/.zshrc       もし対話的シェルなら
## 7: /etc/zlogin    もしログインシェルなら
## 8: ~/.zlogin      もしログインシェルなら

### ログアウト時
## 1: ~/.zlogout
## 2: /etc/zlogout

### ZDOTDIR
## ZDOTDIRが設定されているときは、上記の「~」のかわりにZDOTDIRが使われる。
export ZDOTDIR=$HOME/.zsh.d


### ファイルが存在すれば読み込む
function source_if_exist {
  for f in $*; do
    [[ -f $f ]] && source $f
  done
}


##################################################
### locale の設定
if [ -z "$LANG" ]; then
  export LANG=ja_JP.UTF-8
fi



##################################################
### パスの設定
## 重複したパスを登録しない。
typeset -U path

## (N-/): 存在しないディレクトリは登録しない。
##    パス(...): ...という条件にマッチするパスのみ残す。
##            N: NULL_GLOBオプションを設定。
##               globがマッチしなかったり存在しないパスを無視する。
##            -: シンボリックリンク先のパスを評価。
##            /: ディレクトリのみ残す。
path=(
  ~/bin(N-/)
  /opt/ruby19/bin(N-/)
  /usr/local/mysql/bin(N-/)
  /usr/local/teTeX/bin(N-/)
  /opt/local/libexec/gnubin(N-/)
  /usr/local/bin(N-/)
  /opt/local/ghc/bin(N-/)
  /opt/local/bin(N-/)
  /opt/local/sbin(N-/)
  /usr/bin(N-/)
  /bin(N-/)
  /usr/sbin(N-/)
  /sbin(N-/)
)

## man用パスの設定
manpath=(
  /usr/local/teTeX/man(N-/)
  $manpath
)


## LD_LIBRARY_PATH
typeset -xT LD_LIBRARY_PATH ld_library_path
typeset -U ld_library_path
ld_library_path=(
  /opt/local/lib(N-/)
  /usr/local/lib(N-/)
)

## LIBRARY_PATH
typeset -xT LIBRARY_PATH library_path
typeset -U library_path
library_path=(
  /opt/local/lib(N-/)
  /usr/local/lib(N-/)
)


##################################################
### コマンドの設定
### PAGER ###
if type lv > /dev/null 2>&1; then
  export PAGER=lv
else
  export PAGER=less
fi


### lvの設定 ###
if [ "$PAGER" = "lv" ]; then
  ## -c: ANSIエスケープシーケンスの色付けなどを有効にする。
  ## -l: 1行が長くと折り返されていても1行として扱う。
  ##     （コピーしたときに余計な改行を入れない。）
  export LV="-c -l"
else
  ## lvがなくてもlvでページャーを起動する。
  alias lv="$PAGER"
fi



### grepの設定 ###
grep_version="$(grep --version | head -n 1 | sed -e 's/^[^0-9.]*\([0-9.]*\)$/\1/')"
export GREP_OPTIONS

## バイナリファイルにはマッチさせない。
GREP_OPTIONS="--binary-files=without-match"

## grep対象としてディレクトリを指定したらディレクトリ内を再帰的にgrepする。
case "$grep_version" in
  1.*|2.[0-4].*|2.5.[0-3])
    ;;
  *)
    ## grep 2.5.4以降のみの設定
    GREP_OPTIONS="--directories=recurse $GREP_OPTIONS"
    ;;
esac

## 管理用ディレクトリを無視する。
if grep --help | grep -q -- --exclude-dir
then
  GREP_OPTIONS="--exclude-dir=.svn $GREP_OPTIONS"
  GREP_OPTIONS="--exclude-dir=.git $GREP_OPTIONS"
  GREP_OPTIONS="--exclude-dir=.hg $GREP_OPTIONS"
  GREP_OPTIONS="--exclude-dir=.deps $GREP_OPTIONS"
  GREP_OPTIONS="--exclude-dir=.libs $GREP_OPTIONS"
fi

## 可能なら色を付ける。
if grep --help | grep -q -- --color
then
  GREP_OPTIONS="--color=auto $GREP_OPTIONS"
fi



### エディタの設定 ###
export EDITOR=vim
## vimがなくてもvimでviを起動する。
if ! type vim > /dev/null 2>&1
then
  alias vim=vi
fi



### Emacsのshell modeで動くように
[[ $EMACS = t ]] && unsetopt zle


### ホストごとの設定を読む
hostspecialfile="${HOME}/.zsh.d/zshenv-${HOST}"
source_if_exist $hostspecialfile
unset hostspecialfile
