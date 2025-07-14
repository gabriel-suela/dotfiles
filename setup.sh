#!/bin/bash

set -e

REPO_URL="git@github.com:gabriel-suela/dotfiles.git"
NVIM_DIR="$HOME/.config/nvim"

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
ARROW="\033[1;36m→${NC}"

IS_WSL=false
if grep -qi "microsoft" /proc/version || uname -r | grep -qi "microsoft"; then
    IS_WSL=true
fi

log()    { echo -e "${CYAN}==> $1${NC}"; }
ok()     { echo -e "${GREEN}✓ $1${NC}"; }
fail()   { echo -e "${RED}✗ $1${NC}"; }
run() {
    echo -e "${ARROW} ${CYAN}Running: $1${NC}"
    eval "$1" || { fail "Command failed: $1"; exit 1; }
}

install_yay() {
    if ! command -v yay &>/dev/null; then
        log "Installing yay (AUR helper)"
        run "sudo pacman -S --needed --noconfirm base-devel git"
        run "git clone https://aur.archlinux.org/yay.git /tmp/yay"
        run "cd /tmp/yay && makepkg -si --noconfirm"
        run "rm -rf /tmp/yay"
    else
        ok "yay already installed"
    fi
}

install_packages() {
    local common=(ripgrep tmux python python-pip neovim unzip docker docker-compose kubectl zsh yazi umu-launcher tandem-chat qbittorrent)
    local desktop=(flameshot bitwarden alacritty ttf-jetbrains-mono-nerd wine )
    local packages=("${common[@]}")
    $IS_WSL || packages+=("${desktop[@]}")

    log "Installing system packages"
    run "yay -Syu --noconfirm"
    for pkg in "${packages[@]}"; do
        yay -Qi "$pkg" &>/dev/null || run "yay -S --noconfirm $pkg"
    done
}


install_tools() {
    log "Installing additional tools"

    [ -d "$HOME/google-cloud-sdk" ] || {
        run "curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz"
        run "tar -xf google-cloud-cli-linux-x86_64.tar.gz -C \$HOME"
        run "$HOME/google-cloud-sdk/install.sh --quiet"
        run "rm google-cloud-cli-linux-x86_64.tar.gz"
        grep -q google-cloud-sdk "$HOME/.zshrc" || echo 'export PATH="$HOME/google-cloud-sdk/bin:$PATH"' >> "$HOME/.zshrc"
    }

    [ -d "$HOME/.zsh/pure" ] || run "git clone https://github.com/sindresorhus/pure.git $HOME/.zsh/pure"
    [ -d "$HOME/zsh-syntax-highlighting" ] || run "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/zsh-syntax-highlighting"
    [ -d "$HOME/.tmux/plugins/tpm" ] || run "git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm"
    command -v nvm &>/dev/null || run "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash"
}

post_install() {
    log "Post-install steps"
    groups | grep -q docker || {
        run "sudo usermod -aG docker $USER"
        run "systemctl enable docker"
        run "pip install --break-system-packages dotbins"
    }
    $IS_WSL || {
        [ -f "/etc/modprobe.d/audio_disable_powersave.conf" ] || echo "options snd_hda_intel power_save=0" | sudo tee /etc/modprobe.d/audio_disable_powersave.conf >/dev/null
    }
}

main() {
    install_yay
    install_packages
    install_tools
    post_install
    echo -e "\n${GREEN}Setup finished${NC}"
}

main
