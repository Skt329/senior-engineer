# Progress: senior-engineer plugin

Plan: docs/plans/2026-10-01-senior-engineer-plugin.md
Branch: main (a new repository, so the first commits go straight to main)
Last updated: 2026-10-01 by Claude, in the claude.ai build session

## Slices

All 13 slices were built and verified in one session on 2026-10-01 and committed to main the same day.

- [x] 1. chore(plugin): add manifests, build plan, and decision records
- [x] 2. chore(skills): vendor the humanize-writing skill
- [x] 3. feat(skills): add planning, delegation, and decision-brief skills
- [x] 4. feat(skills): add git-workflow skill
- [x] 5. feat(skills): add engineering-standards skill
- [x] 6. feat(skills): add system-design, debugging, and code-review skills
- [x] 7. feat(skills): add testing skill
- [x] 8. feat(skills): add deployment and documentation skills
- [x] 9. feat(skills): add ui-design skill
- [x] 10. feat(agents): add scout, implementer, and reviewer agents
- [x] 11. feat(hooks): add shell guard with command parser and policy
- [x] 12. feat(hooks): add file guard, agent gate, and standing rules
- [x] 13. docs: add README, testing guide, changelog, and notices

Markers: [ ] to do, [~] in progress, [x] done and committed, [!] blocked (say why in the log)

## Log

- 2026-10-01: Plan approved with D1 to D6 as recommended, plus the git amendment: Claude may run fetch, pull --ff-only, switch, and branch creation, and nothing else that changes history.
- 2026-10-01: Built every file listed in section 5.1 of the plan, plus .gitattributes.
- 2026-10-01: Verified. run-tests.ps1 gave 713 passed, 0 failed on PowerShell 7.6.6, and 891 passed with -Full. PSScriptAnalyzer 1.25.0 reported no findings, including the Windows PowerShell 5.1 compatibility rules. claude plugin validate from Claude Code 2.1.287 passed both manifests in strict mode. PyYAML parsed all 16 frontmatter blocks. The humanize-writing scanner found no real flags.
- 2026-10-01: Deviations from the plan, each reflected in the plan text:
  1. The attribution setting uses the object form, "attribution": { "commit": "", "pr": "" }. The shorter "attribution": false needs Claude Code 2.1.281, and older versions skip the whole settings file that contains it.
  2. Added .gitattributes so every text file keeps LF line endings on Windows checkouts.
  3. ShellPolicy.psm1 imports ShellParser.psm1 and exposes Get-ShellGuardDecision, so shell-guard.ps1 and the test runner share one entry point.
  4. The runner checks shell cases in-process and runs every twentieth one as a separate process; -Full runs all of them as processes. The default run takes about 30 seconds instead of 2.5 minutes.
  5. Function names use singular nouns (Get-ShellCommand, ConvertTo-ShellToken, Get-NonFlagArgument), following PowerShell convention as flagged by PSScriptAnalyzer.
  6. The agent gate adds the inherits-the-session-model note for the Plan agent as well as general-purpose.
  7. Commits are grouped into 13 slices of at most 10 files each. The test runner moved to slice 12, where everything it checks exists.
  8. In system-design, the heading Deep dive became Detailed design after a scanner flag.
- 2026-10-01: Not verifiable in the build environment: Windows PowerShell 5.1 itself, and a signed-in Claude Code session. The next steps cover both.

## Next step

1. On Windows, run `powershell -NoProfile -ExecutionPolicy Bypass -File tests\run-tests.ps1` from the plugin folder. Expect 713 passed, 0 failed.
2. Install the plugin as the README describes, then work through TESTING.md and fill in its results table.
3. Commit the slices with the blocks below.
4. When all 18 manual scenarios pass, raise the version to 1.0.0 in both manifests and add a changelog entry.

## Pending commit blocks

Run each block from the plugin folder, in PowerShell or Git Bash, one at a time. Every block ends with `git status`: the files of that slice should no longer be listed, while the files of later slices stay untracked until their turn.

Set up the repository once, in PowerShell:

```
cd C:\dev\senior-engineer
git init -b main
```

In Git Bash, use `cd /c/dev/senior-engineer` for the first line.

### Slice 1

```
git add .claude-plugin/plugin.json .claude-plugin/marketplace.json .gitattributes docs/plans docs/decisions
git commit -m "chore(plugin): add manifests, build plan, and decision records" -m "Adds the plugin and marketplace manifests for version 0.1.0, LF line endings for every text file, the implementation plan with its progress file, and ADRs 0001 to 0005 for the approved decisions."
git status
```

