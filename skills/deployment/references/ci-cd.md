# CI/CD

## Pipeline stages
Every pull request runs: install with the lockfile, lint, type check, unit tests, integration tests, and a build. The main branch also builds the release artifact and deploys to staging. Production deploys are triggered deliberately: a tag, a manual approval, or a protected environment.

## Principles
- Pin action versions (or commit SHAs) and tool versions so builds are reproducible.
- Cache dependencies by lockfile hash.
- Build the artifact once and promote the same artifact through environments; do not rebuild for production.
- Tag images with the commit SHA. Avoid deploying `latest`.
- Use least-privilege credentials. On GCP, authenticate CI with Workload Identity Federation instead of service account keys.
- Keep secrets in the CI secret store, never in workflow files.
- Fail fast: run the cheapest checks first.

## GitHub Actions example (Python service)

```yaml
name: ci
on:
  pull_request:
  push:
    branches: [main]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
          cache: pip
      - run: pip install -r requirements-dev.txt
      - run: ruff check .
      - run: mypy src
      - run: pytest -q
```

Check the current major versions of each action before using this, and match the Python version to the repository.

## Cloud Build
- Keep cloudbuild.yaml in the repository; changes to it need the user's approval (the file guard asks).
- Use a dedicated build service account with only the roles it needs (Artifact Registry writer, Cloud Run deployer on the specific service).
- Use substitutions for environment-specific values.

## Android
- CI runs lint, unit tests, and assembles a debug build on every pull request.
- Release builds are signed in CI with the keystore and passwords from secrets, and uploaded to Firebase App Distribution or the Play Console internal track.
