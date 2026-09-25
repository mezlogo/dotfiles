#!/usr/bin/env bash

yay -S --needed --noconfirm \
	steam lib32-nvidia-utils ttf-liberation \
	vulkan-tools

#stow --adopt --target=$HOME \
#  idea

sudo stow --adopt --target=/ \
  steam_root

