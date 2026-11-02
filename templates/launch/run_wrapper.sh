#!/usr/bin/env bash
# Wraps any training/eval command so every run leaves the same traces:
#   <run_dir>/run_meta.json  commit, dirty flag, job id, host, command, start/end, exit code
#   <run_dir>/run.log        full output
#   <run_dir>/DONE or FAILED sentinel
# Usage: bash launch/run_wrapper.sh <run_dir> -- <command ...>
set -uo pipefail
RUN_DIR="$1"; shift
[ "${1:-}" = "--" ] && shift
mkdir -p "$RUN_DIR"
rm -f "$RUN_DIR/DONE" "$RUN_DIR/FAILED"
REPO_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
COMMIT="$(git -C "$REPO_DIR" rev-parse HEAD 2>/dev/null || echo unknown)"
if git -C "$REPO_DIR" status --porcelain 2>/dev/null | grep -q .; then DIRTY=true; else DIRTY=false; fi
JOB_ID="${SLURM_JOB_ID:-${OAR_JOB_ID:-local}}"

python3 - "$RUN_DIR/run_meta.json" "$COMMIT" "$DIRTY" "$JOB_ID" "$@" <<'PY'
import json, socket, sys, datetime
path, commit, dirty, job, *cmd = sys.argv[1:]
json.dump({"commit": commit, "dirty": dirty == "true", "job_id": job,
           "host": socket.gethostname(), "command": cmd,
           "start": datetime.datetime.now().isoformat(timespec="seconds")},
          open(path, "w"), indent=2)
PY

"$@" 2>&1 | tee "$RUN_DIR/run.log"
CODE=${PIPESTATUS[0]}

python3 - "$RUN_DIR/run_meta.json" "$CODE" <<'PY'
import json, sys, datetime
path, code = sys.argv[1], int(sys.argv[2])
d = json.load(open(path))
d.update(end=datetime.datetime.now().isoformat(timespec="seconds"), exit_code=code)
json.dump(d, open(path, "w"), indent=2)
PY

if [ "$CODE" -eq 0 ]; then touch "$RUN_DIR/DONE"; else touch "$RUN_DIR/FAILED"; fi
exit "$CODE"
