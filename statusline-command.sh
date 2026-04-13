#!/usr/bin/env bash
# Claude Code status line — clean, no ANSI colors (terminal renders plain text)

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "?"')
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Shorten cwd: keep last 3 segments
short_cwd=$(echo "$cwd" | awk -F'/' '{
  n=split($0,a,"/");
  if(n<=3) print $0;
  else print "…/" a[n-2] "/" a[n-1] "/" a[n]
}')

# Git branch
git_branch=""
if git -C "$cwd" rev-parse --git-dir --no-optional-locks >/dev/null 2>&1; then
  git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
               || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

# Context usage
ctx=""
if [ -n "$used" ]; then
  ctx="ctx:$(printf "%.0f" "$used")%"
fi

# Build: 📂 …/kcd/mobile  ⎇ main  🤖 Claude Opus 4.6  📊 ctx:12%
parts=""
parts="${parts}${short_cwd}"
[ -n "$git_branch" ] && parts="${parts}  ⎇ ${git_branch}"
parts="${parts}  ⏐  ${model}"
[ -n "$ctx" ] && parts="${parts}  ⏐  ${ctx}"

printf "%s" "$parts"
