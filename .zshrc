# GRML upstream
NOCOR=1
[[ -f ~/.zsh/grml-arch.zsh ]] && source ~/.zsh/grml-arch.zsh
prompt off
omz_lib_path="~/.zplug/repos/robbyrussell/oh-my-zsh/lib"
[[ -d ~/.zplug/repos/robbyrussell/oh-my-zsh/lib ]] && for f in ~/.zplug/repos/robbyrussell/oh-my-zsh/lib/*; do source $f; done

export PATH="$HOME/.local/share/gem/ruby/3.0.0/bin:$PATH"
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

# history
HISTSIZE=10000
SAVEHIST=10000

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE
setopt EXTENDED_HISTORY

HISTORY_IGNORE="(ls|cd|pwd|clear|exit|history|* --help)"

# Vars, aliases
export BROWSER='brave'
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

# AI Command Generator (model: $OLLAMA_MODEL, set in ~/.profile)
# The few-shot examples that keep output bare are baked into the model's
# TEMPLATE -- see ~/workspace/llm/Modelfile.fast-cli.
ai() {
  local user_prompt="$*"
  [[ -z "$user_prompt" ]] && { print -u2 "usage: ai <what you want to do>"; return 1; }

  # Use the HTTP API, not `ollama run`: the CLI writes spinner/cursor ANSI
  # escapes to stdout even when piped, and $(...) captures them as invisible
  # junk in the command buffer.
  local raw
  raw=$(curl -sS --max-time 120 "${OLLAMA_HOST_URL:-http://localhost:11434}/api/generate" \
        -d "$(jq -nc --arg m "${OLLAMA_MODEL:-fast-cli}" --arg p "$user_prompt" \
              '{model:$m, prompt:$p, stream:false}')" 2>/dev/null \
        | jq -r '.response // empty')
  [[ -z "$raw" ]] && { print -u2 "ai: no response from ${OLLAMA_MODEL:-fast-cli}"; return 1; }

  # Strip ANSI, code fences and comment lines, drop stray backticks, then keep
  # only the first non-empty line.
  local cmd
  cmd=$(print -r -- "$raw" \
    | sed -E 's/\x1b\[[0-9;?]*[a-zA-Z]//g' \
    | grep -vE '^[[:space:]]*```' \
    | grep -vE '^[[:space:]]*(#|//)' \
    | sed -E 's/^[[:space:]]*[`$][[:space:]]*//; s/[`[:space:]]+$//' \
    | grep -vE '^[[:space:]]*$' \
    | head -n 1)

  [[ -z "$cmd" ]] && { print -u2 "ai: no command found in:\n$raw"; return 1; }
  print -z -- "$cmd"
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

# Nvim as terminal multiplexer; set NVIM_AUTOSTART=0 (e.g. in ~/.profile) to opt out
# Only on a real TTY: apps that spawn `zsh -i` headless (e.g. Claude Desktop env probes) otherwise leak nvim
if [[ -o interactive && -t 0 && -t 1 ]] && [ "$TERM_PROGRAM" != "vscode" ] \
        && [[ $NVIM_AUTOSTART != 0 && -z $NVIM && -z $CLAUDECODE ]]; then
    command -v nvim > /dev/null && nvim -c "terminal"
fi

# Nvim host control
export PATH="$PATH:$HOME/.scripts/nvim:$HOME/tools"
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

    export EDITOR='nvr --remote-tab-wait'
fi

#if inside wsl
if command -v wslinfo > /dev/null; then
    git-bcdiff() {
      git difftool --no-prompt --extcmd="bcompare" "$@"
    }
fi

fgc() {
  local branch
  branch=$(git branch --all | sed 's/^[* ] //' | sort -u | fzf) || return
  git checkout "${branch#remotes/origin/}"
}

export TERMINFO=/usr/lib/terminfo

bindkey '^[|' zsh_gh_copilot_explain  # bind Alt+shift+\ to explain
bindkey '^[\' zsh_gh_copilot_suggest  # bind Alt+\ to suggest

alias chfont="gconftool-2 --set /apps/gnome-terminal/profiles/Default/font --type string"

export QNX_HOST=/home/deeplow/qnx/qnx710/host/linux/x86_64
export QNX_TARGET=/home/deeplow/qnx/qnx710/target/qnx7

export PATH="$HOME/.ghcup/bin:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:${QNX_HOST}/usr/bin:$PATH"
export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# The block above only knows /opt/miniconda3; fall back to a per-user install
if ! command -v conda > /dev/null; then
    for __conda_dir in ~/miniforge3 ~/miniconda3; do
        if [ -f "$__conda_dir/etc/profile.d/conda.sh" ]; then
            . "$__conda_dir/etc/profile.d/conda.sh"
            break
        fi
    done
    unset __conda_dir
fi

# conda only exists on some machines
if command -v conda > /dev/null; then
    conda activate base
fi
