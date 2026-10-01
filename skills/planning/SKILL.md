---
name: planning
description: This skill should be used before writing code for any standard or major task, for example when the user asks to plan, build or add a feature, start a new project, refactor, migrate, or implement something that touches several files, and whenever Claude Code is in plan mode. It provides the procedure and templates for plans that a less capable model such as Sonnet can execute in a fresh session without guessing, covering clarifying questions, task sizing, decision briefs, commit-sized slices, per-step verification, the plan file in docs/plans/, and the progress file used to resume work. Use it even when the user does not say the word plan.
---

# Planning

A plan is the contract between the person who decides and the agent who executes. Write it so a cheaper model in a new session, with no access to this conversation, can finish the work without asking a single question. If a step still needs judgment the executor does not have, the plan is not finished.

## Pick the depth

- Trivial (typo, one-line fix, rename, question): no plan. Do the work and summarize it.
- Standard (a bug fix or small change, about 3 files or fewer, no new design decisions): a short plan in chat with four parts: goal, steps (each naming the files it touches), checks (the commands that prove it works), and risks. Wait for approval, then implement.
- Major (a feature, a new project, a refactor, more than about 3 files, or a choice that is expensive to reverse): the full procedure below, with a plan file and a progress file.

Say which mode you picked in one line. The user can override it.

## Procedure for major tasks

1. Sync the repository and create the branch (git-workflow skill).
2. Learn the ground truth. Read the README, CONTRIBUTING, docs/, existing ADRs, and the code paths the task touches. If the search is broad, propose a scout batch first (delegation skill). Record the repo's conventions (engineering-standards skill), because the plan must follow them.
3. Ask clarifying questions in one message. Number them, group them by topic, and give each a proposed default so the user can answer "defaults" for the ones they do not care about. Stop and wait.
4. Write a decision brief for every choice that is expensive to reverse (decision-brief skill). Stop and wait for the decisions.
5. Draft the plan from references/plan-template.md.
6. Check it against references/plan-checklist.md and fix every item that fails.
7. Present it. In chat, give a short summary (goal, decisions, slices, risks) and the plan's path, then ask for approval. In plan mode, files cannot be written yet: show the plan, and make saving it the first action after approval.
8. After approval, create the progress file from references/progress-template.md, then execute one slice at a time, or hand the plan to another session (see "Handing off").

## What "executable without guessing" means

Every step names:
- the exact files to create or change;
- the functions, classes, or components involved, with signatures and types;
- data shapes: request and response bodies, database columns, events, config keys, environment variables;
- the libraries and versions to use, and why;
- edge cases and error behavior;
- the tests to add, by name and by what they assert;
- the command that verifies the step and the result to expect.

A vague step, which is not acceptable:

> Add caching to the user endpoint.

The same step written for an executor:

> In app/services/user_service.py, wrap get_user_profile(user_id: int) -> UserProfile with a Redis cache. Key: user:profile:{user_id}. TTL: 300 seconds. Serialize with UserProfile.model_dump_json(). On a Redis connection error, log a warning and fall through to the database. Delete the key in update_user_profile() after the commit succeeds. Tests in tests/services/test_user_service.py: test_profile_cache_hit, test_profile_cache_miss_populates, test_profile_redis_down_falls_back, test_update_invalidates_cache. Verify with `pytest tests/services/test_user_service.py -q` (expect 4 passed).

Words that show a step is unfinished: "etc.", "as needed", "appropriately", "handle errors", "update the relevant files", "similar to", "and so on", "TBD". Replace each with the specific thing it stands for.

## Code in plans

Always include signatures, types, schemas, API contracts, migration operations, config keys, and exact commands. Include full code only for the tricky parts, where a cheaper model is likely to get it wrong: concurrency and locking, security checks, parsing and regular expressions, money and time arithmetic, data migrations and backfills, retry and idempotency logic, and anything that took several attempts to get right while planning. Never put placeholder code in a plan; a stub the executor must "fill in" is a guess waiting to happen.

## Slices and commits

Split the work into slices. Each slice becomes one commit the user makes:
- one logical change that leaves the build and tests green;
- at most about 10 files and 300 to 400 changed lines;
- tests in the same slice as the code they cover;
- refactors, formatting-only changes, and dependency upgrades in slices of their own.

Order slices so each builds on finished work: preparatory refactors, then schema and migrations, then domain logic, then API or UI, then docs. For each slice list the files, steps, tests, verification commands with expected results, and the commit message (git-workflow skill).

## Libraries, versions, and infrastructure

Prefer what the repository already uses. For anything new, check the current stable version at planning time in the package registry rather than trusting memory, pin it, and note in one line why it beat the alternatives. Name infrastructure exactly (service, region, tier, scaling settings), and send expensive-to-reverse choices through a decision brief.

## Handing off

To run the plan in a fresh session or with a cheaper model, give the user this prompt:

```
Read docs/plans/<file>.md and docs/plans/<file>.progress.md.
Execute only the next unchecked slice, exactly as written, and run its verification commands.
Update the progress file, then stop and give me the commit block for that slice.
If anything in the plan is ambiguous or wrong, stop and ask instead of guessing.
```

## Keeping the plan true

Update the progress file after every step. When reality differs from the plan, change the plan section, log the deviation and its reason in the progress file, and tell the user. Never deviate silently. Plans and progress files are committed with the work, under docs/plans/.
