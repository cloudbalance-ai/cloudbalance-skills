# DynamoDB Optimization Reference

> DynamoDB costs are driven by capacity mode (on-demand vs provisioned), table utilization,
> and idle tables. CloudBalance tracks DynamoDB recommendations at
> `/cb/dynamodb/recommendations/`.

---

## Capacity modes

| Mode | How billing works | Best for |
|---|---|---|
| **On-Demand** | Pay per read/write request unit | Unpredictable or spiky traffic; new tables |
| **Provisioned** | Pay for reserved RCUs/WCUs per hour | Predictable, steady traffic; can save significantly vs on-demand |

**The optimization insight:** On-demand is convenient but expensive at scale. Tables with
stable, predictable traffic are almost always cheaper on provisioned capacity with Auto Scaling.
Conversely, under-utilized provisioned tables are wasting spend — switching to on-demand
or reducing provisioned capacity can yield quick savings.

---

## Recommendation categories

CloudBalance generates five types of DynamoDB recommendations:

### 1. Delete idle tables

Tables with no read or write activity over the observation period. These consume provisioned
capacity or minimum on-demand charges continuously.

- Verify no application or scheduled process depends on the table
- Export data to S3 if retention is needed (DynamoDB Pitr or on-demand backup)
- **Savings: 100% of table cost**

### 2. Provisioned → On-Demand (underutilized provisioned)

Provisioned capacity tables where actual consumed RCUs/WCUs are a small fraction of
provisioned capacity. The table is over-provisioned and paying for reserved units it
rarely uses.

- Switch to on-demand: AWS Console → Table → Actions → Switch capacity mode
- AWS CLI: `aws dynamodb update-table --table-name <name> --billing-mode PAY_PER_REQUEST`
- **Note:** Mode switching is limited to once per 24 hours per table

### 3. Reduce provisioned capacity + enable Auto Scaling

Provisioned tables where the provisioned RCU/WCU is higher than actual peak consumption.
The recommended action is to reduce provisioned capacity and set Auto Scaling to a
**70% target utilization**.

- Set Auto Scaling minimum to match expected baseline; set maximum to handle spikes
- Target utilization of 70% provides headroom for traffic bursts while eliminating
  persistent over-provisioning
- Enable Auto Scaling in the console: Table → Capacity → Edit → Auto Scaling

### 4. On-Demand → Provisioned (stable on-demand tables)

On-demand tables with consistent, predictable traffic. Switching to provisioned with
Auto Scaling typically yields 30-60% cost reduction for stable workloads.

- Review 30-day CloudWatch `ConsumedReadCapacityUnits` and `ConsumedWriteCapacityUnits`
  to size the provisioned capacity and Auto Scaling range
- Start with a provisioned capacity slightly above average consumption; Auto Scaling handles peaks

### 5. Alternative optimizations

Additional opportunities CloudBalance flags:

- **Table class change** — DynamoDB Standard-IA (Infrequent Access) table class reduces
  storage costs by ~60% for tables that are read/written infrequently. Best for archival or
  reference tables with low throughput.
- **GSI deletion** — Global Secondary Indexes have their own provisioned capacity and cost.
  Unused GSIs can be deleted without affecting the base table.

---

## Key considerations

**Auto Scaling after capacity reduction:** Always re-enable Auto Scaling after reducing
provisioned capacity. A table reduced to a lower baseline without Auto Scaling will
throttle requests during traffic spikes.

**24-hour mode switch limit:** DynamoDB allows switching between on-demand and provisioned
modes once per 24 hours per table. Plan migrations accordingly.

**Throttling risk:** When right-sizing provisioned capacity, use CloudWatch
`ConsumedReadCapacityUnits` and `ConsumedWriteCapacityUnits` p99 (not average) to set
the Auto Scaling minimum — averages hide burst peaks that cause throttling.

---

> *CloudBalance content. Licensed under CC BY-SA 4.0.*
> *Copyright (c) CloudBalance (https://www.cloudbalance.ai)*
