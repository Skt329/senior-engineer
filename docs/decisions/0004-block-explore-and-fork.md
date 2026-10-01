# 0004. Block the built-in Explore agent, fork subagents, and Opus subagents

Date: 2026-10-01
Status: accepted

## Context
The built-in Explore agent inherits the session's model (Claude Code 2.1.198), which is Opus in planning sessions. Fork subagents are on by default and copy the whole conversation (2.1.232). Both make broad searches expensive. The plugin's scout agent does the same job on Haiku with read-only tools.

## Options considered
- Allow them as usual.
- Ask before each one, like any other subagent.
- Deny them by default, with an environment variable to turn them back on.

## Decision
The agent gate denies Explore and fork subagents unless `SENIOR_ENGINEER_ALLOW_BUILTIN_AGENTS=1` is set, and denies any subagent on Opus unless `SENIOR_ENGINEER_ALLOW_OPUS_SUBAGENTS=1` is set. Each denial tells Claude which plugin agent to use instead.

## Consequences
- Good: searches run on Haiku, and no subagent quietly runs on the most expensive model.
- Bad: Claude cannot use those built-in conveniences without the override, and the general-purpose agent still inherits the session model (the gate warns about it in the approval prompt).
- Follow-ups: revisit if Claude Code lets plugins set the model of built-in agents.
