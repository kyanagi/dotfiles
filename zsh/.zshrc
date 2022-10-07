##################################################
### Zim
zstyle ':zim:zmodule' use 'degit'
export ZIM_HOME="${XDG_CACHE_HOME}/zim"
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
       https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi
source ${ZIM_HOME}/init.zsh

##################################################
### キーバインドの設定
bindkey -e

for name in $ZDOTDIR/functions/*(.); do
  name=${name:t}
  autoload -Uz $name
  zle -N $name
done

## ^ で cd ..
bindkey '\^' cdup-or-insert-circumflex

## M-^ で git のワークツリーのトップへ移動
bindkey '^[\^' cd-git-toplevel

## C-w は リージョンが有効なときは kill-region にする
bindkey '^W' kill-region-or-backward-kill-word

## backward-kill-word 等が日本語でもきちんと動くようにする
autoload -Uz select-word-style
select-word-style default
zstyle ':zle:*' word-chars " /:@+|"
zstyle ':zle:*' word-style unspecified

## コマンドの入力中にC-pで、その入力で履歴を検索する
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

## Enter で ls と git status を表示する
bindkey '^m' ls-and-git-status

## Alt+Enter で git diff を表示する
function my-git-diff {
  git diff
  zle reset-prompt
  return 0
}
zle -N my-git-diff
bindkey "^[^m" my-git-diff

## URL の入力をエスケープする
# autoload -Uz url-quote-magic
# zle -N self-insert url-quote-magic

##################################################
### ヒストリ
## メモリ上のヒストリ数
export HISTSIZE=2000000

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

##################################################
### プロンプト
## PROMPT内で変数展開・コマンド置換・算術演算を実行する
setopt prompt_subst

## 色の簡易表記のため
autoload -U colors
colors

autoload -Uz add-zsh-hook

## プロンプトの設定
() {
  local prompt_color prompt_body prompt_mark

  if [[ -z "$SSH_CONNECTION" ]]; then
    prompt_body=''
    prompt_color=cyan
    prompt_mark_normal='🐳'
    prompt_mark_error='🐙'
  else
    prompt_body="%n@${EC2_INSTANCE_NAME:-%m}"
    prompt_mark_normal='%#'
    prompt_mark_error='%#'
    if [ "$EC2_INSTANCE_ENV" = "production" ]; then
      prompt_color=magenta
    else
      prompt_color=yellow
    fi
  fi

  case "$TERM" in
    dumb*|emacs*)
      PROMPT='%m%# '
      RPROMPT=''
      ;;
    *)
      PROMPT="%F{$prompt_color}${prompt_body}%f\${prompt_mark_color}\${prompt_mark}%f "
      local rprompt=(
        "%F{$prompt_color}["
        "%~ %*" # HH:MM:SS
        "]%f"
      )
      RPROMPT=${(j..)rprompt}

      ## コマンドの終了ステータスに応じてプロンプトの色を変える。
      ## 一度色違いで表示したら、プロンプト再描画の際には色を戻す。
      function setup_prompt_mark_color {
        if (( prompt_mark_displayed != 1 && $? != 0 )); then
          prompt_mark_color='%F{magenta}'
          prompt_mark=$prompt_mark_error
        else
          prompt_mark_color=''
          prompt_mark=$prompt_mark_normal
        fi
        prompt_mark_displayed=1
      }
      add-zsh-hook precmd setup_prompt_mark_color

      function reset_prompt_mark_displayed {
        prompt_mark_displayed=0
      }
      add-zsh-hook preexec reset_prompt_mark_displayed
      ;;
  esac
}

##################################################
### 補完
## 初期化
autoload -U compinit
compinit -C -u

## 補完リストに色をつける
if type dircolors > /dev/null; then
  evalcache dircolors -b # LS_COLORSの設定
  zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
else
  zstyle ':completion:*:default' list-colors 'di=34;01' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'
fi
zstyle ':completion:*:*:*:*:processes' list-colors "=(#b)[^0-9]#([0-9]#)*[0-9:.]## ([^ ]#)*=$color[none]=$color[bold];$color[cyan]=$color[green]"

## 補完リストを全てグループ分けして表示
zstyle ':completion:*' group-name ''

## 補完リストが1画面に収まらなかったときのプロンプト
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'

## 補完リストで候補のカーソル選択を有効に
zstyle ':completion:*:default' menu select=1

## カーソル選択で候補を選んでいるときのプロンプト（補完リストが1画面に収まらなかった場合）
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'

## m:{a-z}={A-Z}: 小文字を大文字に変えたものでも補完する
#zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

## 補完候補をキャッシュする。
zstyle ':completion:*' use-cache yes

## 詳細な情報を使う
zstyle ':completion:*' verbose yes

## メッセージフォーマット
zstyle ':completion:*:descriptions' format '%F{yellow}%B%d%b%f' # 補完リストの上に出てくるdescription
zstyle ':completion:*:messages' format '%d' # 補完時のメッセージ
zstyle ':completion:*:warnings' format 'No matches for: %d' # 補完がマッチしなかったとき

## man の補完をセクションごとに区分する
zstyle ':completion:*:manuals' separate-sections true

## セクション番号を挿入する(セクション1以外)
zstyle ':completion:*:manuals.(^1*)' insert-sections true

## コマンドラインに既に入力されているものは補完対象にしない
zstyle ':completion:*:(rm|mv|cp|diff|kill):*' ignore-line other

## parent: foo/../ から foo を補完しない
## pwd: ../ からカレントディレクトリを補完しない
zstyle ':completion:*:(cd|mv|cp):*' ignore-parents parent pwd

## 辞書順ではなく数字順に並べる
setopt numeric_glob_sort

## 補完リストを詰めて表示
setopt list_packed

## ディレクトリの補完に続いてデリミタ等を入力したとき、
## ディレクトリ末尾の「/」を自動的に削除する
setopt auto_remove_slash

## 一意に補完できなかったらベルを鳴らす
setopt list_beep

##################################################
### 展開
## --prefix=~/localというように「=」の後でもファイル名展開を行う
setopt magic_equal_subst

## 拡張globを有効にする
setopt extended_glob

## {a-c}をa b cに展開する
setopt brace_ccl

##################################################
### コマンド・エイリアス
alias mv='nocorrect mv'

case "$OSTYPE" in
  freebsd*)
    alias ls='ls -F -G -w'
    export LSCOLORS=ExgxfxdxCxDxDxhbadacec
    ;;
  *)
    alias ls='ls -F --color=auto --show-control-chars'
    export TIME_STYLE=long-iso
    ;;
esac
alias ll='ls -l'
alias la='ls -a'

alias be='bundle exec'

## manに色をつける
function man {
  # mb: blinking
  # md: bold
  # so: standout-mode
  # us: underline
  env \
    LESS_TERMCAP_mb=$'\E[01;31m' \
    LESS_TERMCAP_md=$'\E[01;38;5;76m' \
    LESS_TERMCAP_so=$'\E[48;5;94;1;37m' \
    LESS_TERMCAP_us=$'\E[04;38;5;146m' \
    LESS_TERMCAP_me=$'\E[0m' \
    LESS_TERMCAP_se=$'\E[0m' \
    LESS_TERMCAP_ue=$'\E[0m' \
    man "$@"
}

## zshellのman用
function zman {
  PAGER="less -g -s -p '^       "$1"'" man zshall
}

## fzf
if type fzf > /dev/null 2>&1; then
  source "${HOMEBREW_PREFIX}/opt/fzf/shell/completion.zsh"
  source "${HOMEBREW_PREFIX}/opt/fzf/shell/key-bindings.zsh"
  bindkey "^O" fzf-file-widget
  export FZF_DEFAULT_COMMAND='unset REPORTTIME && rg --color=never --files --no-ignore --hidden --no-messages'
  export FZF_DEFAULT_OPTS='--height 40% --border'
  export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
  export FZF_CTRL_R_OPTS='--bind=ctrl-e:accept'
fi

## ビルトインコマンドでも run-help を使えるようにする
unalias run-help > /dev/null 2>&1 && autoload -Uz run-help


##################################################
### ディレクトリ移動
## cdしたとき、移動前のディレクトリを自動でpushdする
setopt auto_pushd

## pushdのディレクトリスタックに重複を含めない
setopt pushd_ignore_dups

## zoxide
if type zoxide > /dev/null 2>&1; then
  export _ZO_DATA_DIR="${XDG_DATA_HOME}/zoxide"
  export _ZO_ECHO="1"
  evalcache zoxide init zsh --cmd c
fi

## gitワークツリー内に移動したときはブランチ名を表示
function chpwd-show-git-branch {
  local git_toplevel git_branch_name
  git_toplevel=$(git rev-parse --show-toplevel 2> /dev/null)

  # 移動先がgitワークツリー内で、移動前と別ワークツリーだったら
  if [[ -n $git_toplevel && $git_toplevel != $git_toplevel_prev ]]; then
    git_branch_name=$(git rev-parse --abbrev-ref @ 2> /dev/null) || git_branch_name="(no commit)"
    echo "## ${fg[green]}${git_branch_name}"
  fi

  git_toplevel_prev=${git_toplevel}
}
add-zsh-hook chpwd chpwd-show-git-branch


##################################################
### その他

## 実行したプロセスの消費時間が3秒以上かかったら
## 自動的に消費時間の統計情報を表示する。
REPORTTIME=3

## メールチェックしない
MAILCHECK=0
