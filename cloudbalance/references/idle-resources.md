# Idle Resource Identification Reference

> Idle resources represent pure waste — compute or storage spend with no meaningful workload.
> They are typically the highest-confidence, lowest-risk savings opportunity in an AWS account.
> CloudBalance tracks idle resources at `/cb/idle/recommendations/`.

---

## What makes a resource idle

Idle classification uses a combination of AWS Compute Optimizer analysis and CloudWatch
metrics. Resources must meet thresholds consistently over the observation window (14 days)
to be flagged — not just a momentary dip in activity.

### EC2 instances

| Criterion | Threshold |
|---|---|
| Peak CPU utilization | < 5% |
| Network I/O | < 5 MB/day |

Both criteria must be met. An instance with low CPU but meaningful network traffic
(e.g., a proxy or bastion host) will not be classified as idle.

**Recommended action:** Stop or terminate. If the instance serves a periodic batch job
that hasn't run in the observation window, verify before terminating — check CloudWatch
for historical CPU spikes outside the 14-day window.

### EC2 Auto Scaling Groups

| Criterion | Threshold |
|---|---|
| Peak CPU across all instances | < 5% |
| Network utilization across all instances | < 5 MB/day |

Both criteria must be met across the group (no single instance may exceed the threshold).
Recommended action: scale down to one instance or delete the ASG.

### EBS volumes

| Criterion | Threshold |
|---|---|
| IOPS | < 1 IOPS/day |
| Unattached duration | > 32 days |

Unattached volumes accrue full storage charges with no utilization. Attached volumes
with near-zero IOPS are also candidates for deletion.

**Recommended action:** Delete or snapshot-and-delete. Always take a final snapshot before
deleting if there is any uncertainty about whether the data is needed.

### RDS databases

| Criterion | Threshold |
|---|---|
| Database connections | 0 (no connections) |
| CPU utilization | Very low |
| Database activity | Very low |

**Recommended action:** Stop (temporary, up to 7 days — AWS auto-starts after 7 days) or
delete. For development databases that see occasional use, consider using RDS stop/start
scheduling or migrating to Aurora Serverless v2.

### ECS Fargate

| Criterion | Threshold |
|---|---|
| CPU utilization | < 1% |
| Memory utilization | < 1% |

**Recommended action:** Review task definitions and services; stop unused services or tasks.

---

## Common pitfalls

**Scheduled jobs:** A resource may appear idle because its workload runs outside the
14-day observation window. Check CloudWatch metrics beyond the default window before
acting on the recommendation.

**Monitoring and health check traffic:** Some resources generate minimal CPU/network
from health checks or monitoring agents. This can keep them from being classified idle
even though they serve no real workload. Review the resource purpose directly.

**Deliberate standby:** Warm standbys, DR instances, and pre-scaled capacity may
intentionally sit idle. Use CloudBalance's exclude tags feature to suppress
recommendations for resources that should not be touched.

---

## Using CloudBalance for idle resource management

1. Review idle recommendations at `/cb/idle/recommendations/`
2. Filter by resource type (EC2, EBS, RDS) and sort by monthly cost
3. Tag resources you want to exclude from future recommendations with the configured
   exclude tag (set in Automation Config at `/cb/automation/settings/`)
4. CloudBalance can schedule stop/terminate actions with an approval workflow —
   enable at `/cb/automation/settings/`

---

> *CloudBalance content. Licensed under CC BY-SA 4.0.*
> *Copyright (c) CloudBalance (https://www.cloudbalance.ai)*
