# Architecture Decision Record template

Save as docs/decisions/NNNN-<slug>.md. Number it after the highest existing ADR (0001, 0002, ...). Keep it to one page and write it with the humanize-writing skill.

```markdown
# NNNN. <Decision title, for example "Use Celery with Redis for background jobs">

Date: YYYY-MM-DD
Status: proposed | accepted | superseded by NNNN

## Context
The problem and the constraints that shaped the decision, in a few sentences.

## Options considered
- Option A: one line.
- Option B: one line.
- Option C: one line.

## Decision
What was chosen, in one or two sentences.

## Consequences
- Good: what gets easier.
- Bad: what gets harder, and the costs accepted.
- Follow-ups: work this decision creates.
```

When a decision changes, write a new ADR with "Supersedes NNNN" in its context, and change the old ADR's status to "superseded by" the new number. Leave the rest of the old ADR as it was.
