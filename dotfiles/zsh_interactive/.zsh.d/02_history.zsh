#turn off ksh-like !!
unsetopt bang_hist
#turn off modifiers like `print /usr/bin/cat(:t)`
unsetopt bare_glob_qual

setopt inc_append_history
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_find_no_dups
setopt hist_reduce_blanks
setopt hist_ignore_space
unsetopt hist_save_by_copy
unsetopt append_history

HISTSIZE=20000
SAVEHIST=20000
HISTFILE="$HOME/.zsh_history"
