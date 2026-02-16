# Claude Context

## What this project is

This repo is a **blueprint and reference implementation** for building Dataform projects on BigQuery. It is not just a data pipeline — it is a template that captures best practices, conventions, and setup patterns that the team can replicate across future Dataform projects.

The dataset used is `bigquery-public-data.thelook_ecommerce`, chosen because it is freely accessible and rich enough to demonstrate a realistic layered data model.

## Primary goals

- Establish a **layered modeling architecture**: sources → staging → intermediate → marts
- Define and document **team conventions** (naming, structure, testing) in a way that can be enforced in CI
- Make the project **easy to onboard** for engineers coming from dbt or other transformation tools
- Keep setup **reproducible** across local environments and CI

## What to keep in mind

- Every decision made here will likely be replicated in other projects — think in terms of patterns, not one-off solutions
- Conventions and tooling choices should be **documented with rationale**, not just implemented (see `docs/blueprint.md` and `docs/rules.md`)
- Prefer **simple and explicit** over clever — this is a reference project, clarity matters more than brevity
- The project targets an audience familiar with dbt, so dbt parallels are useful when introducing Dataform concepts

## Current state

- Project scaffold complete: `workflow_settings.yaml`, `package.json`, `.nvmrc`, `.gitignore`
- Source declarations created for all 7 `thelook_ecommerce` tables (`definitions/sources/thelook/`)
- CI: commitlint enforced on all PRs via GitHub Actions
- Docs: `docs/rules.md` (naming conventions NM01–NM05), `docs/blueprint.md` (setup decisions)
- **Staging, intermediate, and mart layers not yet built**

## What's next

- Build the staging layer (`definitions/staging/thelook/`) — 7 models, one per source table
- Build the intermediate layer (`definitions/intermediate/`) — joins and business logic
- Build the mart layer (`definitions/marts/`) — facts and dimensions for BI consumption
- Add `includes/utils.js` with reusable JavaScript helpers

## Key docs

- `docs/rules.md` — naming convention rules with codes and examples
- `docs/blueprint.md` — rationale behind setup and tooling decisions
- `README.md` — getting started, project structure, dbt → Dataform cheat sheet
