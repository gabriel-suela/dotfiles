#!/bin/bash

# List of packages to install
packages=("alacritty" "oh-my-zsh-git" "nvm" "tmux" "flameshot" "tandem-chat" "steam" "github-cli" "lazygit" "lazydocker" "helm" "helmfile" "ripgrep" "sops" "go-yq" "sops" "neovim" "yarn" "unzip" "zsh" "go-task" "fzf" "docker" "docker-compose" "kind" "kubectl" "azure-cli" "cilium-cli" "k9s")

# Check if yay is installed
if ! command -v yay &>/dev/null; then
	echo "yay not found, installing yay..."
	# Install yay
	sudo pacman -S --needed base-devel git
	git clone https://aur.archlinux.org/yay.git
	cd yay
	makepkg -si
	cd ..
	rm -rf yay
else
	logStep "yay is already installed"
fi

# Update yay
yay -Syu

# Install packages
for package in "${packages[@]}"; do
	yay -S --noconfirm "$package"
done

logStep "All aur packages have been installed."

logStep "Installing manual bins"

logStep "gcloud"
curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz
tar -xf google-cloud-cli-linux-x86_64.tar.gz
./google-cloud-sdk/install.sh
rm google-cloud-cli-linux-x86_64.tar.gz
