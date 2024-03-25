#! /bin/bash

source scripts/p.sh
source scripts/color.sh

# ============== CONFIG ==============

d=$(detectDistro)
if [[ $d == "Debian" ]]; then
    sudo apt install -y curl
elif [[ $d == "Arch" ]]; then
    sudo pacman -Sy curl
fi

p i stow

# Link dotfile home to $HOME
echo -e "${GREEN}[+] Symlinking dotfiles...${ENDCOLOR}"
stow -v -t $HOME home --adopt