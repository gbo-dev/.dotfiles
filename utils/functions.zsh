# Place in utils to not clutter ~
pp() {
  local dir
  dir="$(pick project "${1:-}")" || return
  cd "$dir" || return
  nvim .
}

config() {
  local dir
  dir="$(pick config "${1:-}")" || return
  cd "$dir" || return
  nvim .
}

nws() {
  if [ "$#" -eq 0 ]; then
    echo "Usage: nws <dir1> <dir2> ..."
    return 1
  fi
  # 1. Create a temporary workspace directory
  local ws_dir=$(mktemp -d -t nvim-ws-XXXXXX)
  # 2. Symlink all provided directories into it
  for dir in "$@"; do
    # Ensure we get the absolute path
    local abs_dir=$(realpath "$dir")
    local base_name=$(basename "$dir")
    ln -s "$abs_dir" "$ws_dir/$base_name"
  done

  # 3. Open Neovim in the new workspace
  (cd "$ws_dir" && nvim .)
  # 4. Clean up the temporary workspace when Neovim closes
  # (This only deletes the symlinks, your actual files are safe!)
  rm -rf "$ws_dir"
}
