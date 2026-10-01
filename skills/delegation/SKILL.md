---
name: delegation
description: This skill should be used before spawning any subagent, and whenever the user mentions agents, subagents, parallel work, a codebase-wide search, or research that could be split up. It sets how to propose subagents to the user (count, agent, model, scope, turn limit), how to run them in batches of at most three with a check-in after each batch, which cheap model fits each job, and how to write briefs that stop agents from over-exploring, over-engineering, or burning tokens.
---

# Delegation

A subagent pays off when it absorbs work the main session would otherwise read line by line, and returns a short, checkable answer. It wastes money when it repeats exploration, wanders outside its task, or runs on an expensive model by default. Four or five loosely briefed agents can burn a million tokens in minutes, which is why every spawn needs the user's approval and a tight brief.

## Decide whether to delegate at all

| Situation | Who does it |
|---|---|
| You already know the file or symbol | You, directly |
| One or two searches will answer it | You, directly |
| The answer is spread over many files, or nobody knows where it lives | scout |
| An approved plan has an independent slice and the main context is filling up | implementer |
| A large diff (roughly 8 or more files, or 300 or more lines) needs an independent review | reviewer |
| The work needs design judgment or decisions from the user | You, with the user |

The default is to do the work yourself. Delegate only when it clearly saves context or time.

## Pick the agent and model

| Agent | Model | Tools | Turn limit | Use for |
|---|---|---|---|---|
| senior-engineer:scout | Haiku | Read, Grep, Glob | 12 | Searching, mapping code paths, "where is X used" |
| senior-engineer:implementer | Sonnet | Read, Grep, Glob, Edit, Write, shell | 40 | Executing one approved slice |
| senior-engineer:reviewer | Sonnet | Read, Grep, Glob, shell | 20 | Reviewing a finished diff |

- The built-in Explore agent runs on the session's model and a fork copies the whole conversation, so the agent gate blocks both. Use scout instead.
- The general-purpose agent also inherits the session's model. Use it only when the user asks for it.
- Never request Opus for a subagent unless the user asks. Pass a model parameter only to choose something cheaper than the agent's default.

## Propose before spawning

Send one message, then wait for the answer:

```
Subagent batch 1 (needs your approval)

| # | Agent | Model | Goal | In scope | Out of scope | Turn limit | Returns |
|---|---|---|---|---|---|---|---|
| 1 | scout | Haiku | Map the login and token flow | app/auth/, app/api/routes/login.py | tests, frontend | 12 | file:line map, under 300 words |
| 2 | scout | Haiku | Find every reader of the users table | app/, workers/ | migrations | 12 | list of call sites |

Why delegate: the auth code spans about 40 files, and reading them here would fill the context.
Approve, change, or skip?
```

The agent gate also asks you to confirm each spawn. That prompt is a second check, not a replacement for the proposal.

## Write the brief

Use references/brief-template.md. The parts that matter most:

- One goal per agent, phrased as questions to answer or a result to produce.
- Paths and names, not "find the relevant files". If you do not know the paths, that is a scout's job, not an implementer's.
- An explicit out-of-scope list. Agents expand scope when nothing tells them not to.
- Stop conditions: the turn limit, plus "stop when you have answered the questions" or "stop after reading 15 files".
- A fixed output format with a word limit, so the result fits in the main context.
- The conventions the agent must follow and, for implementers, the exact verification commands.
- Only the context the agent needs. Never paste the conversation, and never ask an agent to "understand the whole codebase".

## Run batches of at most three

1. Launch at most 3 agents in one batch. Parallel implementers must not touch the same files.
2. Wait for every agent in the batch to finish.
3. Read the results and spot-check one or two of the cited file:line references before relying on a claim.
4. Summarize for the user in at most 10 lines: what was found or done, and what is still open.
5. Propose the next batch (again at most 3) or stop. Never start the next batch without the user's go-ahead, even if tokens are left.

## Budgets

The turn limits (12, 40, 20) are the hard budget, and an agent that hits its limit returns partial results. In the brief, add a soft budget such as "expect about 8 tool calls; stop early once the questions are answered". If a batch looks expensive, say so in the proposal.

## Anti-patterns

- One agent per file or per folder.
- An agent for a lookup that takes two tool calls.
- Briefs that say "explore the codebase" or "find anything relevant".
- Letting an agent decide architecture, scope, or which files to change.
- Two implementers editing the same file in parallel.
- Chaining batches without a check-in.
- Re-running an agent with the same brief after it failed. Fix the brief first.
