# dataform-thelook

Dataform transformation project for `bigquery-public-data.thelook_ecommerce`. Implements a layered data model on BigQuery, structured as a framework/template for teams coming from dbt.

---

## Getting started

1. Install the Dataform CLI: `npm install -g @dataform/cli`
2. Install project dependencies: `dataform install`
3. Set your GCP project in `workflow_settings.yaml` (`defaultProject`)
4. Compile to verify the DAG: `dataform compile`
5. Run all models: `dataform run`
6. Run a single layer: `dataform run --tags staging`

---

## Project structure

```
definitions/
├── sources/
│   └── thelook/             # Source declarations (type: declaration)
├── staging/
│   └── thelook/             # Light cleaning, one view per source table
├── intermediate/             # Business logic joins and aggregations (views)
└── marts/                    # Fact and dimension tables consumed by BI tools
includes/
└── utils.js                  # Reusable JavaScript helpers (macros equivalent)
docs/
└── rules.md                  # Team rules — naming, granularity, testing (NM01+)
```

---

## Modeling layers

| Layer | Schema | Type | Purpose |
|---|---|---|---|
| **Source** | `bigquery-public-data.thelook_ecommerce` | `declaration` | Register external tables in the DAG. No SQL, no materialisation. |
| **Staging** | `staging` | `view` | Rename, cast, and lightly clean source columns. One model per source table. No joins. |
| **Intermediate** | `intermediate` | `view` | Join staging models, apply business logic, build reusable building blocks. |
| **Marts** | `marts` | `table` / `incremental` | Final facts and dimensions consumed by BI tools and analysts. |

---

## Conventions & rules

See [`docs/rules.md`](docs/rules.md) for all team rules with codes, descriptions, and examples.

---

## Key differences from dbt

| Concept | dbt | Dataform |
|---|---|---|
| Project config | `dbt_project.yml` | `workflow_settings.yaml` |
| Model files | `.sql` + `.yml` | `.sqlx` (config + SQL in one file) |
| Sources | `sources.yml` | `type: "declaration"` in `.sqlx` |
| Ref function | `{{ ref('model') }}` | `${ref("model")}` |
| Macros | `macros/*.sql` (Jinja) | `includes/*.js` (JavaScript) |
| Tests | `schema.yml` assertions | `assertions:` block in model config |
| Tags | `tags:` in `dbt_project.yml` | `tags:` in model `config {}` block |
| Incremental | `{{ is_incremental() }}` | `${when(incremental(), "...")}` |
