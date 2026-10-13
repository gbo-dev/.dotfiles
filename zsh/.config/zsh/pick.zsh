# Fuzzy pickers, split into sources, a UI, and actions:
#   _pick_src_<name>  prints candidates, one per line
#   _pick_list <name> the source, ranked by zoxide frecency
#   _pick_ui <name>   interactive picker; set PICKER to swap it. tv uses the
#                     matching channel in ~/.config/television/cable when one
#                     exists; any other value is a stdin→stdout command
#                     (e.g. PICKER="fzy", "sk")
#   pick <name> [q]   prints one selection; with a query, takes the best match
# Adding a picker means adding a source plus a small action function.
# Kept free of side effects so tv channels can source it non-interactively.

_pick_list() {
  local -a cands=( ${(f)"$(_pick_src_$1)"} )
  local -aU ranked=( ${(f)"$(zoxide query -l 2>/dev/null)"} )
  # Candidates zoxide knows, by frecency, then the rest in the source's order.
  local -aU out=( ${ranked:*cands} $cands )
  print -rl -- $out
}

_pick_src_projects() {
  print -rl -- ~/dev/*(-/N) ~/.dotfiles(-/N)
}

_pick_src_configs() {
  print -rl -- ~/.config/*(-/N) ~/.dotfiles(-/N)
}

# fzf with a per-picker accent. The directory preview goes on the right (layout
# from fzfrc), starts hidden, and Alt-P toggles it (bound in fzfrc).
_pick_fzf() {
  local name=$1 accent band
  case $name in
    projects) accent=#fabd2f band=#3a2d11 ;;
    configs)  accent=#7fa2ac band=#273842 ;;
    *)        accent=#8ec07c band=#26332c ;;
  esac
  print -r -- $2 | fzf --prompt="${(C)name} ❯ " --height=60% --tiebreak=index \
    --preview='ls -lA --group-directories-first --color=always {}' \
    --color="prompt:$accent,pointer:$accent,hl+:$accent:bold,input-label:$accent,input-border:$accent,bg+:$band"
}

_pick_ui() {
  case ${PICKER:-fzf} in
    fzf) _pick_fzf $1 "$(_pick_list $1)" ;;
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
    # Index tiebreak keeps the list's zoxide order among equal scores.
    sel=$(_pick_list $src | fzf --filter="$query" --tiebreak=index | head -n1)
    [[ -n $sel ]] || print -u2 "pick: no match for: $query"
  else
    sel=$(_pick_ui $src)
  fi
  [[ -n $sel ]] || return 1
  # Count the pick as a visit even when the action never cd's (e.g. `c app`).
  (( $+commands[zoxide] )) && [[ -d $sel ]] && zoxide add -- $sel
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
