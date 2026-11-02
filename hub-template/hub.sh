#!/usr/bin/env bash
# Keeps a Claude Code Remote Control server running for this hub, restarting it
# if it exits (e.g. after a long network outage).
#
# First time, run it attached so you can answer the one-time prompts:
#   tmux new -s research-hub "bash ~/research-hub/hub.sh"
# Afterwards it can start detached at boot (see docs/SETUP.md in the kit).
set -u
HUB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HUB_DIR"
NAME="${RH_SESSION_NAME:-research-hub@$(hostname -s)}"
CLAUDE_BIN="${CLAUDE_BIN:-$(command -v claude || echo "$HOME/.local/bin/claude")}"

while true; do
  echo "[$(date -Is)] starting Remote Control server '$NAME' in $HUB_DIR"
  "$CLAUDE_BIN" remote-control --name "$NAME" --spawn same-dir --permission-mode acceptEdits
  echo "[$(date -Is)] server exited (code $?). Restarting in 30 s — Ctrl+C now to stop."
  sleep 30
done
