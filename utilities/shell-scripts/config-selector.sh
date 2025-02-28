#!/usr/bin/env zsh

# Define config names and paths (order matters)
typeset -A config_map=(
  "nvim"      "$HOME/.dotfiles/.config/nvim"       # Path to your dotfiles repo
  "alacritty" "$HOME/.dotfiles/.config/alacritty"
  "kitty"     "$HOME/.dotfiles/.config/kitty"
  "zsh"       "$HOME/.dotfiles/.zshrc"
  "bash"      "$HOME/.dotfiles/.bashrc"
  "tmux"      "$HOME/.dotfiles/.config/tmux/.tmux.conf"
)

# Main function for the config command
config() {
  # Declare all variables as local
  local OPEN_EDITOR=false selection config_path config_dir

  # Parse arguments
  case "$1" in
    "edit"|"-e")
      OPEN_EDITOR=true
      shift
      ;;
    "list"|"-l")
      echo "Available configs:"
      for name path in "${(@kv)config_map}"; do
        printf "  %-10s → %s\n" "$name" "$path"
      done
      return
      ;;
  esac

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

  # Security: Verify path is within dotfiles directory
  if [[ "$config_path" != "$HOME/.dotfiles/"* ]]; then
    echo "Error: Path '$config_path' is outside dotfiles directory" >&2
    return 1
  fi

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
