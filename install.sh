#!/usr/bin/env bash
set -euo pipefail

REINS_DIR="$(cd "$(dirname "$0")" && pwd)"

ACTION="push"
RUNTIME="cursor"

for arg in "$@"; do
    case "$arg" in
        push|pull) ACTION="$arg" ;;
        cursor|claude) RUNTIME="$arg" ;;
        *)
            echo "Usage: ./install.sh [push|pull] [cursor|claude]"
            echo ""
            echo "  push   Install skills from repo → runtime (default)"
            echo "  pull   Sync skill edits from runtime → repo"
            exit 1
            ;;
    esac
done

case "$RUNTIME" in
    cursor) SKILLS_DEST="$HOME/.cursor/skills" ;;
    claude) SKILLS_DEST="$HOME/.claude/skills" ;;
esac

if [ "$ACTION" = "push" ]; then
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
    echo "Done. Skills installed to $SKILLS_DEST"
    echo "After retro edits, run ./install.sh pull to sync back."

else
    echo "Pulling skill edits back to repo"
    echo "Runtime: $SKILLS_DEST → skills/"

    changed=0
    for skill_dir in "$REINS_DIR/skills/reins-"*/; do
        [ -d "$skill_dir" ] || continue
        skill_name="$(basename "$skill_dir")"
        src="$SKILLS_DEST/$skill_name"

        [ -d "$src" ] || continue

        if ! diff -rq "$src" "$skill_dir" > /dev/null 2>&1; then
            echo "  ← $skill_name (changed)"
            cp -r "$src"/* "$skill_dir"/
            changed=$((changed + 1))
        else
            echo "  · $skill_name (unchanged)"
        fi
    done

    echo ""
    if [ "$changed" -gt 0 ]; then
        echo "Pulled $changed skill(s). Review with: git diff skills/"
    else
        echo "No changes to pull."
    fi
fi
