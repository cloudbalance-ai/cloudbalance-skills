# Automated Changes Reference

> CloudBalance can execute or schedule rightsizing changes directly against AWS resources
> via the cross-account IAM role. This covers EC2 instance type changes, EBS volume
> modifications, RDS instance class changes, and idle resource stop/termination.
> Configure automation at `/cb/automation/settings/`.

---

## How automated changes work

1. CloudBalance runs a weekly recommendation scan for the company
2. Eligible changes are selected — up to 10 per resource type, ordered by potential savings
3. Each change is validated before execution (see Validation Checks below)
4. Changes are scheduled for the next maintenance window
5. CloudBalance monitors health post-change and sends notifications on completion or failure
6. All changes are tracked with rollback support

---

## Enabling automation

Automation is configured per resource type in `/cb/automation/settings/`:

| Setting | Description |
|---|---|
| Enable/disable per type | EC2, EBS, RDS, and Idle can each be independently enabled |
| Require approval | When enabled, changes are queued for human review before execution |
| Exclude tags | Resources tagged with the configured key/value are never touched |
| Maintenance window | Time window when changes are allowed to execute |

**Recommendation:** Start with approval required enabled. Review a few cycles of
recommendations before switching to fully automated execution.

---

## Validation checks

Before executing any EC2 instance type change, CloudBalance performs 7 validation checks:

| Check | What it verifies |
|---|---|
| Architecture compatibility | Target instance type uses the same CPU architecture (x86_64 or arm64) as the current AMI. Graviton migrations require an arm64-compatible AMI. |
| Stop protection | Instance does not have stop protection (EC2 stop protection) enabled |
| Reserved Instance pricing impact | Flags if the instance is covered by an RI for its current instance type — changing type may lose the RI discount |
| Exclude tag | Instance does not carry the configured exclusion tag |
| Auto Scaling Group membership | Instance is not part of an ASG — ASG instances should be right-sized via launch template, not directly |
| Capacity reservation | Instance is not using a targeted capacity reservation that only applies to the current instance type |
| Placement group | Instance is not in a cluster placement group that may have constraints on the new instance type |

If any check fails, the change is blocked and CloudBalance notifies the user with the
specific reason. The change remains in the recommendation list for manual review.

---

## EC2 change execution process

1. **Stop** — CloudBalance stops the instance (causes brief downtime)
2. **Modify** — Changes the instance type via `ModifyInstanceAttribute`
3. **Start** — Restarts the instance
4. **Monitor** — Watches CPU, memory, disk I/O, and network for up to one month post-change

**Downtime note:** EC2 instance type changes require a stop-start cycle. Duration varies
by OS and startup configuration but is typically 1–5 minutes. Plan for this during
maintenance windows. Public IPs change unless an Elastic IP is attached.

---

## Post-change monitoring

CloudBalance monitors key CloudWatch metrics after an instance type change on this schedule:
- Every 15 minutes for the first 2 hours
- Every hour for the first 24 hours
- Once per day for the first week
- Once per week for the first month

Alert thresholds:

| Metric | Alert threshold | Agent required? |
|---|---|---|
| CPU utilization | > 80% | No (default EC2 metric) |
| Memory utilization | > 80% | Yes (CloudWatch Agent with `mem_used_percent`) |
| Disk read/write latency | > 10 ms | Yes (CloudWatch Agent with disk I/O metrics) |
| Disk throughput | > 500 MB/s | Yes (CloudWatch Agent) |
| Network throughput | > 100 MB/s | No (default EC2 metric) |

If any threshold is exceeded, an email alert is sent. Missing metrics (no CloudWatch Agent)
are treated as passing rather than failures.

---

## Rollback

If post-change monitoring detects a problem, or the user manually requests a rollback,
CloudBalance can reverse the instance type change:

1. Stop the instance
2. Restore the original instance type
3. Restart and re-monitor

Rollback history is tracked in the automated changes log.

---

> *CloudBalance content. Licensed under CC BY-SA 4.0.*
> *Copyright (c) CloudBalance (https://www.cloudbalance.ai)*
