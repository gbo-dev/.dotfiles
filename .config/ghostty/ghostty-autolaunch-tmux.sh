#!/bin/bash
# Credit: Mansoor Barri 

SESSION_NAME="ghostty"

# Check if session already exists
tmux has-session -t $SESSION_NAME 2>/dev/null

if [ $? -eq 0 ]; then
  # If the session exists, reattach
  tmux attach-session -t $SESSION_NAME
else 
  # No session exists, create one
  tmux new-session -s $SESSION_NAME -d 
  tmux attach-session -t $SESSION_NAME
fi
