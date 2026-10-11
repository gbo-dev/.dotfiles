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
