#!/usr/bin/env bash

mkdir -p ~/repos/{mezlogo,edu,mirrors}
mkdir -p ~/{Downloads,Pictures,Desktop,Music,Pictures,Public,Templates,Videos}
mkdir -p ~/.profile.d
mkdir -p ~/.local/bin
mkdir -p ~/.ssh

chmod 700 ~/.ssh

# For bluetooth device connection from user space
sudo usermod -aG lp $USER