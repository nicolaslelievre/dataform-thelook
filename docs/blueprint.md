# Project Blueprint

Documents the intentional design decisions and setup choices made in this repo. Each entry explains what was implemented, why, and how to replicate it in a new project.

Use this as a checklist when bootstrapping a new Dataform project.

---

## Decision Index

| # | Decision | Area |
|---|---|---|
| 1 | [Node version pinned via nvm](#1-node-version-pinned-via-nvm) | Setup |
| 2 | [Dataform CLI as local devDependency](#2-dataform-cli-as-local-devdependency) | Setup |
| 3 | [workflow_settings.yaml over dataform.json](#3-workflow_settingsyaml-over-dataformjson) | Setup |
| 4 | [Commit message linting via commitlint](#4-commit-message-linting-via-commitlint) | CI |

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

### 2. Dataform CLI as local devDependency

**What:** `@dataform/cli` is installed as a `devDependency` in `package.json` rather than as a global npm package. All `dataform` commands are run via `npx dataform`.

**Why:** A global install (`npm install -g @dataform/cli`) ties the CLI version to whatever each developer happens to have installed. Moving it to `devDependencies` means the version is committed in `package.json`, locked in `package-lock.json`, and identical across all environments — local, CI, and production. This is the same principle as pinning `dbt-core` in a `requirements.txt`.

**How to use:**
```bash
npm install            # installs both @dataform/core and @dataform/cli locally
npx dataform compile   # runs the local CLI, not a global one
npx dataform run
```

**Files:** `package.json`

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

**Files:** `commitlint.config.js`, `.github/workflows/commitlint.yml`

