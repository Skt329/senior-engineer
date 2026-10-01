---
name: deployment
description: This skill should be used when the user wants to deploy, release, ship, roll out, or roll back, set up or change CI/CD pipelines, Dockerfiles, environments, or infrastructure, run database migrations, or handle a production incident or outage. It covers pre-deploy checklists, CI/CD with GitHub Actions or Cloud Build, Cloud Run, Firebase and Android release paths, zero-downtime migrations with expand and contract, feature flags, rollback plans, post-deploy verification, and incident response with blameless postmortems. Every deploy or infrastructure change needs the user's explicit approval.
---

# Deployment

A deploy is safe when you know what will change, how you will tell whether it worked, and how you will undo it. Prepare all three before anything ships.

## Who does what

Claude prepares: the checklist, the commands, CI changes, migration scripts, rollout and rollback plans, and release notes. The user approves and runs anything that changes a real environment. The shell guard asks before deploy, infrastructure, and migration commands, and the file guard asks before CI configuration changes.

## Before any deploy

Work through references/deploy-checklist.md. The essentials:
- The change is merged or at least reviewed, CI is green, and the version or image tag is the commit that was tested.
- Migrations are backwards compatible with the code that is still running (references/migrations.md).
- New configuration and secrets exist in the target environment.
- The rollback path is written down and tested where possible.
- You know which metrics, logs, and checks will show success or failure.

## Rollout

- Deploy to staging first and run the smoke tests.
- In production, prefer gradual rollouts: Cloud Run traffic splitting, Play Console staged rollouts, or feature flags for risky behavior.
- Watch error rate, latency, and the key business metric for a set time after each step.
- Stop and roll back at the first clear sign of trouble. Investigate afterwards.

## Platform guides

- references/ci-cd.md for GitHub Actions and Cloud Build pipelines.
- references/gcp-firebase.md for Cloud Run, Firebase Hosting and Functions, Firestore rules, and Android releases with App Distribution and the Play Console.
- references/migrations.md for zero-downtime schema changes and backfills.

## After the deploy

- Run the smoke tests against the deployed environment.
- Check logs and dashboards for new errors.
- Update the changelog and release notes (documentation skill).
- Tell the user what was deployed, where, and how to roll back.

## Incidents

When production is broken, follow references/incident-response.md: stabilize first (roll back or turn off the flag), communicate, then find the root cause, and write a blameless postmortem afterwards.
