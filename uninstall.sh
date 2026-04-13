#!/bin/bash
# uninstall.sh — Remove symlinks created by install.sh
# Usage: ./uninstall.sh

set -e

CLAUDE_DIR="$HOME/.claude"

remove_link() {
  local path="$1"
  if [ -L "$path" ]; then
    rm "$path"
    echo "  Removed: $path"
  fi
}

echo "Removing Claude Code config symlinks..."
echo ""

# Skills
echo "Skills:"
for link in "$CLAUDE_DIR"/skills/*/; do
  [ -L "${link%/}" ] && remove_link "${link%/}"
done

# Agents
echo "Agents:"
for link in "$CLAUDE_DIR"/agents/*.md; do
  [ -L "$link" ] && remove_link "$link"
done

# Rules
echo "Rules:"
for link in "$CLAUDE_DIR"/rules/*.md; do
  [ -L "$link" ] && remove_link "$link"
done

# Hooks
echo "Hooks:"
for link in "$CLAUDE_DIR"/hooks/*.sh; do
  [ -L "$link" ] && remove_link "$link"
done

# Root config
echo "Config:"
for f in CLAUDE.md settings.json mcp_servers.json statusline-command.sh; do
  remove_link "$CLAUDE_DIR/$f"
done

echo ""
echo "Done. Symlinks removed."
echo "Check $CLAUDE_DIR/backups/ for previous config files."
