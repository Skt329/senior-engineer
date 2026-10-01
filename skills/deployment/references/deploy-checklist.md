# Deploy checklist

Copy this into the PR or the chat before a deploy, and tick each item.

## Before
- [ ] CI is green on the exact commit being deployed.
- [ ] The artifact (image tag, APK or AAB version, build number) matches that commit.
- [ ] Code review is done, and the PR description covers risks and rollback.
- [ ] Migrations are backwards compatible with the running version, or downtime is agreed.
- [ ] Database backup or point-in-time recovery is confirmed for risky migrations.
- [ ] New environment variables and secrets exist in the target environment.
- [ ] Feature flags are set to the intended defaults.
- [ ] Dependencies on other teams or services are deployed first.
- [ ] Rollback steps are written down: previous revision or version, flag to turn off, and how to undo data changes.
- [ ] Monitoring is ready: dashboards, alerts, and the log query to watch.
- [ ] The deploy window suits the users (not right before a holiday or a big event).

## During
- [ ] Deploy to staging and run the smoke tests.
- [ ] Production rollout in steps where the platform allows it (for example 10 percent, 50 percent, 100 percent).
- [ ] Watch error rate, latency, and key metrics after each step.

## After
- [ ] Smoke tests pass in production.
- [ ] No new error types in the logs for the agreed period.
- [ ] Changelog and release notes updated.
- [ ] Stakeholders told what changed.
- [ ] Old resources and temporary flags scheduled for cleanup.
