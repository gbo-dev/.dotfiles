# Startup prompts: show day, date, week #
date=$(date '+%A %b%e - Week %W: %H:%M')
echo "$date"

# zsh
source "$ZDOTDIR/.zsh_aliases"
source "$ZDOTDIR/fzf.zsh"
source "$ZDOTDIR/aliases.zsh"
source "$ZDOTDIR/plugins.zsh"
source "$ZDOTDIR/bindings.zsh"
source "$ZDOTDIR/shell.zsh"

# export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="gorgeous"
HIST_STAMPS="yyyy-mm-dd"
HISTSIZE=100000
SAVEHIST=100000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_SPACE # useful for secrets, prepend with space
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS

plugins=(git colored-man-pages colorize bun)

# Environment
export EDITOR=nvim
export PATH="\
$HOME/.local/bin:\
$HOME/.local/platform-tools:\
$HOME/bin:\
$HOME/.cargo/bin:\
$HOME/go/bin:\
$HOME/.opencode/bin:\
$HOME/.bun/bin:\
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

export COLORTERM=truecolor
export GTK_THEME=Adwaita:dark

# Rust / Cargo
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# zoxide
eval "$(zoxide init --cmd cd zsh)"

# Scripts
if [ -d "$HOME/.dotfiles/utils/" ]; then
  export PATH="$PATH:$HOME/.dotfiles/utils/"
  source "$HOME/.dotfiles/utils/functions.zsh"
fi

# ROCm library path for building with hipcc
export LIBRARY_PATH="\
/opt/rocm/lib:\
${LIBRARY_PATH}"

# bun
export BUN_INSTALL="$HOME/.bun"

# Enable interactive completion menu selection
zstyle ':completion:*' menu select

# Make completion case-insensitive
# Example: "doc" can complete to "Documents"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'  # lowercase input matches upper and lower

export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-${SHORT_HOST:-$HOST}-${ZSH_VERSION}"
source "$HOME/.oh-my-zsh/oh-my-zsh.sh"

# fzf key bindings (must be after compinit)
source <(fzf --zsh)

# Register ft completion (must be after compinit has run)
compdef _ft ft

source ~/.providers
