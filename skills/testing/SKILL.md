---
name: testing
description: This skill should be used whenever code is written or changed and when the user asks about tests, test strategy, coverage, TDD, mocks, fixtures, flaky tests, or how to verify a change, for example to write tests, add a test plan, or test a feature. It covers deciding what to test at each level, writing a failing test first for bugs, mocking only at system boundaries, test naming and structure, coverage targets, and verification commands, with guides for pytest with FastAPI and Celery, Android with JUnit and Compose, and web frontends with Vitest and Playwright.
---

# Testing

Tests are how a change proves it works, today and after the next ten changes. A test earns its place when it would fail if the behavior broke and pass when an implementation detail changes.

## What to test at each level

| Level | Checks | Speed | Share |
|---|---|---|---|
| Unit | One function or class, with no I/O | Milliseconds | Most tests |
| Integration | A component with its real neighbors: database, cache, framework | Seconds | Each important path |
| End-to-end | The system the way a user drives it | Slow | A few critical journeys |

Business rules, calculations, parsing, validation, state machines, and permission checks deserve unit tests. Queries, migrations, API contracts, and serialization deserve integration tests. Sign-in, payment, and the main user journey deserve end-to-end tests.

## Rules

- For a bug, write the test that reproduces it first, watch it fail, then fix the code. The test stays as a regression guard.
- For new behavior, write tests in the same slice as the code. Writing them first is encouraged when the behavior is clear.
- Test behavior through public interfaces, not private helpers or call order.
- Mock only at system boundaries: external HTTP APIs, payment providers, email and SMS, the clock, randomness, and the file system when needed. Use a real database (in a container or a test instance) for repository and integration tests instead of mocking the ORM.
- Every test is independent: it creates its own data and does not depend on test order.
- No real network calls, no sleeps (control time instead), and no reliance on wall-clock time zones.
- Cover failure paths: invalid input, missing records, permission denied, timeouts, retries, and duplicate deliveries.

## Naming and structure

- Names describe the behavior: `test_refund_fails_when_order_already_refunded`, not `test_refund_2`.
- Structure each test as arrange, act, assert, with one behavior per test.
- Put shared setup in fixtures or factories, not in copied blocks.
- Mirror the source layout in the test folder unless the repository does it differently.

## Coverage

Coverage shows what is not tested; it does not show what is tested well. Aim for about 80 percent line coverage on business logic, and do not lower coverage with a change. Never write assertion-free tests to raise the number.

## Flaky tests

A test that sometimes fails is a bug. Find the cause (shared state, timing, ordering, network, randomness) and fix it. Never add retries to hide it, and never delete it without telling the user.

## Test plans for major tasks

For major tasks, add a test plan to the plan (references/test-plan-template.md): what is tested at which level, the data needed, and the manual checks.

## Verification commands

Every slice ends with the commands that prove it works, and the report gives the real results: "14 passed, 0 failed", never "should pass". If tests cannot run in this environment, say so and give the user the command.

## Stack guides

- references/testing-python.md for pytest, FastAPI, SQLAlchemy, and Celery.
- references/testing-android.md for JUnit, coroutines, Flow, Room, and Compose.
- references/testing-web.md for Vitest, Testing Library, and Playwright.
