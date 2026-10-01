# Pull request description template

Write the description with the humanize-writing skill. Keep each section short; reviewers read the first lines and skim the rest.

```markdown
## Summary
Two to four sentences: what this changes and why. Link the plan or issue if there is one.

## Changes
- One line per commit or per area, in the order a reviewer should read them.

## How to test
1. Steps a reviewer can follow, with the expected result for each.

## Risks and rollback
What could go wrong in production, how you would notice, and how to undo it (for example: revert the merge commit; the migration is backwards compatible).

## Screenshots
Before and after, for any UI change. Delete this section otherwise.

## Follow-ups
Work deliberately left for later, with the reason.
```

Title: use the subject of the main commit, for example `feat(auth): add refresh token endpoint`.
