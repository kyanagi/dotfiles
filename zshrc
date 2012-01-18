# -*- mode: sh; coding: utf-8 -*-

##################################################
### キーバインド
## Emacsキーバインド
bindkey -e

## ^ で上位ディレクトリへ移動
function cdup() {
  echo
  cd ..
  zle reset-prompt
}
zle -N cdup
bindkey '\^' cdup

## コマンドの入力中にC-pで、その入力で履歴を検索する
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

## ヒストリのインクリメンタル検索でglobを使えるように
if zle -la history-incremental-pattern-search-backward; then
  bindkey '^R' history-incremental-pattern-search-backward
  bindkey '^S' history-incremental-pattern-search-forward
fi


##################################################
### ヒストリ
## メモリ上のヒストリ数
export HISTSIZE=200000

## ファイルに保存するヒストリ数とそのファイル
export SAVEHIST=$HISTSIZE
export HISTFILE=~/var/log/zsh-history

## ヒストリファイルにコマンドラインだけでなく実行時刻と実行時間も保存する
setopt extended_history

## 同じコマンドラインを連続で実行した場合はヒストリに登録しない
setopt hist_ignore_dups

## スペースで始まるコマンドラインはヒストリに登録しない
setopt hist_ignore_space

## ヒストリから冗長なスペースを削除する
setopt hist_reduce_blanks

## zshプロセス間でヒストリを共有する
setopt share_history

## すぐヒストリファイルに追記する
setopt inc_append_history

## C-sでのヒストリ検索が潰されてしまうため、出力停止・開始用にC-s/C-qを使わない
setopt no_flow_control

## 全てのヒストリを表示
function history-all { history -E 1 }



##################################################
### プロンプト
## PROMPT内で変数展開・コマンド置換・算術演算を実行する
setopt prompt_subst

## 色の簡易表記のため
autoload -U colors
colors

## バージョン管理システムの状態を表示する
autoload -Uz is-at-least
if is-at-least 4.3.10; then
  autoload -Uz vcs_info
  autoload -Uz add-zsh-hook
  zstyle ':vcs_info:*' max-exports 3
  zstyle ':vcs_info:*' actionformats '%F{white}%s:%f%F{green}%%b%f:%F{magenta}%a%f%c%u' '%b' '%r'
  zstyle ':vcs_info:*' formats       '%F{white}%s:%f%F{green}%%b%f%c%u' '%b' '%r' # ブランチ名は後で置換するので %%b にしておく
  zstyle ':vcs_info:*' enable git hg
  zstyle ':vcs_info:hg:*' get-revision true
  zstyle ':vcs_info:*' check-for-changes true
  zstyle ':vcs_info:git:*' stagedstr "%F{136}⚡%f" # U+26A1 'HIGH VOLTAGE SIGN'
  zstyle ':vcs_info:git:*' unstagedstr "%F{63}⚡%f"
  zstyle ':vcs_info:hg:*' unstagedstr "%F{136}⚡%f"

  add-zsh-hook precmd _update_vcs_info_message
  function _update_vcs_info_message {
    vcs_info
    # get-revision が true だと %b が長いブランチ名になるので、短くしている
    vcs_info_msg_0_=${vcs_info_msg_0_//\%b/${vcs_info_msg_1_%%:*}}
  }
fi


function setup_prompt {
  local prompt_color
  local prompt_body

  if [ -z "$SSH_CONNECTION" ]; then
    prompt_body='%m'
    prompt_color=cyan
  else
    prompt_body='%n@%m'
    case $HOST in
      hiro)
        prompt_color=magenta
        ;;
      *)
        prompt_color=yellow
        ;;
    esac
  fi

  case "$TERM" in
    dumb*|emacs*)
      PROMPT='%m%# '
      RPROMPT=''
      ;;
    *)
      PROMPT="%F{$prompt_color}$prompt_body%f%# "
      local rprompt
      rprompt=(
        "%F{$prompt_color}["
        "\${vcs_info_msg_0_:+\${vcs_info_msg_0_} }%f" # VCS の情報があれば表示
        "%F{$prompt_color}"
        # $PWD は ~ が展開されているので ~ に戻し、リポジトリ名の部分に下線を付ける。
        # リポジトリ名は $vcs_info_msg_2_ に入っている。
        "\${\${PWD/#\$HOME/~}/\${vcs_info_msg_2_}/%U\${vcs_info_msg_2_}%u}"
        " %*]%f"
      )
      RPROMPT=${(j..)rprompt}
      ;;
  esac
}
setup_prompt



##################################################
### 補完
## 初期化
autoload -U compinit
compinit -u

## 補完リストに色をつける
eval `dircolors -b` # LS_COLORSの設定
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:kill:*:processes' list-colors "=(#b)[^0-9]#([0-9]#)*[0-9:.]## ([^ ]#)*=$color[none]=$color[bold];$color[cyan]=$color[green]"

## 補完リストを全てグループ分けして表示
zstyle ':completion:*' group-name ''

## 補完リストが1画面に収まらなかったときのプロンプト
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'

## 補完リストで候補のカーソル選択を有効に
zstyle ':completion:*:default' menu select=1

## カーソル選択で候補を選んでいるときのプロンプト（補完リストが1画面に収まらなかった場合）
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'

## m:{a-z}={A-Z}: 小文字を大文字に変えたものでも補完する
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

## 補完候補をキャッシュする。
zstyle ':completion:*' use-cache yes

## 詳細な情報を使う
zstyle ':completion:*' verbose yes

## メッセージフォーマット
zstyle ':completion:*:descriptions' format '%B%d%b' # 補完リストの上に出てくるdescription
zstyle ':completion:*:messages' format '%d' # 補完時のメッセージ
zstyle ':completion:*:warnings' format 'No matches for: %d' # 補完がマッチしなかったとき

## 辞書順ではなく数字順に並べる
setopt numeric_glob_sort

## 補完リストを詰めて表示
setopt list_packed

## ディレクトリの補完に続いてデリミタ等を入力したとき、
## ディレクトリ末尾の「/」を自動的に削除する
setopt auto_remove_slash



##################################################
### 展開
## --prefix=~/localというように「=」の後でもファイル名展開を行う
setopt magic_equal_subst

## 拡張globを有効にする
setopt extended_glob

## 展開後のパスがディレクトリだったら最後に「/」をつける
#setopt mark_dirs

## {a-c}をa b cに展開する
setopt brace_ccl



##################################################
### ジョブ
## jobsでプロセスIDも出力する
setopt long_list_jobs

## 実行したプロセスの消費時間が3秒以上かかったら
## 自動的に消費時間の統計情報を表示する。
REPORTTIME=3



##################################################
### エイリアス
alias mv='nocorrect mv'
alias ls='ls -F --color=auto --show-control-chars'



##################################################
### ディレクトリスタック
## cdしたとき、移動前のディレクトリを自動でpushdする
setopt auto_pushd

## pushdのディレクトリスタックに重複を含めない
setopt pushd_ignore_dups




### 単語境界に含まれない文字
WORDCHARS='*?_-.[]~&;!#$%^(){}<>' # `/'と`='を抜く



### パッケージ管理
source $ZDOTDIR/package.zsh
source $ZDOTDIR/package-conf/zsh-syntax-highlighting.zsh


### ホームディレクトリから開始
cd
