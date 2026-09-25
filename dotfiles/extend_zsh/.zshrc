# extend zsh by dynamic source everything from ~/.zsh.d

for profile in $HOME/.zsh.d/*.zsh; do
    test -r "$profile" && source "$profile"
done
unset profile
