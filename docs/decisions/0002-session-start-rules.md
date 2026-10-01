# 0002. Inject the standing rules with a SessionStart hook

Date: 2026-10-01
Status: accepted

## Context
The user repeats the same instructions in every session. They need to be present from the first message, survive /clear and compaction, ship with the plugin, and reach subagents in a shorter form. Claude Code moves hook output over 10,000 characters into a file instead of the context.

## Options considered
- A user-level CLAUDE.md maintained by hand.
- An output style.
- A SessionStart hook that injects a rules file, plus a SubagentStart hook for subagents.
- Skills only, with no always-on rules.

## Decision
A SessionStart hook injects `context/core-rules.md`, capped at 7,500 characters, and fires again after /clear and compaction. A SubagentStart hook injects `context/subagent-rules.md`. The detailed procedures live in skills that load on demand. Users also set the attribution setting to its object form, `{ "commit": "", "pr": "" }`, so Claude Code stops suggesting Co-Authored-By lines; the shorter `false` form needs 2.1.281, and older versions skip the whole settings file that contains it.

## Consequences
- Good: one install sets everything up, the rules are versioned with the plugin, and they return after /clear and compaction.
- Bad: the rules file must stay short, so details have to move into skills. The rules arrive as hook context rather than as CLAUDE.md, which is why the attribution setting matters.
- Follow-ups: the tests check the size and encoding of both files.
