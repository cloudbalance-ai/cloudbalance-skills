# CloudBalance MCP Tools Reference

> Two MCP servers are available. Both authenticate with the same `X-CB-Api-Token` header.
> **Always prefer CloudBalance tools** - they use cached CUR data and incur no AWS API charges.
> Use BCM tools only when CloudBalance tools cannot answer the query.

---

## CloudBalance MCP server (`/mcp`)

These tools query CloudBalance's own datastore (pre-processed CUR data). They are fast,
free, and always available as long as CUR data has been ingested.

---

### `cb_health`

Returns service status. No authentication required.

**When to use:** Verify the MCP server is reachable before troubleshooting other issues.

**Returns:** `{"service": "...", "version": "...", "time_utc": "..."}`

---

### `cb_time_info`

Returns current UTC time and month helpers.

**When to use:** Always call this first when constructing date parameters for other tools.
Never guess the current month - use this tool.

**Returns:**
```json
{
  "now_utc": "2025-03-26T18:00:00Z",
  "current_month": "2025-03",
  "first_of_current_month": "2025-03-01",
  "last_full_month": "2025-02",
  "months_last_13": ["2024-03", "2024-04", ..., "2025-03"],
  "labels_last_13": ["Mar 2024", "Apr 2024", ..., "Mar 2025"]
}
```

---

### `cb_get_cost_summary`

Returns AWS costs from CloudBalance's CUR datastore at monthly or daily granularity.

**When to use:**
- Any cost question broken down by service or instance type
- Spending trends over time
- Top services by spend
- Daily cost spikes or anomalies

**Prefer over BCM `cost-explorer`** for all standard cost queries - CUR-cached, no AWS charges.

**Parameters:**

| Parameter | Required | Values | Default |
|---|---|---|---|
| `group_by` | Yes | `"service"` or `"instance_type"` | - |
| `granularity` | No | `"monthly"` or `"daily"` | `"monthly"` |
| `cost_type` | No | `"unblended"` or `"amortized"` | `"unblended"` |
| `time_range` | No | See formats below | Last 13 months (monthly) |
| `filters` | No | JSON string - see below | All accounts, all line items |

**`time_range` formats:**
- Single month: `"2025-02"`
- Month range: `"2024-12..2025-02"`
- Single day: `"2025-03-15"`
- Day range: `"2025-03-01..2025-03-15"`
- Future dates are clamped to today automatically

**`filters` JSON fields:**
```json
{
  "account_id": "123456789012",
  "top_n": 10,
  "include_usage": true,
  "include_credit": true,
  "include_refund": false,
  "include_tax": false
}
```

**Example invocations:**

Top services last 3 months:
```
cb_get_cost_summary(group_by="service", time_range="2024-12..2025-02")
```

EC2 instance type costs for a specific account this month:
```
cb_get_cost_summary(
  group_by="instance_type",
  time_range="2025-03",
  filters='{"account_id": "123456789012"}'
)
```

Daily costs last 30 days, top 5 services:
```
cb_get_cost_summary(
  group_by="service",
  granularity="daily",
  time_range="2025-02-24..2025-03-25",
  filters='{"top_n": 5}'
)
```

**Returns:** Array of cost records with `month`/`date`, `group_value`, and cost fields.

---

### `cb_get_commitment_performance`

Returns Savings Plans and Reserved Instance commitments with optional monthly performance data.

**When to use:**
- SP or RI utilization and savings questions
- Coverage rate analysis
- Commitment expiration review
- Month-over-month commitment performance

**Prefer over BCM `sp-performance` and `ri-performance`** for standard commitment questions.

**Parameters:**

| Parameter | Required | Values | Default |
|---|---|---|---|
| `include_meta` | No | `true`/`false` | `false` |
| `include_performance` | No | `true`/`false` | `false` |
| `active_only` | No | `true`/`false` | `true` |
| `types` | No | JSON array: `"SP"`, `"EC2"`, `"RDS"` | `["SP","EC2","RDS"]` |
| `time_range` | No | `"YYYY-MM"` or `"YYYY-MM..YYYY-MM"` | Current month |

