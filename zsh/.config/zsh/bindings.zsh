# Bindings

# zsh auto-uses vi keybindings when $EDITOR contains "vi"; force emacs mode.
bindkey -e

# Edit current command in editor buffer
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line
