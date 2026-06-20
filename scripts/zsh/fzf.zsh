# fzf tuning. Loaded only when fzf is available.

if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --hidden --strip-cwd-prefix --exclude .git'
  export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --strip-cwd-prefix --exclude .git'
elif command -v fdfind >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fdfind --hidden --strip-cwd-prefix --exclude .git'
  export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
  export FZF_ALT_C_COMMAND='fdfind --type d --hidden --strip-cwd-prefix --exclude .git'
fi

local preview_cmd=''
if command -v bat >/dev/null 2>&1; then
  preview_cmd='bat --color=always --style=numbers --line-range=:500 {}'
elif command -v batcat >/dev/null 2>&1; then
  preview_cmd='batcat --color=always --style=numbers --line-range=:500 {}'
elif command -v sed >/dev/null 2>&1; then
  preview_cmd='sed -n "1,200p" {}'
fi

if [[ -n "${preview_cmd}" ]]; then
  export FZF_CTRL_T_OPTS="--preview '${preview_cmd}' --bind 'ctrl-/:change-preview-window(down|hidden|)'"
fi

export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:-} --height 40% --layout=reverse --border --info=inline"
