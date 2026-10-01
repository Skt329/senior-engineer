# Subagent brief template

Fill in every field. A brief that fits on one screen is usually a good brief.

```
Role: <scout | implementer | reviewer> working for the main agent on <project>.

Goal: <the questions to answer or the result to produce, in one or two sentences>

Context:
- Plan section: docs/plans/<file>.md, slice <n> (implementers and reviewers)
- Key files: <paths>
- Conventions to follow: <three to six bullets from the repo audit>

In scope: <paths, modules, or questions>
Out of scope: <what to leave alone>

Steps or questions:
1. ...

Stop conditions:
- Turn limit <n>. Expect about <m> tool calls.
- Stop as soon as the goal is met.
- Stop and report if you need files outside the scope, or if the same approach fails twice.

Verification (implementers): <exact commands and the expected result>

Output: <the sections to return>, at most <n> words.
```

## Filled example: scout

```
Role: scout working for the main agent on the payments service.
Goal: Where are payment webhooks received, validated, and turned into database writes?
Context:
- Key files: app/api/routes/, app/services/
In scope: app/
Out of scope: tests/, migrations/, frontend/
Questions:
1. Which route receives provider webhooks, and how is the signature checked?
2. Which service functions write payment status, and which tables do they touch?
Stop conditions: turn limit 12, expect about 8 tool calls, stop when both questions are answered.
Output: Answer, Evidence (path:line), Not checked. At most 300 words.
```

## Filled example: implementer

```
Role: implementer working for the main agent on the payments service.
Goal: Execute slice 3 of docs/plans/2026-10-01-webhook-retries.md: retry failed webhook processing with exponential backoff.
Context:
- Plan section: slice 3 (read it first, then the progress file)
- Key files: app/workers/webhooks.py, tests/workers/test_webhooks.py
- Conventions: Celery tasks take IDs not objects; structured logging through app.core.logging; tests use the celery_eager fixture.
In scope: app/workers/webhooks.py, tests/workers/test_webhooks.py
Out of scope: everything else, including settings and migrations.
Stop conditions: turn limit 40; stop and report if the slice needs other files or if a test fails twice for the same reason.
Verification: pytest tests/workers/test_webhooks.py -q (expect 6 passed), ruff check app/workers (expect no errors).
Output: Summary, Files changed, Verification, Deviations, Open issues. At most 400 words.
```

## Filled example: reviewer

```
Role: reviewer working for the main agent on the payments service.
Goal: Review the change on the current branch against slice 3 of docs/plans/2026-10-01-webhook-retries.md.
Context:
- Diff: git diff main...HEAD
- Checklist: correctness of retry limits, idempotency of the task, logging without secrets.
In scope: the files in the diff.
Out of scope: code outside the diff, style nits already covered by ruff.
Stop conditions: turn limit 20.
Output: Verdict, Findings table, What is good, Tests run (do not run tests). At most 400 words.
```
