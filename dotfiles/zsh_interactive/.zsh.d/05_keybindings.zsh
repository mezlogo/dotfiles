bindkey -v
export KEYTIMEOUT=1

bindkey -M viins '^P' history-substring-search-up
bindkey -M viins '^N' history-substring-search-down
bindkey -M viins '^E' end-of-line
bindkey -M viins '^A' beginning-of-line

copy-to-xsel() {
  zle kill-buffer
  print -rn -- $CUTBUFFER | xsel -ib
}

zle     -N            copy-to-xsel
bindkey -M viins "^Y" copy-to-xsel

# insert file selected by fzf
__fzf_select_file() {
  local find_files="fd -t f"
  local find_dirs="fd -t d"
  fzf_cmd="fzf --preview 'bat -f {}' --prompt 'f> ' --header 'ctrl-d: dirs / ctrl-f: files' --bind 'ctrl-d:change-prompt(d> )+reload(fd -t d)+change-preview(ls -al {})' --bind 'ctrl-f:change-prompt(f> )+reload(fd -t f)+change-preview(bat -f {})'"
  setopt localoptions pipefail no_aliases 2> /dev/null
  eval "$find_files" | eval "$fzf_cmd" | while read item; do
    echo -n "$item"
  done
  local ret=$?
  echo
  return $ret
}

fzf-file-widget() {
  LBUFFER="${LBUFFER}$(__fzf_select_file)"
  local ret=$?
  zle reset-prompt
  return $ret
}

zle     -N            fzf-file-widget
bindkey -M vicmd '^T' fzf-file-widget
bindkey -M viins '^T' fzf-file-widget

bindkey -M vicmd '^q' accept-and-hold
bindkey -M viins '^q' accept-and-hold

bindkey -M viins '^R' history-search-multi-word
bindkey -M vicmd '^R' history-search-multi-word

bindkey -M viins '^[[3~' delete-char
bindkey -M vicmd '^[[3~' delete-char

bindkey -M viins '^[.' insert-last-word
bindkey -M vicmd '^[.' insert-last-word