**Commitment types:**
- `"SP"` - Savings Plans (Compute SP, EC2 Instance SP, SageMaker SP)
- `"EC2"` - EC2 Reserved Instances
- `"RDS"` - RDS Reserved Instances

**Rate fields are fractions (0..1) - multiply by 100 for percentages.**

**Example invocations:**

All active commitments with 3-month performance:
```
cb_get_commitment_performance(
  include_performance=True,
  time_range="2024-12..2025-02"
)
```

Savings Plans only, last 6 months:
```
cb_get_commitment_performance(
  types='["SP"]',
  include_performance=True,
  time_range="2024-09..2025-02"
)
```

Include expired commitments:
```
cb_get_commitment_performance(active_only=False, include_performance=True)
```

---

### `cb_get_co_rec_and_sav_summary`

Returns the latest Compute Optimizer recommendation and savings summary.

**When to use:**
- EC2, EBS, or RDS rightsizing questions
- Total savings opportunity overview
- Recommendation counts by type

**When to use BCM `compute-optimizer` instead:** When you need live recommendations
directly from AWS (not CloudBalance's weekly snapshot), or for detailed per-instance
recommendation history.

**Parameters:**

| Parameter | Required | Values | Default |
|---|---|---|---|
| `include_meta` | No | `true`/`false` | `false` |

`include_meta=True` adds `company_id`, `latest_recommendation_date`, and `generated_at_utc`
to the response - useful for confirming data freshness.

**Example invocations:**

Get rightsizing summary:
```
cb_get_co_rec_and_sav_summary()
```

Get with metadata to check data date:
```
cb_get_co_rec_and_sav_summary(include_meta=True)
```

---

## BCM MCP server (`/mcp-bcm`)

These tools make live AWS API calls. They incur per-request AWS Cost Explorer charges.
Use only when CloudBalance tools cannot answer the query.

### When to escalate to BCM tools

| Situation | BCM tool |
|---|---|
| Cost data older than 13 months | `cost-explorer` (getCostAndUsage) |
| Resource-level cost attribution (last 14 days) | `cost-explorer` (getCostAndUsageWithResources) |
| AWS-detected cost anomalies | `cost-anomaly` |
| Budget status and alerts | `budgets` |
| AWS on-demand pricing lookup | `aws-pricing` |
| Live Compute Optimizer recommendations | `compute-optimizer` |
| Cost Optimization Hub recommendations | `cost-optimization` |
| Savings Plans CE data (live coverage/utilization) | `sp-performance` |
| RI CE data (live coverage/utilization) | `ri-performance` |
| Pricing Calculator workload estimates | `bcm-pricing-calc` |
| S3 Storage Lens metrics | `storage-lens` |
| Cross-session SQL queries on cost data | `session-sql` |
| Billing Conductor groups | `list-billing-groups`, `list-account-associations` |

### BCM `cost-explorer` key operations

```
cost-explorer(operation="getCostAndUsage",
  start_date="2024-01-01", end_date="2024-02-01",
  granularity="MONTHLY", metrics=["UnblendedCost"],
  group_by='[{"Type": "DIMENSION", "Key": "SERVICE"}]')
```

Note: `end_date` is **exclusive** in CE API (use the first day of the next period).

Default metric: `UnblendedCost`. Use `AmortizedCost` when analyzing SP/RI impact.
Exclude `Credit` and `Refund` record types by default unless the user requests them.

---

## Tool selection quick reference

```
Cost question?
  └── By service or instance type → cb_get_cost_summary
  └── Older than 13 months → BCM cost-explorer
  └── Resource-level (last 14 days) → BCM cost-explorer (WithResources)

Commitment question?
  └── SP/RI performance, coverage, utilization → cb_get_commitment_performance
  └── Need live CE data specifically → BCM sp-performance / ri-performance

Rightsizing question?
  └── Summary of recommendations → cb_get_co_rec_and_sav_summary
  └── Live AWS recommendations → BCM compute-optimizer

Anomaly / budget question?
  └── BCM cost-anomaly / budgets

Date/time context?
  └── Always call cb_time_info first
```
