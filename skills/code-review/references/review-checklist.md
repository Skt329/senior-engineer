# Review checklist

## Scope
- Does every change trace to the plan or the issue?
- Are refactors and formatting kept out of the feature diff?
- Is anything missing that the plan required?

## Correctness
- Edge cases: empty, null, zero, negative, very large, duplicate, unicode input.
- Error paths: is every failure handled or propagated with context, and is the user shown something sensible?
- Boundaries: off-by-one errors, pagination, time windows, time zones, rounding of money.
- Concurrency: races, missing locks, retries that are not idempotent.
- Data: migrations included and reversible, constraints and indexes match the code's assumptions, old data still readable.

## Security
- Inputs validated at the boundary, queries parameterized, no shell injection.
- Authorization and ownership checked on every new endpoint.
- No secrets in code, logs, or test fixtures, and no personal data in logs.
- File paths, URLs, and uploads handled safely.

## Performance
- No N+1 queries, unbounded queries, or loops over user-controlled sizes.
- No blocking calls in async code, and timeouts on network calls.
- New filters and sorts have indexes; caches have TTLs and invalidation.

## Maintainability
- Names say what things are, and the code follows the repository's conventions.
- Functions are small and do one thing; no needless abstraction and no copy-paste.
- No dead or commented-out code, and no TODO without an owner.
- Public functions have docstrings in the repository's style.

## Tests
- New behavior and failure paths are tested at the right level.
- Tests would fail if the behavior broke, and do not depend on order, time, or the network.
- Bug fixes include a regression test.

## Docs and operations
- README, API docs, and the changelog updated where behavior changed.
- New configuration documented, and .env.example updated.
- Logs and metrics are enough to debug the feature in production.
- Deployment needs (migrations, feature flags, new secrets) are called out in the PR.
