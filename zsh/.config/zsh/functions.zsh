# Place in utils to not clutter ~
pp() {
  local dir
  dir="$(pick project "${1:-}")" || return
  cd "$dir" || return
  ${EDITOR:-nvim} .
}

# Print one conventional entry-point file for a config directory.
# A convention with multiple matches is deliberately ambiguous: fall back to
# opening the directory rather than guess which file an application reads.
_config_unique_file() {
  local dir="$1"
  shift

  local name candidate
  local -a matches=()
  for name in "$@"; do
    candidate="$dir/$name"
    [[ -f "$candidate" ]] && matches+=("$candidate")
  done

  case ${#matches[@]} in
    0) return 1 ;;
    1) print -r -- "${matches[1]}" ;;
    *) return 2 ;;
  esac
}

_config_main_file() {
  local dir="$1"
  local app="${dir:t}"
  local result

  _config_unique_file "$dir" \
    "$app.conf" "$app.toml" "$app.yaml" "$app.yml" "$app.json" \
    "$app.jsonc" "$app.ini" "$app.kdl"
  result=$?
  (( result == 0 )) && return
  (( result == 2 )) && return 1

  _config_unique_file "$dir" config
  result=$?
  (( result == 0 )) && return
  (( result == 2 )) && return 1

  _config_unique_file "$dir" \
    config.conf config.toml config.yaml config.yml config.json config.jsonc \
    config.ini config.kdl
  result=$?
  (( result == 0 )) && return
  (( result == 2 )) && return 1

  _config_unique_file "$dir" \
    settings.conf settings.toml settings.yaml settings.yml settings.json \
    settings.jsonc settings.ini settings.kdl
  result=$?
  (( result == 0 )) && return
  return 1
}

config() {
  local open_dir=false
  if [[ "$1" == "-d" ]]; then
    open_dir=true
    shift
  fi

  local query="${1:-}"
  local dir target
  dir="$(pick config "$query")" || return

  # A query means the caller selected an application deliberately, so prefer
  # its conventional entry point. Bare `c` retains directory-first browsing.
  if [[ "$open_dir" == false && -n "$query" ]]; then
    target="$(_config_main_file "$dir")"
  fi

  if [[ -n "$target" ]]; then
    ${EDITOR:-nvim} "$target"
  else
    cd "$dir" || return
    ${EDITOR:-nvim} .
  fi
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
