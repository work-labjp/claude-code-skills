#!/bin/bash
# PreToolUse hook: block dangerous Bash commands
# Reads JSON from stdin, checks command, returns deny decision if dangerous

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Check for destructive patterns
if echo "$COMMAND" | grep -qE 'rm -rf /$|rm -rf ~$|rm -rf ~/\s|DROP DATABASE|drop database|push.*--force.*main|push.*main.*--force'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Comando destructivo bloqueado por hook de seguridad"
    }
  }'
  exit 0
fi

exit 0
