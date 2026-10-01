---
name: code-review
description: This skill should be used to review code before it is handed off and whenever the user asks for a review, for example to review this PR, check this diff, check my code, or ask whether a change is ready to merge, and after finishing any slice or feature. It provides a review procedure and checklist covering scope against the plan, correctness, security, performance, maintainability, tests, and docs, with findings ranked as blocker, should-fix, or nit, and explains when to hand a large diff to the reviewer subagent.
---

# Code review

A review answers one question: should this change go in as it is, and if not, what exactly must change? Good findings are specific, located, and actionable. "Consider improving error handling" is not a finding; "app/routes/orders.py:88 swallows PaymentError, so failed charges return 200" is.

## When to review

- Self-review every slice before handing it over.
- Review the user's code or PR when asked.
- For a large diff (roughly 8 or more files, or 300 or more changed lines), propose a senior-engineer:reviewer subagent (delegation skill). It reviews with fresh eyes and keeps the main context small.

## Procedure

1. Get the diff: `git diff` for uncommitted work, `git diff main...HEAD` for a branch, or the PR diff.
2. Read the plan section or the issue, so you know what the change is meant to do.
3. Check scope: every changed line should trace to the task. Flag unrequested features, drive-by refactors, and formatting churn.
4. Go through references/review-checklist.md in order: correctness, security, performance, maintainability, tests, docs and operations.
5. Run the linters and tests if you can, and report the real results.
6. Write the findings.

## Severity

| Severity | Meaning | Examples |
|---|---|---|
| blocker | Must be fixed before merging | A bug, a security hole, data loss, a broken build, a missing migration |
| should-fix | Fix now unless there is a good reason not to | A missing test for new behavior, a confusing name, duplicated logic, a missing timeout |
| nit | Optional polish | Wording, small style points the formatter does not catch |

## Output

```
Verdict: approve | approve with nits | changes needed

| Severity | Location | Issue | Suggested fix |
|---|---|---|---|

What is good: up to three points.
Tests and checks run: commands and results.
```

## Reviewing the user's code

Be direct and kind. Explain why each finding matters, with an example of the failure it could cause, and show the fix in a few lines of code where that helps. Point out what is done well, too: it shows which habits to keep.
