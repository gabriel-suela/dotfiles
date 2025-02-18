# -----------------------------------------------------
# INIT
# -----------------------------------------------------
export EDITOR=nvim
export PATH="/usr/lib/ccache/bin/:$PATH"
export PATH=$HOME/bin:$HOME/.local/bin:$HOME/.local/scripts:${KREW_ROOT:-$HOME/.krew}/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"

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

# Set-up oh-my-zsh
source $ZSH/oh-my-zsh.sh
source /home/suela/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# .zshrc
fpath+=($HOME/.zsh/pure)
autoload -U promptinit; promptinit
prompt pure

eval "$(zoxide init zsh)"

gcof() {
  
  git branch --all | sed -E 's|^\*? +||; s|remotes/origin/||' | sort -u | fzf --height 40% --border --prompt "Checkout branch: " | xargs git checkout

}

# -----------------------------------------------------
# Set-up FZF key bindings (CTRL R for fuzzy history finder)
# -----------------------------------------------------
source <(fzf --zsh)
bindkey -s ^f "tmux-sessionizer\n"
alias lt='eza -a --tree --level=1 --icons'
alias v='$EDITOR'
alias vim='$EDITOR'
alias task="go-task"
alias sopsd="sops --decrypt" 
alias sopsdi="sops --decrypt --in-place" 
alias sopsei="sops --encrypt --in-place" 

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
