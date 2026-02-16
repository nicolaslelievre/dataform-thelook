# Project Blueprint

Documents the intentional design decisions and setup choices made in this repo. Each entry explains what was implemented, why, and how to replicate it in a new project.

Use this as a checklist when bootstrapping a new Dataform project.

---

## Decision Index

| # | Decision | Area |
|---|---|---|
| 1 | [Node version pinned via nvm](#1-node-version-pinned-via-nvm) | Setup |
| 2 | [Dataform CLI version pinned via Makefile](#2-dataform-cli-version-pinned-via-makefile) | Setup |
| 3 | [workflow_settings.yaml over dataform.json](#3-workflow_settingsyaml-over-dataformjson) | Setup |
| 4 | [Commit message linting via commitlint](#4-commit-message-linting-via-commitlint) | CI |
| 5 | [SQL linting via SQLFluff with PR annotations](#5-sql-linting-via-sqlfluff-with-pr-annotations) | CI |

---

## Setup

### 1. Node version pinned via nvm

**What:** `.nvmrc` at the project root pins Node.js to version 20 LTS.

**Why:** Dataform's CLI and core package are Node.js-based. Without a pinned version, different team members or CI environments can run on different Node versions, leading to inconsistent behaviour or subtle bugs. `nvm` is the standard Node version manager (equivalent to `pyenv` for Python).

**How to use:**
```bash
# Install nvm if not already installed
# https://github.com/nvm-sh/nvm

nvm install   # installs the version specified in .nvmrc
nvm use       # activates it in the current shell
```

**Files:** `.nvmrc`

---

### 2. Dataform CLI version pinned via Makefile

**What:** The Dataform CLI version is pinned in a `Makefile` variable and run via `npx @dataform/cli@<version>`. All Dataform commands are wrapped as `make` targets.

**Why:** Dataform v3 does not allow `package.json` or `node_modules/` in the project root — both will cause compile to fail with an "unexpected file" error. Dataform v3 manages its own dependency resolution entirely through `workflow_settings.yaml` (`dataformCoreVersion`), with `@dataform/core` bundled in the CLI itself. There is no `dataform install` step needed.

This means npm cannot be used in the Dataform project for the CLI. The solution is `npx @dataform/cli@<version>` which pulls the CLI from npx's global cache without touching the project directory. The version is pinned in one place (`Makefile`) and all commands are exposed as `make` targets — the equivalent of a Python `Makefile` or `justfile` wrapping a pinned interpreter.

**How to use:**
```bash
make compile       # validates the DAG, no BigQuery calls
make run           # runs all models
make run-staging   # runs staging layer only
make help          # lists all available targets
```

To change the CLI version, update `DATAFORM_VERSION` in the `Makefile`. Also update `dataformCoreVersion` in `workflow_settings.yaml` to match.

**Files:** `Makefile`

---

### 3. workflow_settings.yaml over dataform.json

**What:** Project configuration uses `workflow_settings.yaml` (Dataform v3 format) instead of the legacy `dataform.json`.

**Why:** `dataform.json` is the legacy configuration format. `workflow_settings.yaml` is the current standard from Dataform v3 onwards, is supported by Dataform in Google Cloud, and supports additional fields like `vars` for runtime variable injection. New projects should always use `workflow_settings.yaml`.

**Key fields:**
```yaml
defaultProject: your-gcp-project   # GCP project ID
defaultDataset: thelook_dataform    # fallback BigQuery dataset
defaultLocation: US                 # BigQuery region
dataformCoreVersion: 3.0.0
vars:
  env: "dev"                        # overridable at runtime via --vars
```

**Files:** `workflow_settings.yaml`

---

## CI

### 4. Commit message linting via commitlint

**What:** Every PR runs commitlint against all commits in the PR using the [wagoid/commitlint-github-action](https://github.com/wagoid/commitlint-github-action). Rules are defined in `commitlint.config.js` extending the [Conventional Commits](https://www.conventionalcommits.org) spec.

**Why:** Consistent commit messages make the git log readable, enable automated changelog generation, and give reviewers a shared vocabulary. Enforcing it in CI ensures no one bypasses it locally. The wagoid action was chosen over running the CLI manually because it handles commit range detection, Node setup, and dependency installation internally — keeping the workflow minimal.

**Commit format:**
```
type(optional scope): short description

feat: add stg_thelook__orders staging model
fix: correct join condition in int_orders__enriched
docs: update blueprint with commitlint decision
chore: bump dataform core to 3.1.0
ci: add commitlint github action
refactor: extract date logic to utils.js
```

**Allowed types:** `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `style`, `ci`, `perf`, `build`, `revert`

**Key implementation details:**
- Triggers on all `pull_request` events regardless of target branch — not just PRs to `main`
- `fetch-depth: 0` is required so the action can access the full commit history to lint all commits in the PR, not just the tip
- `@commitlint/cli` and `@commitlint/config-conventional` are kept in `devDependencies` so the rules can also be run locally (`npx commitlint --from HEAD~1`)

**Onboarding tip — warning mode:** When introducing commitlint to an existing team, consider making the check non-blocking first by adding `continue-on-error: true` to the job. This lets the CI surface violations as warnings without blocking PR merges, giving the team time to adopt the convention before it is enforced.

```yaml
jobs:
  commitlint:
    runs-on: ubuntu-latest
    continue-on-error: true  # remove once the team is comfortable
```

Remove `continue-on-error` once the convention is well understood.

**Files:** `commitlint.config.js`, `.github/workflows/commitlint.yml`

---

### 5. SQL linting via SQLFluff with PR annotations

**What:** Every PR runs SQLFluff against all `.sqlx` files in `definitions/` and posts inline annotations on the diff using `yuzutech/annotations-action`.

**Why:** SQL style issues are easier to catch and fix during code review when they appear as inline comments directly on the changed lines, rather than as a log to dig through. SQLFluff's `--format github-annotation` produces output compatible with the GitHub Checks API, and `yuzutech/annotations-action` posts them without requiring a custom PAT.

**Key implementation details:**
- `templater = dataform` in `.sqlfluff` — requires the `sqlfluff-templater-dataform` plugin (separate pip package). Handles the `config {}` block and `${ref(...)}` expressions in `.sqlx` files
- `--annotation-level warning` — violations appear as warnings, not errors, so they don't block the merge (adjust to `failure` to enforce)
- `|| true` on the lint step prevents the step from failing before annotations are posted
- `definitions/sources/` is excluded via `.sqlfluffignore` — source declarations have no SQL body to lint
- `checks: write` permission is required for the annotations action to post to the GitHub Checks API

**Local setup:**
```bash
pip install -r requirements-dev.txt
sqlfluff lint definitions/
```

**Files:** `.sqlfluff`, `.sqlfluffignore`, `requirements-dev.txt`, `.github/workflows/sqlfluff.yml`

