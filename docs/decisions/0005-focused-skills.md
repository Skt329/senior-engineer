# 0005. Ship twelve focused skills plus humanize-writing

Date: 2026-10-01
Status: accepted

## Context
The plugin must cover planning, coding, testing, review, deployment, documentation, and UI work for Python, Android, and GCP projects. Claude loads a skill when its description matches the task, and only a skill's description is always in context.

## Options considered
- One large skill that covers everything.
- Twelve focused skills, each with references that load only when needed, plus the bundled humanize-writing skill.
- Skills plus slash commands for each workflow.

## Decision
Twelve focused skills (planning, delegation, git-workflow, engineering-standards, system-design, decision-brief, testing, debugging, code-review, deployment, documentation, ui-design), each under 500 lines with stack-specific references, plus humanize-writing bundled unchanged. No slash commands in v0.1.

## Consequences
- Good: each task loads only what it needs, and descriptions can name precise triggers.
- Bad: more files to maintain, and descriptions must stay free of ": " because that breaks the YAML frontmatter.
- Follow-ups: add slash commands in a later version if a workflow needs a fixed entry point.
