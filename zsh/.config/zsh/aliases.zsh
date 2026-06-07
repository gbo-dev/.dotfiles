# Aliases

if command -v bat >/dev/null 2>&1; then
    alias cat="bat"
fi

if command -v fdfind >/dev/null 2>&1; then
    alias fd="fdfind"
fi

alias diff="diff --color=auto"
alias df="df -h"
alias ls="ls -F --color=auto"
alias ll="ls -lh --color=auto"
alias lsa="ls -la --color=auto"
alias count='find . -type f | wc -l'
alias hg='history | grep'
alias ..="cd .."
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias v="nvim"
alias t="tmux"
alias c="config"
alias oc="opencode"
alias todo="tuxedo ~/.todo.txt"
alias fe="fzf --exact -i"
alias fh="find . | fzf --exact -i"
alias gs="git status"
alias gd="git diff"
alias gl="git log --oneline --graph --decorate -n 30 --format=format:'%C(auto)%h %C(blue)%an %C(green)%ar%C(reset) %s'"
alias rpi="kitten ssh vpn@rpi"
alias lg="lazygit"
alias logout='loginctl terminate-session "$XDG_SESSION_ID"'
alias rrs="systemctl list-units --type=service --state=running" # (r)eview (r)unning (s)ervices
