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
export GREP_OPTIONS
grep_help=$(grep --help)

## バイナリファイルにはマッチさせない。
GREP_OPTIONS="--binary-files=without-match"

## grep対象としてディレクトリを指定したらディレクトリ内を再帰的にgrepする。
GREP_OPTIONS="--recursive $GREP_OPTIONS"

## 管理用ディレクトリを無視する。
if echo $grep_help | grep -q -- --exclude-dir
then
  for ext (.svn .git .hg .deps .libs)
  do
    GREP_OPTIONS="--exclude-dir=$ext $GREP_OPTIONS"
  done
fi

## 可能なら色を付ける。
if echo $grep_help | grep -q -- --color
then
  GREP_OPTIONS="--color=auto $GREP_OPTIONS"
fi

unset grep_help


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
source_if_exist "${HOME}/.zsh.d/zshenv-${HOST}"
