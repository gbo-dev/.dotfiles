# Startup prompts: show day, date, week #
date=$(date '+%A %b%e - Week %W: %H:%M')
echo "$date"

# Aliases
source ~/.zsh_aliases

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="eastwood"
HIST_STAMPS="yyyy-mm-dd"

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
plugins=(git colored-man-pages colorize zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# Environment
export EDITOR=nvim
export PATH="\
$PATH:\
$HOME/.local/bin:\
$HOME/bin:\
$HOME/.cargo/bin:\
$HOME/go/bin:\
/usr/local/bin:\
/usr/local/go/bin:\
/usr/local/sbin:\
/usr/local/games:\
/usr/sbin:\
/usr/bin:\
/usr/games:\
/sbin:\
/bin:\
/snap/bin:\
/snap/bin:\
/opt/nvim-linux64/bin:"

export COLORTERM=truecolor

# Rust / Cargo
source "$HOME/.cargo/env"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# zoxide
eval "$(zoxide init --cmd cd zsh)"

# Scripts
if [ -f "$HOME/.dotfiles/shared/utilities/shell-scripts/config-selector.sh" ]; then
  source "$HOME/.dotfiles/shared/utilities/shell-scripts/config-selector.sh"
fi
