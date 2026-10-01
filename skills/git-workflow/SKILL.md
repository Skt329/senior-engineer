---
name: git-workflow
description: This skill should be used at the start of every coding or code-analysis task inside a git repository, and whenever work reaches a commit point, needs a branch, or is ready for a pull request. It covers syncing with origin before reading or changing code (fetch, fast-forward pull, and what to do with a dirty or diverged tree), creating feature branches from the updated default branch, slicing work into small reviewable commits, Conventional Commit messages, PR descriptions, and ready-to-paste commands that work in PowerShell and Git Bash. Claude never commits, pushes, or merges.
---

# Git workflow

Two rules shape everything here. First, work on the latest code: bugs already fixed on origin should never be re-fixed or analyzed in a stale checkout. Second, the user owns history: Claude prepares changes and commit blocks, and the user runs every command that writes history. The plugin's shell guard enforces the second rule.

## Commands Claude may run

- Read-only: status, diff, log, show, blame, ls-files, rev-parse, rev-list, symbolic-ref, branch (listing), remote -v, stash list, config --get.
- Syncing and branching: `git fetch`, `git pull --ff-only`, `git switch <branch>`, `git switch -c <new-branch>`, `git checkout -b <new-branch>`.
- Everything else that changes history, the index, or the working tree (add, commit, push, merge, rebase, reset, restore, revert, cherry-pick, clean, stash) belongs to the user. When the guard blocks one, explain why and give the user the command. Do not try another way to run it.

## Start of every task: sync with origin

Run these in order and act on the result:

```
git rev-parse --is-inside-work-tree
git status --porcelain=v1 --branch
git remote
git fetch --prune origin
git rev-parse --abbrev-ref --symbolic-full-name "@{u}"
git rev-list --left-right --count "HEAD...@{u}"
```

Keep the quotes around `@{u}`: in PowerShell, `@{` starts a hashtable and the command breaks without them.

| What you see | What to do |
|---|---|
| Not a git repository | Say so in one line and continue without syncing |
| Uncommitted changes in `git status` | Stop. Show the changed files and ask the user whether to continue on top of them or let them commit or stash first. Never stash, reset, or discard them yourself |
| No remote | Say "no remote, skipping sync" and continue |
| No upstream for the current branch | Say so. If the task is new work, follow "Starting new work" below |
| Behind only (second number greater than 0, first is 0) | Run `git pull --ff-only` |
| Ahead only | Fine. Mention that there are unpushed commits |
| Both numbers greater than 0 (diverged) | Stop. Explain that local and remote both have new commits, and let the user decide how to reconcile them |
| Detached HEAD, a rebase, or a merge in progress | Stop and ask |

Finish with one line, for example: "Synced: on feature/refresh-tokens, up to date with origin (pulled 3 commits)."

## Find the default branch

```
git symbolic-ref --short refs/remotes/origin/HEAD
```

This prints something like `origin/main`. If it fails, read the "HEAD branch" line of `git remote show origin`. If that fails too, check whether `origin/main` or `origin/master` exists with `git show-ref --verify refs/remotes/origin/main`. If CONTRIBUTING or the README describes a different base for new work (for example `develop`), follow it.

## Starting new work

For a new feature, fix, or other change that deserves its own branch:

```
git switch main
git pull --ff-only
git switch -c feature/refresh-tokens
```

- The working tree must be clean before switching. If it is not, stop and ask.
- If you are already on a feature branch, ask whether the task belongs there before creating another one.
- Branch names are `<type>/<short-kebab-slug>`, at most about 50 characters. Types: feature, fix, chore, docs, refactor, test, perf. Use ticket IDs only if the repository already does.
- Do not push. At handoff, give the user `git push -u origin <branch>`.

## Slicing work into commits

- One logical change per commit, leaving the build and tests green.
- At most about 10 files and 300 to 400 changed lines. Split anything bigger.
- Tests go in the same commit as the code they cover.
- Refactors, formatting-only changes, and dependency upgrades go in separate commits. Lockfile changes go with the change that caused them.
- Order: preparatory refactors, then schema and migrations, then logic, then API or UI, then docs.

After each slice, stop and hand over the commit block. Start the next slice only after the user says it is committed.

## The ready-to-paste block

```
git add app/auth/tokens.py app/api/routes/auth.py tests/auth/test_tokens.py
git commit -m "feat(auth): add refresh token endpoint" -m "Clients can trade a refresh token for a new access token without signing in again. Tokens rotate on every use and expire after 30 days."
git status
```

Rules for the block:
- One command per line. Windows PowerShell 5.1 has no `&&`.
- `git add` with explicit paths, never `git add .` or `git add -A`. Include deleted and renamed paths too; `git add` stages a deletion for a path given explicitly.
- Quote paths that contain spaces.
- Subject in the first `-m`, body in the second. Add one `-m` per extra paragraph.
- Inside messages, avoid double quotes, backticks, `$`, and `!`. PowerShell expands `$` and backticks inside double quotes, and interactive Git Bash expands `!`. Plain ASCII only.
- No `Co-Authored-By` lines, no "Generated with" footers, no AI attribution of any kind, and no emoji.
- End with `git status` so the user can confirm the tree is clean, then wait for them.

## Commit messages

Use Conventional Commits: `type(scope): subject`.
- Types: feat, fix, refactor, perf, test, docs, build, ci, chore, revert.
- Scope: the module or area, such as auth, api, worker, android, infra.
- Subject: imperative mood, lowercase after the colon, no period, at most 72 characters.
- Body: why the change was made and what it changes, in plain sentences. Write it with the humanize-writing skill.
- Breaking changes: add `!` after the type or scope, and a paragraph that starts with `BREAKING CHANGE:`.

references/commit-messages.md has good and bad examples.

## Pull requests

When the branch is ready, write the PR description with references/pr-template.md and the humanize-writing skill, and give the user:

```
git push -u origin feature/refresh-tokens
```

The user opens and merges the pull request. Do not run `gh pr create` or `gh pr merge` unless the user asks for it; the guard asks or blocks.

## End-of-task handoff

List the commits made so far and any pending commit blocks, the branch push command, the PR title and description, and anything the reviewer should look at first.