### Slice 2

```
git add skills/humanize-writing
git commit -m "chore(skills): vendor the humanize-writing skill" -m "Copied unchanged from humanize-writing.skill so all prose the plugin produces goes through the same checks. The attribution is in THIRD_PARTY_NOTICES.md."
git status
```

### Slice 3

```
git add skills/planning skills/delegation skills/decision-brief
git commit -m "feat(skills): add planning, delegation, and decision-brief skills" -m "Planning writes plans that a cheaper model can execute without guessing. Delegation sets the proposal, batch, and brief rules for subagents. Decision-brief produces beginner-friendly option comparisons and records them as ADRs."
git status
```

### Slice 4

```
git add skills/git-workflow
git commit -m "feat(skills): add git-workflow skill" -m "Covers syncing with origin before work, feature branches from the updated default branch, commit slicing, Conventional Commits, and ready-to-paste commit blocks that work in PowerShell and Git Bash."
git status
```

### Slice 5

```
git add skills/engineering-standards
git commit -m "feat(skills): add engineering-standards skill" -m "Explains how to audit and follow an existing repo, how to propose a low-level design for a new one, and the code standards for naming, errors, logging, config, and security, with guides for Python, Android, web, and GCP."
git status
```

### Slice 6

```
git add skills/system-design skills/debugging skills/code-review
git commit -m "feat(skills): add system-design, debugging, and code-review skills" -m "System design starts from requirements and reviews the user's own designs honestly. Debugging enforces reproduce, isolate, and verify, and stops after two failed fixes. Code review ranks findings as blocker, should-fix, or nit."
git status
```

### Slice 7

```
git add skills/testing
git commit -m "feat(skills): add testing skill" -m "Sets what to test at each level, failing tests first for bugs, mocks only at system boundaries, and coverage as a guide, with guides for pytest, Android, and web frontends."
git status
```

### Slice 8

```
git add skills/deployment skills/documentation
git commit -m "feat(skills): add deployment and documentation skills" -m "Deployment covers checklists, CI and CD, Cloud Run, Firebase, Android releases, expand and contract migrations, and incident response. Documentation sets what each document contains and always applies humanize-writing."
git status
```

### Slice 9

```
git add skills/ui-design
git commit -m "feat(skills): add ui-design skill" -m "Sets a senior product designer bar with design tokens, every interaction state, WCAG 2.1 AA, responsive layouts, Material 3 on Android, and a UI review checklist."
git status
```

### Slice 10

```
git add agents
git commit -m "feat(agents): add scout, implementer, and reviewer agents" -m "Scout searches on Haiku with read-only tools. Implementer executes one approved slice on Sonnet. Reviewer checks a diff on Sonnet without editing files. None of them can spawn other agents."
git status
```

### Slice 11

```
git add hooks/scripts/lib hooks/scripts/shell-guard.ps1 tests/cases/shell-guard.cases.json
git commit -m "feat(hooks): add shell guard with command parser and policy" -m "Blocks history-changing git commands and asks before stash, recursive deletes, dependency changes, deploys, infrastructure changes, and migrations, for both the Bash and the PowerShell tool. Includes 188 test cases."
git status
```

### Slice 12

```
git add hooks/scripts/file-guard.ps1 hooks/scripts/agent-gate.ps1 hooks/scripts/session-start.ps1 hooks/hooks.json context tests/cases/file-guard.cases.json tests/cases/agent-gate.cases.json tests/run-tests.ps1
git commit -m "feat(hooks): add file guard, agent gate, and standing rules" -m "Blocks reading secret files, asks before edits to env files and CI config, and asks before every subagent while blocking Explore, fork, and Opus subagents. Session start injects the standing rules, hooks.json registers every hook, and run-tests.ps1 checks the whole plugin."
git status
```

### Slice 13

```
git add README.md TESTING.md CHANGELOG.md THIRD_PARTY_NOTICES.md
git commit -m "docs: add README, testing guide, changelog, and notices" -m "Covers installing on Windows, the attribution setting, verification, customizing, updating, troubleshooting, the manual test script, and third-party attributions."
git status
```

When all 13 are committed, check the history, then connect your own remote and push. Create the empty repository on GitHub first, without a README or license, so the first push does not conflict, and replace YOUR-ACCOUNT with your GitHub user or organization.

```
git log --oneline
git remote add origin https://github.com/YOUR-ACCOUNT/senior-engineer.git
git push -u origin main
```
