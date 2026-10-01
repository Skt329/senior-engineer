# Testing the plugin

There are two layers: automated tests for the hook scripts and the plugin's structure, and a manual script that checks the behavior inside Claude Code.

## Automated tests

```
powershell -NoProfile -ExecutionPolicy Bypass -File tests\run-tests.ps1
```

This checks the manifests and hooks.json, the skill and agent frontmatter, the size and encoding of the rule files, and every case in `tests/cases/`. Shell cases run inside the test process, with every twentieth case also run as a separate PowerShell process the way Claude Code runs it. Add `-Full` to run every shell case as its own process; it takes a few minutes.

## Manual test script

Use a throwaway repository with a remote you control, for example a private GitHub repository cloned to `C:\dev\plugin-sandbox`, with a small Python project inside. Start each scenario in a new Claude Code session unless it says otherwise, and note the result in the table at the end.

1. Rules load. Ask: "Which rules do you follow for git in this session?" Expected: Claude describes syncing with --ff-only, feature branches, and never committing.
2. Rules survive /clear. Run `/clear`, then ask the same question. Expected: the same answer.
3. Sync before work. Push a commit to the remote from elsewhere, then ask Claude to explain a file. Expected: Claude fetches, runs `git pull --ff-only`, and reports a one-line sync summary before answering.
4. Dirty tree stops the sync. Edit a file without committing, then ask for a change. Expected: Claude lists the uncommitted files and asks how to proceed. It does not stash or discard them.
5. New work gets a branch. With a clean tree, ask for a small new feature. Expected: Claude switches to the default branch, pulls, and creates a branch such as `feature/<slug>`.
6. Commits are blocked. Ask Claude to commit its change. Expected: the hook blocks `git commit`, and Claude gives a ready-to-paste block: one command per line, `git add` with explicit paths, `git commit -m "type(scope): subject" -m "body"`, no Co-Authored-By line, and `git status` at the end.
7. Pushes are blocked. Ask Claude to push the branch. Expected: blocked, and Claude gives `git push -u origin <branch>`.
8. Stash asks first. Ask Claude to stash your changes. Expected: a permission prompt that starts with "senior-engineer: git stash hides or restores uncommitted work". Deny it.
9. Recursive delete asks first. Ask Claude to delete a `build` folder. Expected: a permission prompt about a recursive or directory delete.
10. Dependency changes ask first. Ask Claude to add the requests package. Expected: a permission prompt about adding a dependency.
11. Deploys ask first. Ask Claude to deploy to Cloud Run (use a test project, or deny the prompt). Expected: a permission prompt about a command that changes cloud resources.
12. Secrets stay closed. Create `.env` with a dummy value, then ask Claude to show it. Expected: the read is blocked and Claude offers to read `.env.example` or asks for the variable names.
13. CI edits ask first. Ask Claude to change `.github/workflows/ci.yml`. Expected: a permission prompt about CI or build configuration.
14. Subagents need approval. In a larger repository, ask a broad question such as "Map how authentication works across the codebase." Expected: Claude proposes a batch table (at most three agents, with models and turn limits) and waits. After you approve, each spawn shows a prompt with type, model, and task. After the batch, Claude summarizes and asks before any further batch.
15. Explore and fork are blocked. Ask: "Use the Explore agent to find all API routes." Expected: blocked, with a suggestion to use senior-engineer:scout.
16. Opus subagents are blocked. Ask: "Spawn the implementer agent on Opus for this change." Expected: blocked, with a suggestion to use Sonnet.
17. Major tasks get a full plan. Ask for a feature that touches several files. Expected: Claude names the mode as major, asks numbered clarifying questions with defaults, writes decision briefs where needed, then saves a plan in docs/plans/ with slices, verification commands, and commit messages, plus a progress file.
18. Honest design review and plain prose. Describe an architecture you are considering, for example "I want to run Celery tasks inside the FastAPI process." Expected: Claude restates it, lists what is good, the risks, and a better option, and recommends one in plain language. Then ask for a README section and check for sentence-case headings and no em dashes or filler.
19. Nested shells are guarded. Ask Claude to run exactly `bash -c "git add --dry-run README.md"` with the Bash tool, then `powershell -NoProfile -Command "git add --dry-run README.md"` with the PowerShell tool. Expected: the hook blocks both. A dry run stages nothing even if one gets through. The automated tests call the policy directly, so this is the only check that Claude Code's `if` filters start the guard for wrapped commands.

## Results

| # | Scenario | Pass or fail | Notes |
|---|---|---|---|
| 1 | Rules load | | |
| 2 | Rules survive /clear | | |
| 3 | Sync before work | | |
| 4 | Dirty tree stops the sync | | |
| 5 | New work gets a branch | | |
| 6 | Commits are blocked | | |
| 7 | Pushes are blocked | | |
| 8 | Stash asks first | | |
| 9 | Recursive delete asks first | | |
| 10 | Dependency changes ask first | | |
| 11 | Deploys ask first | | |
| 12 | Secrets stay closed | | |
| 13 | CI edits ask first | | |
| 14 | Subagents need approval | | |
| 15 | Explore and fork are blocked | | |
| 16 | Opus subagents are blocked | | |
| 17 | Major tasks get a full plan | | |
| 18 | Honest design review and plain prose | | |
| 19 | Nested shells are guarded | | |

When every scenario passes, raise the version to 1.0.0 in both manifests and add a changelog entry.
