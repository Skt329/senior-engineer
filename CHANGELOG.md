# Changelog

All notable changes to this plugin are recorded here. The format follows Keep a Changelog, and versions follow Semantic Versioning.

## [Unreleased]

## [0.1.0] - 2026-10-01

### Added
- Standing rules injected at session start and again after /clear and compaction, plus short rules for every subagent.
- Shell guard for the Bash and PowerShell tools. It blocks history-changing git commands and asks before git stash, recursive deletes, dependency changes, deploys, infrastructure changes, and database migrations.
- File guard that blocks reading secret files and asks before edits to environment files and CI configuration.
- Agent gate that asks before every subagent spawn and blocks the built-in Explore agent, fork subagents, and Opus subagents unless they are turned back on.
- Three agents: scout on Haiku, implementer on Sonnet, and reviewer on Sonnet.
- Twelve skills: planning, delegation, git-workflow, engineering-standards, system-design, decision-brief, testing, debugging, code-review, deployment, documentation, and ui-design.
- The humanize-writing skill, bundled unchanged.
- An automated test runner for the hooks and the plugin structure, and a manual test script.
