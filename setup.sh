#!/usr/bin/env bash

set -euo pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log() { printf '%b==> %s%b\n' "${CYAN}" "$1" "${NC}"; }
ok() { printf '%b✓ %s%b\n' "${GREEN}" "$1" "${NC}"; }
fail() { printf '%b✗ %s%b\n' "${RED}" "$1" "${NC}" >&2; }

run() {
  log "Running: $*"
  "$@"
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

is_wsl() {
  grep -qi microsoft /proc/version 2>/dev/null || uname -r | grep -qi microsoft
}

is_arch() {
  [[ -r /etc/arch-release ]]
}

ensure_yay() {
  has_cmd yay && { ok "yay already installed"; return; }

  if ! is_arch; then
    log "Skipping yay installation on non-Arch system"
    return
  fi

  log "Installing yay"
  run sudo pacman -S --needed --noconfirm base-devel git

  local tmp_dir
  tmp_dir="$(mktemp -d)"

  run git clone https://aur.archlinux.org/yay.git "${tmp_dir}/yay"
  (
    cd "${tmp_dir}/yay"
    run makepkg -si --noconfirm
  )
  rm -rf "${tmp_dir}"
}

install_arch_packages() {
  if ! is_arch; then
    log "Skipping package installation on non-Arch system"
    return
  fi

  if ! has_cmd yay; then
    fail "yay is required to install packages on Arch"
    return 1
  fi

  local common_packages=(
    ripgrep
    tmux
    python
    python-pip
    neovim
    unzip
    docker
    docker-compose
    kubectl
    zsh
    yazi
    fzf
    zoxide
  )

  local desktop_packages=(
    bitwarden
    alacritty
    ttf-cascadia-mono-nerd
    ttf-jetbrains-mono-nerd
    wine
    umu-launcher
    qbittorrent
    apple-fonts
  )

  local packages=("${common_packages[@]}")
  if ! is_wsl; then
    packages+=("${desktop_packages[@]}")
  fi

  log "Installing system packages with yay"
  run yay -Syu --noconfirm
  run yay -S --needed --noconfirm "${packages[@]}"
}

install_google_cloud_sdk() {
  [[ -d "${HOME}/google-cloud-sdk" ]] && { ok "google-cloud-sdk already installed"; return; }

  log "Installing Google Cloud SDK"

  local archive
  archive="$(mktemp --suffix=.tar.gz)"

  run curl -fsSL -o "${archive}" \
    https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz
  run tar -xf "${archive}" -C "${HOME}"
  run "${HOME}/google-cloud-sdk/install.sh" --quiet
  rm -f "${archive}"
}

clone_repo_if_missing() {
  local repo_url="$1"
  local target_dir="$2"

  if [[ -d "${target_dir}" ]]; then
    ok "${target_dir} already present"
    return
  fi

  run git clone "${repo_url}" "${target_dir}"
}

install_tools() {
  install_google_cloud_sdk
  clone_repo_if_missing https://github.com/sindresorhus/pure.git "${HOME}/.zsh/pure"
  clone_repo_if_missing https://github.com/zsh-users/zsh-syntax-highlighting.git "${HOME}/zsh-syntax-highlighting"
  clone_repo_if_missing https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"

  if has_cmd nvm; then
    ok "nvm already installed"
  else
    log "Installing nvm"
    run bash -lc 'curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash'
  fi
}

post_install() {
  if has_cmd docker && ! id -nG "${USER}" | grep -qw docker; then
    run sudo usermod -aG docker "${USER}"
  fi

  if has_cmd systemctl && systemctl list-unit-files | grep -q '^docker\.service'; then
    run sudo systemctl enable docker
  fi

  if has_cmd pip; then
    run pip install --break-system-packages dotbins
  fi

  if ! is_wsl; then
    local audio_conf="/etc/modprobe.d/audio_disable_powersave.conf"
    if [[ ! -f "${audio_conf}" ]]; then
      printf 'options snd_hda_intel power_save=0\n' | sudo tee "${audio_conf}" >/dev/null
    fi
  fi
}

main() {
  ensure_yay
  install_arch_packages
  install_tools
  post_install
  ok "Setup finished"
}

main "$@"
