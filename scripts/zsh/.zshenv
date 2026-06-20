# Environment loaded from ~/.zshenv by the installer-managed ZDOTDIR block.

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-${HOME}/.local/state}"
export ZDOTDIR="${ZDOTDIR:-${XDG_CONFIG_HOME}/zsh}"

path=("${HOME}/.local/bin" $path)
export PATH

if command -v nvim >/dev/null 2>&1; then
  export EDITOR="nvim"
elif command -v vim >/dev/null 2>&1; then
  export EDITOR="vim"
else
  export EDITOR="vi"
fi
export VISUAL="${VISUAL:-${EDITOR}}"

if command -v tty >/dev/null 2>&1; then
  export GPG_TTY="$(tty 2>/dev/null || true)"
fi

export STARSHIP_CONFIG="${ZDOTDIR}/starship.toml"

if command -v bat >/dev/null 2>&1; then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
elif command -v batcat >/dev/null 2>&1; then
  export MANPAGER="sh -c 'col -bx | batcat -l man -p'"
else
  export MANPAGER="less -R"
fi
