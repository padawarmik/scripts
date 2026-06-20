# Key bindings and plugin-related settings. Safe when optional plugins are absent.

bindkey -e
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^[[5D' backward-word
bindkey '^[[5C' forward-word

# zsh-vi-mode settings are consumed only if the plugin is loaded.
ZVM_CURSOR_STYLE_ENABLED=true
ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
ZVM_VI_HIGHLIGHT_BACKGROUND=none

if command -v fzf >/dev/null 2>&1 && command -v fd >/dev/null 2>&1; then
  fzf-file-widget-no-hidden() {
    local selected
    selected=$(fd --type f --strip-cwd-prefix --exclude .git | fzf) || return
    LBUFFER+="${selected}"
    zle reset-prompt
  }
  zle -N fzf-file-widget-no-hidden
  bindkey '^F' fzf-file-widget-no-hidden
fi

if [[ ${+widgets[autosuggest-toggle]} -eq 1 ]]; then
  bindkey '^\\' autosuggest-toggle
fi

if [[ ${+widgets[history-substring-search-up]} -eq 1 ]]; then
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
fi
