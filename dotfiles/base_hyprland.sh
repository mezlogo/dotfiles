#!/usr/bin/env bash

mkdir -p $HOME/.local/bin
mkdir -p $HOME/.profile.d
mkdir -p $HOME/.zsh.d

yay -S --needed --noconfirm \
	git openssh less \
	btop nvtop \
	zip unzip \
	bluez  bluez-utils blueman \
	pipewire wireplumber pipewire-pulse pavucontrol \
	docker docker-compose \
	tmux zellij \
	ffmpeg wf-recorder mpv \
	zsh zsh-completions fish fisher nushell \
	neovim \
	tree-sitter-cli \
	socat \
	wireshark-cli wireshark-qt \
	ripgrep fzf fd jq bat eza git-delta yazi zoxide duf dust xh dua tokei \
	ttf-font-awesome nerd-fonts \
	waybar wofi dunst kitty \
	obsidian \
	telegram-desktop \
	visual-studio-code-bin \
	chromium firefox \
	keepassxc \
	wlr-randr \
	uwsm libnewt \
	sddm \
	hyprland hyprpolkitagent hyprutils xdg-desktop-portal-hyprland \
	keyd \
	light \
	wl-clipboard cliphist \
	qt5-wayland qt6-wayland \
	xdg-desktop-portal-hyprland \
	grim slurp satty \
    mise npm go rust cargo \
	qemu-full samba spice-gtk virt-viewer \
	jdk17-openjdk jdk21-openjdk openjdk21-src maven gradle \
    ltrace strace valgrind gcc make cmake clang ccls cppcheck splint uncrustify indent gdb lldb bear \
    nodejs-lts-jod npm typescript typescript-language-server \
	lsof tree ldns lnav sqlite async-profiler ctags

stow --adopt --target=$HOME \
  extend_login_shell \
  extend_zsh \
  fish \
  zsh_interactive \
  extend_path \
  base_scripts \
  kitty \
  tmux \
  nvim \
  antidote \
  hyprland \
  uwsm_agnostic \
  electron_wayland \
  waybar \
  wofi \
  maven \
  idea

sudo stow --adopt --target=/ \
  keyd_root

add_groups() {
	for group in "$@"; do
		sudo usermod -aG "$group" "$USER"
	done
}

add_groups wireshark libvirt docker video wheel

enable_user_services() {
	for service in "$@"; do
		echo "Trying to enable USER SERVICE $service"
		systemctl --user enable "$service"
	done
}

enable_user_services ssh-agent.service xdg-desktop-portal-hyprland hyprpolkitagent pipewire pipewire-pulse wireplumber

enable_system_services() {
	for service in "$@"; do
		echo "Trying to enable SYSTEM SERVICE $service"
		sudo systemctl enable "$service"
	done
}

enable_system_services keyd sshd docker bluetooth rfkill-unblock@all sddm

set_shell() {
	if [ $# -eq 0 ]; then
    		echo "Error: No shell provided as argument."
		return
	fi

	desired_shell="$1"
	current_shell=$(getent passwd "$USER" | cut -d: -f7)

	if [ "$current_shell" != "$desired_shell" ]; then
    		echo "Changing shell from $current_shell to $desired_shell"
    		chsh -s "$desired_shell"
	else
    		echo "Shell is already set to $desired_shell"
	fi
}

set_shell /usr/bin/zsh
