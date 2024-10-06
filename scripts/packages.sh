#!/bin/bash

# Colors
GREEN='\033[00;32m'
NC='\033[0m'
RED='\033[00;31m'
CYAN='\033[00;36m'
SEA="\\033[38;5;49m"

# Emoji
ARROW="${SEA}\xE2\x96\xB6${NC}"

# List of packages to install
packages=( "ripgrep" "xclip" "tmux" "python" "python-pip" "lazygit" "lazydocker" "helm" "helmfile" "kustomize" "ripgrep" "sops" "go-yq" "sops" "neovim" "yarn" "unzip" "zsh" "go-task" "fzf" "docker" "docker-compose" "kind" "kubectl" "azure-cli" "cilium-cli" "k9s")

logStep "Check if yay is installed"
if ! command -v yay &>/dev/null; then
	echo -e "${RED}yay not found, installing yay...${NC}"
	logStep "Install yay"
	sudo pacman -S --needed base-devel git
	git clone https://aur.archlinux.org/yay.git
	cd yay || exit
	makepkg -si
	cd ..
	rm -rf yay
else
	logStep "${GREEN}yay is already installed${NC}"
fi

logStep "Update yay"
yay -Syu

logStep "Install packages"
for package in "${packages[@]}"; do
	yay -S --noconfirm "$package"
done

logStep "All aur packages have been installed."

logStep "Creating symlinks"
ln -s ~/dotfiles/.gitconfig ~/.config/
ln -s ~/dotfiles/.zshrc ~/.config/
ln -s ~/dotfiles/alacritty/ ~/.config/
ln -s ~/dotfiles/tmux/ ~/.config/
mkdir ~/.local/scripts
ln -s ~/dotfiles/scripts/tmux-sessionizer ~/.local/scripts/

logStep "Installing manual bins"

logStep "Tmux TPM"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

logStep "Docker without sudo"
sudo usermod -aG docker "$USER"
echo -e "${ARROW} ${CYAN}Please reboot your computer to complete this setup.${NC}"
