# Prompt setup.

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
else
  PROMPT='%F{cyan}%n@%m%f:%F{blue}%~%f %# '
fi
