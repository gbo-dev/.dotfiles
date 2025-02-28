# Show day, date, week #, and time on startup
date=$(date '+%A %b%e - Week %W: %H:%M')
echo "$date"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="eastwood"

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
plugins=(git colored-man-pages colorize zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

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
alias c="config"
alias fe="fzf --exact -i"
alias fh="find . | fzf --exact -i"
alias gs="git status"
alias pissh="ssh vpn@192.168.0.144"
alias cat="bat"

export EDITOR=nvim
export PATH=$PATH:/usr/local/go/bin:$HOME/.local/bin:/opt/nvim-linux64/bin:$HOME/go/bin
export PATH=$HOME/go/bin:$PATH
export PATH=$HOME/bin:/usr/local/bin:$PATH

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export COLORTERM=truecolor

eval "$(zoxide init --cmd cd zsh)"

# Source config selector script 
if [ -f "$HOME/utilities/shell-scripts/config-selector.sh" ]; then
  source "$HOME/utilities/shell-scripts/config-selector.sh"
fi


# oh-my-zsh stuff
# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi
