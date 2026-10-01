---
name: documentation
description: This skill should be used whenever Claude writes prose that people will read, for example a README, docs page, docstring, code comment, API reference, changelog entry, ADR, design doc, PR description, commit body, release note, runbook, or onboarding guide, and when the user asks to document something. It sets what each kind of document must contain and where it lives, keeps docs in sync with code changes, follows Keep a Changelog, and always applies the humanize-writing skill so the text reads as if a knowledgeable engineer wrote it.
---

# Documentation

Documentation is for a specific reader with a specific question: how do I run this, why does it work this way, what changed? Write for that reader, and only what they need.

## Always use humanize-writing

Load the humanize-writing skill for every piece of prose: docs, READMEs, PR descriptions, commit bodies, ADRs, design docs, and release notes. In short: plain words, sentence-case headings, no filler or hype, no em dashes, minimal bold, and concrete facts instead of vague praise.

## What goes where

| Document | Location | Reader's question |
|---|---|---|
| README | Repository root | What is this, and how do I run it in five minutes? |
| Docs pages | docs/ | How does this work, and how do I do a specific task? |
| Plans and progress | docs/plans/ | What exactly will be built, and where are we? |
| Design docs | docs/design/ | How is this system designed, and why? |
| ADRs | docs/decisions/ | Why was this decision made? |
| Changelog | CHANGELOG.md | What changed in each version? |
| Runbooks | docs/runbooks/ | Something is wrong; what do I do now? |
| Docstrings | In code | What does this function promise? |
| Comments | In code | Why is this code written this way? |

Follow the repository's existing layout if it differs. references/doc-types.md has a short template for each.

## Keep docs in sync

Any change that alters behavior, configuration, setup, or an API includes the doc update in the same slice. Before handing off, check the README quick start, .env.example, API docs, and the changelog against the change.

## Changelog

Follow Keep a Changelog: an Unreleased section at the top, then versions with dates, grouped under Added, Changed, Deprecated, Removed, Fixed, and Security. Write entries for users of the software, not as a commit log.

## Code comments and docstrings

- Docstrings state what a function does, its parameters, what it returns, and the errors it raises, in the repository's style (Google, NumPy, or reST for Python; KDoc for Kotlin; TSDoc for TypeScript).
- Comments explain why: a business rule, a workaround with a link, a performance reason. If a comment explains what the code does, the code probably needs better names instead.

## Before handing off any document

- Does it answer the reader's question within the first few lines?
- Are the commands copy-pasteable and correct on Windows (PowerShell) where the reader works there?
- Are names, versions, and paths accurate?
- Has it been through the humanize-writing checks?
