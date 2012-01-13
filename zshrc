alias mv='nocorrect mv'
alias ls='ls -F --color=auto --show-control-chars'
alias mgrep='migemo-grep /usr/local/share/migemo/migemo-dict'
alias pd='popd'
alias ll='ls -ltr'
#alias -g L='| $PAGER'

setopt auto_remove_slash magic_equal_subst no_flow_control
setopt extended_glob hist_ignore_dups monitor print_eight_bit
setopt prompt_subst append_history share_history inc_append_history
setopt auto_pushd pushd_ignore_dups 
setopt numeric_glob_sort
setopt hist_ignore_space

function history-all { history -E 1 }

function gd() {
    dirs -v
    echo -n "number: "
    local newdir
    read newdir
    cd +"$newdir"
}

bindkey -e

function cdup() {
   echo
   cd ..
   zle reset-prompt
}
zle -N cdup
bindkey '\^' cdup

# keychain
#keychain ~/.ssh/id_dsa
#. .keychain/`hostname`-sh

zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*' group-name ''
cd




# The following lines were added by compinstall

zstyle ':completion:*' insert-unambiguous true
zstyle ':completion:*' original false
zstyle :compinstall filename '/Users/ani/.zshrc'

autoload -U compinit
compinit -u
# End of lines added by compinstall
