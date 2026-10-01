# Incident response

## Severity
| Level | Meaning | Example |
|---|---|---|
| SEV1 | Most users cannot use the product, or data is being lost or exposed | Site down, payments failing for everyone, data leak |
| SEV2 | A major feature is broken for many users | Login failing for one region, a key API erroring often |
| SEV3 | A minor feature is broken, or there is a workaround | Exports slow, one screen broken |
| SEV4 | Cosmetic or very limited impact | A typo, a rare edge case |

## During the incident
1. Stabilize first. The fastest safe fix is usually a rollback, a feature flag switched off, or traffic moved to the last good revision. Find the root cause later.
2. Communicate. Say what is broken, who is affected, what is being done, and when the next update comes. Update regularly, even when there is no news.
3. Keep a timeline: what happened, when, and who did what. It feeds the postmortem.
4. Change one thing at a time, and note each change.

Claude's role: read logs and metrics, form hypotheses, prepare rollback and fix commands, and draft updates. The user approves and runs every change to production.

## After the incident: blameless postmortem
Write it within a few days, with the humanize-writing skill. Blameless means it asks how the system allowed the mistake, not who made it.

```markdown
# Postmortem: <title>

Date: YYYY-MM-DD   Severity: SEVn   Duration: <start to end>

## Summary
Two or three sentences: what broke, the impact, and how it was fixed.

## Impact
Who was affected, how many, and for how long. Data loss, if any.

## Timeline
- HH:MM: event

## Root cause
What actually caused it, and why the safeguards did not catch it.

## What went well

## What went poorly

## Action items
| Action | Owner | Due | Type (prevent, detect, mitigate) |
|---|---|---|---|
```
