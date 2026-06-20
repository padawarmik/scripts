# Minimal frameworkless Zsh configuration.
PZSHVER="2.0"

[[ -o interactive ]] || return 0

mkdir -p "${XDG_STATE_HOME:-${HOME}/.local/state}/zsh" "${XDG_CACHE_HOME:-${HOME}/.cache}/zsh"

# History
HISTSIZE=100000
SAVEHIST=100000
HISTFILE="${XDG_STATE_HOME:-${HOME}/.local/state}/zsh/history"
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt hist_expire_dups_first
setopt autocd
setopt no_beep
setopt numeric_glob_sort

# Completion
if autoload -Uz compinit; then
  zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
  zstyle ':completion:*' menu select
  compinit -d "${XDG_CACHE_HOME:-${HOME}/.cache}/zsh/zcompdump-${ZSH_VERSION}"
fi

# Optional shell integrations. Every block is guarded so missing tools are safe.
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion zsh)
fi

if command -v fzf >/dev/null 2>&1; then
  for fzf_file in \
    /usr/share/fzf/key-bindings.zsh \
    /usr/share/fzf/completion.zsh \
    /usr/share/doc/fzf/examples/key-bindings.zsh \
    /usr/share/doc/fzf/examples/completion.zsh \
    "${HOME}/.fzf.zsh"; do
    [[ -r "${fzf_file}" ]] && source "${fzf_file}" 2>/dev/null || true
  done
  eval "$(fzf --zsh 2>/dev/null || true)" 2>/dev/null || true
fi

for zsh_module in fzf aliases plugins bindings prompt; do
  [[ -r "${ZDOTDIR:-${HOME}/.config/zsh}/${zsh_module}.zsh" ]] && source "${ZDOTDIR:-${HOME}/.config/zsh}/${zsh_module}.zsh"
done

[[ -r "${HOME}/.aliases/custom_aliases" ]] && source "${HOME}/.aliases/custom_aliases"
[[ -r "${HOME}/.aliases/customs" ]] && source "${HOME}/.aliases/customs"

if [[ -d "${KREW_ROOT:-${HOME}/.krew}/bin" ]]; then
  export PATH="${KREW_ROOT:-${HOME}/.krew}/bin:${PATH}"
fi

alias zsh-rerun="curl -fsSL https://raw.githubusercontent.com/padawarmik/scripts/main/scripts/zsh/zsh.sh | bash"
