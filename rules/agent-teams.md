# Agent Teams Conventions

## Team Size
- Keep teams small: 3-5 agents max
- Only spawn agents that are needed for the task
- Use quick-review (single agent) for simple reviews instead of a full team

## File Ownership
- Each agent must own specific files — never have two agents editing the same file
- Assign file ownership in the task description
- If two tasks touch the same file, make one block the other via TaskUpdate

## Communication
- Use SendMessage for direct agent-to-agent communication
- Use broadcast only for critical blockers that affect everyone
- Always include a clear summary in messages

## Task Coordination
- Use TaskCreate with clear descriptions and acceptance criteria
- Set blockedBy dependencies when tasks have ordering requirements
- Agents should check TaskList after completing each task
- Mark tasks completed only when fully done — not partially

## Quality Gates
- Security-sensitive changes require security-auditor review before merge
- All code changes must have passing tests before task completion
- The tech-lead synthesizes final results — individual agents report findings

## Naming
- Team names: `{purpose}-{timestamp}` (e.g., `review-1709125200`)
- Task subjects: imperative form (e.g., "Audit auth module for injection flaws")
- Keep agent names consistent with ~/.claude/agents/ definitions
