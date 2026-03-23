#!/usr/bin/env bash
set -euo pipefail

REINS_DIR="$(cd "$(dirname "$0")" && pwd)"
RUNTIME="${1:-cursor}"

case "$RUNTIME" in
    cursor)
        SKILLS_DEST="$HOME/.cursor/skills"
        ;;
    claude)
        SKILLS_DEST="$HOME/.claude/skills"
        ;;
    *)
        echo "Unknown runtime: $RUNTIME"
        echo "Usage: ./install.sh [cursor|claude]"
        exit 1
        ;;
esac

echo "Installing Reins skills globally"
echo "Runtime: $RUNTIME → $SKILLS_DEST"

mkdir -p "$SKILLS_DEST"

for skill_dir in "$REINS_DIR/skills/reins-"*/; do
    [ -d "$skill_dir" ] || continue
    skill_name="$(basename "$skill_dir")"
    dest="$SKILLS_DEST/$skill_name"

    if [ -d "$dest" ]; then
        echo "  ↻ $skill_name (updating)"
    else
        echo "  → $skill_name"
    fi

    mkdir -p "$dest"
    cp -r "$skill_dir"/* "$dest"/
done

echo ""
echo "Done. Skills installed globally to $SKILLS_DEST"
echo "Re-run to push updated skills from source."
