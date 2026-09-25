# --- Helper: install only the plugins that are not already installed ---
function fisher_install_needed
    set -l installed (fisher list 2>/dev/null)

    set -l needed
    for plugin in $argv
        if not contains -- $plugin $installed
            set -a needed $plugin
        end
    end

    if test (count $needed) -gt 0
        echo "Installing missing plugins: $needed"
        fisher install $needed
    end
end

if status is-interactive
    set -g fish_key_bindings fish_vi_key_bindings
end

function user_key_bindings
    bind -M insert shift-tab complete
    bind -M insert tab complete-and-search

    bind \cl clear
end

if status is-interactive
    set -g fish_greeting

    set -g fish_key_bindings fish_vi_key_bindings

    set fzf_preview_dir_cmd eza --all --color=always
    set fzf_preview_file_cmd bat
    set fzf_fd_opts --hidden --max-depth 5
    set fzf_diff_highlighter delta --paging=never --width=20

    user_key_bindings

    #eval "$(mise activate fish)"
end

fish_add_path -g ~/.local/bin
