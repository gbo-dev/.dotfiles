# Startup prompts: show day, date, week #
date=$(date '+%A %b%e - Week %W: %H:%M')
echo "$date"

# zsh
ZSH_THEME="gorgeous"
HIST_STAMPS="yyyy-mm-dd"
HISTSIZE=100000
SAVEHIST=100000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
# setopt HIST_IGNORE_SPACE # useful for secrets, prepend with space
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS

plugins=(git colored-man-pages colorize bun)

export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-${SHORT_HOST:-$HOST}-${ZSH_VERSION}"
source "$HOME/.oh-my-zsh/oh-my-zsh.sh"

source "$ZDOTDIR/fzf.zsh"
source "$ZDOTDIR/aliases.zsh"
source "$ZDOTDIR/plugins.zsh"
source "$ZDOTDIR/bindings.zsh"
source "$ZDOTDIR/shell.zsh"
source "$ZDOTDIR/functions.zsh"
source "$ZDOTDIR/completion.zsh"

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

export COLORTERM=truecolor
export GTK_THEME=Adwaita:dark

# Rust / Cargo
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# zoxide
eval "$(zoxide init --cmd cd zsh)"

# ROCm library path for building with hipcc
export LIBRARY_PATH="\
/opt/rocm/lib:\
${LIBRARY_PATH}"

# bun
export BUN_INSTALL="$HOME/.bun"

source ~/.providers
