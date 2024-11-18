# -----------------------------------------------------
# INIT
# -----------------------------------------------------
export EDITOR=nvim
export PATH="/usr/lib/ccache/bin/:$PATH"
export PATH=$HOME/bin:$HOME/.local/bin:$HOME/.local/scripts:${KREW_ROOT:-$HOME/.krew}/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"

plugins=(
    git
    sudo
    web-search
    archlinux
    copyfile
    copybuffer
    dirhistory
)
# Set-up oh-my-zsh
source $ZSH/oh-my-zsh.sh
# -----------------------------------------------------
# Set-up FZF key bindings (CTRL R for fuzzy history finder)
# -----------------------------------------------------
source <(fzf --zsh)
bindkey -s ^f "tmux-sessionizer\n"
eval "$(starship init zsh)"

alias ls='eza -a --icons'
alias ll='eza -al --icons'
alias lt='eza -a --tree --level=1 --icons'
alias v='$EDITOR'
alias vim='$EDITOR'
alias task="go-task"
alias sopsd="sops --decrypt" 
alias sopsdi="sops --decrypt --in-place" 
alias sopsei="sops --encrypt --in-place" 

# -----------------------------------------------------
# AUTOSTART
# -----------------------------------------------------
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba init' !!
export MAMBA_EXE='/home/suela/.local/bin/micromamba';
export MAMBA_ROOT_PREFIX='/home/suela/micromamba';
__mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    alias micromamba="$MAMBA_EXE"  # Fallback on help from mamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=1000000000
export SAVEHIST=1000000000
setopt EXTENDED_HISTORY
# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/suela/google-cloud-sdk/path.zsh.inc' ]; then . '/home/suela/google-cloud-sdk/path.zsh.inc'; fi
# The next line enables shell command completion for gcloud.
if [ -f '/home/suela/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/suela/google-cloud-sdk/completion.zsh.inc'; fi
# bun completions
[ -s "/home/suela/.bun/_bun" ] && source "/home/suela/.bun/_bun"
# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
source /home/suela/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
source /home/suela/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
