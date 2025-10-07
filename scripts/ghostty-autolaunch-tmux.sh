#!/bin/bash

# Check if main session exists
if tmux has-session -t main 2>/dev/null; then
  # Check if main is attached
  if tmux list-sessions | grep "^main:" | grep -q "(attached)"; then
    # Main exists and is attached, create a new session
    exec tmux new-session -s "session_$(date +%s)"
  else
    # Main exists but is detached (crashed), reattach to it
    exec tmux attach-session -t main
  fi
else
  # No main session exists, create it
  exec tmux new-session -s "main"
fi




# #!/bin/bash
# # Credit: Mansoor Barri 
#
# SESSION_NAME="ghostty"
#
# # Check if session already exists
# tmux has-session -t $SESSION_NAME 2>/dev/null
#
# if [ $? -eq 0 ]; then
#   # If the session exists, reattach
#   tmux attach-session -t $SESSION_NAME
# else 
#   # No session exists, create one
#   tmux new-session -s $SESSION_NAME -d 
#   tmux attach-session -t $SESSION_NAME 
# fi
