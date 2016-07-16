## About
---
Full ```zsh``` and ```nvim``` configuration and a handy installation script that *might* work on *some* distributions of **Ubuntu** and **Mint**.

This configuration lets you run your shell by default inside a ```nvim``` window with full vim controlls and comes with a bunch of useful plugins and extra configurations for ```nvim``` as well as for ```zsh```.

If you only want the vim configuration you can skip anything containing something zsh related, but I recommend it because the configuration adds some pretty neat features.

```vim``` doesn't come with a terminal emulator and there isn't a very good plugin for that AFAIK so you **need** ```nvim``` to run this buid. It works on top of ```vim``` so it is compatible with any configuration you might have had before.
## Installation 
---

Clone the repo:

    git clone https://github.com/dennisplosceanu/dotfiles.git --recursive

If you're using the script you have to run it using ```sudo```:

    sudo ./install.sh

### Manual Installation
---

#### Install NeoVim

    sudo apt-repository ppa:neovim-ppa/unstable
    sudo apt-get update
    sudo apt-get install neovim

If you want ```vi``` and ```vim``` to start ```nvim```:

    update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
    update-alternatives --config vi
    update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
    update-alternatives --config vim
    update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
    update-alternatives --config editor

#### Install zsh

You need at least **zsh version 5.2.0** to not have errors in the config file.
Check if ```apt``` will install a ```zsh``` package with at least that version:

    sudo apt-cache policy zsh

If the version is ok then install using ```apt-get```:

    sudo apt-get install zsh

Otherwise you will have to compile it yourself.
Download the source (could be outdated by the time you read this):

    wget http://sourceforge.net/projects/zsh/files/zsh/5.2/zsh-5.2.tar.gz
    tar xzf zsh-5.2.tar.gz

And install (make sure you run preconfig from the project root directory like below **not** from Util):

    cd zsh-5.2
    ./Util/preconfig
    ./configure
    make
    make install
    ln -fs /usr/local/bin/zsh /usr/bin/zsh

Make ```zsh``` your default shell (you will have to relog with your user for this change to take effect):

    chsh -s `which zsh`

Create symbolic links to the files (or alternatively you could move the files in their appropriate location):

    ln -fs `realpath ./.zsh` ~
    ln -fs `realpath ./.zshrc` ~
    ln -fs `realpath ./.vimrc` ~
    ln -fs `realpath ./.vim` ~

    mkdir -p ~/.scripts
    ln -fs `realpath ./.scripts/nvim` ~/.scripts/

    mkdir -p ~/.config/nvim
    ln -fs ~/.vimrc ~/.config/nvim/init.vim

You might need to install some python packages if you don't already have them:

    sudo apt-get install python-dev python-pip python3-dev python3-pip

And if you want support for python plugins in ```nvim``` (you don't need both, you can choose depending on what python version do you use but running both installations  won't break anything):

    pip2 install neovim
    pip3 install neovim

To install the ```nvim``` plugins run the following:
    
    nvim +PluginInstall +qall

It will start ```nvim``` to install al the plugins in the config file and then exit.

Your current terminal font probably won't render some of the characters in the vim-airline plugin correclty so you will need some new fonts.

    git clone https://github.com/powerline/fonts
    cd fonts
    ./install.sh

Then pick a font you like in the terminal's profile settings (I recommend **Hack**). If you use gnome-terminal you can run:
    
    
    gconftool-2 --set /apps/gnome-terminal/profiles/Default/font --type string "<font> <size>"


Enjoy :).

