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
plugins=(git colored-man-pages colorize)

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

# Node.js / nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# zoxide
eval "$(zoxide init --cmd cd zsh)"

# Scripts
if [ -d "$HOME/.dotfiles/utils/" ]; then
  export PATH="$PATH:$HOME/.dotfiles/utils/"
  source "$HOME/.dotfiles/utils/functions.zsh"
fi

# Neovim
export PATH="/opt/nvim-linux-x86_64/bin:$PATH"
