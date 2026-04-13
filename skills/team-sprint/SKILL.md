---
name: team-sprint
description: >
  This skill should be used when the user asks to "run a sprint", "implement a feature end to end",
  "plan and build", "full development cycle", or needs coordinated multi-agent work for a feature or fix.
  Orchestrates tech-lead, backend-dev, devops-engineer, qos-reviewer, and security-auditor.
  Do NOT use for small tasks or single-file changes — use quick-review or direct editing instead.
version: 2.0.0
disable-model-invocation: true
model: opus-4-6
allowed-tools:
  - Agent
  - Read
  - Glob
  - Grep
  - Bash(git *)
  - TaskCreate
  - TaskUpdate
  - TaskList
  - TaskGet
  - TeamCreate
  - SendMessage
---

# Team Sprint

Run a full development sprint using an Agent Team to plan, implement, and verify a task.

## Instructions

1. **Create an Agent Team** named `sprint-{timestamp}` using TeamCreate
2. **Phase 1 — Planning** (1 agent):
   - Create a task for the `tech-lead` to:
     - Analyze the requirement: $ARGUMENTS
     - Break it into implementable subtasks (max 3-5)
     - **Assign file ownership** — each subtask owns specific files, no overlap
     - Identify dependencies between subtasks (set `blockedBy`)
     - Define acceptance criteria per subtask
   - Spawn the `tech-lead` teammate and assign the planning task
   - **Gate**: Wait for plan approval before proceeding

3. **Phase 2 — Implementation** (2-3 agents max):
   - Create tasks from the plan with clear file ownership
   - Spawn `backend-dev` teammate(s) for coding — **max 2 devs**
   - Spawn `devops-engineer` ONLY if infrastructure changes needed
   - Use `blockedBy` for tasks with dependencies
   - Agents use `SendMessage` to report blockers immediately
   - **Rule**: If two tasks need the same file, make one `blockedBy` the other

4. **Phase 3 — Verification** (1-2 agents):
   - Spawn `qos-reviewer` to review code quality and conventions
   - Spawn `security-auditor` ONLY if changes touch auth, input handling, secrets, or APIs
   - `backend-dev` runs project tests (`npm test`, `pytest`, `./gradlew test`, etc.)
   - **Gate**: All tests must pass, no Critical findings from reviewers

5. **Phase 4 — Synthesis**:
   - Collect all results via `TaskList` and present:
     - Summary of changes made (files created/modified)
     - Test results (pass/fail count)
     - Review findings (Critical / Suggestion / Observation)
     - Remaining TODOs (if any)

## Team Size Rules
- **Total agents**: 3-5 max (including tech-lead)
- **Never** spawn agents you don't need — small tasks need fewer agents
- If the task is simple (1-2 files), use `quick-review` instead

## Error Handling
- If an agent reports a blocker via `SendMessage`, pause dependent tasks
- If tests fail, assign fix to the original `backend-dev` (they have context)
- If a review finds Critical issues, create fix tasks before marking sprint complete
- **Never mark the sprint complete with failing tests or Critical review findings**

## Task

$ARGUMENTS
