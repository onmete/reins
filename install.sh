#!/usr/bin/env bash
set -euo pipefail

REINS_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_SRC="$REINS_DIR/.claude/skills"

ACTION="push"
RUNTIME="cursor"

for arg in "$@"; do
    case "$arg" in
        push|pull) ACTION="$arg" ;;
        cursor|claude) RUNTIME="$arg" ;;
        *)
            echo "Usage: ./install.sh [push|pull] [cursor|claude]"
            echo ""
            echo "  push   Symlink skills from repo → runtime (default)"
            echo "  pull   (no-op — symlinks write through to repo)"
            echo ""
            echo "  cursor Install to ~/.cursor/skills (default)"
            echo "  claude Install to ~/.claude/skills"
            exit 1
            ;;
    esac
done

case "$RUNTIME" in
    cursor) SKILLS_DEST="$HOME/.cursor/skills" ;;
    claude) SKILLS_DEST="$HOME/.claude/skills" ;;
esac

if [ "$ACTION" = "push" ]; then
    echo "Installing Reins skills globally (symlinked)"
    echo "Runtime: $RUNTIME → $SKILLS_DEST"
    mkdir -p "$SKILLS_DEST"

    for skill_dir in "$SKILLS_SRC/reins-"*/; do
        [ -d "$skill_dir" ] || continue
        skill_name="$(basename "$skill_dir")"
        dest="$SKILLS_DEST/$skill_name"

        # Clean up stale copy (directory, not a symlink)
        if [ -d "$dest" ] && [ ! -L "$dest" ]; then
            echo "  ✕ $skill_name (removing old copy)"
            rm -rf "$dest"
        fi

        if [ -L "$dest" ]; then
            current_target="$(readlink "$dest")"
            if [ "$current_target" = "$skill_dir" ]; then
                echo "  · $skill_name (already linked)"
                continue
            else
                echo "  ↻ $skill_name (re-linking)"
                rm "$dest"
            fi
        else
            echo "  → $skill_name"
        fi

        ln -s "$skill_dir" "$dest"
    done

    echo ""
    echo "Done. Skills symlinked to $SKILLS_DEST"
    echo "Edits from any repo write through to $SKILLS_SRC"

else
    echo "Pull is a no-op — symlinks write through to the repo."
    echo "Check changes with: git -C \"$REINS_DIR\" diff .claude/skills/"
fi
