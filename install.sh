#!/bin/bash

update_packages() {
    sudo pacman -Syy
}

install_prerequisites() {
    sudo pacman -S yay
}

install_nvim() {
    sudo pacman -S lua nodejs yarn neovim
    yay -S neovim-remote
}

install_zsh() {
    sudo pacman -S zsh

    curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh

    # make zsh default shell
    chsh -s `which zsh`
}

create_links() {
    # install realpath if not already installed
    if ! command -v realpath &> /dev/null; then
        sudo pacman -S realpath
    fi

    ln -fs `realpath ./.zsh` ~
    ln -fs `realpath ./.zshrc` ~
    ln -fs `realpath ./.gdbinit` ~

    mkdir -p ~/.scripts
    rm -rf ~/.scripts/nvim &>/dev/null
    ln -fs `realpath ./.scripts/nvim` ~/.scripts/

    if [ ! -d ~/.config ]; then
	    mkdir ~/.config
    fi

    ln -fs `realpath ./.config/nvim` ~/.config/
    ln -fs `realpath ./.config/alacritty` ~/.config/
    ln -fs `realpath ./.config/nitrogen` ~/.config/
    ln -fs `realpath ./.config/polybar` ~/.config/

    ln -fs ~/.config/nvim/init.vim ~/.vimrc

}

nvim_python() {
    if ! command -v pip &>/dev/null; then
        sudo pacman -S python python-pip
    fi

    pip install --user neovim
}

install_fonts() {
    cd fonts
    ./install.sh
    cd ..
}

install_pwndbg() {
    if ! command -v gdb &>/dev/null; then
        sudo pacman -S gdb
    fi

    git clone https://github.com/pwndbg/pwndbg
    pushd pwndbg
    ./setup.sh
    popd
    rm -rf pwndbg
}


# update packages
update_packages
/bin/echo -e "\e[32mUpdating package lists......................\e[32mDONE!\e[39m"
install_prerequisites
/bin/echo -e "\e[32mInstalling prerequisites....................\e[32mDONE!\e[39m"
# install nvim and update alternatives
install_nvim
/bin/echo -e "\e[32mInstalling Neovim...........................\e[32mDONE!\e[39m"
# install python packages for neovim
nvim_python
/bin/echo -e "\e[32mNeovim python packages......................\e[32mDONE!\e[39m"
# install zsh and set as default shell
install_zsh
/bin/echo -e "\e[32mZsh install.................................\e[32mDONE!\e[39m"
# install pwndbg
install_pwndbg
/bin/echo -e "\e[32mPwndbg install..............................\e[32mDONE!\e[39m"
# create links from the repo directory to the required paths
create_links
/bin/echo -e "\e[32mCreate links................................\e[32mDONE!\e[39m"
# install special fonts for powerline, some fonts don't render some unicode
# characters the same way
install_fonts

/bin/echo -e "\e[91mYou need to relog for the default shell changes to take effect\e[39m"
