---
name: skill-creator
description: >
  This skill should be used when the user asks to "create a skill", "test a skill",
  "eval a skill", "benchmark a skill", "improve a skill", "skill-creator",
  "optimize skill description", "test skill triggers", or needs to create, evaluate,
  improve, or benchmark Claude Code skills. Operates in 4 modes: create, eval, improve, benchmark.
version: 2.0.0
user-invocable: true
allowed-tools:
  - Agent
  - Read
  - Glob
  - Grep
  - Edit
  - Write
  - Bash(mkdir *)
  - Bash(ls *)
---

# Skill Creator

Create, evaluate, improve, and benchmark Claude Code skills. Operates in 4 modes.

## Mode Detection

Parse the user's intent from $ARGUMENTS:

- **`create <name>`** → Mode: Create
- **`eval <skill-name>`** → Mode: Eval
- **`improve <skill-name>`** → Mode: Improve
- **`benchmark <skill-name>`** → Mode: Benchmark
- No arguments or just a description → Mode: Create (interactive)

---

## Mode 1: Create

Generate a new skill from scratch following Skills 2.0 best practices.

### Process

1. **Understand** — Ask the user:
   - What should the skill do? (2-3 concrete examples)
   - What trigger phrases should activate it?
   - Does it need scripts, references, or assets?

2. **Plan** — Identify:
   - Resources needed (references/, scripts/, assets/)
   - Which tools the skill should have access to (`allowed-tools`)
   - Whether it needs a subagent (`context: fork` + `agent`)
   - Model override if needed (`model`)

3. **Create** the skill directory:
   ```
   ~/.claude/skills/<skill-name>/
   ├── SKILL.md
   ├── references/    (if needed)
   └── scripts/       (if needed)
   ```

4. **Write SKILL.md** with proper frontmatter:
   ```yaml
   ---
   name: skill-name
   description: >
     This skill should be used when the user asks to "trigger phrase 1",
     "trigger phrase 2", "trigger phrase 3", or needs [purpose].
   version: 1.0.0
   user-invocable: true
   allowed-tools:
     - Read
     - Glob
     - Grep
   ---
   ```

5. **Validate** — Check:
   - [ ] Description uses third person ("This skill should be used when...")
   - [ ] Includes 3+ specific trigger phrases in quotes
   - [ ] Body uses imperative form (not "you should")
   - [ ] SKILL.md < 3000 words (details in references/)
   - [ ] All referenced files exist
   - [ ] `allowed-tools` is minimal (principle of least privilege)

---

## Mode 2: Eval

Test a skill with real prompts to verify it triggers correctly and produces good output.

### Process

1. **Load the skill**: Read `~/.claude/skills/$ARGUMENTS/SKILL.md`

2. **Generate eval set** — Create 5-8 test cases:
   ```
   Eval Set for: <skill-name>

   SHOULD TRIGGER (true positives):
   1. "<prompt that should activate the skill>"
      Expected: skill activates, output contains [criteria]
   2. "<another trigger prompt>"
      Expected: skill activates, output contains [criteria]
   3. "<edge case trigger>"
      Expected: skill activates, handles edge case

   SHOULD NOT TRIGGER (true negatives):
   4. "<prompt that looks similar but shouldn't trigger>"
      Expected: skill does NOT activate
   5. "<unrelated prompt>"
      Expected: skill does NOT activate

   QUALITY CHECKS:
   6. "<prompt testing output quality>"
      Expected: output follows [specific format/standard]
   7. "<prompt testing completeness>"
      Expected: output includes [all required sections]
   ```

3. **Run evals** — For each test case, spawn an isolated agent (`context: fork`):
   - **Executor**: Run Claude with the skill loaded, using the test prompt
   - **Grader**: Evaluate if the output matches expected criteria
   - Score: PASS / FAIL / PARTIAL with evidence

4. **Report results**:
   ```
   ## Eval Results — <skill-name>

   | # | Type | Prompt | Expected | Result | Score |
   |---|------|--------|----------|--------|-------|
   | 1 | TP   | "..."  | activates| ...    | PASS  |
   | 2 | TP   | "..."  | activates| ...    | FAIL  |
   | 4 | TN   | "..."  | no trigger| ...   | PASS  |

   Pass Rate: X/Y (Z%)
   Issues Found: [list]
   ```

