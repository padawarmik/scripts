# Optional aliases. Each alias is created only when its backing command exists.

if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons=auto --group-directories-first'
  alias ll='eza -lh --icons=auto --git --group-directories-first'
  alias la='eza -lah --icons=auto --git --group-directories-first'
  alias tree='eza --tree --icons=auto --group-directories-first'
fi

if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never'
elif command -v batcat >/dev/null 2>&1; then
  alias cat='batcat --paging=never'
fi

if command -v fd >/dev/null 2>&1; then
  alias find='fd'
elif command -v fdfind >/dev/null 2>&1; then
  alias find='fdfind'
fi

if command -v rg >/dev/null 2>&1; then
  alias grep='rg'
fi

alias diff='diff --color=auto'
alias -- -='cd -'

if command -v nvim >/dev/null 2>&1; then
  alias vim='nvim'
fi

if command -v git >/dev/null 2>&1; then
  alias gs='git status --short'
  alias ga='git add'
  alias gc='git commit'
  alias gp='git push'
  alias gl='git log --oneline --decorate --graph --all'
fi
