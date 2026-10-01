# Plan template

Copy the block below into docs/plans/YYYY-MM-DD-<slug>.md and fill in every section. Remove a section only when it truly does not apply, and leave one line saying why.

```markdown
# <Feature or project>: implementation plan

Status: draft | approved | in progress | done
Date: YYYY-MM-DD
Mode: major
Branch: feature/<slug>
Executor: <for example Sonnet in Claude Code>
Progress file: docs/plans/YYYY-MM-DD-<slug>.progress.md

## 1. Goal
Two or three sentences: what changes for users or the system, and why.

## 2. Non-goals
What this plan deliberately leaves out, so the executor does not add it.

## 3. Context
- Repository facts: stack and versions, entry points, how to run and test.
- Conventions to follow (paste the summary from the existing-repo audit).
- Constraints: deadlines, budgets, compatibility, environments.

## 4. Decisions
| Decision | Choice | Why | ADR |
|---|---|---|---|

## 5. Design
- Components and how they interact (a Mermaid or ASCII diagram if it helps).
- Data model changes: tables or collections, columns, types, constraints, indexes.
- API contracts: method, path, request body, response body, error codes.
- Background jobs, events, and schedules.
- Error handling, retries, idempotency, and timeouts.
- Security and privacy notes.

## 6. Slices
| # | Commit message | Files | Verify |
|---|---|---|---|

### Slice 1: <commit subject>
Files:
- path/to/file.py (new | changed)
Steps:
1. ...
Code for the tricky part (only if needed):
Tests:
- test_name: what it asserts
Verify: `<command>`, expected `<result>`
Commit message:
- subject: type(scope): subject
- body: why the change was made

## 7. Verification
- Automated: the full commands, in order.
- Manual: numbered steps a person can follow, each with the expected result.

## 8. Risks and mitigations
| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|

## 9. Rollback
How to undo each slice or the whole feature, including data and config.

## 10. Open questions
Anything unresolved, with the default the executor should use.

## 11. Executor notes
Rules that are easy to miss: files not to touch, commands not to run, conventions that differ from the usual.
```
