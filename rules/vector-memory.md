# Vector Memory - Automatic Context Management

## On conversation START
When the user's first message relates to a project, past work, or continuing previous work:
- Call `mcp__vector-memory__search_memory` with a query based on the user's message (limit=3)
- Only call `search_conversations` if the user explicitly references a past conversation
- Skip memory search for simple, self-contained requests (e.g., "fix this typo", "what time is it")

## During conversation
Store memories ONLY for high-value information that will be useful in future conversations:
- `decision` — architectural or technical decisions
- `preference` — how the user likes to work
- `feedback` — corrections to Claude's behavior
- `architecture` — system design, tech stack choices
Do NOT store: temporary debugging info, one-off questions, or info already in CLAUDE.md/git

## On conversation END (triggered by Stop hook)
Store a conversation summary ONLY if the conversation involved:
- Significant code changes or new features
- Important decisions or architecture discussions
- New project setup or configuration
Skip for: quick fixes, simple questions, or short interactions (< 5 exchanges)

## Rules
- Search memory BEFORE asking the user for context they may have already provided
- Be concise — optimize for retrieval, not readability
- Do NOT store duplicates — search before storing
- Prefer limit=3 over limit=5 to reduce token usage
