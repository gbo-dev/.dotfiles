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
$HOME/.local/bin:\
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

# Rust / Cargo
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# Node.js / nvm (lazy-loaded for faster shell startup)
export NVM_DIR="$HOME/.nvm"
_lazy_nvm() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}
nvm() { _lazy_nvm; nvm "$@"; }
node() { _lazy_nvm; node "$@"; }
npm() { _lazy_nvm; npm "$@"; }
npx() { _lazy_nvm; npx "$@"; }

# fzf
source <(fzf --zsh)
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=fg:-1,fg+:#f4ede0,bg:-1,bg+:#0a0a0a
  --color=hl:#48b08f,hl+:#6ce4be,info:#8788b0,marker:#00a6ff
  --color=prompt:#00d6ba,spinner:#a2b9b9,pointer:#5e7eff,header:#87afaf
  --color=border:#202020,label:#aeaeae,query:#d9d9d9
  --border="sharp" --border-label="" --preview-window="border-sharp" --prompt="> "
  --marker=">" --pointer="◆" --separator="-" --scrollbar="│"
  --layout="reverse" --info="right"'

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

# opencode
export PATH=/home/g/.opencode/bin:$PATH
