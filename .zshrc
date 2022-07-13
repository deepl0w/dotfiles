# GRML upstream
NOCOR=1
[[ -f ~/.zsh/grml-arch.zsh ]] && source ~/.zsh/grml-arch.zsh
prompt off
omz_lib_path="~/.zplug/repos/robbyrussell/oh-my-zsh/lib"
[[ -d ~/.zplug/repos/robbyrussell/oh-my-zsh/lib ]] && for f in ~/.zplug/repos/robbyrussell/oh-my-zsh/lib/*; do source $f; done

export PATH="$HOME/.local/share/gem/ruby/3.0.0/bin:$PATH"
export PYTHONPATH=$HOME/.local/lib/python2.7/site-packages:$HOME/.local/lib/python3.8/site-packages:$HOME/extra/python_modules
export ANDROID_HOME=$HOME/Android/Sdk
[[ -f ~/.profile ]] && source ~/.profile

# zplug plugins
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
if [ "$TERM_PROGRAM" != "vscode" ]; then
    if command -v nvim > /dev/null && \
            [[ -z $NVIM_INSIDE_ZSH ]]; then
                export NVIM_INSIDE_ZSH=1
                nvim -c "terminal"
    fi
fi

# Nvim host control
export PATH="$PATH:$HOME/.scripts/nvim"
if command -v nvr > /dev/null; then
    e() {
        nvr "$@"
    }
    tabe() {
        nvr -c "lcd $PWD | tabe $@"
    }
    sp() {
        nvr -c "lcd $PWD | sp $@"
    }
    vsp() {
        nvr -c "lcd $PWD | vsp $@"
    }
    man() {
        nvr -c "lcd $PWD | Man $@"
    }
fi

alias chfont="gconftool-2 --set /apps/gnome-terminal/profiles/Default/font --type string"
