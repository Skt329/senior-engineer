# Contributing

Thanks for helping. To get started, fork and clone the repository, then run this from its root:

```
powershell -NoProfile -ExecutionPolicy Bypass -File tests/run-tests.ps1
```

It takes under a minute and should end with `... passed, 0 failed`. You need Windows PowerShell 5.1, which comes with Windows, and Git. You do not need to install the plugin to run the tests.

Most contributions fall into one of these kinds:

- A guard got a command wrong: it blocked something safe, or let through something it should have stopped. See [Fix a guard decision](#fix-a-guard-decision).
- A rule or skill made Claude behave badly in a real session. Open an issue with the prompt and what Claude did.
- Support for macOS and Linux, which is the main goal for v0.2. See [Working on macOS and Linux support](#working-on-macos-and-linux-support).
- Docs that were wrong or unclear. Send a pull request.

Small fixes can go straight to a pull request. For anything larger, such as a new guard, a new skill, or a change to how the rules work, open an issue first so we can agree on the approach before you spend time on it. Questions go in [Discussions](https://github.com/Skt329/senior-engineer/discussions).

## Reporting a problem

Use the [bug report form](https://github.com/Skt329/senior-engineer/issues/new?template=bug_report.yml). The most useful reports include:

- the exact command line or file path Claude tried, copied from the transcript;
- the tool it ran in (Bash or PowerShell);
- what the plugin did and what you expected;
- your Claude Code version (`claude --version`) and PowerShell version (`$PSVersionTable.PSVersion`).

A way around a guard is a normal bug. The guards are guardrails for an assistant you already trust with your machine, not a security boundary, so it is fine to report them in public.

## Set up a working copy

1. Fork the repository and clone your fork, for example to `C:\dev\senior-engineer`.
2. If you installed the plugin from GitHub, uninstall that copy first so the two do not both load:

   ```
   /plugin uninstall senior-engineer@senior-engineer
   /plugin marketplace remove senior-engineer
   ```

3. Add your clone as a local marketplace and install from it:

   ```
   /plugin marketplace add C:\dev\senior-engineer
   /plugin install senior-engineer@senior-engineer
   ```

4. Restart Claude Code. A plugin installed from a local folder runs from that folder, so your edits apply at the next session start, or when you run `/reload-plugins`, without a version change. SessionStart hooks only run when a session starts, so test rule changes in a new session.

## Run the tests

From the repository root, in PowerShell or Git Bash:

```
powershell -NoProfile -ExecutionPolicy Bypass -File tests/run-tests.ps1
```

This should end with `... passed, 0 failed`. It checks the manifests and hooks.json, the skill and agent frontmatter, the size and encoding of the rule files, and every case in `tests/cases/`. Before you open a pull request that touches the hooks, also run the slower full mode, which starts a separate PowerShell process for every shell case, the way Claude Code runs the hook:

```
powershell -NoProfile -ExecutionPolicy Bypass -File tests/run-tests.ps1 -Full
```

If you have PowerShell 7, run the same commands with `pwsh` instead of `powershell`. CI runs both versions on every pull request.

[TESTING.md](TESTING.md) also has a manual script for checking the plugin inside Claude Code. Run the scenarios your change affects.

## Fix a guard decision

Every guard change starts with a test case that fails.

1. Add a case to the right file in `tests/cases/`:

   | File | One case looks like |
   |---|---|
   | `shell-guard.cases.json` | `{ "cmd": "git push --force origin main", "expect": "deny" }`, plus `"tool": "PowerShell"` for a PowerShell-tool case (Bash is the default) |
   | `file-guard.cases.json` | `{ "tool": "Read", "path": "backend/.env.production", "expect": "deny" }` |
   | `agent-gate.cases.json` | `{ "toolInput": { "subagent_type": "senior-engineer:scout", "description": "Map the auth code" }, "expect": "ask" }` |

   `expect` is `deny`, `ask`, or `none`, which means the guard prints nothing and Claude Code carries on as usual. Add `"reasonContains": "..."` when the wording of the reason matters.
2. Run the tests and check that your new case fails.
3. Fix the policy. Command rules live in `hooks/scripts/lib/ShellPolicy.psm1`, and command parsing in `hooks/scripts/lib/ShellParser.psm1`. A new program also needs `if` entries in `hooks/hooks.json` for both the Bash and the PowerShell matcher, or the guard never runs for it.
4. Run the tests again, including `-Full`.

## House rules for changes

These keep the plugin loading on every supported version of Windows PowerShell and Claude Code. The test runner enforces most of them.

- Keep `.ps1`, `.psm1`, `hooks/hooks.json`, and the files in `context/` ASCII-only. Windows PowerShell 5.1 misreads UTF-8 without a byte order mark.
- Keep the scripts compatible with Windows PowerShell 5.1: no `??`, no ternary operator, and no `&&` or `||` between commands.
- Keep `context/core-rules.md` under 7,500 characters and `context/subagent-rules.md` under 1,500. Claude Code moves hook output over 10,000 characters into a file instead of the context.
- Skill descriptions stay on one line, in the third person ("This skill should be used..."), and free of `: ` sequences, which break the YAML that Claude Code reads. `skills/humanize-writing/` is vendored, so leave it as it is.
- No new dependencies. The plugin runs on what Windows ships with.
- Prose that people read, such as docs, skill text, and the changelog, uses plain words and sentence-case headings, with no em dashes or filler. The humanize-writing skill describes the style.

## Commits and pull requests

1. Branch from the latest `main` with a prefix and a short slug, for example `fix/stash-pop-prompt` or `feature/macos-hooks`.
2. Keep each commit to one logical change, with its tests in the same commit, and leave the tests passing after every commit.
3. Write commit messages as [Conventional Commits](https://www.conventionalcommits.org/), for example `fix(hooks): ask before git stash pop`.
4. Add a line under `## [Unreleased]` in [CHANGELOG.md](CHANGELOG.md) for any change a user would notice, and update README.md or TESTING.md when behavior changes.
5. Open the pull request and fill in the template. CI has to pass before it is merged.

The plugin applies these rules to Claude too. If you use Claude Code with this plugin to write your change, it will stop and give you the commit commands rather than committing for you.

## Working on macOS and Linux support

The guard logic is plain PowerShell, so the open question is how `hooks/hooks.json` starts it on each system. Claude Code has no per-platform hook command, `powershell.exe` exists only on Windows, and `pwsh` is not installed on Windows by default. If you want to take this on, open an issue with the approach you have in mind before you write code. Any approach has to keep working on a stock Windows machine with only Windows PowerShell 5.1.

On macOS or Linux you can already run `pwsh -File tests/run-tests.ps1`. The test runner skips `-ExecutionPolicy` off Windows. Expect the hooks.json structure checks to fail, because they require every hook to start `powershell.exe`; changing that check is part of the port. Nobody has run the rest of the suite on macOS yet, so please report what you see.

## Releasing

Maintainers only.

1. Raise `version` in both `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`. The tests check that they match. Installed copies only update when this number changes.
2. Move the `## [Unreleased]` entries in CHANGELOG.md under a new version heading with today's date.
3. Run the tests and `claude plugin validate --strict .`, then merge to `main`.
4. Create a GitHub release with a tag such as `v0.2.0`, using the changelog entries as the notes.

## License

By contributing, you agree that your contribution is released under the [MIT License](LICENSE). Changes inside `skills/humanize-writing/` are released under CC BY-SA 4.0, as [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) explains.
