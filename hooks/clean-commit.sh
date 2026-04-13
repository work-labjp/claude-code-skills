#!/bin/bash
# clean-commit.sh - Block commits with Co-Authored-By and enforce single-line messages
# Used as a PreToolUse hook for Claude Code

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only process git commit commands
if ! echo "$COMMAND" | grep -qE "git commit"; then
  exit 0
fi

# Block if contains Co-Authored-By or "Generated with Claude"
if echo "$COMMAND" | grep -qiE "Co-Authored-By|Generated with Claude"; then
  echo '{"decision":"block","reason":"No agregar Co-Authored-By ni Generated with Claude. Haz el commit sin esas lineas, mensaje en una sola linea."}' >&1
  exit 2
fi

# Block if uses HEREDOC (multi-line commit message pattern)
if echo "$COMMAND" | grep -qE "<<.*EOF|<<-.*EOF"; then
  echo '{"decision":"block","reason":"Usa git commit -m en una sola linea, sin HEREDOC ni mensajes multi-linea."}' >&1
  exit 2
fi

exit 0
