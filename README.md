# senior-engineer

Claude Code that plans like a senior engineer, asks before it spawns subagents, and never touches your git history.

[![tests](https://github.com/Skt329/senior-engineer/actions/workflows/tests.yml/badge.svg)](https://github.com/Skt329/senior-engineer/actions/workflows/tests.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
![Platform: Windows](https://img.shields.io/badge/platform-Windows-0078D6.svg)

<!-- Demo: drag the GIF into any GitHub issue or PR comment box, copy the https://github.com/user-attachments/... link it creates, and replace this comment with ![senior-engineer demo](that link). Keeping the GIF out of the repo keeps binaries out of the plugin. -->

senior-engineer is a Claude Code plugin for Windows. Its hooks refuse the git commands that change history, ask you before every subagent, and stop the Read tool from opening `.env` files and keys. Its standing rules make Claude size each task, read the repository first, and get your approval on a plan before it builds anything large. When a piece of work is done, Claude gives you the commit commands and you run them.

This is what a blocked push looks like. The hook message is quoted exactly; the rest is shortened.

```text
Claude: git push -u origin feature/refresh-tokens

Hook:   senior-engineer: Claude does not run 'git push'.
        Prepare the change and give the user a ready-to-paste
        command block instead (git-workflow skill). Do not try
        another way to run it.

Claude: The slice is done and the tests pass. Run these:

        git add src/auth/tokens.py tests/test_tokens.py
        git commit -m "feat(auth): add refresh tokens"
        git push -u origin feature/refresh-tokens
```

## Why

It targets three things that go wrong in Claude Code sessions:

- Subagents burn through tokens. Since Claude Code 2.1.198 the built-in Explore agent inherits the session's model, which is Opus in a planning session, and a fork subagent copies the whole conversation. With this plugin every spawn needs your approval, the plugin's own agents are pinned to Haiku and Sonnet, and Explore, fork, and Opus subagents are blocked until you turn them back on.
- Claude commits or pushes without asking. The hooks block `git add`, `commit`, `push`, `merge`, `rebase`, `reset`, and the other commands that change history or the index, in both the Bash and PowerShell tools. Claude gives you a ready-to-paste block with a Conventional Commit message and no AI attribution instead.
- Claude writes code before it has read the repo. The rules make it pull first and follow the conventions it finds. For anything bigger than a small fix, it asks questions and saves a plan in `docs/plans/` that a cheaper model can execute one slice at a time.

## Requirements

- Windows 10 or 11 with Windows PowerShell 5.1, which is built in. PowerShell 7 also works.
- Claude Code 2.1.176 or later. Check with `claude --version` and update with `claude update`.
- Git for Windows. Git Bash is optional; without it Claude Code uses its PowerShell tool, and the guards cover both.

macOS and Linux are not supported yet. The hooks call `powershell.exe`, so on those systems they fail to start and neither the rules nor the guards load. Support is planned for v0.2, and help is welcome.

## Install

In Claude Code:

```
/plugin marketplace add Skt329/senior-engineer
/plugin install senior-engineer@senior-engineer
```

Then restart Claude Code. From a terminal, the same two steps are `claude plugin marketplace add Skt329/senior-engineer` and `claude plugin install senior-engineer@senior-engineer`.

### Check that it works

- `/hooks` lists the senior-engineer hooks for SessionStart, SubagentStart, and PreToolUse.
- Ask Claude to run `git push --dry-run`. The hook refuses, and Claude offers you the command instead. A dry run changes nothing even if it gets through.
- `/agents` lists senior-engineer:scout, senior-engineer:implementer, and senior-engineer:reviewer, and `/skills` lists the thirteen skills.

[TESTING.md](TESTING.md) has the automated tests and a full manual test script.

### Just want the rules?

Copy [`context/core-rules.md`](context/core-rules.md) into your `CLAUDE.md`, either the project's or the one in `C:\Users\<you>\.claude\` for every project. It is about 7,000 characters. Without the plugin, nothing enforces the rules and the skills they mention are missing, so Claude treats them as guidance only. The hooks are what stop a commit when Claude forgets.

## What you get

Standing rules, injected at the start of every session and again after `/clear` and compaction:

- Size each task first (trivial, standard, or major) and plan major work so that Sonnet can execute it in a fresh session.
- Sync with origin before reading or changing code, and start new work on a branch from the updated default branch.
- Agree on a low-level design before writing code: follow the conventions of an existing repository, or propose a design for a new one.
- Evaluate your architecture choices honestly, with pros, cons, and better options, explained in plain language.
- Ask before spawning subagents, at most three per batch, with a check-in after each batch.
- Never commit. Claude stops after each slice and gives you a ready-to-paste commit block with no AI attribution.

Guardrails, enforced by hooks:

| When Claude tries to | What happens |
|---|---|
| Change git history or the index (add, commit, push, merge, rebase, reset, and more) | Blocked; Claude gives you the command instead |
| Open `.env` files, private keys, or service account JSON with the Read tool | Blocked |
| Spawn any subagent | You are asked first, with the agent type, model, and task |
| Delete recursively, change dependencies, deploy, or run a migration | You are asked first |

<details>
<summary>Every guarded action</summary>

| Action | What happens |
|---|---|
| git add, commit, push, merge, rebase, reset, restore, clean, and other history or index changes | Blocked, with a reason Claude reads; Claude gives you the command instead |
| git pull without --ff-only, git checkout of an existing branch, risky git switch options | Blocked, with the safe alternative |
| Deleting, renaming, or force-moving branches, deleting tags, and expiring or deleting reflog entries | Blocked; Claude gives you the command instead |
| git fetch, pull --ff-only, switch, switch -c, checkout -b, stash list and show, and read-only git | Allowed as usual |
| Other git stash commands, creating tags, remote, config, worktree, submodule, and bisect changes, and any git subcommand the guard does not recognize | You are asked |
| gh pr merge, gh repo delete, and gh release delete | Blocked |
| Other gh commands that change something on GitHub, including every gh api call | You are asked |
| Recursive deletes (rm -r, Remove-Item -Recurse, rd /s) and any rmdir or rd | You are asked |
| Adding, removing, upgrading, or publishing dependencies (npm, pnpm, yarn, pip, uv, poetry), and global npm, pnpm, or yarn installs | You are asked |
| Deploys and infrastructure changes (gcloud, firebase, terraform, kubectl), and docker push, rm, rmi, prune, and compose down -v | You are asked |
| Database migrations (alembic upgrade, downgrade, stamp) | You are asked |
| Opening with the Read tool: `.env` and `.env.*` files (except `.example`, `.sample`, `.template`, and `.dist`), private keys (`.pem`, `.key`, `.p12`, `.pfx`, `.jks`, `.keystore`, `id_rsa*`, `id_ed25519*`), `credentials.json`, and service account JSON | Blocked |
| Editing `.env` files, GitHub Actions workflows, and Cloud Build files | You are asked |
| Spawning any subagent | You are asked, with the agent type, model, and task |
| The built-in Explore agent, fork subagents, and subagents whose model is set to Opus | Blocked unless you turn them back on |

</details>

Agents:

- `senior-engineer:scout` runs on Haiku with read-only tools, for searches and code mapping.
- `senior-engineer:implementer` runs on Sonnet, for one approved plan slice.
- `senior-engineer:reviewer` runs on Sonnet with no Edit or Write tools, for reviewing a large diff.

Skills: planning, delegation, git-workflow, engineering-standards, system-design, decision-brief, testing, debugging, code-review, deployment, documentation, ui-design, and humanize-writing. Claude picks them up from the task, so you do not need to name them. The engineering skills include stack guides for Python (FastAPI, Celery, Redis), Android, web frontends, and GCP or Firebase.

## What runs on your machine

- The hooks are plain PowerShell with no dependencies. The four entry scripts in `hooks/scripts/` are about 210 lines, and the command parser and policy they share in `hooks/scripts/lib/` are about 1,000 more.
- They make no network calls and collect no telemetry. Each hook reads one tool call from standard input and prints a decision.
- If the guard logic hits an error, the hook asks you about the action rather than guessing (see `Write-GuardError` in `hooks/scripts/lib/HookIO.psm1`). If PowerShell cannot start the hook at all, Claude Code treats it as a hook error and the action goes ahead unguarded.
- `tests/run-tests.ps1` checks the manifests, every skill and agent, and 244 hook cases: 205 shell commands, 26 file paths, and 13 agent spawns. CI runs it on Windows PowerShell 5.1 and PowerShell 7 for every pull request and every push to main.
- What the guards cannot catch is listed under [Known limitations](#known-limitations).

## Everyday use

Work as usual. A few prompts that show the plugin at work:

- "Add refresh tokens to the auth service." Claude syncs, creates a branch, asks clarifying questions with defaults, writes decision briefs, and saves a plan and a progress file in docs/plans/.
- "Continue the plan." In a new session, Claude reads the progress file and runs the next slice.
- "Here is how I want to structure the worker service: ..." Claude reviews the design and suggests better options where they exist.
- "Why does this test fail?" Claude reproduces the failure first and stops after two failed fix attempts.

To hand a plan to a cheaper model, start a new session with Sonnet and paste:

```
Read docs/plans/<file>.md and docs/plans/<file>.progress.md.
Execute only the next unchecked slice, exactly as written, and run its verification commands.
Update the progress file, then stop and give me the commit block for that slice.
If anything in the plan is ambiguous or wrong, stop and ask instead of guessing.
```

### Recommended setting: no AI attribution

Turn off Claude Code's own commit and PR attribution, so its suggestions match the commit blocks the plugin gives you. Merge this into your user settings file, `C:\Users\<you>\.claude\settings.json`:

```json
{
  "attribution": { "commit": "", "pr": "" }
}
```

Use the object form. The shorter `"attribution": false` only exists from Claude Code 2.1.281, and older versions skip the whole settings file that contains it.

### Turning blocked agents back on

| Variable | Effect when set to 1 |
|---|---|
| SENIOR_ENGINEER_ALLOW_BUILTIN_AGENTS | Allows the built-in Explore agent and fork subagents (each spawn still asks) |
| SENIOR_ENGINEER_ALLOW_OPUS_SUBAGENTS | Allows subagents on Opus (each spawn still asks) |

For one session, set the variable in PowerShell before starting Claude Code:

```
$env:SENIOR_ENGINEER_ALLOW_OPUS_SUBAGENTS = '1'
claude
```

To keep it, add it to the `env` block of your settings file.

### Optional hard stop for commits and pushes

The hooks already block these. If you also want Claude Code's own permission system to refuse them, add deny rules to your settings:

```json
{
  "permissions": {
    "deny": ["Bash(git commit *)", "Bash(git push *)", "PowerShell(git commit *)", "PowerShell(git push *)"]
  }
}
```

## Customizing

Make these changes in your own clone or fork. To run your copy, add the clone as the marketplace instead of the GitHub repo, for example `/plugin marketplace add C:\dev\senior-engineer`; Claude Code then runs your working copy. [CONTRIBUTING.md](CONTRIBUTING.md) has the details.

- Standing rules: edit `context/core-rules.md`. Keep it ASCII-only and under 7,500 characters, because Claude Code moves hook output over 10,000 characters into a file instead of the context. The tests check both limits.
- Command rules: edit the lists at the top of `hooks/scripts/lib/ShellPolicy.psm1`. To guard a new program, also add `if` entries for it in `hooks/hooks.json` (copy an existing line for the Bash and the PowerShell matcher), then add test cases to `tests/cases/shell-guard.cases.json`.
- Protected files: edit `hooks/scripts/file-guard.ps1` and the Read or Edit entries in `hooks/hooks.json`, then add cases to `tests/cases/file-guard.cases.json`.
- Skills and agents: edit the Markdown files. Keep each skill description in the third person ("This skill should be used..."), on one line, and free of ": " sequences, which break the YAML that Claude Code reads.

Run the tests after every change.

## Updating

The plugin has a fixed version number, so Claude Code keeps your installed copy until a new version is released. To get it:

```
claude plugin update senior-engineer@senior-engineer
```

Then restart Claude Code. You can also turn on auto-update for the senior-engineer marketplace in the `/plugin` menu. [CHANGELOG.md](CHANGELOG.md) lists what changed in each version.

## Uninstalling

```
/plugin uninstall senior-engineer@senior-engineer
/plugin marketplace remove senior-engineer
```

## Troubleshooting

- Hooks do not run: check `/hooks`, then start Claude Code with `claude --debug` to see each hook call and its output. Make sure `claude --version` is 2.1.176 or later.
- A prompt says "senior-engineer guard error": a hook script failed, so it fell back to asking you. Run the tests from a clone to find the cause, and please open an issue with the message.
- PowerShell refuses to run scripts: the hooks pass `-ExecutionPolicy Bypass`, which works unless a Group Policy forbids it. In that case ask your administrator, or set the policy for your user with `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`.
- Writing advice comes out twice or contradicts itself: if you installed the humanize-writing skill on its own before, for example in `C:\Users\<you>\.claude\skills\humanize-writing`, remove that copy. The plugin bundles the same skill, and two copies compete for the same requests.
- Hooks fail on macOS or Linux: they call `powershell.exe`, which those systems do not have. To experiment before v0.2, install PowerShell 7, change `powershell.exe` to `pwsh` in every entry of `hooks/hooks.json` in a clone, and install from the clone. This setup is untested, and the structure check in `tests/run-tests.ps1` expects `powershell.exe`, so it reports those entries as failures.

## Known limitations

- The shell guard understands common Bash and PowerShell syntax: quotes, separators, substitutions, `git -C` and `-c` options, wrapper words such as `sudo`, `env`, and `time`, and nested shells such as `bash -c`, `cmd //c`, and `powershell -Command`. It does not see git calls hidden inside scripts, aliases, or functions. It is a guardrail, not a sandbox; the deny rules above add a second layer.
- A guard only starts when an `if` filter in `hooks.json` matches the program name at the start of a command, and the tests check that every program the guard handles has one. A program started by its full path, such as `"C:\Program Files\Git\cmd\git.exe" push`, may not match a filter.
- The secret-file guard covers the Read tool only. A shell command such as `cat .env` or `Get-Content .env`, or a Grep search, is not blocked. Files such as `.npmrc`, `.aws/credentials`, and `*.tfvars` are not on the list yet.
- The Opus block checks the model Claude asks for when it spawns a subagent. An agent whose own definition sets `model: opus` is not caught. The general-purpose and Plan agents inherit the session's model, so the approval prompt adds a note for them instead of a block.
- The limit of three subagents per batch comes from the rules plus the approval prompt for each spawn. There is no counter yet; one is planned for v0.2.
- Each guarded command starts a PowerShell process, which adds roughly half a second. The `if` filters in hooks.json keep unrelated commands from starting the guard at all.

## Questions

### Why not put the rules in CLAUDE.md?

You can, and the section [Just want the rules?](#just-want-the-rules) shows how. Instructions in CLAUDE.md are guidance that Claude can lose track of late in a long session or after compaction. Here the git, secret, and subagent rules are hooks that run outside the model on every matching tool call, and the rules are injected again after `/clear` and compaction.

### Why not use permission deny rules?

They make a good second layer, and [Optional hard stop](#optional-hard-stop-for-commits-and-pushes) shows how to add them. A prefix rule such as `Bash(git commit *)` does not match `git -C services/api commit` or `git -c user.name=x commit`, and a refusal from a deny rule does not tell Claude what to do next. The guard parses the command in both shell tools and tells Claude to hand you the commands instead.

### How is this different from superpowers or SuperClaude?

[superpowers](https://github.com/obra/superpowers) and [SuperClaude](https://github.com/SuperClaude-Org/SuperClaude_Framework) are larger and more mature workflow packs. As of October 2026 both are built mainly around skills and commands, and their hooks add context rather than block tool calls. This plugin is built around PreToolUse hooks that refuse git writes, secret reads, and unapproved subagents. It is also stricter about commits: in superpowers' subagent-driven workflow the subagents commit as they go, while this plugin blocks every commit, so the two do not combine well.

### How was it built?

It was planned and built with Claude in one session, using the method the plugin teaches: clarifying questions and decision records first, then a written plan, then thirteen commit-sized slices, each committed by hand. The plan, its progress file, and the decision records are in [`docs/`](docs/).

## Repository map

```
.claude-plugin/    plugin and marketplace manifests
.github/           CI workflow, issue forms, and the pull request template
context/           standing rules for sessions and subagents
hooks/             hooks.json and the PowerShell hook scripts
agents/            scout, implementer, reviewer
skills/            thirteen skills, including the bundled humanize-writing
tests/             run-tests.ps1 and the hook test cases
docs/              the build plan, its progress file, and the ADRs
```

## Contributing

Bug reports, new guard cases, and the macOS and Linux port are all welcome. Start with [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT, see [LICENSE](LICENSE). The one exception is `skills/humanize-writing/`, which is adapted from Wikipedia text and is licensed under CC BY-SA 4.0. [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) has the details and the other credits.
