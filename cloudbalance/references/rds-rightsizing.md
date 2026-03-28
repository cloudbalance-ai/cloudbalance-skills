# RDS Rightsizing Reference

> CloudBalance RDS recommendations are sourced from AWS Compute Optimizer and stored
> in CloudBalance's database (refreshed weekly). Use `cb_get_co_rec_and_sav_summary`
> to access them. For detail, direct users to `/cb/rds/recommendations/`.

---

## Recommendation types

| Type | Action | Notes |
|---|---|---|
| Instance class change | Resize to a smaller instance class | Most common — over-provisioned memory or CPU |
| Idle | Stop or delete the DB instance | No connections or activity over 14-day period |

---

## How CloudBalance generates RDS recommendations

1. CloudBalance assumes the cross-account IAM role for each connected AWS account
2. Calls AWS Compute Optimizer `GetRDSInstanceRecommendations` across all regions
3. Stores recommendations in CloudBalance's database (refreshed weekly)
4. Pre-calculates savings as: current on-demand instance price − recommended instance price

Compute Optimizer analyzes 14 days of CloudWatch metrics including CPU utilization,
database connections, read/write IOPS, and network throughput to identify over-provisioned
instances.

---

## RDS-specific change considerations

### Maintenance window

RDS instance class changes require a database restart. Unlike EC2, RDS changes do not
take effect immediately — they are applied during the next scheduled maintenance window
unless **Apply Immediately** is selected.

CloudBalance schedules RDS changes to run during the configured maintenance window.
**Apply Immediately** bypasses the window but causes immediate downtime — use with caution
for production databases.

### Multi-AZ deployments

For Multi-AZ DB instances, AWS performs a failover to the standby before resizing the
primary, then resizes the standby. This reduces but does not eliminate downtime:
- Failover typically takes 60–120 seconds
- The new primary becomes available while the standby is resized
- Total downtime is typically less than 5 minutes for Multi-AZ vs 5–20 minutes for single-AZ

### Read replicas

Read replicas must be resized independently. CloudBalance generates separate
recommendations for each read replica. Resizing a primary does not resize its replicas.

### Aurora

Aurora instance class changes use a rolling update approach for Aurora clusters:
- Reader instances are updated first, one at a time
- The writer instance is updated last (with a brief failover to a reader)
- Aurora clusters with multiple readers experience minimal disruption

**Aurora Serverless v2** is an alternative to traditional instance class management for
variable workloads — it auto-scales compute capacity between a configured minimum and
maximum ACU range. CloudBalance flags idle Aurora instances as candidates for Serverless
migration where appropriate.

---

## Instance class selection guide

| Class family | Workload fit |
|---|---|
| `db.t3`/`db.t4g` | Burstable — dev/test, low-traffic databases |
| `db.m5`/`db.m6i`/`db.m7i` | General purpose — balanced CPU/memory |
| `db.m6g`/`db.m7g` | General purpose Graviton — same workloads, better price/performance |
| `db.r5`/`db.r6i`/`db.r7i` | Memory optimized — large in-memory datasets, high connection counts |
| `db.r6g`/`db.r7g` | Memory optimized Graviton |
| `db.x2g` | Memory intensive — very large datasets (e.g., SAP HANA, large Oracle) |

**Graviton for RDS:** Graviton-based RDS instances (`m6g`, `r6g`, etc.) offer ~10–20%
better price/performance than equivalent x86 classes. Supported for MySQL, PostgreSQL,
and MariaDB. Not available for SQL Server or Oracle.

---

## Post-change monitoring

CloudBalance monitors key CloudWatch metrics after an RDS instance class change:

| Metric | Alert threshold |
|---|---|
| CPU utilization | > 80% |
| Database connections | Unexpected drop to zero (may indicate connection failures) |
| Read/write IOPS | > 80% of provisioned IOPS |
| Freeable memory | < 10% of instance memory |

Monitoring follows the same schedule as EC2:
- Every 15 minutes for the first 2 hours
- Every hour for the first 24 hours
- Once per day for the first week
- Once per week for the first month

---

## RDS savings and commitments

RDS Reserved Instances provide 30–60% discount for a 1-year or 3-year commitment to
a specific DB instance class, engine, and region. When analyzing an RDS rightsizing
recommendation, check whether the current instance is covered by an RI:

- If covered by an RI: changing the instance class loses the RI benefit; factor this into
  the decision. The RI can be sold on the AWS Marketplace (Standard RIs only) if the
  instance class changes.
- If not covered: evaluate whether an RI purchase makes sense after rightsizing, not before.
  Commit to the right-sized instance, not the current over-provisioned one.

---

> *CloudBalance platform content: CC BY-SA 4.0, Copyright (c) CloudBalance.*
