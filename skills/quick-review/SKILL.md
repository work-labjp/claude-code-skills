---
name: quick-review
description: >
  This skill should be used when the user asks for a "quick review", "review my code",
  "check this before commit", "review staged changes", or needs a fast code review using
  a single qos-reviewer subagent. No Agent Team overhead — use for small/medium changes.
version: 2.0.0
disable-model-invocation: true
context: fork
agent: qos-reviewer
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash(git diff*)
  - Bash(gh pr diff*)
---

# Quick Review

Run a fast code review using a single Agent (no Agent Team overhead).

## Instructions

1. **Do NOT create an Agent Team** — use a simple Agent subagent instead

2. **Determine what to review**:
   - If $ARGUMENTS is a file path: review that file
   - If $ARGUMENTS is a PR number: `gh pr diff $ARGUMENTS`
   - If $ARGUMENTS is "staged" or empty: `git diff --staged`
   - If $ARGUMENTS is "all": `git diff` + `git diff --staged`

3. **Spawn a single agent** (subagent_type: `qos-reviewer`) with this prompt:
   - Read the changed files
   - Detect the language/framework and apply relevant conventions
   - Check for:
     - Bugs, logic errors, off-by-one, null/undefined risks
     - Security issues (injection, auth bypass, hardcoded secrets, XSS)
     - Convention violations (naming, formatting, structure)
     - Unnecessary complexity or dead code
     - Missing error handling at boundaries
     - Hardcoded values that should be constants/config
   - Return a concise review in this format:

```
## Quick Review — [file/scope]

**Blockers** (must fix):
- [FILE:LINE] Description

**Suggestions** (worth considering):
- [FILE:LINE] Description

**Score**: X/5
- 5: Ship it
- 4: Minor suggestions, safe to merge
- 3: Some issues worth fixing
- 2: Significant concerns
- 1: Do not merge
```

4. **Present** the review results directly — no synthesis needed

## Scope

$ARGUMENTS

If no arguments, review staged changes.
