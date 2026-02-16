# Rule Index

Rules the team must follow in this Dataform project. Each rule has a code, a dot-notation name, a description, and examples.

**Core Rule** — rules marked ✓ are mandatory and will be enforced in CI.

---

## Rule Index

| Bundle | Rule Name | Code | Core Rule |
|---|---|---|---|
| Naming bundle | `naming.source` | NM01 | ✓ |
| | `naming.staging` | NM02 | ✓ |
| | `naming.intermediate` | NM03 | ✓ |
| | `naming.fact` | NM04 | ✓ |
| | `naming.dimension` | NM05 | ✓ |

---

## Naming bundle

Rules governing how files and models are named across all layers.

---

### naming.source

| Field | Value |
|---|---|
| **Code** | NM01 |
| **Pattern** | `src_{source}__{table}` |
| **Applies to** | Files in `definitions/sources/` |

**Description**

Source declaration files must be prefixed with `src_`, followed by the source system name, a double underscore (`__`), and the raw table name in snake_case. The prefix is a **file organisation convention only**.

In Dataform, the `name:` field in the declaration config controls both the BigQuery table it resolves to and the `ref()` name used in downstream models. The `src_thelook__` prefix must not be used as the `name:` value — it must be set to the actual BigQuery table name (e.g. `name: "orders"`).

```sqlx
config {
  type: "declaration",
  database: "bigquery-public-data",
  schema: "thelook_ecommerce",
  name: "orders",             -- actual BQ table name + ref() name
  ...
}
```

Downstream models reference sources using the raw table name:
```
${ref("orders")}              -- correct
${ref("src_thelook__orders")} -- wrong, table does not exist in BQ
```

**Examples**

```
# Good — file uses src_thelook__ prefix, config name is raw table name
src_thelook__orders.sqlx           (name: "orders")
src_thelook__order_items.sqlx      (name: "order_items")
src_thelook__distribution_centers.sqlx  (name: "distribution_centers")

# Bad — missing src_ prefix
orders.sqlx
thelook_orders.sqlx

# Bad — single underscore between source and table
src_thelook_orders.sqlx

# Bad — name: in config set to prefixed filename
name: "src_thelook__orders"   -- resolves to non-existent BQ table
```

---

### naming.staging

| Field | Value |
|---|---|
| **Code** | NM02 |
| **Pattern** | `stg_{source}__{table}` |
| **Applies to** | Files in `definitions/staging/` |

**Description**

Staging models must be prefixed with `stg_`, followed by the source system name, a double underscore (`__`), and the entity name in snake_case. There must be exactly one staging model per source table — staging is a strict 1-to-1 mapping layer.

Staging models must not join other models. Joins belong in the intermediate layer.

**Examples**

```
# Good
stg_thelook__orders.sqlx
stg_thelook__order_items.sqlx
stg_thelook__users.sqlx

# Bad — missing stg_ prefix
orders_clean.sqlx
thelook_orders.sqlx

# Bad — single underscore between source and table
stg_thelook_orders.sqlx

# Bad — source system absent
stg__orders.sqlx
```

---

### naming.intermediate

| Field | Value |
|---|---|
| **Code** | NM03 |
| **Pattern** | `int_{entity}__{verb}` |
| **Applies to** | Files in `definitions/intermediate/` |

**Description**

Intermediate models must be prefixed with `int_`, followed by the primary entity name, a double underscore (`__`), and a verb describing the transformation. The verb must be meaningful and specific: prefer `enriched`, `pivoted`, `aggregated`, `joined`, `deduplicated` over vague terms like `final` or `new`.

Intermediate models are not exposed to BI tools. They exist to keep mart models readable and to allow logic reuse across multiple downstream consumers.

**Examples**

```
# Good
int_orders__enriched.sqlx          -- orders joined with user and item aggregates
int_order_items__enriched.sqlx     -- order items joined with product and cost data
int_users__order_metrics.sqlx      -- user-grain aggregation of order history

# Bad — no verb, transformation not described
int_orders.sqlx
int_users.sqlx

# Bad — missing int_ prefix
orders_enriched.sqlx
enriched_orders.sqlx

# Bad — single underscore between entity and verb
int_orders_enriched.sqlx
```

---

### naming.fact

| Field | Value |
|---|---|
| **Code** | NM04 |
| **Pattern** | `fct_{entity}` |
| **Applies to** | Files in `definitions/marts/` that represent facts |

**Description**

Fact tables must be prefixed with `fct_`, followed by the entity name in snake_case. The entity name should reflect the grain — one row per what? Use the plural noun that answers that question (e.g. `fct_orders` = one row per order).

Fact tables are materialised as incremental tables with BigQuery partitioning and clustering.

**Examples**

```
# Good
fct_orders.sqlx          -- one row per order
fct_order_items.sqlx     -- one row per order item

# Bad — wrong prefix
fact_orders.sqlx
orders_fact.sqlx
orders.sqlx
```

---

### naming.dimension

| Field | Value |
|---|---|
| **Code** | NM05 |
| **Pattern** | `dim_{entity}` |
| **Applies to** | Files in `definitions/marts/` that represent dimensions |

**Description**

Dimension tables must be prefixed with `dim_`, followed by the entity name in snake_case. Dimensions are full-refresh tables (not incremental) and must contain exactly one current row per entity.

**Examples**

```
# Good
dim_users.sqlx
dim_products.sqlx

# Bad — wrong prefix
dimension_users.sqlx
users_dim.sqlx
users.sqlx

# Bad — using fact prefix for a dimension
fct_users.sqlx
```

---

## Double underscore rule

The double underscore (`__`) separates two semantic parts of a name. Single underscores connect words *within* a part.

```
stg  _  thelook  __  order  _  items
 ^           ^    ^^      ^
prefix    source  separator  table name (two words)
```

This makes every model name machine-parseable and unambiguous to read.
