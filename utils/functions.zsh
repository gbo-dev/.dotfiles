pp() {
  local dir
  dir="$(pick project)" || return
  cd "$dir" || return
  nvim .
}

config() {
  local dir
  dir="$(pick config)" || return
  cd "$dir" || return
  nvim .
}
