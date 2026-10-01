---
name: system-design
description: This skill should be used when the user asks to design or architect a system, service, feature, API, data model, or infrastructure, compares architectures, or asks how something should scale, for example when they say design, architecture, HLD, LLD, system design, scalability, microservices versus monolith, queues, caching, or the database schema. It also applies when the user describes an architecture they plan to build, so it can be evaluated honestly. It gives a requirements-first procedure, a design-doc template stored in docs/design/, and checklists for scale, reliability, security, cost, and observability.
---

# System design

Good design starts from requirements and constraints, not from technologies. A design is finished when someone else can build it, run it, and explain why it looks the way it does.

## Procedure

1. Requirements. Write down the functional requirements (what the system does) and the non-functional ones: expected load and growth, latency targets, availability, data size, consistency needs, compliance, budget, and team skills. Ask for anything you cannot infer, with a proposed default for each.
2. Estimates. Turn the load into numbers: requests per second at peak, data written per day, storage after a year. Rough orders of magnitude are enough to rule options in or out.
3. High-level design. Components, data stores, external services, and the flows between them. Draw it as a Mermaid or ASCII diagram.
4. Detailed design. The data model (entities, keys, indexes), the API contracts, background jobs and events, and the one or two hardest parts of the problem.
5. Scale and reliability. Bottlenecks, caching, queues, timeouts, retries, idempotency, failure modes, and how the system degrades.
6. Security, cost, and observability. Use references/design-checklist.md.
7. Trade-offs. For every significant choice, write a decision brief (decision-brief skill) and record the approved choice as an ADR.
8. Write it down from references/design-doc-template.md in docs/design/YYYY-MM-DD-<slug>.md, using the humanize-writing skill. The plan then links to it.

## Defaults worth proposing

- A modular monolith before microservices. Split out a service only when a part needs independent scaling, deployment, or ownership, and say which of these applies.
- Managed services over self-hosted ones when the team is small.
- Synchronous request and response for user-facing reads; a queue for slow, retryable, or bursty work.
- A relational database unless the access patterns clearly fit a document or key-value store.
- Idempotent writes and at-least-once processing, which are simpler and more reliable than exactly-once claims.

## Evaluating the user's design

When the user proposes or describes an architecture, review it before building anything:

1. Restate it in a few lines to confirm you understood it.
2. Say what is good about it and why.
3. List the risks and weaknesses, starting with the one most likely to hurt.
4. Offer one or two better alternatives where they exist, with a short comparison of the trade-offs.
5. Recommend one option and explain the choice in plain language.

Explain every term the first time it appears, as if to someone new to the topic. Do not soften real problems: a design flaw found now is cheap, the same flaw found in production is not. If the user's design is the best option, say so plainly; agreeing for the sake of agreeing helps nobody, and neither does disagreeing for the sake of it.
