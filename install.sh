#!/bin/bash
# install.sh — Link Claude Code config from this repo to ~/.claude/
# Usage: ./install.sh
#
# Creates symlinks so that `git pull` automatically updates your config.
# Safe to re-run — idempotent. Backs up existing files before replacing.

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$CLAUDE_DIR/backups/pre-install-$(date +%Y%m%d-%H%M%S)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

link_file() {
  local src="$1"
  local dest="$2"

  if [ -L "$dest" ]; then
    rm "$dest"
  elif [ -e "$dest" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "${dest#$CLAUDE_DIR/}")"
    mv "$dest" "$BACKUP_DIR/${dest#$CLAUDE_DIR/}"
    echo -e "  ${YELLOW}Backed up:${NC} $dest"
  fi

  ln -s "$src" "$dest"
  echo -e "  ${GREEN}Linked:${NC} $(basename "$dest")"
}

link_dir() {
  local src="$1"
  local dest="$2"

  if [ -L "$dest" ]; then
    rm "$dest"
  elif [ -d "$dest" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "${dest#$CLAUDE_DIR/}")"
    mv "$dest" "$BACKUP_DIR/${dest#$CLAUDE_DIR/}"
    echo -e "  ${YELLOW}Backed up:${NC} $dest"
  fi

  ln -s "$src" "$dest"
  echo -e "  ${GREEN}Linked:${NC} $(basename "$dest")"
}

echo "Installing Claude Code config from: $REPO_DIR"
echo ""

# Skills
echo "Skills:"
mkdir -p "$CLAUDE_DIR/skills"
for skill in "$REPO_DIR"/skills/*/; do
  name=$(basename "$skill")
  link_dir "$skill" "$CLAUDE_DIR/skills/$name"
done

# Agents
echo "Agents:"
mkdir -p "$CLAUDE_DIR/agents"
for agent in "$REPO_DIR"/agents/*.md; do
  name=$(basename "$agent")
  link_file "$agent" "$CLAUDE_DIR/agents/$name"
done

# Rules
echo "Rules:"
mkdir -p "$CLAUDE_DIR/rules"
for rule in "$REPO_DIR"/rules/*.md; do
  name=$(basename "$rule")
  link_file "$rule" "$CLAUDE_DIR/rules/$name"
done

# Hooks
echo "Hooks:"
mkdir -p "$CLAUDE_DIR/hooks"
for hook in "$REPO_DIR"/hooks/*.sh; do
  name=$(basename "$hook")
  link_file "$hook" "$CLAUDE_DIR/hooks/$name"
done

# Root config files
echo "Config:"
link_file "$REPO_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
link_file "$REPO_DIR/settings.json" "$CLAUDE_DIR/settings.json"
link_file "$REPO_DIR/mcp_servers.json" "$CLAUDE_DIR/mcp_servers.json"
link_file "$REPO_DIR/statusline-command.sh" "$CLAUDE_DIR/statusline-command.sh"

echo ""
echo "Done. Config linked from $REPO_DIR"
if [ -d "$BACKUP_DIR" ]; then
  echo "Backups saved to: $BACKUP_DIR"
fi
echo ""
echo "To update: cd $REPO_DIR && git pull"
echo "Restart Claude Code to load changes."
