#!/usr/bin/env bash

./init.sh

exec stow --target=$HOME \
  extend_login_shell \
  extend_zsh \
  test_extend_login_shell \
  test_extend_zsh zsh_interactive \
  tmux \
  i3wm
