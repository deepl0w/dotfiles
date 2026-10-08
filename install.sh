#!/bin/bash
set -e

# Paths below are relative to the repo root
cd "$(dirname "$(realpath "$0")")"

# Supported: arch (and Arch-based), ubuntu (and Debian-based)
detect_distro() {
    . /etc/os-release
    case " $ID $ID_LIKE " in
        *" arch "*) echo arch ;;
        *" ubuntu "*|*" debian "*) echo ubuntu ;;
        *)
            echo "Unsupported distribution: ${PRETTY_NAME:-$ID}" >&2
            exit 1
            ;;
    esac
}

DISTRO=$(detect_distro)

pkg_install() {
    case $DISTRO in
        arch) sudo pacman -S --needed "$@" ;;
        ubuntu) sudo apt-get install -y "$@" ;;
    esac
}

update_packages() {
    case $DISTRO in
        arch) sudo pacman -Syy ;;
        ubuntu) sudo apt-get update ;;
    esac
}

install_prerequisites() {
    case $DISTRO in
        arch)
            pkg_install git curl base-devel

            # yay lives in the AUR, so it has to be built with makepkg
            if ! command -v yay &>/dev/null; then
                local tmp
                tmp=$(mktemp -d)
                git clone https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
                (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
                rm -rf "$tmp"
            fi
            ;;
        ubuntu)
            pkg_install git curl build-essential pipx
            ;;
    esac
}

# The config needs Neovim >= 0.11 (vim.lsp.config), newer than Ubuntu's package, so
# install the official release build there instead.
install_nvim_release() {
    local arch
    case $(uname -m) in
        x86_64) arch=x86_64 ;;
        aarch64|arm64) arch=arm64 ;;
        *) echo "No Neovim release build for $(uname -m)" >&2; exit 1 ;;
    esac
    local dir=nvim-linux-$arch

    sudo rm -rf "/opt/$dir"
    curl -fL "https://github.com/neovim/neovim/releases/latest/download/$dir.tar.gz" | sudo tar -xz -C /opt
    sudo ln -sf "/opt/$dir/bin/nvim" /usr/local/bin/nvim
}

install_nvim() {
    case $DISTRO in
        arch)
            pkg_install lua nodejs yarn neovim
            yay -S neovim-remote
            ;;
        ubuntu)
            pkg_install lua5.4 nodejs npm yarnpkg
            install_nvim_release
            # neovim-remote isn't packaged; pipx puts nvr in ~/.local/bin
            pipx install --force neovim-remote
            ;;
    esac
}

install_nvim_plugins() {
    nvim --headless "+Lazy sync" +qa
}

install_zsh() {
    pkg_install zsh

    curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh

    # make zsh default shell; chsh can't change domain (LDAP/SSSD) accounts that
    # aren't in /etc/passwd, so don't abort the install over it
    if ! chsh -s "$(command -v zsh)"; then
        /bin/echo -e "\e[33mCouldn't change the login shell; start zsh from ~/.bashrc instead (e.g. exec zsh)\e[39m"
    fi
}

install_zsh_plugins() {
    # A plain `zsh -c` doesn't read .zshrc, and an interactive one would start nvim
    # from it, so load zplug and the plugin list from .zshrc by hand.
    zsh -c 'source ~/.zplug/init.zsh && eval "$(grep "^zplug " ~/.zshrc)" && zplug install'
}

create_links() {
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
}

nvim_python() {
    # pip --user is refused for the externally managed system python (PEP 668)
    case $DISTRO in
        arch) pkg_install python python-pynvim ;;
        ubuntu) pkg_install python3 python3-pynvim ;;
    esac
}

install_fonts() {
    cd fonts
    ./install.sh
    cd ..
}

install_pwndbg() {
    if command -v gdb &>/dev/null; then
        return
    fi
    case $DISTRO in
        arch) pkg_install gdb pwndbg ;;
        ubuntu)
            pkg_install gdb
            /bin/echo -e "\e[33mpwndbg isn't packaged for Ubuntu; .gdbinit expects it in /usr/share/pwndbg\e[39m"
            ;;
    esac
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
# install zplug plugins listed in the linked .zshrc
install_zsh_plugins
/bin/echo -e "\e[32mZsh plugins.................................\e[32mDONE!\e[39m"
# install nvim plugins
install_nvim_plugins
/bin/echo -e "\e[32mNeovim plugins..............................\e[32mDONE!\e[39m"
# install special fonts for powerline, some fonts don't render some unicode
# characters the same way
install_fonts

/bin/echo -e "\e[91mYou need to relog for the default shell changes to take effect\e[39m"
