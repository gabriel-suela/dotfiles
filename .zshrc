export PATH=$HOME/bin:$HOME/.local/bin:$HOME/.local/scripts:${KREW_ROOT:-$HOME/.krew}/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"
export EDITOR=nvim

ZSH_THEME="robbyrussell"

plugins=(git)

alias task="go-task"
bindkey -s ^f "tmux-sessionizer\n"
alias sopsd="sops --decrypt" 
alias sopsdi="sops --decrypt --in-place" 
alias sopsei="sops --encrypt --in-place" 

gch() {
 git checkout "$(git branch --all | fzf --height=20% --reverse --info=inline | tr -d '[:space:]')"
}

eval "$(zoxide init zsh)"

# wsl only
[[ -n "$WT_SESSION" ]] && {
  chpwd() {
    echo -en '\e]9;9;"'
    wslpath -w "$PWD" | tr -d '\n'
    echo -en '"\x07'
  }
}

fpath+=($HOME/.zsh/pure)
autoload -U promptinit; promptinit
prompt pure

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

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/suela/google-cloud-sdk/path.zsh.inc' ]; then . '/home/suela/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/suela/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/suela/google-cloud-sdk/completion.zsh.inc'; fi
