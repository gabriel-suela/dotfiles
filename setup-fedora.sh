#!/usr/bin/env bash

set -euo pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { printf '%b==> %s%b\n' "${CYAN}" "$1" "${NC}"; }
ok() { printf '%b✓ %s%b\n' "${GREEN}" "$1" "${NC}"; }
warn() { printf '%b! %s%b\n' "${YELLOW}" "$1" "${NC}"; }
fail() { printf '%b✗ %s%b\n' "${RED}" "$1" "${NC}" >&2; }

run() {
  log "Running: $*"
  "$@"
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

run_shell() {
  local cmd="$1"
  log "Running: ${cmd}"
  bash -lc "${cmd}"
}

is_fedora() {
  [[ -r /etc/fedora-release ]] || grep -q '^ID=fedora$' /etc/os-release 2>/dev/null
}

has_nvidia_gpu() {
  has_cmd lspci && lspci | grep -qi 'NVIDIA'
}

secure_boot_enabled() {
  has_cmd mokutil && mokutil --sb-state 2>/dev/null | grep -qi 'enabled'
}

rpmfusion_enabled() {
  rpm -q rpmfusion-free-release rpmfusion-nonfree-release >/dev/null 2>&1
}

install_first_available() {
  local label="$1"
  shift

  local candidate
  for candidate in "$@"; do
    if sudo dnf install -y "${candidate}"; then
      ok "Installed ${label} with package ${candidate}"
      return 0
    fi
  done

  warn "Unable to install ${label}. Tried: $*"
  return 1
}

enable_rpmfusion() {
  if rpmfusion_enabled; then
    ok "RPM Fusion already configured"
    return 0
  fi

  log "Enabling RPM Fusion free and nonfree repositories"
  run_shell "sudo dnf install -y \
    https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-\$(rpm -E %fedora).noarch.rpm \
    https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-\$(rpm -E %fedora).noarch.rpm"
}

ensure_flathub() {
  has_cmd flatpak || install_first_available flatpak flatpak || return 1

  if flatpak remote-list --columns=name 2>/dev/null | grep -qx flathub; then
    ok "flathub already configured"
    return 0
  fi

  run flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
}

install_fedora_packages() {
  if ! is_fedora; then
    log "Skipping package installation on non-Fedora system"
    return
  fi

  log "Refreshing Fedora packages"
  run sudo dnf upgrade --refresh -y

  enable_rpmfusion

  local common_packages=(
    git
    curl
    tar
    gzip
    ripgrep
    tmux
    python3
    python3-pip
    neovim
    unzip
    zsh
    pciutils
    yazi
    fzf
    zoxide
  )

  log "Installing common packages with dnf"
  run sudo dnf install -y "${common_packages[@]}"

  install_first_available docker moby-engine docker || true
  install_first_available docker-compose docker-compose-plugin docker-compose || true
  install_first_available kubectl kubernetes-client kubectl || true

  local desktop_packages=(
    alacritty
    wine
    qbittorrent
  )

  log "Installing desktop packages with dnf"
  run sudo dnf install -y "${desktop_packages[@]}"

  install_first_available "Bitwarden desktop" bitwarden-desktop || {
    ensure_flathub || true
    if has_cmd flatpak; then
      run flatpak install -y flathub com.bitwarden.desktop
      ok "Installed Bitwarden via flatpak"
    else
      warn "Bitwarden was not installed because neither dnf nor flatpak provided it"
    fi
  }

  install_first_available "Cascadia Mono Nerd Font" cascadia-mono-nf-fonts cascadia-code-nf-fonts || \
    warn "Cascadia Nerd Font package not available in configured Fedora repositories"
  install_first_available "JetBrains Mono Nerd Font" jetbrains-mono-fonts-all jetbrains-mono-nf-fonts || \
    warn "JetBrains Mono Nerd Font package not available in configured Fedora repositories"
  install_first_available umu-launcher umu-launcher || \
    warn "umu-launcher package not available in configured Fedora repositories"
  install_first_available apple-fonts apple-fonts || \
    warn "apple-fonts package not available in configured Fedora repositories"
}

prepare_nvidia_secure_boot() {
  if ! secure_boot_enabled; then
    return 0
  fi

  log "Secure Boot detected; preparing akmods signing key"
  run sudo dnf install -y mokutil openssl

  if [[ ! -f /etc/pki/akmods/certs/public_key.der ]]; then
    run sudo kmodgenca -a
  else
    ok "akmods signing key already present"
  fi

  if mokutil --list-enrolled 2>/dev/null | grep -qi 'CN=akmods'; then
    ok "akmods Machine Owner Key already enrolled"
    return 0
  fi

  warn "Secure Boot requires MOK enrollment on the next reboot"
  log "mokutil will ask you to create a one-time password for firmware enrollment"
  run sudo mokutil --import /etc/pki/akmods/certs/public_key.der
}

enable_nvidia_services() {
  if ! has_cmd systemctl; then
    return 0
  fi

  local unit
  for unit in nvidia-suspend.service nvidia-resume.service nvidia-hibernate.service nvidia-persistenced.service; do
    if systemctl list-unit-files | grep -q "^${unit}"; then
      run sudo systemctl enable "${unit}"
    fi
  done
}

install_nvidia_drivers() {
  if ! has_nvidia_gpu; then
    log "No NVIDIA GPU detected; skipping NVIDIA driver installation"
    return
  fi

  log "Installing NVIDIA drivers for Fedora via RPM Fusion"
  enable_rpmfusion
  run sudo dnf install -y \
    akmods \
    gcc \
    kernel-devel \
    kernel-headers \
    kernel-modules-extra \
    akmod-nvidia \
    xorg-x11-drv-nvidia \
    xorg-x11-drv-nvidia-cuda \
    xorg-x11-drv-nvidia-power \
    xorg-x11-drv-nvidia-libs.i686 \
    nvidia-settings \
    nvidia-persistenced

  prepare_nvidia_secure_boot

  log "Building NVIDIA kernel modules with akmods"
  run sudo akmods --force --rebuild
  run sudo dracut --force

  enable_nvidia_services
  ok "NVIDIA driver installation complete"

  if secure_boot_enabled; then
    warn "Secure Boot is enabled: reboot, enroll the akmods key in MOK Manager, then reboot again"
  else
    warn "Reboot once so Fedora boots with the NVIDIA kernel modules instead of nouveau"
  fi
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
    run sudo systemctl start docker
  fi

  if has_cmd python3; then
    run python3 -m pip install --user --upgrade dotbins
  fi

  local audio_conf="/etc/modprobe.d/audio_disable_powersave.conf"
  if [[ ! -f "${audio_conf}" ]]; then
    printf 'options snd_hda_intel power_save=0\n' | sudo tee "${audio_conf}" >/dev/null
  fi
}

main() {
  if ! is_fedora; then
    fail "This script is intended for Fedora systems"
    exit 1
  fi

  install_fedora_packages
  install_nvidia_drivers
  install_tools
  post_install
  ok "Fedora setup finished"
}

main "$@"
