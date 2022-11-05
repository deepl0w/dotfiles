## About
---
Full `zsh` and `nvim` configuration and a handy installation script for Arch based distributions.

This configuration lets you run your shell by default inside a `nvim` window with full vim controlls and comes with a bunch of useful plugins and extra configurations for `nvim` as well as for `zsh`.

If you only want the vim configuration you can skip anything containing something zsh related, but I recommend it because the configuration adds some pretty neat features.

`vim` doesn't come with a terminal emulator and there isn't a very good plugin for that AFAIK so you **need** `nvim` to run this buid. It works on top of `vim` so it is compatible with any configuration you might have had before.

## Installation
---

Clone the repo:

    git clone https://github.com/dennisplosceanu/dotfiles.git --recursive

If you're using the script you have to run it using (might prompt for sudo password):

    ./install.sh

### Manual Installation
---

#### Install NeoVim

    sudo pacman -S neovim

#### Install zsh

    sudo pacman -S zsh

Make `zsh` your default shell (you will have to relog with your user for this change to take effect):

    chsh -s `which zsh`

Create symbolic links to the files (or alternatively you could move the files in their appropriate location):

    ln -fs `realpath ./.zsh` ~
    ln -fs `realpath ./.zshrc` ~
    ln -fs `realpath ./.gdbinit` ~

    mkdir -p ~/.scripts
    ln -fs `realpath ./.scripts/nvim` ~/.scripts/

    ln -fs `realpath ./.config/nvim` ~/.config
    ln -fs `realpath ./.config/alacritty` ~/.config/
    ln -fs `realpath ./.config/nitrogen` ~/.config/
    ln -fs `realpath ./.config/polybar` ~/.config/

    ln -fs ~/.config/nvim/init.vim ~/.vimrc

You might need to install some `python` and `pip` if you don't have them:

    sudo pacman -S python python-ip

And if you want support for python plugins in `nvim`:

    pip install neovim

To install the `nvim` plugins run the following:

    nvim +PluginInstall +qall

Your current terminal font probably won't render some of the characters in the
vim-airline plugin correclty so you will need some new fonts.

    cd fonts
    ./install.sh

Enjoy :).

