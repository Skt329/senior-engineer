# Design document template

Save as docs/design/YYYY-MM-DD-<slug>.md and write it with the humanize-writing skill.

```markdown
# <System or feature>: design

Status: draft | approved | superseded by <link>
Date: YYYY-MM-DD
Author: <name>

## Context
What problem this solves and why now. Link the request, issue, or plan.

## Requirements
Functional:
- ...
Non-functional:
- Load: peak requests per second, daily active users, growth
- Latency: p95 target for the main operations
- Availability and recovery: target uptime, acceptable data loss
- Data: size now and in one year, retention, consistency needs
- Security and compliance:
- Budget and team constraints:

## Estimates
Back-of-the-envelope numbers and how they were calculated.

## High-level design
Diagram (Mermaid or ASCII) and a short walk through the main flows.

## Data model
Entities, fields, keys, indexes, and relationships.

## APIs and events
Endpoints with request and response shapes and error codes; events with their payloads and producers and consumers.

## Detailed design
The hardest parts: algorithms, concurrency, consistency, and migration of existing data.

## Scale and reliability
Bottlenecks, caching, queues, timeouts and retries, failure modes and how the system degrades.

## Security
Authentication, authorization, data protection, and secrets.

## Observability
Logs, metrics, traces, dashboards, and the alerts that wake someone up.

## Cost
Expected monthly cost at launch and at the one-year estimate, and the main cost drivers.

## Alternatives considered
Each alternative and why it was not chosen. Link the ADRs.

## Rollout and migration
How this reaches production safely, and how to roll it back.

## Open questions
```
