---
name: debugging
description: This skill should be used when something is broken or behaves unexpectedly, for example a bug report, an error message or stack trace, a failing or flaky test, a crash, wrong output, a performance regression, or "it works locally but not in production". It enforces a reproduce, isolate, hypothesize, and verify loop that finds the root cause before changing code, adds a regression test, and stops to ask after two failed fix attempts instead of piling up guesses.
---

# Debugging

The fastest way to fix a bug is to understand it first. Changing code until the symptom disappears hides the cause, and the bug returns in a different form.

## The loop

1. Sync first (git-workflow skill). The bug may already be fixed on origin.
2. Reproduce. Get the exact error, stack trace, inputs, environment, and steps. Make it happen on demand, ideally as a failing automated test. If you cannot reproduce it, say so and collect more evidence (logs, versions, data) before changing anything.
3. Isolate. Narrow down where it happens: the smallest input that triggers it, the last version that worked (`git log`, and `git bisect` with the user's approval), and the component where good data turns bad. Add temporary logging if needed.
4. Hypothesize. Write down one to three possible causes, each with a prediction you can check: "If the cache returns stale data, clearing key X will fix the second request."
5. Test the hypothesis with the smallest experiment possible. Read the code path end to end, and confirm the cause with evidence, not intuition.
6. Fix the root cause, not the symptom. A fix that only makes the error message go away (catching and ignoring the exception, adding a null check without knowing why the value is null) is not a fix.
7. Prove it. The failing test now passes, the full suite still passes, and the original reproduction steps no longer fail. Remove temporary logging.
8. Report with references/debug-report-template.md.

## The loop breaker

If two fix attempts fail, stop. Write down what you tried, what happened, and what you now believe, and ask the user before trying a third approach. Repeated guessing burns time and tokens and tends to break other things. A fresh look at the evidence, or information only the user has, usually breaks the deadlock.

## Common causes to check

- Stale state: caches, old builds, an outdated checkout, unapplied migrations, environment variables from another environment.
- Environment differences: versions, time zones, locale, file paths and separators, line endings, permissions, network access.
- Data: nulls, empty collections, duplicates, unexpected encodings, very large values, and data written by an older version.
- Concurrency: race conditions, missing locks, non-idempotent retries, tasks running twice.
- Boundaries: off-by-one errors, pagination edges, time-window edges, integer overflow, floating-point money.

## Flaky tests

Treat flakiness as a bug with a real cause: shared state between tests, order dependence, timing and sleeps, real network calls, unseeded randomness, or time zones. Run the test repeatedly to reproduce, then fix the cause (testing skill).

## Production issues

Do not change production while debugging. Read logs and metrics, reproduce locally or in staging, and leave deploys, rollbacks, and data fixes to the user's approval (deployment skill, incident-response reference).
