# Bindings

# zsh auto-uses vi keybindings when $EDITOR contains "vi"; force emacs mode.
bindkey -e

# Ctrl+Left/Right move between words.
bindkey '\e[1;5D' backward-word
bindkey '\e[1;5C' forward-word

# Edit current command in editor buffer
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# Ctrl+Left/Right jump words (xterm and tmux/ghostty encodings)
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^[[5D' backward-word
bindkey '^[[5C' forward-word

# Ctrl+Enter arrives as a modifyOtherKeys/CSI-u sequence zsh doesn't know; treat as Enter
bindkey '^[[27;5;13~' accept-line
bindkey '^[[13;5u' accept-line
