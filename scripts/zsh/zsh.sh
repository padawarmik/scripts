#!/bin/bash

set -euo pipefail

K9S_VERSION=v0.32.5
RAW_BASE_URL="https://raw.githubusercontent.com/padawarmik/scripts/main/scripts/zsh"

if [[ ${EUID} -eq 0 ]]; then
  SUDO=()
else
  SUDO=(sudo)
fi

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

detect_package_manager() {
  if command_exists apt-get; then
    echo "apt"
  elif command_exists pacman; then
    echo "pacman"
  else
    echo ""
  fi
}

install_base_packages() {
  local package_manager="$1"

  case "${package_manager}" in
    apt)
      printf "Updating apt package index\n"
      "${SUDO[@]}" apt-get update
      printf "Installing base packages with apt\n"
      "${SUDO[@]}" apt-get install -y curl zsh git ca-certificates wget tar gzip
      ;;
    pacman)
      printf "Updating system and installing base packages with pacman\n"
      "${SUDO[@]}" pacman -Syu --needed --noconfirm curl zsh git ca-certificates wget tar gzip
      ;;
    *)
      printf "Unsupported package manager. This script supports Debian-like (apt) and Arch-like (pacman) distributions.\n" >&2
      exit 1
      ;;
  esac
}

kubectl_arch() {
  case "$(uname -m)" in
    x86_64|amd64) echo "amd64" ;;
    aarch64|arm64) echo "arm64" ;;
    armv7l|armv7|armv6l|armv6) echo "arm" ;;
    *)
      printf "Unsupported architecture for kubectl: %s\n" "$(uname -m)" >&2
      exit 1
      ;;
  esac
}

k9s_arch() {
  case "$(uname -m)" in
    x86_64|amd64) echo "amd64" ;;
    aarch64|arm64) echo "arm64" ;;
    armv7l|armv7) echo "armv7" ;;
    *)
      printf "Unsupported architecture for k9s %s: %s\n" "${K9S_VERSION}" "$(uname -m)" >&2
      exit 1
      ;;
  esac
}

install_kubernetes_tools_apt() {
  local kube_arch
  local k9s_release_arch
  kube_arch="$(kubectl_arch)"
  k9s_release_arch="$(k9s_arch)"

  printf "Installing kubectl\n"
  curl -fsSLO "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/${kube_arch}/kubectl"
  "${SUDO[@]}" install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  rm -f kubectl

  printf "Installing Helm\n"
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

  printf "Installing k9s\n"
  curl -fsSLO "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_${k9s_release_arch}.tar.gz"
  tar -xf "k9s_Linux_${k9s_release_arch}.tar.gz" k9s
  "${SUDO[@]}" install -o root -g root -m 0755 k9s /usr/local/bin/k9s
  rm -f "k9s_Linux_${k9s_release_arch}.tar.gz" k9s
}

install_kubernetes_tools_pacman() {
  printf "Installing Kubernetes tools with pacman\n"
  "${SUDO[@]}" pacman -Syu --needed --noconfirm kubectl helm k9s
}

install_kubernetes_tools() {
  local package_manager="$1"

  case "${package_manager}" in
    apt) install_kubernetes_tools_apt ;;
    pacman) install_kubernetes_tools_pacman ;;
    *)
      printf "Unsupported package manager. This script supports Debian-like (apt) and Arch-like (pacman) distributions.\n" >&2
      exit 1
      ;;
  esac
}

prompt_yes_no() {
  local prompt="$1"
  local answer=""

  if [[ -r /dev/tty ]]; then
    read -r -p "${prompt}" -n 1 answer < /dev/tty
    printf "\n" > /dev/tty
  else
    printf "%sN\n" "${prompt}"
  fi

  [[ ${answer} =~ ^[Yy]$ ]]
}

download_zsh_config() {
  printf "Downloading Powerlevel10k and Zsh configuration\n"
  curl -fsSL "${RAW_BASE_URL}/.p10k.zsh" -o "${HOME}/.p10k.zsh"

  if [[ -f "${HOME}/.zshrc" ]]; then
    if prompt_yes_no "Your .zshrc file will be replaced. Do you want to continue?[Yy/Nn] "; then
      printf "Replacing .zshrc\n"
      rm -f "${HOME}/.zshrc"
      curl -fsSL "${RAW_BASE_URL}/.zshrc" -o "${HOME}/.zshrc"
    fi
  else
    curl -fsSL "${RAW_BASE_URL}/.zshrc" -o "${HOME}/.zshrc"
  fi
}

main() {
  local package_manager
  package_manager="$(detect_package_manager)"

  sleep 1
  printf "\n\n"
  printf "_______________________________________________________________________________"
  printf "\n\nYou are going to install zsh with some plugins.\n"
  printf "Detected package manager: %s\n" "${package_manager:-unsupported}"
  printf "_______________________________________________________________________________"
  printf "\n\n"

  if prompt_yes_no "Do you want to install additional recommended software?[Yy/Nn] "; then
    install_base_packages "${package_manager}"

    if prompt_yes_no "Do you want to install kubernetes tools?[Yy/Nn] "; then
      install_kubernetes_tools "${package_manager}"
    fi
  fi

  download_zsh_config

  mkdir -p "${HOME}/.aliases"
  touch "${HOME}/.aliases/custom_aliases"
  touch "${HOME}/.aliases/customs"

  printf "\n\n"
  printf "The work has been done, restart your terminal now to feel the power of the ZSH command prompt\nNow you can run chsh -s '%s' to set default shell.\n" "$(command -v zsh || echo zsh)"
  printf "You can now add custom aliases to the ~/.aliases/custom_aliases file.\n"
  printf "To rerun this script run 'zsh-rerun'\n"
}

if [[ "${BASH_SOURCE[0]:-$0}" == "$0" ]]; then
  main "$@"
fi
