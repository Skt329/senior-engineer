# senior-engineer

A Claude Code plugin that makes Claude work like a senior software engineer on your projects. It loads a short set of standing rules into every session, guards git and other risky commands with hooks, adds three subagents pinned to cheap models, and ships twelve skills for planning, design, coding, testing, review, deployment, documentation, and UI work, plus the humanize-writing skill for anything people will read.

It was built for Windows and PowerShell, and for Python (FastAPI, Celery, Redis), Android, and GCP or Firebase projects. The rules themselves are general and work in any repository.

## What it does

Standing rules, injected at the start of every session and again after `/clear` and compaction:
- Size each task first (trivial, standard, or major) and plan major work so that Sonnet can execute it in a fresh session.
- Sync with origin before reading or changing code, and start new work on a branch from the updated default branch.
- Agree on a low-level design before writing code: follow the conventions of an existing repository, or propose a design for a new one.
- Evaluate your architecture choices honestly, with pros, cons, and better options, explained in plain language.
- Ask before spawning subagents, at most three per batch, with a check-in after each batch.
- Never commit. Claude stops after each slice and gives you a ready-to-paste commit block with no AI attribution.

Guardrails, enforced by hooks:

| Action | What happens |
|---|---|
| git add, commit, push, merge, rebase, reset, restore, clean, and other history or index changes | Blocked, with a reason Claude reads; Claude gives you the command instead |
| git pull without --ff-only, git checkout of an existing branch, risky git switch and branch options | Blocked, with the safe alternative |
| git fetch, pull --ff-only, switch, switch -c, checkout -b, and read-only git | Allowed as usual |
| git stash, tag, remote and config changes | You are asked |
| Recursive deletes (rm -r, Remove-Item -Recurse, rd /s, rmdir) | You are asked |
| Adding, removing, or upgrading dependencies (npm, pnpm, yarn, pip, uv, poetry), global installs | You are asked |
| Deploys and infrastructure changes (gcloud, firebase, terraform, kubectl, docker push and prune) | You are asked |
| Database migrations (alembic upgrade, downgrade, stamp) | You are asked |
| Reading .env files, keys, keystores, and service account JSON | Blocked |
| Editing .env files and CI configuration | You are asked |
| Spawning any subagent | You are asked, with the agent type, model, and task |
| The built-in Explore agent, fork subagents, and Opus subagents | Blocked unless you turn them back on |

Agents:
- `senior-engineer:scout` runs on Haiku with read-only tools, for searches and code mapping.
- `senior-engineer:implementer` runs on Sonnet, for one approved plan slice.
- `senior-engineer:reviewer` runs on Sonnet with read-only file access, for reviewing a large diff.

Skills: planning, delegation, git-workflow, engineering-standards, system-design, decision-brief, testing, debugging, code-review, deployment, documentation, ui-design, and humanize-writing. Claude picks them up from the task; you do not need to name them.

## Requirements

- Windows 10 or 11 with Windows PowerShell 5.1, which is built in. PowerShell 7 also works.
- Claude Code 2.1.176 or later. Check with `claude --version` and update with `claude update`.
- Git for Windows. Git Bash is optional; without it Claude Code uses its PowerShell tool, and the guards cover both.

## Install

1. Extract the zip into `C:\dev`, so that `C:\dev\senior-engineer\.claude-plugin\plugin.json` exists. Another folder works too; adjust the paths below to match.
2. In Claude Code, add the folder as a marketplace and install the plugin:

   ```
   /plugin marketplace add C:\dev\senior-engineer
   /plugin install senior-engineer@senior-engineer
   ```

3. Turn off commit and PR attribution in your user settings, `%USERPROFILE%\.claude\settings.json`, so Claude Code stops suggesting Co-Authored-By lines:

   ```json
   {
     "attribution": { "commit": "", "pr": "" }
   }
   ```

   Merge this into the existing file rather than replacing it. Use the object form shown here: the shorter `"attribution": false` only exists from Claude Code 2.1.281, and older versions skip the whole settings file that contains it.

4. If you installed humanize-writing on its own before (for example in `%USERPROFILE%\.claude\skills\humanize-writing`), remove that copy. The plugin bundles the same skill, and two copies compete for the same requests.
5. Restart Claude Code.

## Check that it works

- `/hooks` lists the senior-engineer hooks for SessionStart, SubagentStart, and PreToolUse.
- `/agents` lists senior-engineer:scout, senior-engineer:implementer, and senior-engineer:reviewer.
- `/skills` lists the thirteen skills.
- Run the automated tests (about 30 seconds):

  ```
  powershell -NoProfile -ExecutionPolicy Bypass -File C:\dev\senior-engineer\tests\run-tests.ps1
  ```

  The last line should read `... passed, 0 failed`.
- Follow TESTING.md for the manual checks inside Claude Code.

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

- Standing rules: edit `context/core-rules.md`. Keep it ASCII-only and under 7,500 characters, because Claude Code moves hook output over 10,000 characters into a file instead of the context. The tests check both limits.
- Command rules: edit the lists at the top of `hooks/scripts/lib/ShellPolicy.psm1`. To guard a new program, also add `if` entries for it in `hooks/hooks.json` (copy an existing line for the Bash and the PowerShell matcher), then add test cases to `tests/cases/shell-guard.cases.json`.
- Protected files: edit `hooks/scripts/file-guard.ps1` and the Read or Edit entries in `hooks/hooks.json`, then add cases to `tests/cases/file-guard.cases.json`.
- Skills and agents: edit the Markdown files. Keep each skill description in the third person ("This skill should be used..."), on one line, and free of ": " sequences, which break the YAML that Claude Code reads.

Run the tests after every change.

## Updating

After changing files, raise the version in both `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`, then update the installed copy and restart Claude Code:

```
claude plugin marketplace update senior-engineer
claude plugin update senior-engineer@senior-engineer
```

You can do the same from the `/plugin` menu.

## Uninstalling

```
/plugin uninstall senior-engineer@senior-engineer
/plugin marketplace remove senior-engineer
```

## Troubleshooting

- Hooks do not run: check `/hooks`, then start Claude Code with `claude --debug` to see each hook call and its output. Make sure `claude --version` is 2.1.176 or later.
- A prompt says "senior-engineer guard error": a hook script failed, so it fell back to asking you. Run the tests to find the cause.
- PowerShell refuses to run scripts: the hooks pass `-ExecutionPolicy Bypass`, which works unless a Group Policy forbids it. In that case ask your administrator, or set the policy for your user with `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`.
- Hooks fail on macOS or Linux: they call `powershell.exe`. Install PowerShell 7 and change `powershell.exe` to `pwsh` in `hooks/hooks.json`.

## Known limitations

- The shell guard understands common Bash and PowerShell syntax: quotes, separators, substitutions, and nested shells. It does not see git calls hidden inside scripts, aliases, or functions. It is a guardrail, not a sandbox; the deny rules above add a second layer.
- The limit of three subagents per batch comes from the rules plus the approval prompt for each spawn. There is no counter yet; one is planned for v0.2.
- Each guarded command starts a PowerShell process, which adds roughly half a second. The `if` filters in hooks.json keep unrelated commands from starting the guard at all.

## Repository map

```
.claude-plugin/    plugin and marketplace manifests
context/           standing rules for sessions and subagents
hooks/             hooks.json and the PowerShell hook scripts
agents/            scout, implementer, reviewer
skills/            twelve skills plus humanize-writing
tests/             run-tests.ps1 and the hook test cases
docs/              the build plan, its progress file, and the ADRs
```

## Credits

See THIRD_PARTY_NOTICES.md.
