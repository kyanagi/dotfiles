## このファイルが置かれているディレクトリをZDOTDIRに設定
if [[ -z "$ZDOTDIR" ]]; then
  ZDOTDIR="${${(%):-%N}:A:h}"
fi

if [[ -z "$LANG" ]]; then
  export LANG=ja_JP.UTF-8
fi

## /etc/zshrc等は読まない
setopt no_global_rcs

## Emacsのshell modeで動くように
[[ $EMACS = t ]] && unsetopt zle

##################################################
### 各種パスの設定

## XDG
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_STATE_HOME="${HOME}/.local/state"

## evalcacheの準備
FPATH="${ZDOTDIR}/functions" autoload +X evalcache

## Homebrew
if [[ -x /opt/homebrew/bin/brew ]]; then
  evalcache /opt/homebrew/bin/brew shellenv
elif [[ -x /usr/local/bin/brew ]]; then
  evalcache  /usr/local/bin/brew shellenv
fi

## volta
export VOLTA_HOME="${XDG_CONFIG_HOME}/volta"

## Rust
export RUSTUP_HOME="${XDG_DATA_HOME}/rustup"
export CARGO_HOME="${XDG_DATA_HOME}/cargo"

## PATH
## 重複したパスを登録しない。
typeset -U path

for formula in grep utils coreutils findutils gnu-tar
do
  path=(${HOMEBREW_PREFIX}/opt/${formula}/libexec/gnubin $path)
done

path=(
  ~/bin
  ~/local/bin
  /usr/local/bin
  ${CARGO_HOME}/bin
  ${VOLTA_HOME}/bin
  /opt/homebrew/opt/bison/bin
  $path
)
path=( ${^path}(N-/) )

typeset -U fpath

## FPATH
fpath=(
  $ZDOTDIR/functions
  ~/g/zsh-completions/src
  ${HOMEBREW_PREFIX}/share/zsh/site-functions
  $fpath
)
fpath=( ${^fpath}(N-/) )

## LD_LIBRARY_PATH
unset LD_LIBRARY_PATH
typeset -xT LD_LIBRARY_PATH ld_library_path
typeset -U ld_library_path
ld_library_path=(
  /opt/local/lib
  /usr/local/lib
)
ld_library_path=( ${^ld_library_path}(N-/) )

## LIBRARY_PATH
unset LIBRARY_PATH
typeset -xT LIBRARY_PATH library_path
typeset -U library_path
library_path=(
  /opt/local/lib
  /usr/local/lib
)
library_path=( ${^library_path}(N-/) )


## readline, openssl
if [[ -n "$HOMEBREW_PREFIX" ]]; then
  local readline_path="${HOMEBREW_PREFIX}/opt/readline"
  local openssl_path="${HOMEBREW_PREFIX}/opt/openssl@1.1"
  export LDFLAGS="-L${readline_path}/lib -L${openssl_path}/lib"
  export CPPFLAGS="-I${readline_path}/include -I${openssl_path}/include"
  export PKG_CONFIG_PATH="${readline_path}/lib/pkgconfig:${openssl_path}/lib/pkgconfig"
  export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$openssl_path --with-readline-dir=$readline_path --disable-install-doc"

  path=(
    $openssl_path/bin(N-/)
    $path
  )
fi

## rbenv
if type rbenv > /dev/null 2>&1; then
  evalcache rbenv init - zsh
fi

## awscli
export AWS_SHARED_CREDENTIALS_FILE="${XDG_CONFIG_HOME}/aws/credentials"
export AWS_CONFIG_FILE="${XDG_CONFIG_HOME}/aws/config"

### コマンドの設定
export PAGER=less
export EDITOR=vim
typeset -xT LESS less ' '
less=(
  --max-back-scroll=1000
  --ignore-case
  --LONG-PROMPT
  --RAW-CONTROL-CHARS
)
