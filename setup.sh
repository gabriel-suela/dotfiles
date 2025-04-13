#!/bin/bash

# Configuration
REPO_URL="git@github.com:gabriel-suela/dotfiles.git"
REPO_DIR="$HOME/dotfiles"
NVIM_REPO="git@github.com:gabriel-suela/nvim.git"
NVIM_DIR="$HOME/.config/nvim"

# Colors and formatting
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'
ARROW="\033[1;36m→${NC}"

# Detect environment
IS_WSL=false
if grep -qi "microsoft" /proc/version || uname -r | grep -qi "microsoft"; then
    IS_WSL=true
fi

# Helper functions
log_step() {
    echo -e "${CYAN}==> ${1}${NC}"
}

log_success() {
    echo -e "${GREEN}✓ ${1}${NC}"
}

log_error() {
    echo -e "${RED}✗ ${1}${NC}"
}

run_cmd() {
    echo -e "${ARROW} ${CYAN}Running: ${1}${NC}"
    eval "$1"
    if [ $? -ne 0 ]; then
        log_error "Command failed: $1"
        exit 1
    fi
}

# Main functions
#

ssh_gen() {
  log_step "Generating new ssh key"
  ssh-keygen -t ed25519 -C "gscsuela@gmail.com"
}

clone_nvim() {
    if [ ! -d "$NVIM_DIR" ]; then
        log_step "Cloning nvim repository"
        run_cmd "git clone $NVIM_REPO $NVIM_DIR"
    else
        log_success "Dotfiles repository already exists"
    fi

}

clone_repo() {
    if [ ! -d "$REPO_DIR" ]; then
        log_step "Cloning dotfiles repository"
        run_cmd "git clone $REPO_URL $REPO_DIR"
    else
        log_success "Dotfiles repository already exists"
    fi
}

install_yay() {
    if ! command -v yay &> /dev/null; then
        log_step "Installing yay (AUR helper)"
        run_cmd "sudo pacman -S --needed --noconfirm base-devel git"
        run_cmd "git clone https://aur.archlinux.org/yay.git /tmp/yay"
        run_cmd "cd /tmp/yay && makepkg -si --noconfirm"
        run_cmd "rm -rf /tmp/yay"
    else
        log_success "yay is already installed"
    fi
}

install_packages() {
    local common_packages=(
        ripgrep tmux python python-pip neovim yarn unzip 
        docker docker-compose kubectl github-cli zsh
    )
    
    local wsl_packages=(
        # Additional WSL-specific packages
    )
    
    local desktop_packages=(
        flameshot google-chrome bitwarden alacritty
        ttf-jetbrains-mono-nerd arch-gaming-meta tandem-chat
    )

    local packages=("${common_packages[@]}")
    
    if $IS_WSL; then
        packages+=("${wsl_packages[@]}")
    else
        packages+=("${desktop_packages[@]}")
    fi

    log_step "Installing system packages"
    run_cmd "yay -Syu --noconfirm"
    
    for pkg in "${packages[@]}"; do
        if ! yay -Qi "$pkg" &> /dev/null; then
            run_cmd "yay -S --noconfirm $pkg"
        else
            log_success "$pkg is already installed"
        fi
    done
}

setup_symlinks() {
    log_step "Setting up configuration symlinks"

    # Common symlinks for both environments
    local common_links=(
        ".gitconfig"
        ".zshrc"
        ".gnupg/gpg-agent.conf"
        ".config/dotbins"
        ".gnupg/gpg.conf"
        ".config/tmux"
        ".local/scripts/tmux-sessionizer"
        ".local/scripts/sysmaintence.sh"
    )

    # Desktop-only symlinks
    if ! $IS_WSL; then
        common_links+=(
            ".config/i3"
            ".config/picom"
            ".config/dunst"
            ".config/rofi"
            ".config/alacritty"
        )
    fi

    for link in "${common_links[@]}"; do
        local src="$REPO_DIR/$link"
        local dest="$HOME/$link"

        # Make sure the destination directory exists
        run_cmd "mkdir -p $(dirname "$dest")"

        if [ ! -e "$dest" ]; then
            run_cmd "ln -sf $src $dest"
            log_success "Linked $dest -> $src"
        else
            log_success "$dest already exists"
        fi
    done
}

install_additional_tools() {
    log_step "Installing additional tools"
    
    # Google Cloud CLI
    if [ ! -d "$HOME/google-cloud-sdk" ]; then
        run_cmd "curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz"
        run_cmd "tar -xf google-cloud-cli-linux-x86_64.tar.gz -C $HOME"
        run_cmd "$HOME/google-cloud-sdk/install.sh --quiet"
        run_cmd "rm google-cloud-cli-linux-x86_64.tar.gz"
        
        if ! grep -q "google-cloud-sdk" "$HOME/.zshrc"; then
            echo 'export PATH="$HOME/google-cloud-sdk/bin:$PATH"' >> "$HOME/.zshrc"
        fi
    else
        log_success "Google Cloud SDK already installed"
    fi
    
    # Pure Zsh theme
    if [ ! -d "$HOME/.zsh/pure" ]; then
        run_cmd "git clone https://github.com/sindresorhus/pure.git $HOME/.zsh/pure"
    fi

    # zsh-syntax-highlighting
    if [ ! -d "$HOME/zsh-syntax-highlighting/" ]; then
      run_cmd "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME" 
    fi
    
    # Tmux Plugin Manager
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        run_cmd "git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm"
    fi
    
    # UV package manager
    if ! command -v uv &> /dev/null; then
        run_cmd "curl -LsSf https://astral.sh/uv/install.sh | sh"
    fi

    if ! command -v nvm &> /dev/null; then
      run_cmd "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash"
    fi
}

post_install_tasks() {
    log_step "Running post-install tasks"
    
    # Docker without sudo
    if ! groups | grep -q docker; then
        run_cmd "sudo usermod -aG docker $USER"
        log_success "Added user to docker group (requires logout/reboot)"
        run_cmd "systemctl enable docker"
        log_success "Docker service has been enabled by default (requires logout/reboot)"
    fi
    
    # Audio power saving fix (desktop only)
    if ! $IS_WSL; then
        if [ ! -f "/etc/modprobe.d/audio_disable_powersave.conf" ]; then
            echo "options snd_hda_intel power_save=0" | sudo tee /etc/modprobe.d/audio_disable_powersave.conf >/dev/null
        fi
    fi
}

main() {
    echo -e "\n${CYAN}Starting Arch Linux setup${NC}\n"
    
    ssh_gen
    clone_repo
    clone_nvim
    install_yay
    install_packages
    setup_symlinks
    install_additional_tools
    post_install_tasks
    
    echo -e "\n${GREEN}Setup completed successfully!${NC}"
    echo -e "${CYAN}Note: Some changes may require a logout/reboot to take effect.${NC}\n"
}

main
