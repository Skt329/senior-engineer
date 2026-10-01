# Progress file template

The progress file lets any session, or a different model, pick up the work exactly where the last one stopped. Keep it next to the plan as docs/plans/YYYY-MM-DD-<slug>.progress.md and update it after every step, not at the end.

```markdown
# Progress: <plan title>

Plan: docs/plans/YYYY-MM-DD-<slug>.md
Branch: feature/<slug>
Last updated: YYYY-MM-DD HH:MM by <agent or person>

## Slices
- [x] 1. feat(auth): add refresh token model and migration
- [~] 2. feat(auth): add token refresh endpoint
- [ ] 3. docs(auth): document the refresh flow

Markers: [ ] to do, [~] in progress, [x] done and committed, [!] blocked (say why below)

## Log
- YYYY-MM-DD: slice 1 done. `pytest tests/auth -q` gave 14 passed. Committed by the user.
- YYYY-MM-DD: slice 2 deviates from the plan: the token table needs an index on user_id; the plan section was updated.

## Pending commit blocks
<finished slices the user has not committed yet, each with its ready-to-paste block>

## Next step
<one line telling the next session exactly where to start>
```
