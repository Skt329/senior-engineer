# Testing Python services: pytest, FastAPI, SQLAlchemy, Celery

## Layout and commands
- tests/unit for pure logic, tests/integration for anything with a database, cache, or framework, plus a shared tests/conftest.py.
- Run one file with `pytest tests/unit/test_pricing.py -q`, one test with `pytest -k test_name -q`, and the suite with coverage using `pytest --cov=src --cov-report=term-missing -q`.

## Fixtures and factories
- Keep fixtures small and composable. Use factory functions or factory_boy for model instances instead of large shared objects.
- Use `tmp_path` for files and `monkeypatch` for environment variables.

## FastAPI
- Use `TestClient` (or `httpx.AsyncClient` with an ASGI transport for async apps) against an app built by the app factory.
- Override dependencies instead of patching internals:

```python
app.dependency_overrides[get_current_user] = lambda: make_user(role="admin")
```

- Clear overrides in fixture teardown.
- Assert on status code, response body, and side effects such as database rows and queued tasks.

## Database
- Run integration tests against the same database engine as production (PostgreSQL in a container, for example with testcontainers or a docker compose service), not SQLite, when the code uses engine-specific features.
- Wrap each test in a transaction that is rolled back, or recreate the schema per session and truncate tables between tests.
- Test migrations: upgrade to head on an empty database, and for risky migrations, upgrade from the previous revision with sample data.

## Async code
- pytest-asyncio or anyio for async tests. Avoid mixing event loops between fixtures and tests.

## Celery
- Unit-test the task's function body directly with plain arguments.
- Eager mode (`task_always_eager=True`) only for quick unit tests; it hides serialization and retry behavior.
- For integration, use the celery_worker pytest fixtures from Celery's test plugin, or a real worker against a test Redis.
- Test idempotency: run the task twice with the same input and assert one side effect.
- Test retries by raising the transient error and asserting that a retry was scheduled.

## External services and time
- HTTP: respx (for httpx) or responses (for requests) to stub calls, and assert on the requests made.
- Time: freezegun or time-machine, or inject a clock.
- Redis: fakeredis for unit tests, and a real Redis for integration tests of locks and expiry.
