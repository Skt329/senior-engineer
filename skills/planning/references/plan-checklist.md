# Plan checklist

Run through this list before showing a plan. Each "no" means the executor would have to guess; fix it first.

## Coverage
- Does every slice name every file it creates or changes?
- Does every new function, class, endpoint, or component have a signature or contract?
- Are data changes exact: names, types, nullability, defaults, constraints, indexes?
- Are new configuration keys and environment variables listed, with example values and where they are read?
- Does every external call (HTTP, database, queue, cache) specify timeouts, retries, and what happens on failure?

## Executability
- Could a model that has never seen this conversation execute each step without asking a question?
- Is every library pinned to a version that was checked in the registry while planning?
- Is full code given for the tricky parts, and only those?
- Does any step contain "etc.", "as needed", "appropriately", "handle errors", "relevant files", "similar to", or "TBD"?
- Are the steps in an order that works, with no step depending on a later one?

## Verification
- Does every slice have a verification command and the result to expect?
- Do the tests cover failure paths as well as the happy path?
- Is there a manual check for anything automated tests cannot see (UI, emails, real cloud resources)?

## Slices
- Is each slice one logical change that leaves the build and tests green?
- Is each slice within about 10 files and 300 to 400 changed lines?
- Are refactors, formatting, and dependency upgrades in their own slices?
- Does each slice have a Conventional Commit message?

## Decisions and risk
- Is every expensive-to-reverse choice backed by an approved decision brief or ADR?
- Are the main risks listed with a mitigation?
- Is there a rollback path for each slice, including data and configuration?
- Are migrations backwards compatible, or is the downtime agreed?

## Fit with the repo
- Does the plan follow the conventions recorded in the existing-repo audit?
- Are the existing package manager, formatter, linter, and test runner used, with no new tools added without approval?

## Writing
- Is the prose plain and specific, following humanize-writing (sentence-case headings, no filler, no em dashes)?
