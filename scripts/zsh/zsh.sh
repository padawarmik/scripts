#!/bin/bash

set -euo pipefail

K9S_VERSION=v0.32.5
RAW_BASE_URL="${RAW_BASE_URL:-https://raw.githubusercontent.com/padawarmik/scripts/main/scripts/zsh}"
ZSH_CONFIG_SOURCE_DIR="${ZSH_CONFIG_SOURCE_DIR:-}"
ZSH_CONFIG_DIR="${ZSH_CONFIG_DIR:-${XDG_CONFIG_HOME:-${HOME}/.config}/zsh}"
LOCAL_BIN_DIR="${LOCAL_BIN_DIR:-${HOME}/.local/bin}"

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

apt_package_available() {
  apt-cache show "$1" >/dev/null 2>&1
}

install_apt_packages_if_available() {
  local packages=()
  local package

  for package in "$@"; do
    if apt_package_available "${package}"; then
      packages+=("${package}")
    else
      printf "Skipping optional apt package not available in enabled repositories: %s\n" "${package}"
    fi
  done

  if ((${#packages[@]} > 0)); then
    "${SUDO[@]}" apt-get install -y "${packages[@]}"
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

install_cli_tools() {
  local package_manager="$1"

  case "${package_manager}" in
    apt)
      printf "Installing recommended CLI tools with apt when available\n"
      install_apt_packages_if_available neovim eza bat fd-find fzf zoxide starship ripgrep
      ensure_debian_command_wrappers
      ;;
    pacman)
      printf "Installing recommended CLI tools with pacman\n"
      "${SUDO[@]}" pacman -Syu --needed --noconfirm neovim eza bat fd fzf zoxide starship ripgrep
      ;;
    *)
      printf "Unsupported package manager. This script supports Debian-like (apt) and Arch-like (pacman) distributions.\n" >&2
      exit 1
      ;;
  esac
}

ensure_debian_command_wrappers() {
  mkdir -p "${LOCAL_BIN_DIR}"

  if ! command_exists bat && command_exists batcat; then
    cat > "${LOCAL_BIN_DIR}/bat" <<'WRAPPER'
#!/bin/sh
exec batcat "$@"
WRAPPER
    chmod +x "${LOCAL_BIN_DIR}/bat"
    printf "Created bat wrapper at %s\n" "${LOCAL_BIN_DIR}/bat"
  fi

  if ! command_exists fd && command_exists fdfind; then
    cat > "${LOCAL_BIN_DIR}/fd" <<'WRAPPER'
#!/bin/sh
exec fdfind "$@"
WRAPPER
    chmod +x "${LOCAL_BIN_DIR}/fd"
    printf "Created fd wrapper at %s\n" "${LOCAL_BIN_DIR}/fd"
  fi
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

  if read -r -p "${prompt}" -n 1 answer 2>/dev/null < /dev/tty; then
    printf "\n" > /dev/tty 2>/dev/null || true
  else
    printf "%sN\n" "${prompt}"
  fi

  [[ ${answer} =~ ^[Yy]$ ]]
}

ensure_xdg_zsh_dirs() {
  mkdir -p \
    "${ZSH_CONFIG_DIR}" \
    "${XDG_STATE_HOME:-${HOME}/.local/state}/zsh" \
    "${XDG_CACHE_HOME:-${HOME}/.cache}/zsh" \
    "${LOCAL_BIN_DIR}" \
    "${HOME}/.aliases"
}

backup_file() {
  local path="$1"
  local backup

  if [[ -e "${path}" || -L "${path}" ]]; then
    backup="${path}.bak.$(date +%Y%m%d%H%M%S)"
    mv "${path}" "${backup}"
    printf "Backed up %s to %s\n" "${path}" "${backup}"
  fi
}

install_config_file() {
  local name="$1"
  local destination="${ZSH_CONFIG_DIR}/${name}"
  local source="${ZSH_CONFIG_SOURCE_DIR:+${ZSH_CONFIG_SOURCE_DIR}/${name}}"

  if [[ -n "${ZSH_CONFIG_SOURCE_DIR}" && -f "${source}" ]]; then
    if [[ -f "${destination}" ]] && cmp -s "${source}" "${destination}"; then
      return
    fi
    backup_file "${destination}"
    cp "${source}" "${destination}"
  else
    if ! command_exists curl; then
      printf "curl is required to download %s. Install curl or run with ZSH_CONFIG_SOURCE_DIR.\n" "${name}" >&2
      exit 1
    fi
    if [[ -f "${destination}" ]]; then
      backup_file "${destination}"
    fi
    curl -fsSL "${RAW_BASE_URL}/${name}" -o "${destination}"
  fi
}

configure_zdotdir() {
  local zshenv="${HOME}/.zshenv"
  local begin="# >>> padawarmik zsh setup >>>"
  local end="# <<< padawarmik zsh setup <<<"
  local block

  block="${begin}
export XDG_CONFIG_HOME=\"\${XDG_CONFIG_HOME:-\${HOME}/.config}\"
export ZDOTDIR=\"\${ZDOTDIR:-\${XDG_CONFIG_HOME}/zsh}\"
[[ -r \"\${ZDOTDIR}/.zshenv\" ]] && source \"\${ZDOTDIR}/.zshenv\"
${end}"

  touch "${zshenv}"
  if grep -Fq "${begin}" "${zshenv}"; then
    local tmp
    tmp="$(mktemp)"
    awk -v begin="${begin}" -v end="${end}" -v block="${block}" '
      $0 == begin { print block; in_block=1; next }
      $0 == end { in_block=0; next }
      !in_block { print }
    ' "${zshenv}" > "${tmp}"
    mv "${tmp}" "${zshenv}"
  else
    printf "\n%s\n" "${block}" >> "${zshenv}"
  fi
}

install_zsh_dotfiles() {
  local files=(.zshenv .zshrc fzf.zsh aliases.zsh bindings.zsh plugins.zsh prompt.zsh starship.toml)
  local file

  printf "Installing modular Zsh configuration into %s\n" "${ZSH_CONFIG_DIR}"
  ensure_xdg_zsh_dirs
  configure_zdotdir

  for file in "${files[@]}"; do
    install_config_file "${file}"
  done

  touch "${HOME}/.aliases/custom_aliases" "${HOME}/.aliases/customs"
}

main() {
  local package_manager
  local installed_recommended=false
  package_manager="$(detect_package_manager)"

  sleep 1
  printf "\n\n"
  printf "_______________________________________________________________________________"
  printf "\n\nYou are going to install a minimal, frameworkless zsh setup.\n"
  printf "Detected package manager: %s\n" "${package_manager:-unsupported}"
  printf "_______________________________________________________________________________"
  printf "\n\n"

  if prompt_yes_no "Do you want to install additional recommended software?[Yy/Nn] "; then
    install_base_packages "${package_manager}"
    install_cli_tools "${package_manager}"
    installed_recommended=true

    if prompt_yes_no "Do you want to install kubernetes tools?[Yy/Nn] "; then
      install_kubernetes_tools "${package_manager}"
    fi
  fi

  install_zsh_dotfiles

  if [[ "${installed_recommended}" == true ]]; then
    touch "${ZSH_CONFIG_DIR}/.enable-plugin-install"
  fi

  printf "\n\n"
  printf "The Zsh configuration has been installed. Restart your terminal to use it.\n"
  if command_exists zsh; then
    printf "You can run chsh -s '%s' to set zsh as your default shell.\n" "$(command -v zsh)"
  else
    printf "zsh is not installed. Install it before changing your default shell.\n"
  fi
  printf "You can add custom aliases to ~/.aliases/custom_aliases.\n"
  printf "To rerun this script run 'zsh-rerun'.\n"

  if [[ "${installed_recommended}" == false ]]; then
    printf "Recommended tools were not installed; the configuration will skip integrations for missing commands.\n"
  fi
}

if [[ "${BASH_SOURCE[0]:-$0}" == "$0" ]]; then
  main "$@"
fi
