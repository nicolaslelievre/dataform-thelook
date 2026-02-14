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

