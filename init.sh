#!/bin/bash

function logStep() {
  echo -e "\n\e[1;32m$1\e[0m"
}

logStep "Again? Ok lets get started"

logStep "Instaling yay"
sudo pacman -Sw --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd
rm -rf /yay


if [[ -e "dotfiles" ]]; then
  logStep "dotfiles folder already exists"
else
  logStep "Cloning dotfiles"
  git clone https://github.com/gabriel-suela/dotfiles.git
fi

logStep "Cloning packer.nvim"
git clone --depth 1 https://github.com/wbthomason/packer.nvim .local/share/nvim/site/pack/packer/start/packer.nvim

logStep "Instaling packages..."

lst_file="packages.lst"
if [ ! -f "$lst_file" ]; then
  echo "Error: $lst_file not found. Please create the .lst file first."
  exit 1
fi

while IFS= read -r package; do
  echo "Downloading $package with yay"
  yay -Sw --noconfirm "$package"
done < "$lst_file"

logStep "Now, font!"
yay -Sw --noconfirm ttf-apple-emoji ttf-jetbrains-mono-nerd ttf-iosevka-nerd

logStep "Instaling micromamba"
"${SHELL}" <(curl -L micro.mamba.pm/install.sh)

logStep "Instaling OhMyZsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

logStep "Instaling TPM"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

logStep "Instaling gloogle cloud sdk"
git clone https://aur.archlinux.org/google-cloud-sdk.git

cd google-cloud-sdk/
pkgbuild is necessary
makepkg -si
cd ../
rm -rf google-cloud-sdk/
