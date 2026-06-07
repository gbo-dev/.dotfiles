# ft shell integration for zsh
ft() {
  local tmp_stdout exit_code cd_target line

  tmp_stdout="$(mktemp -t ft.stdout.XXXXXX)" || {
    printf 'ft: failed to create temporary file\n' >&2
    return 1
  }

  FT_EMIT_CD=1 command ft "$@" >"$tmp_stdout"
  exit_code=$?

  cd_target=""
  while IFS= read -r line; do
    case "$line" in
      __FT_CD__=*)
        cd_target="${line#__FT_CD__=}"
        ;;
      *)
        printf '%s\n' "$line"
        ;;
    esac
  done <"$tmp_stdout"

  rm -f "$tmp_stdout"

  if [ "$exit_code" -ne 0 ]; then
    return "$exit_code"
  fi

  if [ -n "$cd_target" ]; then
    cd "$cd_target" || return 1
  fi

  return 0
}

# yazi

function yazi() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	command rm -f -- "$tmp"
}
