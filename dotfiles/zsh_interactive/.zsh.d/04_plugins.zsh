function load_plugins() {
  local zsh_plugins="$HOME/.zsh_plugins"
  if [ -f "${zsh_plugins}.zsh" ]; then
    source ${zsh_plugins}.zsh
    return 0
  fi

  # local _antifote_path="/usr/share/zsh-antidote/antidote.zsh"
  local _antifote_path="$HOME/.antidote/antidote.zsh"
  if [ -f "$_antifote_path" ]; then
    # source "$_antifote_path"
    # antidote load "$ZDOTDIR/zsh_plugins.txt"
    if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
      (
        source "$_antifote_path"
        antidote bundle <${zsh_plugins}.txt >${zsh_plugins}.zsh
      )
    fi
    source ${zsh_plugins}.zsh
  fi
}

export ZSH_AUTOSUGGEST_USE_ASYNC="true"
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
load_plugins

# FZF BLOCK

if [ -f /usr/share/fzf/completion.zsh ]; then
  source /usr/share/fzf/completion.zsh
fi

# Options to fzf command
export FZF_COMPLETION_OPTS='--border --info=inline'

# Use fd (https://github.com/sharkdp/fd) instead of the default find
# command for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}
