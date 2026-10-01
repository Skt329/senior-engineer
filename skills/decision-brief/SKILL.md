---
name: decision-brief
description: This skill should be used whenever a choice is expensive to reverse or the user must decide between options, for example picking a library, framework, database, queue, hosting service, or architecture pattern, designing an API contract or data model, choosing a migration strategy, or when the user asks which approach is better, wants pros and cons, or describes a decision they have already made. It produces a beginner-friendly brief with options, pros and cons, effort, risk, cost, and a clear recommendation, and records the outcome as an Architecture Decision Record in docs/decisions/.
---

# Decision briefs

A decision brief gives the user what they need to choose well in a few minutes: the options, what each costs and risks, and a clear recommendation they can accept or overrule. The user is the decision maker; the brief makes the decision informed.

## When to write one

- Full brief: choices that are expensive to reverse, such as a database, a framework, a hosting service, an architecture pattern, an API contract that clients will depend on, a data model, an authentication approach, or a migration strategy.
- One-liner: small choices with an obvious answer. "Using httpx because the repo already uses it; say if you want something else."
- No brief: choices the repository's conventions already settle.

## How to write it

1. State the decision as a question in one sentence.
2. List the context and constraints that matter: load, team, budget, existing stack, deadlines.
3. Give two to four real options. Include "do nothing" or "the simplest thing" when it is viable.
4. For each option: what it is in one plain sentence, pros, cons, effort, risk, running cost, and when it would be the right choice.
5. Recommend one option and say why it wins for this context.
6. Say what would change the recommendation, such as "if traffic grows past N" or "if the team adopts Kubernetes".
7. Ask for the decision, and stop until you have it.

Use references/brief-template.md. It includes a worked example.

## Explain like a teacher

The user wants to learn while deciding. Explain each concept the first time it appears, in one plain sentence, before comparing options: "A message queue holds jobs until a worker is free, so a slow job does not block the web request." Avoid unexplained jargon, give a concrete example where one helps, and keep the brief short enough to read in a few minutes.

## When the user has already decided

Review the decision honestly: what is good about it, the risks, and any better alternative, with the reasoning. Then respect the user's call. If the choice has a serious risk, say so once, clearly, and do not repeat the warning in every message.

## Record the decision

After the user decides, write an ADR from references/adr-template.md in docs/decisions/NNNN-<slug>.md, numbered after the highest existing ADR. Write it with the humanize-writing skill and link it from the plan's Decisions table. When a decision changes later, write a new ADR that supersedes the old one, and mark the old one as superseded; never edit history away.
