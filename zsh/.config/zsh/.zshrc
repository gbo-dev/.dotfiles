# Startup prompts: show day, date, week #
zmodload zsh/datetime
strftime '%A %b%e - Week %W: %H:%M' $EPOCHSECONDS

export EDITOR=nvim

# Set PATH before initializing integrations.
export PATH="\
$HOME/.opencode/bin:\
$HOME/.local/bin:\
$HOME/.local/platform-tools:\
$HOME/bin:\
$HOME/.cargo/bin:\
$HOME/go/bin:\
$HOME/.bun/bin:\
$HOME/.dotfiles/utils:\
$HOME/.local/share/npm/bin:\
/usr/local/bin:\
/usr/local/go/bin:\
/usr/local/sbin:\
/usr/sbin:\
/usr/bin:\
/sbin:\
/bin:\
/snap/bin:\
/opt/rocm/bin:\
$PATH"

# zsh
# ZSH_THEME="gorgeous"        # replaced by starship
HIST_STAMPS="yyyy-mm-dd"
HISTSIZE=100000
SAVEHIST=100000
HISTFILE="$HOME/.zsh_history"

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
# setopt HIST_IGNORE_SPACE # useful for secrets, prepend with space
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS

export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-${SHORT_HOST:-$HOST}-${ZSH_VERSION}"
# source "$HOME/.oh-my-zsh/oh-my-zsh.sh"

# omz used to run compinit; do it manually now that it's not sourced
autoload -Uz compinit
compinit -d "$ZSH_COMPDUMP"

# prompt
eval "$(starship init zsh)"

source "$ZDOTDIR/bindings.zsh"
source "$ZDOTDIR/fzf.zsh"
source "$ZDOTDIR/aliases.zsh"
source "$ZDOTDIR/plugins.zsh"
source "$ZDOTDIR/shell.zsh"
source "$ZDOTDIR/functions.zsh"
source "$ZDOTDIR/completion.zsh"

export COLORTERM=truecolor
export GTK_THEME=Adwaita:dark

# zoxide
eval "$(zoxide init --cmd cd zsh)"

# ROCm library path for building with hipcc
export LIBRARY_PATH="\
/opt/rocm/lib:\
${LIBRARY_PATH}"

# bun
export BUN_INSTALL="$HOME/.bun"

source ~/.providers
