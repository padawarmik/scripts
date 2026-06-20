# Tiny plugin loader: no framework or plugin manager required.

ZSH_PLUGIN_DIR="${ZSH_PLUGIN_DIR:-${ZDOTDIR:-${HOME}/.config/zsh}/plugins}"
mkdir -p "${ZSH_PLUGIN_DIR}"

typeset -A ZSH_PLUGINS
ZSH_PLUGINS=(
  fast-syntax-highlighting https://github.com/zdharma-continuum/fast-syntax-highlighting.git
  zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git
  zsh-history-substring-search https://github.com/zsh-users/zsh-history-substring-search.git
  zsh-vi-mode https://github.com/jeffreytse/zsh-vi-mode.git
)

ZSH_ENABLE_PLUGIN_INSTALL="${ZSH_ENABLE_PLUGIN_INSTALL:-}"
if [[ -z "${ZSH_ENABLE_PLUGIN_INSTALL}" && -r "${ZDOTDIR:-${HOME}/.config/zsh}/.enable-plugin-install" ]]; then
  ZSH_ENABLE_PLUGIN_INSTALL=1
fi

_zsh_plugin_source() {
  local name="$1"
  local dir="${ZSH_PLUGIN_DIR}/${name}"

  case "${name}" in
    fast-syntax-highlighting)
      [[ -r "${dir}/fast-syntax-highlighting.plugin.zsh" ]] && source "${dir}/fast-syntax-highlighting.plugin.zsh"
      ;;
    zsh-autosuggestions)
      [[ -r "${dir}/zsh-autosuggestions.zsh" ]] && source "${dir}/zsh-autosuggestions.zsh"
      ;;
    zsh-history-substring-search)
      [[ -r "${dir}/zsh-history-substring-search.zsh" ]] && source "${dir}/zsh-history-substring-search.zsh"
      ;;
    zsh-vi-mode)
      [[ -r "${dir}/zsh-vi-mode.plugin.zsh" ]] && source "${dir}/zsh-vi-mode.plugin.zsh"
      ;;
  esac
}

_zsh_plugin_install_missing() {
  local name="$1"
  local url="$2"
  local dir="${ZSH_PLUGIN_DIR}/${name}"

  if [[ ! -d "${dir}" ]]; then
    if [[ "${ZSH_ENABLE_PLUGIN_INSTALL}" == 1 ]] && command -v git >/dev/null 2>&1; then
      git clone --depth 1 "${url}" "${dir}"
    else
      return 0
    fi
  fi
}

for plugin_name plugin_url in ${(kv)ZSH_PLUGINS}; do
  _zsh_plugin_install_missing "${plugin_name}" "${plugin_url}"
  _zsh_plugin_source "${plugin_name}"
done

zplugin-update() {
  local dir

  if ! command -v git >/dev/null 2>&1; then
    print -u2 "git is not available; cannot update zsh plugins"
    return 0
  fi

  for dir in "${ZSH_PLUGIN_DIR}"/*(/N); do
    git -C "${dir}" pull --ff-only
  done
}
