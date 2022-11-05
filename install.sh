#!/bin/bash

update_packages() {
    if ! command -v pacman &> /dev/null; then
        sudo pacman -Syy
    fi
}

install_nvim() {
    if ! command -v nvim &> /dev/null; then
        sudo pacman -S neovim
    fi
}

install_zsh() {
    # install zsh if not already installed
    if ! command -v zsh &> /dev/null; then
        sudo pacman -S zsh
    fi

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
    ln -fs `realpath ./.vimrc` ~

    mkdir -p ~/.scripts
    rm -rf ~/.scripts/nvim &>/dev/null
    ln -fs `realpath ./.scripts/nvim` ~/.scripts/

    mkdir -p ~/.config/nvim
    ln -fs ~/.vimrc ~/.config/nvim/init.vim
    ln -fs `realpath ./nvim/lua` ~/.config/nvim/lua
}

nvim_python() {
    if ! command -v python &>/dev/null; then
        sudo pacman -S python python-pip
    fi

    pip install -U neovim
}

install_fonts() {
    cd fonts
    ./install.sh
    cd ..
}


# update packages
update_packages
/bin/echo -e "\e[32mUpdating package lists....................DONE!\e[39m"
# install nvim and update alternatives
install_nvim
/bin/echo -e "\e[32mInstalling Neovim.........................DONE!\e[39m"
# install python packages for neovim
nvim_python
/bin/echo -e "\e[32mNeovim python packages............\e[32mDONE!\e[39m"
# install zsh and set as default shell
install_zsh
/bin/echo -e "\e[32mZsh install.......................\e[32mDONE!\e[39m"
# create links from the repo directory to the required paths
create_links
/bin/echo -e "\e[32mCreate links......................\e[32mDONE!\e[39m"
# install special fonts for powerline, some fonts don't render some unicode
# characters the same way
install_fonts
# install vim plugins
vim +PluginInstall +qall

/bin/echo -e "\e[91mYou need to relog for the default shell changes to take effect\e[39m"
