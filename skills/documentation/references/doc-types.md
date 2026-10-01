# Document types

Short templates. Delete sections that do not apply, and write every one with the humanize-writing skill.

## README
```markdown
# <Project name>
One or two sentences: what it is and who it is for.

## Requirements
Versions of runtimes and tools.

## Quick start
The commands to get it running locally, in order, for each supported OS.

## Configuration
Environment variables, with a pointer to .env.example.

## Running tests

## Project structure
A short map of the main folders.

## Deployment
A pointer to the deploy docs or runbook.

## Contributing
Branching, commits, and reviews, or a pointer to CONTRIBUTING.md.
```

## How-to guide
Title as a task ("Rotate the API signing key"). List the prerequisites, then numbered steps with the exact commands and the expected result after each, then how to verify that it worked.

## API reference
For each endpoint: method and path, authentication, request parameters and body with types, response body with an example, error codes with their meaning, and rate limits.

## Runbook
```markdown
# Runbook: <alert or situation>
Symptoms: what the alert or the user sees.
Impact: who is affected.
Diagnose: the queries, dashboards, and commands to check, in order.
Fix: steps for each likely cause, including rollback.
Escalate: who to contact, and when.
```

## Release notes
For users rather than developers: what is new, what changed, what was fixed, and anything they must do (for example update the app, or change a setting).

## Changelog entry (Keep a Changelog)
```markdown
## [1.4.0] - 2026-10-01
### Added
- Refresh tokens, so users stay signed in for 30 days.
### Fixed
- Exports no longer time out for accounts with more than 10,000 orders.
```

## Onboarding guide
What a new teammate needs in week one: access to request, local setup, how the system fits together, where the docs live, and who to ask.
