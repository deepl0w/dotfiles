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

# nvim-treesitter compiles parsers with the tree-sitter CLI (>= 0.26.1). The release
# binary needs glibc 2.39 (Ubuntu 24.04+); on older releases build it with cargo.
install_tree_sitter_release() {
    if command -v tree-sitter &>/dev/null; then
        return
    fi
    local tmp
    tmp=$(mktemp -d)
    curl -fsSL https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz | gunzip > "$tmp/tree-sitter"
    chmod +x "$tmp/tree-sitter"
    if "$tmp/tree-sitter" --version &>/dev/null; then
        sudo install "$tmp/tree-sitter" /usr/local/bin/tree-sitter
    else
        if [ ! -x ~/.cargo/bin/cargo ]; then
            curl -fsSL --proto '=https' https://sh.rustup.rs | sh -s -- -y --profile minimal --no-modify-path
        fi
        ~/.cargo/bin/cargo install --locked --root ~/.local tree-sitter-cli
    fi
    rm -rf "$tmp"
}

install_nvim() {
    case $DISTRO in
        arch)
            pkg_install lua nodejs yarn neovim tree-sitter-cli
            yay -S neovim-remote
            ;;
        ubuntu)
            pkg_install lua5.4 nodejs npm yarnpkg
            install_nvim_release
            install_tree_sitter_release
            # neovim-remote isn't packaged; pipx puts nvr in ~/.local/bin
            pipx install --force neovim-remote
            ;;
    esac
}

install_nvim_plugins() {
    nvim --headless "+Lazy! sync" +qa
    # mason-lspconfig's ensure_installed runs async and a headless nvim quits first;
    # :MasonInstall blocks in headless mode (same servers as plugins/lsp.lua)
    nvim --headless "+MasonInstall clangd pyright lua-language-server" +qa
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
    # Load the plugin list from the real .zshrc; a set $NVIM keeps it from starting
    # nvim, and a closed stdin answers its "Install? [y/N]" prompt.
    NVIM=skip zsh -ic 'zplug install' </dev/null
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
