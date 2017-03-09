# GRML upstream
NOCOR=1
[[ -f ~/.zsh/grml-arch.zsh ]] && source ~/.zsh/grml-arch.zsh

# Antigen et plugins
export ADOTDIR=~/.zsh/.antigen-cache
export ZSH_CACHE_DIR=~/.zsh/.antigen-cache
[[ -f ~/.zsh/antigen-repo/antigen.zsh ]] && source ~/.zsh/antigen-repo/antigen.zsh
antigen bundle wd
antigen bundle sudo
antigen bundle z
antigen bundle git
antigen bundle dirhistory
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle common-aliases
antigen apply

# Vars, aliases
export BROWSER='firefox'
export EDITOR='vi'
export XDG_CONFIG_HOME=$HOME/.config

if command -v vim > /dev/null; then
    export EDITOR='vim'
    alias vi='vim'
fi

if command -v nvim > /dev/null; then
    export EDITOR='nvim'
    alias vi='nvim'
    alias vim='nvim'

    neovim_autocd() {
        [[ -w $NVIM_LISTEN_ADDRESS ]] && ~/.scripts/nvim/neovim-autocd.py
    }
    chpwd_functions+=( neovim_autocd )

    # quickest way to set nvim's cwd to home
    cd $HOME
fi

wd() {
  . /home/deeplow/.zsh/.antigen-cache/repos/https-COLON--SLASH--SLASH-github.com-SLASH-robbyrussell-SLASH-oh-my-zsh.git/plugins/wd/wd.sh
}

function weather {
    if [[ $# == 0 ]]; then
        curl -4 "http://wttr.in/bucharest"
    else
        curl -4 "http://wttr.in/$1"
    fi
}

function remake {
    make clean || return $?
    if [[ $# == 0 ]]; then
        make
    else
        make $@
    fi
}

# Zsh quick shorcut ref
zsh_hotkeys() {
cat << XXX
^a Beginning of line
^e End of line
^f Forward one character
^b Back one character
^h Delete one character
%f Forward one word
%b Back one word
^w Delete one word
^u Clear to beginning of line
^k Clear to end of line
^y Paste from Kill Ring
^t Swap cursor with previous character
%t Swap cursor with previous word
^p Previous line in history
^n Next line in history
^r Search backwards in history
^l Clear screen
^o Execute command but keep line
XXX
}

# Nvim as terminal multiplexer
if command -v nvim > /dev/null && \
    [[ -z $NVIM_LISTEN_ADDRESS ]]; then
        nvim -c "terminal"
fi

# Nvim host control
export PATH="$PATH:$HOME/.scripts/nvim"
if command -v nvim-host-cmd > /dev/null; then
    v() {
        if [[ $# == 0 ]]; then
            return 0;
        fi

        arg="$1"

        if [[ $# > 0 ]]; then
            shift
            for i in "$@"; do
                crt=`realpath $i | sed 's/ /\\ /g'`
                arg="$arg $crt"
            done
        fi
        nvim-host-cmd $arg
    }
    e() {
        if [[ $# == 1 ]]; then
            file=`realpath $1 | sed 's/ /\\ /g'`
        fi
        arg="edit $file"
        nvim-host-cmd $arg
    }
    tabe() {
        if [[ $# == 1 ]]; then
            file=`realpath $1 | sed 's/ /\\ /g'`
        fi
        arg="tabedit $file"
        nvim-host-cmd $arg
    }
    sp() {
        if [[ $# == 1 ]]; then
            file=`realpath $1 | sed 's/ /\\ /g'`
        fi
        arg="split $file"
        nvim-host-cmd $arg
    }
    vsp() {
        if [[ $# == 1 ]]; then
            file=`realpath $1 | sed 's/ /\\ /g'`
        fi
        arg="vsplit $file"
        nvim-host-cmd $arg
    }
    nerd() {
        if [[ $# == 1 ]]; then
            file=`realpath $1 | sed 's/ /\\ /g'`
        else
            file=`realpath .`
        fi
        arg='execute "Bdelete!" | NERDTree '$file
        nvim-host-cmd $arg
    }
    man() {
        if [[ $# == 1 ]]; then
            page=$1
        elif [[ $# == 2 ]]; then
            page="$1 $2"
        fi

        nvim-host-cmd "Man $page"
    }
fi

alias chfont="gconftool-2 --set /apps/gnome-terminal/profiles/Default/font --type string"

export ANDROID_SDK_ROOT="/home/deeplow/android-sdk-linux"
export PATH=$PATH:$ANDROID_SDK_ROOT/tools
