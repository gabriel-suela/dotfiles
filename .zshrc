# -----------------------------------------------------
# INIT
# -----------------------------------------------------
export EDITOR=nvim
export PATH="/usr/lib/ccache/bin:$HOME/bin:$HOME/.local/bin:$HOME/.local/scripts:${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export HELM_DIFF_THREE_WAY_MERGE=true

# Autostart from tty if im running a WM without a LM
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
  exec startx
fi

plugins=(
    git
    sudo
    web-search
    archlinux
    copyfile
    copybuffer
    dirhistory
)

# dotbins - Add platform-specific binaries to PATH
source "$HOME/.dotbins/shell/zsh.sh"

#export PS1="\n$PS1"
# .zshrc
fpath+=($HOME/.zsh/pure)
autoload -U promptinit; promptinit
prompt pure


eval "$(zoxide init zsh)"

gcof() {
  
  git branch --all | sed -E 's|^\*? +||; s|remotes/origin/||' | sort -u | fzf --height 40% --border --prompt "Checkout branch: " | xargs git checkout

}


# main opts
setopt append_history inc_append_history share_history # better history
# on exit, history appends rather than overwrites; history is appended as soon as cmds executed; history shared across sessions
setopt auto_menu menu_complete # autocmp first menu match
setopt autocd # type a dir to cd
setopt auto_param_slash # when a dir is completed, add a / instead of a trailing space
setopt no_case_glob no_case_match # make cmp case insensitive
setopt globdots # include dotfiles
setopt extended_glob # match ~ # ^
setopt interactive_comments # allow comments in shell
unsetopt prompt_sp # don't autoclean blanklines
stty stop undef # disable accidental ctrl s

# cmp opts
zstyle ':completion:*' menu select # tab opens cmp menu
zstyle ':completion:*' special-dirs true # force . and .. to show in cmp menu
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} ma=0\;33 # colorize cmp menu
# zstyle ':completion:*' file-list true # more detailed list
zstyle ':completion:*' squeeze-slashes false # explicit disable to allow /*/ expansion


# history
HISTFILE=~/.history
HISTSIZE=100000
SAVEHIST=100000
HISTCONTROL=ignoreboth
setopt inc_append_history

bindkey "\e[A" history-beginning-search-backward
bindkey "\e[B" history-beginning-search-forward
autoload -U compinit && compinit

bindkey '^[[1;5C' emacs-forward-word
bindkey '^[[1;5D' emacs-backward-word
bindkey "^[[3~" delete-char

alias ls='ls --color=auto -hv'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -c=auto'

# -----------------------------------------------------
# Set-up FZF key bindings (CTRL R for fuzzy history finder)
# -----------------------------------------------------
source <(fzf --zsh)
bindkey -s "^F" "tmux-sessionizer\n"
alias lt='eza -a --tree --level=1 --icons'
alias v='$EDITOR'
alias vim='$EDITOR'
alias dbsync="GITHUB_TOKEN=$(gh auth token) dotbins sync"
alias k="kubectl"

# WSL
if [[ -n "$WSL_DISTRO_NAME" ]]; then
  export BROWSER="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
fi

# -----------------------------------------------------
# AUTOSTART
# -----------------------------------------------------
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# >>> mamba initialize >>>
# !! Contents within this block are managed by 'micromamba shell init' !!
export MAMBA_EXE='/home/suela/.local/bin/micromamba';
export MAMBA_ROOT_PREFIX='/home/suela/micromamba';
__mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    alias micromamba="$MAMBA_EXE"  # Fallback on help from micromamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/suela/google-cloud-sdk/path.zsh.inc' ]; then . '/home/suela/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/suela/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/suela/google-cloud-sdk/completion.zsh.inc'; fi
source /home/suela/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

. "$HOME/.local/bin/env"
