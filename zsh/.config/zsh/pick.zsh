# Fuzzy pickers, split into sources, a UI, and actions:
#   _pick_src_<name>  prints candidates, one per line
#   _pick_list <name> the source, most recently picked first
#   _pick_ui <name>   interactive picker; set PICKER to swap it. tv uses the
#                     matching channel in ~/.config/television/cable when one
#                     exists; any other value is a stdin→stdout command
#                     (e.g. PICKER="fzy", "sk")
#   pick <name> [q]   prints one selection; with a query, takes the best match
# Adding a picker means adding a source plus a small action function.
# Kept free of side effects so tv channels can source it non-interactively.

_pick_mru_file() {
  print -r -- ${XDG_STATE_HOME:-$HOME/.local/state}/pick/$1
}

_pick_mru_add() {
  local f=$(_pick_mru_file $1)
  local -a old
  [[ -r $f ]] && old=( ${(f)"$(<$f)"} )
  local -aU mru=( $2 $old )
  mkdir -p ${f:h} && print -rl -- ${mru[1,200]} >| $f
}

_pick_list() {
  local f=$(_pick_mru_file $1)
  local -a mru cands=( ${(f)"$(_pick_src_$1)"} )
  [[ -r $f ]] && mru=( ${(f)"$(<$f)"} )
  # MRU entries that are still candidates first, then the source's own order.
  local -aU out=( ${mru:*cands} $cands )
  print -rl -- $out
}

_pick_src_projects() {
  local -aU dirs=( ~/dev/*(-/N) ~/.dotfiles(-/N) )
  local -aU ranked=( ${(f)"$(zoxide query -l 2>/dev/null)"} )
  # zoxide frecency first, then the rest in glob order.
  local -aU out=( ${ranked:*dirs} $dirs )
  print -rl -- $out
}

_pick_src_configs() {
  print -rl -- ~/.config/*(-/N) ~/.dotfiles(-/N)
}

_pick_ui() {
  case ${PICKER:-fzf} in
    fzf) _pick_list $1 | fzf --prompt="${(C)1} ❯ " --height=50% --tiebreak=index ;;
    tv)
      if [[ -f ${XDG_CONFIG_HOME:-$HOME/.config}/television/cable/$1.toml ]]; then
        tv $1
      else
        _pick_list $1 | tv --input-prompt="${(C)1} ❯ "
      fi
      ;;
    *) _pick_list $1 | ${=PICKER} ;;
  esac
}

pick() {
  local src=$1 query=$2 sel
  if (( ! $+functions[_pick_src_$src] )); then
    print -u2 "pick: unknown source: $src"
    return 2
  fi

  if [[ -n $query ]]; then
    # Index tiebreak keeps the list's order (MRU, frecency) among equal scores.
    sel=$(_pick_list $src | fzf --filter="$query" --tiebreak=index | head -n1)
    [[ -n $sel ]] || print -u2 "pick: no match for: $query"
  else
    sel=$(_pick_ui $src)
  fi
  [[ -n $sel ]] || return 1
  _pick_mru_add $src $sel
  print -r -- $sel
}

pp() {
  local dir
  dir=$(pick projects "$1") || return
  cd "$dir" && ${EDITOR:-nvim} .
}

# Print the conventional entry point of a config directory. Ambiguous matches
# within a tier fail deliberately: open the directory rather than guess.
_config_main_file() {
  local dir=$1 app=${(b)1:t} ext='(conf|toml|yaml|yml|json|jsonc|ini|kdl)'
  local p
  local -a m
  for p in "$app.$ext" config "config.$ext" "settings.$ext"; do
    m=( $dir/${~p}(-.N) )
    (( $#m == 1 )) && { print -r -- $m; return }
    (( $#m > 1 )) && return 1
  done
  return 1
}

config() {
  local open_dir=false dir target
  [[ $1 == -d ]] && { open_dir=true; shift }
  dir=$(pick configs "$1") || return

  # A query means the caller selected an application deliberately, so prefer
  # its conventional entry point. Bare `c` retains directory-first browsing.
  if [[ $open_dir == false && -n $1 ]] && target=$(_config_main_file "$dir"); then
    ${EDITOR:-nvim} "$target"
  else
    cd "$dir" && ${EDITOR:-nvim} .
  fi
}
