#!/bin/bash

install_nvim() {
    if ! command -v nvim &> /dev/null; then
        add-apt-repository ppa:neovim-ppa/unstable
        apt-get update
        apt-get install neovim
    fi

    # update alternatives to run nvim with commands like "vi" or "vim"
    update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
    update-alternatives --config vi
    update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
    update-alternatives --config vim
    update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
    update-alternatives --config editor
}

install_zsh() {
    # install zsh if not already installed
    if ! command -v zsh &> /dev/null; then
        wget http://sourceforge.net/projects/zsh/files/zsh/5.2/zsh-5.2.tar.gz
        tar xzf zsh-5.2.tar.gz
        rm zsh-5.2.tar.gz
        cd zsh-5.2
        ./Util/preconfig
        ./configure
        make
        make install
        cd ..
        ln -fs /usr/local/bin/zsh /usr/bin/zsh
    fi

    # make zsh default shell
    chsh -s `which zsh`
}

create_links() {
    # install realpath if not already installed
    if ! command -v realpath &> /dev/null; then
        apt-get install realpath
    fi

    ln -fs `realpath ./.zsh` ~
    ln -fs `realpath ./.zshrc` ~
    ln -fs `realpath ./.vimrc` ~
    ln -fs `realpath ./.vim` ~

    mkdir -p ~/.scripts
    rm -rf ~/.scripts/nvim &>/dev/null
    ln -fs `realpath ./.scripts/nvim` ~/.scripts/

    mkdir -p ~/.config/nvim
    ln -fs ~/.vimrc ~/.config/nvim/init.vim
}

nvim_python() {
    if ! command -v pip &>/dev/null; then
        apt-get install python-dev python-pip python3-dev python3-pip    
    fi

    pip2 install neovim
    pip3 install neovim
}

install_fonts() {
    git clone https://github.com/powerline/fonts
    cd fonts
    ./install.sh
    cd ..
    # set the Hack font
    gconftool-2 --set /apps/gnome-terminal/profiles/Default/font --type string "Hack 11"
}


# install nvim and update alternatives
install_nvim
/bin/echo -e "\e[32mNeovim install....................DONE!\e[39m"
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
