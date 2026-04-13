---
name: team-debug
description: >
  This skill should be used when the user asks to "debug this", "find the root cause",
  "investigate a bug", "why is this failing", or needs collaborative debugging with competing
  hypotheses from multiple agents. Launches 3 agents investigating in parallel.
  Do NOT use for simple errors with obvious fixes — only for non-trivial bugs requiring investigation.
version: 2.0.0
disable-model-invocation: true
model: opus-4-6
allowed-tools:
  - Agent
  - Read
  - Glob
  - Grep
  - Bash(git *)
  - Bash(npm test*)
  - Bash(python -m pytest*)
  - TaskCreate
  - TaskUpdate
  - TaskGet
  - TaskList
  - TeamCreate
  - SendMessage
---

# Team Debug

Launch a collaborative debugging session using an Agent Team with competing hypotheses.

## Instructions

1. **Reproduce first**: Before spawning agents, verify the bug exists:
   - Run the failing test, command, or request
   - Capture the error output, stack trace, or unexpected behavior
   - If it can't be reproduced, ask the user for more details

2. **Create an Agent Team** named `debug-{timestamp}` using TeamCreate

3. **Create 3 hypothesis tasks** — each agent investigates independently:
   - **Hypothesis A** (`backend-dev`): **Code logic bug** — trace execution path, check edge cases, review recent changes (`git log -10`), test boundary conditions
   - **Hypothesis B** (`devops-engineer`): **Environment/config issue** — check dependencies, configs, build output, environment variables, version mismatches
   - **Hypothesis C** (`security-auditor`): **Data/input issue** — check validation, encoding, injection vectors, malformed data, race conditions

4. **Assign file ownership** — split investigation areas:
   - Agent A: source code files related to the feature
   - Agent B: config files, Dockerfiles, CI/CD, package manifests
   - Agent C: input handlers, validators, API boundaries

5. **Each agent must** (include in task description):
   - Gather evidence (read code, grep patterns, check logs)
   - Rate confidence in their hypothesis: **0-100%**
   - Include specific file:line references for evidence
   - Propose a concrete fix if confidence > 60%
   - Use `SendMessage` to broadcast if they find the root cause early

6. **Synthesize results**:
   - Rank hypotheses by confidence and evidence quality
   - If multiple agents found related issues, they may be symptoms of one root cause
   - Apply the highest-confidence fix
   - If no hypothesis > 50%, investigate the intersection of findings

7. **Verify**: Run the original failing test/command to confirm the fix

## When NOT to Use This
- **Simple bugs** (typo, missing import, wrong variable): Just fix it directly
- **Build errors**: Usually obvious — check the error message first
- Use this for **mysterious** bugs where the cause isn't clear

## Bug Description

$ARGUMENTS
