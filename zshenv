export PATH=~/bin:/opt/ruby19/bin:/usr/local/mysql/bin:/usr/local/teTeX/bin:/opt/local/libexec/gnubin:/usr/local/bin:/opt/local/ghc/bin:/opt/local/bin:/opt/local/sbin:$PATH
export MANPATH=/usr/local/teTeX/man:$MANPATH

export LIBRARY_PATH=/opt/local/lib:$LIBRARY_PATH
export LD_LIBRARY_PATH=/opt/local/lib:$LD_LIBRARY_PATH
#export C_INCLUDE_PATH=/opt/local/include:$C_INCLUDE_PATH

# export PROMPT='%m%# '
# export RPROMPT='[%~ %*]'
export PROMPT='%{[36m%}%m%{[m%}%# '
export RPROMPT='%{[36m%}[%~ %*]%{[m%}'

export HISTFILE=/Users/ani/var/log/zsh-history
export SAVEHIST=200000
export HISTSIZE=200000

export TERM=rxvt
#export REFE_DATA_DIR=/usr/local/share/refe

#export PAGER=less
export GREP_OPTIONS='--color'

export EDITOR=vi

#eval `dircolors -b`

[[ $EMACS = t ]] && unsetopt zle
