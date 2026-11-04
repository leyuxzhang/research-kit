#!/usr/bin/env bash
# Keeps a Claude Code Remote Control server running for this hub, restarting it
# if it exits (e.g. after a long network outage).
#
# First time, run it attached so you can answer the one-time prompts:
#   tmux new -s research-hub "bash ~/research-hub/hub.sh"
# Afterwards it can start detached at boot (see docs/SETUP.md in the kit).
#
# Shared machine: Claude and everything it runs get low CPU and disk priority,
# capped math-library threads, and no GPU unless compute.yaml says
# smoke_test: gpu. Your own secrets (e.g. the Zotero key) go in
# ~/.config/research-kit/env, which is loaded here and never shown to Claude.
set -u
HUB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HUB_DIR"
NAME="${RH_SESSION_NAME:-research-hub@$(hostname -s)}"
CLAUDE_BIN="${CLAUDE_BIN:-$(command -v claude || echo "$HOME/.local/bin/claude")}"

compute_value() {  # first "key: value" in compute.yaml, comments stripped
  sed -n "s/^[[:space:]]*$1:[[:space:]]*\([^#]*\).*/\1/p" "$HUB_DIR/compute.yaml" 2>/dev/null \
    | head -n 1 | tr -d "\"' "
}
THREADS="$(compute_value max_threads)"
case "$THREADS" in ''|*[!0-9]*) THREADS=4 ;; esac
export OMP_NUM_THREADS="$THREADS" MKL_NUM_THREADS="$THREADS" \
       OPENBLAS_NUM_THREADS="$THREADS" NUMEXPR_NUM_THREADS="$THREADS" \
       TOKENIZERS_PARALLELISM=false
[ "$(compute_value smoke_test)" = "gpu" ] || export CUDA_VISIBLE_DEVICES=""

ENV_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/research-kit/env"
if [ -f "$ENV_FILE" ]; then set -a; . "$ENV_FILE"; set +a; fi

PRIO=(nice -n 10)
command -v ionice >/dev/null && PRIO+=(ionice -c2 -n7)

while true; do
  echo "[$(date -Is)] starting Remote Control server '$NAME' in $HUB_DIR" \
       "(nice 10, $THREADS threads, GPUs ${CUDA_VISIBLE_DEVICES-visible}${CUDA_VISIBLE_DEVICES+hidden})"
  "${PRIO[@]}" "$CLAUDE_BIN" remote-control --name "$NAME" --spawn same-dir --permission-mode acceptEdits
  echo "[$(date -Is)] server exited (code $?). Restarting in 30 s — Ctrl+C now to stop."
  sleep 30
done
