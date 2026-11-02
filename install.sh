#!/usr/bin/env bash
# Installs research-kit for the current user on this machine:
#   - links every skill into ~/.claude/skills/ (available in all Claude Code sessions)
#   - links the `rh` helper into ~/.local/bin/
#   - optionally creates a hub:  ./install.sh --hub ~/research-hub
# To update an existing install: `rh update` (pulls, re-runs this, syncs the hub).
# Remove with: ./install.sh --uninstall
set -euo pipefail
KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$HOME/.claude/skills"
BIN_DIR="$HOME/.local/bin"

if [ "${1:-}" = "--uninstall" ]; then
  for s in "$KIT_DIR"/skills/*/; do
    n="$(basename "$s")"
    [ -L "$SKILLS_DIR/$n" ] && rm "$SKILLS_DIR/$n" && echo "removed skill $n"
  done
  [ -L "$BIN_DIR/rh" ] && rm "$BIN_DIR/rh" && echo "removed rh"
  echo "Uninstalled. Your hub and code bases were not touched."
  exit 0
fi

mkdir -p "$SKILLS_DIR" "$BIN_DIR"
for s in "$KIT_DIR"/skills/*/; do
  n="$(basename "$s")"
  if [ -e "$SKILLS_DIR/$n" ] && [ ! -L "$SKILLS_DIR/$n" ]; then
    echo "skip $n: $SKILLS_DIR/$n exists and is not a link"
    continue
  fi
  ln -sfn "${s%/}" "$SKILLS_DIR/$n"
  echo "skill  $n"
done
# Skills removed from the kit leave broken links behind: drop them.
KIT_SKILLS="$(cd "$KIT_DIR/skills" && pwd -P)"
for l in "$SKILLS_DIR"/rh-*; do
  [ -L "$l" ] && [ ! -e "$l" ] || continue
  parent="$(cd "$(dirname "$(readlink "$l")")" 2>/dev/null && pwd -P)" || continue
  if [ "$parent" = "$KIT_SKILLS" ]; then
    rm "$l" && echo "removed skill $(basename "$l") (no longer in the kit)"
  fi
done
chmod +x "$KIT_DIR/bin/rh" "$KIT_DIR/templates/launch/"*.sh
ln -sfn "$KIT_DIR/bin/rh" "$BIN_DIR/rh"
echo "tool   rh -> $BIN_DIR/rh"

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) echo; echo "Add this to your ~/.bashrc:  export PATH=\"$BIN_DIR:\$PATH\"";;
esac

if [ "${1:-}" = "--hub" ]; then
  [ -n "${2:-}" ] || { echo "usage: ./install.sh --hub <path>"; exit 1; }
  "$KIT_DIR/bin/rh" init-hub "$2"
fi

echo; echo "Done. Check with: rh doctor"
