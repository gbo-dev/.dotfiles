# fzf

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# Alt+C runs pp (pick.zsh) instead of fzf's directory picker.
export FZF_ALT_C_COMMAND=""
# Preview is hidden until toggled with Alt-P (see fzfrc).
export FZF_CTRL_T_OPTS="--preview '[ -d {} ] && ls -lA --group-directories-first --color=always {} || bat --color=always --style=numbers --line-range=:200 {}'"
export FZF_DEFAULT_OPTS_FILE="$HOME/.dotfiles/fzf/.config/fzf/fzfrc"

# cdi: replace zoxide's layout overrides and use the shared picker style.
# Zoxide supplies a tab-separated score and path; preview only the path.
export _ZO_FZF_OPTS="--height=60% --tiebreak=index --prompt='Directories ❯ ' --preview='ls -lA --group-directories-first --color=always {2..}' --color=prompt:#8ec07c,pointer:#8ec07c,hl+:#8ec07c:bold,input-label:#8ec07c,input-border:#8ec07c,bg+:#26332c"

# Must be after compinit
source <(fzf --zsh)

# Run a picker inline: the typed line stays put and nothing is echoed to the
# scrollback, so Esc leaves the prompt as it was. Starship builds the prompt in
# precmd, so rerun the hooks when the picker changed directory.
_inline_widget() {
  local before=$PWD f
  zle -I
  # ZLE's stdin is not the terminal. Reuse stdout's real tty for the editor.
  "$@" <&1
  if [[ $PWD != $before ]]; then
    for f in $precmd_functions; do $f; done
  fi
  zle reset-prompt
}

pp-widget() { _inline_widget pp }
zle -N pp-widget
bindkey -M emacs '\ec' pp-widget
bindkey -M vicmd '\ec' pp-widget
bindkey -M viins '\ec' pp-widget
