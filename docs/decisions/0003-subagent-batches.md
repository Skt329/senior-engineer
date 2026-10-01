# 0003. Ask before every subagent and limit batches to three

Date: 2026-10-01
Status: accepted

## Context
Several loosely briefed subagents running at once burned through tokens in minutes. The user wants to approve subagents before they start, to keep them on cheap models, and to work in batches of at most three with a check-in after each batch.

## Options considered
- A rule in the standing rules only.
- An approval prompt for every spawn (a PreToolUse hook that returns ask), plus the batch rule in the standing rules and the delegation skill.
- A hard counter that tracks spawns in a state file and blocks the fourth one.

## Decision
The agent gate asks for approval on every spawn and shows the agent type, model, and task. The batch limit of three and the check-in are rules in core-rules.md and the delegation skill, which also requires a proposal table before any batch. The hard counter is deferred to v0.2.

## Consequences
- Good: no subagent starts without the user seeing it, and the proposal makes cost visible before it is spent.
- Bad: one extra approval per spawn. The batch limit relies on Claude following the rules, backed only by those approvals.
- Follow-ups: build the counter in v0.2 if manual testing shows the rule is not enough.
