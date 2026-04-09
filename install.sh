#!/bin/bash
# Install Claude Code skills for Red Hat Consulting
# Usage: ./install.sh
#
# Copies all skills to ~/.claude/skills/ for global availability.
# Safe to re-run — overwrites existing skills with latest version.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="$HOME/.claude/skills"

SKILLS=(
  redhat-atp-docs
  redhat-cer-docs
  redhat-drawio-diagrams
  ocp-redhat-docs
  terminal-screenshot
)

echo "Installing Claude Code skills to $TARGET..."
mkdir -p "$TARGET"

for skill in "${SKILLS[@]}"; do
  if [ -d "$SCRIPT_DIR/$skill" ]; then
    rm -rf "$TARGET/$skill"
    cp -R "$SCRIPT_DIR/$skill" "$TARGET/$skill"
    echo "  Installed: $skill"
  else
    echo "  SKIP: $skill (not found)"
  fi
done

echo ""
echo "Done. ${#SKILLS[@]} skills installed."
echo ""
echo "Available skills:"
echo "  /redhat-atp-docs        — Acceptance Test Plans (ATP) for 10 Red Hat products"
echo "  /redhat-cer-docs        — Consulting Engagement Reports (CER)"
echo "  /redhat-drawio-diagrams — draw.io architecture diagrams with Red Hat icons"
echo "  /ocp-redhat-docs        — Query official Red Hat OpenShift documentation"
echo "  /terminal-screenshot    — Terminal screenshot PNG generator"
echo ""
echo "Restart Claude Code to load the new skills."
