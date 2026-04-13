---
name: team-review
description: >
  This skill should be used when the user asks to "review this PR", "full code review",
  "security review", "architecture review", or needs a multi-perspective team code review
  with security-auditor, qos-reviewer, and tech-lead analyzing in parallel.
  Do NOT use for "quick review" or small changes — use quick-review instead.
version: 2.0.0
disable-model-invocation: true
model: opus-4-6
allowed-tools:
  - Agent
  - Read
  - Glob
  - Grep
  - Bash(git diff*)
  - Bash(gh pr*)
  - TaskCreate
  - TaskUpdate
  - TaskList
  - TeamCreate
  - SendMessage
---

# Team Review

Launch a parallel code review using an Agent Team with specialized reviewers.

## Instructions

1. **Determine scope first**:
   - If $ARGUMENTS is a file/directory path: review those files
   - If $ARGUMENTS is a PR number: fetch with `gh pr diff $ARGUMENTS`
   - If no arguments: review uncommitted changes (`git diff` + `git diff --staged`)
   - **If diff is > 500 lines**: warn user and suggest splitting the review by area

2. **Create an Agent Team** named `review-{timestamp}` using TeamCreate

3. **Create tasks with file ownership** — each reviewer owns specific files:
   - **Security audit** (`security-auditor`): Focus on auth, input handling, secrets, API boundaries, dependency vulnerabilities
   - **Quality review** (`qos-reviewer`): Focus on conventions, naming, readability, duplication, error handling, test coverage
   - **Architecture review** (`tech-lead`): Focus on design patterns, coupling, scalability, layer violations, dependency direction

4. **Spawn 3 teammates** and assign tasks:
   - `security-auditor` (subagent_type: `security-auditor`)
   - `qos-reviewer` (subagent_type: `qos-reviewer`)
   - `tech-lead` (subagent_type: `tech-lead`)

5. **Wait for all reviews** to complete

6. **Synthesize** into a unified report:

```
## Review Summary — [scope]

### Critical (must fix before merge)
- [FILE:LINE] Description — found by [reviewer]

### Suggestions (should fix)
- [FILE:LINE] Description — found by [reviewer]

### Observations (nice to have)
- [FILE:LINE] Description — found by [reviewer]

### Verdict: [APPROVE / REQUEST CHANGES / NEEDS DISCUSSION]
- Security: [PASS/CONCERN]
- Quality: [PASS/CONCERN]
- Architecture: [PASS/CONCERN]
```

## When to Use vs quick-review
- **team-review**: PRs with 3+ files, security-sensitive changes, new features, architectural changes
- **quick-review**: Small fixes, single-file changes, config updates, documentation

## Scope

Review target: $ARGUMENTS

If no arguments given, review uncommitted changes (`git diff` + `git diff --staged`).
