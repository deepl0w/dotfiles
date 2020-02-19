# GRML upstream
NOCOR=1
function compdef { }
[[ -d ~/.zplug/repos/robbyrussell/oh-my-zsh/lib ]] && for f in ~/.zplug/repos/robbyrussell/oh-my-zsh/lib/*; do source $f; done

# zplug plugins
export ADOTDIR=~/.zsh/.antigen-cache
export ZSH_CACHE_DIR=~/.zsh/.antigen-cache
[[ -f ~/.zplug/init.zsh ]] && source ~/.zplug/init.zsh
zplug "plugins/fzf", from:oh-my-zsh
zplug "plugins/wd", from:oh-my-zsh
zplug "plugins/z", from:oh-my-zsh
zplug "plugins/git", from:oh-my-zsh
zplug "plugins/common-aliases", from:oh-my-zsh
zplug "zsh-users/zsh-syntax-highlighting"
zplug "~/git/dotfiles/themes", from:local, as:theme
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi
# Then, source plugins and add commands to $PATH
zplug load

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
        [[ -w $NVIM_LISTEN_ADDRESS ]] && nvr -c "silent lcd! $PWD"
    }
    chpwd_functions+=( neovim_autocd )

    # quickest way to set nvim's cwd to home
    cd $HOME
fi

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
if command -v nvr > /dev/null; then
    e() {
        nvr "$@"
    }
    tabe() {
        nvr -p "$@"
    }
    sp() {
        nvr -c "sp $@"
    }
    vsp() {
        nvr -c "vsp $@"
    }
    man() {
        nvr -c "Man $@"
    }
fi

alias chfont="gconftool-2 --set /apps/gnome-terminal/profiles/Default/font --type string"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.zshrc_user ] && source ~/.zshrc_user