5. **Detect outgrowth** — If base model passes ALL quality checks WITHOUT the skill:
   ```
   ⚠️ OUTGROWTH DETECTED: The base model handles these tasks well without
   the skill. Consider retiring this skill — it may be adding unnecessary
   context overhead without improving output quality.
   ```

---

## Mode 3: Improve

Optimize a skill's description, triggers, and content based on eval results.

### Process

1. **Run eval first** (Mode 2) if no recent eval results exist

2. **Analyze failures**:
   - False negatives (missed fires) → description needs more trigger phrases
   - False positives (wrong triggers) → description needs negative boundaries
   - Quality failures → SKILL.md body needs better instructions

3. **Generate improved version**:
   - Rewrite description with better trigger phrases
   - Add negative boundaries ("Do NOT use for...")
   - Tighten or relax `allowed-tools`
   - Move verbose content to `references/`

4. **A/B Compare** — Run eval on both versions:
   ```
   ## A/B Comparison — <skill-name>

   | Metric       | Version A (current) | Version B (improved) |
   |-------------|--------------------|--------------------|
   | Pass Rate   | X%                 | Y%                 |
   | False Neg   | N                  | N                  |
   | False Pos   | N                  | N                  |
   | Quality     | X/5                | Y/5                |

   Winner: Version [A/B]
   Reason: [evidence-based explanation]
   ```

5. **Apply** the winning version (ask user confirmation first)

---

## Mode 4: Benchmark

Run a standardized assessment measuring performance with vs without the skill.

### Process

1. **Load eval set** from Mode 2 (or generate one)

2. **Run WITH skill** — Execute all eval prompts with skill loaded:
   - Track: pass rate, elapsed time, token usage per prompt
   - Record full outputs

3. **Run WITHOUT skill** (baseline) — Same prompts, no skill:
   - Track: same metrics
   - Record full outputs

4. **Compare** using blind Comparator:
   - Comparator receives Output A and Output B (randomized, no labels)
   - Scores each on: accuracy, completeness, format, usefulness
   - Declares winner per prompt

5. **Report**:
   ```
   ## Benchmark — <skill-name>

   | Metric         | With Skill | Without (baseline) | Delta  |
   |---------------|-----------|-------------------|--------|
   | Pass Rate     | X%        | Y%                | +/-Z%  |
   | Avg Time      | Xs        | Ys                | +/-Zs  |
   | Avg Tokens    | X         | Y                 | +/-Z   |
   | Quality Score | X/5       | Y/5               | +/-Z   |

   Comparator Verdict: X/Y prompts won by [skill/baseline]

   ### Classification
   ```

6. **Classify the skill**:
   - **Capability Uplift**: Skill significantly improves output → KEEP
     - If model improves later and passes without skill → flag for retirement
   - **Workflow/Preference**: Skill enforces specific format/process → KEEP ALWAYS
     - These get MORE valuable as model improves
   - **Neutral/Harmful**: Skill doesn't improve or hurts output → RETIRE

---

## Skill Categories

### Capability Uplift Skills
Fill gaps in model knowledge. Examples: CER docs format, app store compliance checklists.
- Have a **retirement date** — when the model learns this natively
- Run benchmarks quarterly to check for outgrowth

### Workflow/Preference Skills
Enforce specific processes. Examples: clean-code conventions, team-sprint orchestration.
- Get MORE valuable over time
- Never retire — they encode YOUR preferences, not model knowledge

---

## Quick Reference

| Mode | Command | What it does |
|------|---------|-------------|
| Create | `/skill-creator create my-skill` | Build a new skill interactively |
| Eval | `/skill-creator eval redhat-cer-docs` | Test triggers and output quality |
| Improve | `/skill-creator improve clean-code` | Optimize description and content |
| Benchmark | `/skill-creator benchmark mobile-ui-design` | Measure with-skill vs without |

## $ARGUMENTS

$ARGUMENTS
