# Decision brief template

```markdown
## Decision: <the question, in one sentence>

Context: <the constraints that matter: load, team, budget, existing stack, deadlines>

Terms used here:
- <term>: <one plain sentence>

| | Option A | Option B | Option C |
|---|---|---|---|
| What it is | | | |
| Pros | | | |
| Cons | | | |
| Effort | low, medium, or high | | |
| Risk | | | |
| Running cost | | | |
| Best when | | | |

Recommendation: <option>, because <the reason that matters most here>.
This would change if: <conditions>.

Your call: A, B, or C?
```

## Worked example

```markdown
## Decision: How should the API run slow background jobs such as report generation and webhook delivery?

Context: FastAPI on Cloud Run, Redis already used for caching, a team of two, about 2,000 jobs a day, and jobs must not be lost when an instance restarts.

Terms used here:
- Task queue: a list of jobs waiting for a worker. The web request adds a job and returns immediately; a separate worker process runs it.
- Broker: the service that stores the queue. Redis can do this job.
- Idempotent: safe to run twice with the same result, which matters because queues may deliver a job more than once.

| | Celery with Redis | RQ with Redis | Cloud Tasks |
|---|---|---|---|
| What it is | The most widely used Python task queue, with retries, schedules, and routing built in | A small, simple Python queue on Redis | A managed Google service that calls your HTTP endpoint for each job |
| Pros | Mature, rich retry and scheduling options, large community | Very little to learn, easy to debug | Nothing to run or patch, per-queue rate limits, retries built in |
| Cons | Many settings to get right, needs a worker service and monitoring | Fewer features, no built-in periodic jobs, smaller community | Ties the design to GCP; each job is an HTTP request with a time limit; local testing needs an emulator or a fake |
| Effort | Medium | Low | Medium |
| Risk | Misconfigured acks or visibility timeouts can lose or repeat jobs | Outgrowing it if needs get complex | Lock-in, and debugging spans two systems |
| Running cost | One worker service plus Redis, which already exists | Same as Celery | Pay per task; free tier covers this volume |
| Best when | Jobs are varied, need schedules or chains, and will grow | Jobs are few and simple | The team wants zero queue infrastructure and stays on GCP |

Recommendation: Celery with Redis, because the team already runs Redis, the jobs need retries and a daily schedule, and Celery handles both without new infrastructure.
This would change if: the team wants no worker service at all (choose Cloud Tasks), or the jobs stay this simple for the next year (RQ is enough).

Your call: Celery, RQ, or Cloud Tasks?
```
