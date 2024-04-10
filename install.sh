#! /bin/bash

export NIXPKGS_ALLOW_UNFREE=1

detectDistro() {
    if [ "$(uname -s)" = "Darwin" ]; then
        echo "macOS"
    else
        if [ "$(grep -Ei 'debian|buntu|mint' /etc/*release)" ]; then
            echo "Debian"
        elif [ "$(grep -Ei 'arch|manjaro|artix' /etc/*release)" ]; then
            echo "Arch"
        elif [ "$(grep -Ei 'fedora' /etc/*release)" ]; then
            echo "Fedora"
        else
            echo 1
            return 1
        fi
    fi
}

d=$(detectDistro)
if [[ $d == "Debian" ]]; then
    sudo apt install -y curl git
elif [[ $d == "Arch" ]]; then
    sudo pacman -Sy curl git
    sudo pacman -Sy gnome power-profiles-daemon fwupd gst-plugin-pipewire # Gnome and optional dependencies.
    sudo systemctl enable power-profiles-daemon
    sudo systemctl start power-profiles-daemon
elif [[ $d == "Fedora" ]]; then
    sudo dnf install curl git
fi

if [ $(pwd) != "$HOME/dotfiles" ]; then
    cd $HOME
    git clone https://github.com/TrudeEH/dotfiles
    cd dotfiles
fi

if ! nix --version &>/dev/null; then
    echo -e "${YELLOW}[E] Nix not found.${ENDCOLOR}"
    echo -e "${GREEN}[+] Installing the Nix package manager...${ENDCOLOR}"
    sh <(curl -L https://nixos.org/nix/install) --daemon
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    echo -e "${GREEN}[I] Installed Nix.${ENDCOLOR}"
fi

# ============== HOME MANAGER ==============

# Install
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install

# Apply config
mkdir -p $HOME/.config/home-manager
rm $HOME/.config/home-manager/home.nix
ln -s $HOME/dotfiles/home.nix $HOME/.config/home-manager/home.nix

home-manager -b backup switch
echo
echo -e "${GREEN}[I] Done. Rebooting in 5 seconds...${ENDCOLOR}"
sleep 5

systemctl reboot
