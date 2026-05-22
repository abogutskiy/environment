## Implicit requests

Default behavior when a user's message is not a specific, explicit instruction. Interpret the shape of the message before acting.

### Logs, stack traces, or error output provided (no explicit request)

When the user pastes logs, an error trace, or similar diagnostic output without asking for anything specific:

1. **Analyze first.** Read the output carefully before responding.
2. **Check relation to the current session.** If the error is unrelated to what we've been working on in this session, say so explicitly: "This looks unrelated to the previous context, but here's the answer:" — then continue.
3. **Summarize the problem.** One short paragraph: what the error means and likely root cause.
4. **Suggest approaches to fix.** List plausible fixes, shortest to most involved. Do not implement.
5. **Never fix without being asked.** Pasting an error is not a fix request.

### "Fix this" + logs/error trace

When the user explicitly asks to fix something and provides the error output: skip the "approaches" step and fix it directly. Verify the fix against the error.

### "How do I fix this" / "how to fix"

When the user asks how to fix something: just provide the solution (code, command, or steps). No multi-option analysis unless the answer genuinely depends on unstated context.

### Shortcuts

Prefix shortcuts the user may use when pasting logs OR error traces (both apply equally). Treat the shortcut as equivalent to the expanded request:

- **`f <logs-or-trace>`** → same as "fix" + diagnostic output: fix it directly.
- **`htf <logs-or-trace>`** → same as "how to fix": just provide the solution.
- **`wtf <logs-or-trace>`** → same as the default diagnostic-only flow (analyze, check session relevance, summarize, suggest approaches, don't fix) — but go deeper: more thorough root-cause analysis, more detail on each suggested approach, and mention relevant caveats or adjacent issues worth checking.
