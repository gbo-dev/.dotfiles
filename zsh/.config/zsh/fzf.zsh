# fzf

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# Alt+C runs pp (pick.zsh) instead of fzf's directory picker.
export FZF_ALT_C_COMMAND=""
# Preview is hidden until toggled with Alt-P (see fzfrc).
export FZF_CTRL_T_OPTS="--preview '[ -d {} ] && ls -lA --group-directories-first --color=always {} || bat --color=always --style=numbers --line-range=:200 {}'"
export FZF_DEFAULT_OPTS_FILE="$HOME/.dotfiles/fzf/.config/fzf/fzfrc"

# Must be after compinit
source <(fzf --zsh)

pp-widget() {
  zle push-line
  BUFFER="pp"
  zle accept-line
}
zle -N pp-widget
bindkey -M emacs '\ec' pp-widget
bindkey -M vicmd '\ec' pp-widget
bindkey -M viins '\ec' pp-widget
