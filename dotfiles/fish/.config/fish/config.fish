function user_key_bindings
    bind \cl clear
end

if status is-interactive
    set -g fish_greeting

    set -g fish_key_bindings fish_vi_key_bindings

    set fzf_preview_dir_cmd eza --all --color=always
    set fzf_preview_file_cmd bat
    set fzf_fd_opts --hidden --max-depth 5
    set fzf_diff_highlighter delta --paging=never --width=20

    bind -M insert shift-tab complete
    bind -M insert tab complete-and-search

    user_key_bindings

    eval "$(mise activate fish)"
end

fish_add_path -g ~/.local/bin
