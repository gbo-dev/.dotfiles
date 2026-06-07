# fzf

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=fg:-1,fg+:#f4ede0,bg:-1,bg+:#0a0a0a
  --color=hl:#48b08f,hl+:#6ce4be,info:#8788b0,marker:#00a6ff
  --color=prompt:#00d6ba,spinner:#a2b9b9,pointer:#5e7eff,header:#87afaf
  --color=border:#303030,label:#aeaeae,query:#d9d9d9
  --border="sharp" --border-label="" --preview-window="border-sharp" --prompt="> "
  --marker=">" --pointer="◆" --scrollbar="│" --gutter=" "
  --layout="reverse" --info="right"'
