# Deploying on GCP and Firebase

Every command in this file changes a real environment. Prepare it, explain it, and let the user approve and run it.

## Cloud Run
Deploy a built image (preferred, because the tested artifact is the deployed one):

```
gcloud run deploy api --image REGION-docker.pkg.dev/PROJECT/REPO/api:COMMIT_SHA --region REGION --service-account api-runtime@PROJECT.iam.gserviceaccount.com
```

- Set environment variables and secrets with `--set-env-vars` and `--set-secrets`, or better, in Terraform.
- Gradual rollout: deploy with `--no-traffic`, then shift traffic with `gcloud run services update-traffic api --to-revisions NEW_REVISION=10` and raise it step by step.
- Rollback: `gcloud run services update-traffic api --to-revisions PREVIOUS_REVISION=100`.
- Check the result with `gcloud run services describe api --region REGION` and the service's logs.

## Firebase Hosting and Functions
- Preview first: `firebase hosting:channel:deploy preview` gives a temporary URL to check.
- Deploy only what changed: `firebase deploy --only hosting`, or `--only functions:functionName`.
- Firestore rules and indexes: test rules with the emulator suite, then `firebase deploy --only firestore:rules` and `--only firestore:indexes`. A wrong rule can expose or lock all data, so rules changes deserve their own review.
- Rollback for Hosting: release a previous version from the Firebase console's Hosting release history.

## Android releases
- Increase versionCode for every build and versionName for user-visible releases.
- Internal testing: Firebase App Distribution or the Play Console internal track.
- Production: a staged rollout in the Play Console (for example 5, 20, 50, 100 percent), watching crash-free users in Crashlytics and Android vitals at each step. Halt the rollout if crashes rise.
- A shipped build cannot be recalled from devices. Use Remote Config or server-side flags for risky features so they can be turned off without a release.

## Moving workloads between Firebase and GCP
Plan these as a project with a decision brief and a plan: inventory every Firebase feature in use (Auth, Firestore, Storage, Functions, Hosting, Messaging), decide what moves and what stays, migrate data with verification counts, switch traffic gradually, and keep the old path working until the new one is proven.
