#!/usr/bin/env bash
set -euo pipefail

REINS_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:?Usage: ./install.sh /path/to/target/repo [cursor|claude]}"
RUNTIME="${2:-cursor}"
TARGET="$(cd "$TARGET" && pwd)"

case "$RUNTIME" in
    cursor)
        SKILLS_DEST="$TARGET/.cursor/skills"
        ;;
    claude)
        SKILLS_DEST="$TARGET/.claude/skills"
        ;;
    *)
        echo "Unknown runtime: $RUNTIME"
        echo "Supported: cursor, claude"
        exit 1
        ;;
esac

echo "Installing Reins skills into: $TARGET"
echo "Runtime: $RUNTIME → $SKILLS_DEST"

mkdir -p "$SKILLS_DEST"
mkdir -p "$TARGET/.reins/plans"
mkdir -p "$TARGET/.reins/reviews"

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
echo "Done. Skills copied to $SKILLS_DEST"
echo "Skill edits in the target repo show up in git diff."
echo "Re-run to push updated skills from source."
