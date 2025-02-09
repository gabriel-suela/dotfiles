#!/bin/bash

REPO_URL="git@github.com:gabriel-suela/dotfiles.git"
REPO_DIR="~/"

# Colors and Emoji
GREEN='\033[00;32m'
NC='\033[0m'
RED='\033[00;31m'
CYAN='\033[00;36m'
SEA="\\033[38;5;49m"
ARROW="${SEA}\xE2\x96\xB6${NC}"

logStep() {
    echo -e "${CYAN}==> ${1}${NC}"
}

# Clone the repository if it doesn't exist already
clone_repo() {
    if [[ ! -d "$REPO_DIR" ]]; then
        logStep "Cloning repository from $REPO_URL"
        git clone "$REPO_URL"
    else
        logStep "${GREEN}Repository already exists. Skipping clone.${NC}"
    fi
}


# Packages to install
download_packages() {
  common_packages=(
    "zoxide" "ripgrep" "tmux" "python" "python-pip" "lazygit" "lazydocker"
    "helm" "helmfile" "kustomize" "sops" "go-yq" "neovim" "yarn" "unzip"
    "go-task" "fzf" "docker" "docker-compose" "kind" "kubectl" "azure-cli"
    "cilium-cli" "k9s"
  )
  
  wsl_packages=(
    "zsh"
  )
  
  non_wsl_packages=(
    "tandem-chat" "stremio" "apple-fonts" "ttf-jetbrains-mono-nerd"
    "flameshot" "github-cli" "google-chrome" "bitwarden" "alacritty"
  )

  # Choose packages based on the environment (WSL or not)
  if grep -qi "microsoft" /proc/version || uname -r | grep -qi "microsoft"; then
    packages=("${common_packages[@]}" "${wsl_packages[@]}")
  else
    packages=("${common_packages[@]}" "${non_wsl_packages[@]}")
  fi
}

install_yay() {
    if ! command -v yay &>/dev/null; then
        logStep "Installing yay..."
        sudo pacman -S --needed base-devel git
        git clone https://aur.archlinux.org/yay.git
        cd yay || exit
        makepkg -si
        cd .. && rm -rf yay
    else
        logStep "${GREEN}yay is already installed${NC}"
    fi
}

update_yay() {
    logStep "Updating yay"
    yay -Syu
}

install_packages() {
    logStep "Installing packages"
    for package in "${packages[@]}"; do
        if ! yay -Q "$package" &>/dev/null; then
            yay -S --noconfirm "$package"
        else
            logStep "${GREEN}$package is already installed${NC}"
        fi
    done
}

create_symlinks() {
    logStep "Creating symlinks"

    # Detect if running in WSL
    if grep -qi "microsoft" /proc/version || uname -r | grep -qi "microsoft"; then
        # We're in WSL, so symlink only uncommented lines
        [[ -L ~/.config/.gitconfig ]] || ln -sf ~/dotfiles/.gitconfig ~/
        [[ -L ~/.config/.zshrc ]] || ln -sf ~/dotfiles/.zshrc ~/
        [[ -L ~/.config/starship/starship.toml ]] || ln -sf ~/dotfiles/starship/starship.toml ~/.config/
        [[ -L ~/.config/zshrc ]] || ln -sf ~/dotfiles/zshrc ~/.config/
        [[ -d ~/.config/tmux ]] || ln -sf ~/dotfiles/tmux/ ~/.config/
        mkdir -p ~/.local/scripts/
        [[ -L ~/.local/scripts/tmux-sessionizer ]] || ln -sf ~/dotfiles/scripts/tmux-sessionizer ~/.local/scripts/

    else
        # Not in WSL, symlink all files
        [[ -L ~/.config/i3 ]] || ln -sf ~/dotfiles/i3 ~/.config/
        [[ -L ~/.config/picom ]] || ln -sf ~/dotfiles/picom ~/.config/
        [[ -L ~/.config/dunst ]] || ln -sf ~/dotfiles/dunst ~/.config/
        [[ -L ~/.config/starship/starship.toml ]] || ln -sf ~/dotfiles/starship/starship.toml ~/.config/
        [[ -L ~/.config/rofi ]] || ln -sf ~/dotfiles/rofi ~/.config/
        [[ -d ~/.config/alacritty ]] || ln -sf ~/dotfiles/alacritty/ ~/.config/
        [[ -L ~/.config/.gitconfig ]] || ln -sf ~/dotfiles/.gitconfig ~/
        [[ -L ~/.config/.zshrc ]] || ln -sf ~/dotfiles/.zshrc ~/
        [[ -L ~/.config/zshrc ]] || ln -sf ~/dotfiles/zshrc ~/.config/
        [[ -d ~/.config/tmux ]] || ln -sf ~/dotfiles/tmux/ ~/.config/
        mkdir -p ~/.local/scripts/
        [[ -L ~/.local/scripts/tmux-sessionizer ]] || ln -sf ~/dotfiles/scripts/tmux-sessionizer ~/.local/scripts/
    fi
}

install_manual_bins() {
    logStep "Installing manual bins"
    
    # Install Google Cloud CLI
    logStep "Installing Google Cloud CLI"
    curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz
    tar -xf google-cloud-cli-linux-x86_64.tar.gz -C ~
    ~/google-cloud-sdk/install.sh
    if ! grep -q "google-cloud-sdk" ~/.zshrc; then
        echo 'export PATH="$HOME/google-cloud-sdk/bin:$PATH"' >> ~/.zshrc
        logStep "Added Google Cloud CLI to .zshrc"
    else
        logStep "${GREEN}Google Cloud CLI already in .zshrc${NC}"
    fi
    rm google-cloud-cli-linux-x86_64.tar.gz

    # Tmux TPM Installation
    logStep "Installing Tmux Plugin Manager (TPM)"
    if [[ ! -d ~/.tmux/plugins/tpm ]]; then
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
        logStep "TPM installed successfully"
    else
        logStep "${GREEN}TPM already installed${NC}"
    fi

    logStep "Installing Starship"
    curl -sS https://starship.rs/install.sh | sh

    logStep "Zsh Pure Theme"
    mkdir -p "$HOME/.zsh"
    git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
}

docker_without_sudo() {
    logStep "Adding user to docker group"
    sudo usermod -aG docker "$USER"
    echo -e "${ARROW} ${CYAN}Please reboot your computer to complete this setup.${NC}"
}

poping_sound() {
  echo "0" | sudo tee /sys/module/snd_hda_intel/parameters/power_save
  echo "options snd_hda_intel power_save=0" | sudo tee -a /etc/modprobe.d/audio_disable_powersave.conf
}

# Main Execution
download_packages
install_yay
update_yay
install_packages
create_symlinks
install_manual_bins
docker_without_sudo
poping_sound
set_default_shell_to_zsh
source_zshrc_if_exists

