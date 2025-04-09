#!/usr/bin/env zsh

typeset -A config_map=(
  "alacritty" "$HOME/.dotfiles/.config/alacritty"
  "ghostty"   "$HOME/.dotfiles/.config/ghostty/config"
  "kitty"     "$HOME/.dotfiles/.config/kitty"
  "nvim"      "$HOME/.dotfiles/.config/nvim"
  "tmux"      "$HOME/.dotfiles/.config/tmux/.tmux.conf"
  "bash"      "$HOME/.dotfiles/.bashrc"
  "zsh"       "$HOME/.dotfiles/.zshrc"
  "config"    "$HOME/.dotfiles/utilities/shell-scripts/config-selector.sh"
)

config() {
  # Declare all variables as local
  local OPEN_EDITOR=true selection config_path config_dir

  if [[ "$1" == "dir" || "$1" == "-d" ]]; then
    OPEN_EDITOR=false
    shift
  fi

  # Selection process
  if [ -z "$1" ]; then
    if command -v fzf &>/dev/null; then
      selection=$(printf "%s\n" "${(@k)config_map}" | fzf --prompt="Select config: ")
    else
      echo "Select a config:"
      select selection in "${(@k)config_map}"; do
        [ -n "$selection" ] && break
      done
    fi
  else
    # Sanitize user-provided input
    selection="${1//[^a-zA-Z0-9_-]/}"  # Strip invalid characters
    [ -z "$selection" ] && { echo "Invalid config name" >&2; return 1 }
  fi

  # Validate selection exists
  if [ -z "$selection" ] || ! (( ${+config_map[$selection]} )); then
    echo "Error: Invalid config '$selection'" >&2
    return 1
  fi

  # Resolve path
  config_path=${config_map[$selection]}
  [ -z "$config_path" ] && { echo "Path not found for '$selection'" >&2; return 1 }

  # Handle navigation
  if [ -d "$config_path" ]; then
    cd "$config_path" || { echo "Failed to navigate to directory" >&2; return 1 }
    echo "Navigated to $config_path"
  else
    config_dir=$(dirname "$config_path")
    cd "$config_dir" || { echo "Failed to navigate to parent directory" >&2; return 1 }
    echo "Navigated to $config_dir"
  fi

  # Open editor if requested
  if $OPEN_EDITOR; then
    if [ -d "$config_path" ]; then
      ${EDITOR:-nvim} . || echo "Failed to open editor" >&2
    else
      ${EDITOR:-nvim} "$config_path" || echo "Failed to open file" >&2
    fi
  fi
}

# Zsh completion
_config-autocomplete() {
  local -a config_names
  config_names=("${(@k)config_map}")
  _arguments "1: :(${config_names[*]})"
}

compdef _config-autocomplete config
