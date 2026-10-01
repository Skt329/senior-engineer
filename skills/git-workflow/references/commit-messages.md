# Commit messages

## Types

| Type | Use for |
|---|---|
| feat | A new capability for users or callers |
| fix | A bug fix |
| refactor | A code change that neither fixes a bug nor adds a feature |
| perf | A change that makes something faster or cheaper |
| test | Adding or fixing tests only |
| docs | Documentation only |
| build | Build system, packaging, or dependency changes |
| ci | CI configuration |
| chore | Maintenance that fits nowhere else (tooling config, renames) |
| revert | Reverting an earlier commit |

## Good examples

```
git commit -m "feat(api): add pagination to GET /orders" -m "The endpoint returned every order in one response, which timed out for large accounts. It now takes limit and cursor parameters and returns at most 100 orders per page."

git commit -m "fix(worker): stop retrying webhooks that fail validation" -m "Invalid payloads were retried five times and filled the dead-letter queue. Validation errors now fail the task at once and log the provider event ID."

git commit -m "refactor(auth): move token signing into TokenService" -m "Signing logic was duplicated in the login and refresh routes. No behavior change."

git commit -m "feat(android): show offline banner on the home screen" -m "The home screen spun forever without a network. HomeViewModel now exposes an offline state and the screen shows a banner with a retry button."

git commit -m "build(deps): pin httpx to 0.27.2" -m "0.28 changed proxy arguments and broke the payment client."

git commit -m "ci: run mypy on pull requests"

git commit -m "docs(readme): document local setup on Windows"
```

## Breaking change

```
git commit -m "feat(api)!: require API version header" -m "Requests without X-Api-Version are now rejected with 400." -m "BREAKING CHANGE: clients must send X-Api-Version: 2."
```

## Bad examples and fixes

| Bad | Problem | Better |
|---|---|---|
| `fixed stuff` | No type, says nothing | `fix(cart): keep discount when quantity changes` |
| `feat: Added new endpoint.` | Past tense, capitalized, period | `feat(api): add endpoint for order refunds` |
| `update files` | Describes the diff, not the change | `refactor(db): replace raw SQL in order queries with SQLAlchemy` |
| `feat(auth): add refresh tokens and fix logging and bump deps` | Three changes in one commit | Three commits: feat, fix, build |
| Body: "This commit leverages a robust approach to enhance..." | AI filler | Say what changed and why, in plain words |

## Writing the body

- Say why first: the problem, the bug, or the need.
- Then what changed, at the level a reviewer cares about. The diff shows the how.
- Mention anything surprising: a behavior change, a migration, a config change.
- Wrap long paragraphs into separate `-m` arguments instead of very long lines.
