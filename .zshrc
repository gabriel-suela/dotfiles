export PATH="$HOME/bin:/usr/local/bin:$PATH:/home/suela/.local/bin:~/local/bin:${KREW_ROOT:-$HOME/.krew}/bin"
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git)

source $ZSH/oh-my-zsh.sh


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/suela/google-cloud-sdk/path.zsh.inc' ]; then . '/home/suela/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/suela/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/suela/google-cloud-sdk/completion.zsh.inc'; fi

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

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
