# ~/.bashrc

# Only continue for interactive shells.
[[ $- != *i* ]] && return

export EDITOR=nvim
export TERMINAL=alacritty
export PATH="/usr/lib/ccache/bin:$HOME/bin:$HOME/.local/bin:$HOME/.local/scripts:${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export HELM_DIFF_THREE_WAY_MERGE=true
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:${PKG_CONFIG_PATH:-}"

# OnlineFix vars
export WINEDLLOVERRIDES="OnlineFix64=n;SteamOverlay64=n;winmm=n,b;dnet=n;steam\_api64=n"
export GAMEID=480

# Fix AppImage behavior on Wayland.
export QT_QPA_PLATFORM=xcb

# dotbins - Add platform-specific binaries to PATH
if [[ -r "$HOME/.dotbins/shell/bash.sh" ]]; then
  source "$HOME/.dotbins/shell/bash.sh"
fi

gcof() {
  git branch --all | sed -E 's|^\*? +||; s|remotes/origin/||' | sort -u | \
    fzf --height 40% --border --prompt "Checkout branch: " | xargs -r git checkout
}

__bash_tmux_sessionizer() {
  READLINE_LINE="tmux-sessionizer"
  READLINE_POINT=${#READLINE_LINE}
}

__bash_history_sync() {
  builtin history -a
  builtin history -n
}

# History behavior close to the zsh setup.
HISTFILE="$HOME/.history"
HISTSIZE=100000
HISTFILESIZE=100000
HISTCONTROL=ignoreboth
HISTIGNORE='ls:bg:fg:history:clear'
shopt -s histappend cmdhist lithist

# Shell behavior approximations for zsh options.
shopt -s autocd cdspell checkwinsize checkjobs complete_fullquote direxpand dirspell dotglob extglob globstar hostcomplete interactive_comments nocaseglob nocasematch progcomp promptvars
shopt -u force_fignore
stty stop undef 2>/dev/null

# Readline behavior.
bind 'set completion-ignore-case on'
bind 'set show-all-if-ambiguous on'
bind 'set show-all-if-unmodified on'
bind 'set menu-complete-display-prefix on'
bind 'set colored-stats on'
bind 'set colored-completion-prefix on'
bind 'set mark-directories on'
bind 'set mark-symlinked-directories on'
bind 'set visible-stats on'
bind 'TAB:menu-complete'
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
bind '"\e[1;5C": forward-word'
bind '"\e[1;5D": backward-word'
bind '"\e[3~": delete-char'
bind -x '"\C-f": __bash_tmux_sessionizer'

alias ls='ls --color=auto -hv'
alias terraform='tofu'
alias v='nvim'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -c=auto'
alias k='kubectl'

if [[ -n ${WSL_DISTRO_NAME:-} ]]; then
  export BROWSER="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
fi

# Bash completion support.
if [[ -r /usr/share/bash-completion/bash_completion ]]; then
  source /usr/share/bash-completion/bash_completion
fi

# fzf key bindings and completion.
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --bash)
fi

# Git prompt/completion should be loaded after fzf so git keeps its own completer.
if [[ -r /usr/share/git/completion/git-completion.bash ]]; then
  source /usr/share/git/completion/git-completion.bash
fi

if [[ -r /usr/share/git/completion/git-prompt.sh ]]; then
  source /usr/share/git/completion/git-prompt.sh
fi

# Prompt kept simple, with git branch when available.
if declare -F __git_ps1 >/dev/null 2>&1; then
  PS1='\[\e[0;36m\]\w\[\e[0m\]$(__git_ps1 " \[\e[0;33m\](%s)\[\e[0m\]")\n\$ '
else
  PS1='\[\e[0;36m\]\w\[\e[0m\]\n\$ '
fi

PROMPT_COMMAND="__bash_history_sync${PROMPT_COMMAND:+;$PROMPT_COMMAND}"

export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

if [[ -f "$HOME/google-cloud-sdk/path.bash.inc" ]]; then
  source "$HOME/google-cloud-sdk/path.bash.inc"
fi

if [[ -f "$HOME/google-cloud-sdk/completion.bash.inc" ]]; then
  source "$HOME/google-cloud-sdk/completion.bash.inc"
fi

export PATH="$PATH:$HOME/go/bin"

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi
