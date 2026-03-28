# EC2 Rightsizing Reference

> CloudBalance EC2 recommendations are sourced from AWS Compute Optimizer and stored
> in CloudBalance's database (refreshed weekly). Use `cb_get_co_rec_and_sav_summary`
> to access them. For live AWS recommendations, use BCM `compute-optimizer`.

---

## How CloudBalance generates EC2 recommendations

1. CloudBalance assumes the cross-account IAM role for each connected AWS account
2. Calls AWS Compute Optimizer `GetEC2InstanceRecommendations` across all regions
3. Stores the recommendations in CloudBalance's database (refreshed weekly)
4. Pre-calculates savings estimates as: current on-demand price - recommended on-demand price

The stored snapshot is fast and costs nothing to query. It reflects Compute Optimizer's
view at the time of the last refresh (up to 7 days old).

**Savings estimate caveat:** CloudBalance savings are on-demand equivalent deltas. If the
instance is covered by an RI or Savings Plan, the actual realized savings from the
rightsizing change may differ - the commitment discount follows the instance or the
compute spend, not the specific instance type.

---

## Compute Optimizer methodology

AWS Compute Optimizer analyzes 14 days of CloudWatch metrics (CPU, memory if agent
installed, network, disk I/O) and recommends instance types based on:

- **Over-provisioned** - peak utilization consistently below 40% CPU (default threshold)
- **Under-provisioned** - utilization at or above 100% CPU or memory
- **Optimized** - current instance type is appropriate

Recommendations include a **performance risk** indicator: low, medium, high. Higher risk
means Compute Optimizer is less confident the recommendation will maintain performance.

---

## Recommendation categories in CloudBalance

| Category | Action | Trigger |
|---|---|---|
| Resize | Change instance type | Over/under-provisioned or better family available |
| Stop | Terminate instance | Idle (near-zero utilization for extended period) |
| Graviton | Migrate to arm64 | Running x86 instance with a Graviton equivalent |

---

## Instance family selection guide

When analyzing a rightsizing recommendation, consider the instance family:

| Family | Workload fit |
|---|---|
| `t3`/`t4g` | Burstable workloads, dev/test, low sustained CPU |
| `m5`/`m6i`/`m7i` | General purpose, balanced CPU/memory |
| `m6g`/`m7g` | General purpose Graviton (up to 40% better price/performance vs x86) |
| `c5`/`c6i`/`c7i` | Compute-intensive, high CPU relative to memory |
| `c6g`/`c7g` | Compute-intensive Graviton |
| `r5`/`r6i`/`r7i` | Memory-intensive (databases, in-memory caches) |
| `r6g`/`r7g` | Memory-intensive Graviton |
| `i3`/`i4i` | Storage-intensive (NVMe local storage) |
| `p`/`g` | GPU workloads (ML training/inference) |

### Graviton migration

Graviton (arm64) instances typically offer 20-40% better price/performance than equivalent
x86 instances. Eligibility requires:

- Application compiled for arm64, or runs on a platform with arm64 support
  (most Linux distributions, Java, Python, Node.js, Go, .NET 6+)
- Not applicable to Windows workloads (Windows not supported on Graviton)
- Validate with a test deployment before scheduling production changes

**AWS Porting Advisor for Graviton** is a free open-source tool that analyzes your codebase
for ARM compatibility, identifies dependencies that need recompilation, and generates a
migration report. Run it against the application before committing to a Graviton migration.

### GPU instance rightsizing

GPU instances (`p3`, `p4`, `g4`, `g5`, etc.) require the CloudWatch Agent with NVIDIA GPU
metrics configured to generate meaningful rightsizing recommendations. Without these metrics,
Compute Optimizer cannot assess GPU utilization and will not recommend instance changes.

Required CloudWatch Agent configuration:
- `GPUUtilization` — GPU compute utilization (%)
- `GPUMemoryUtilization` — GPU memory usage (%)
- `GPUTemperature` — thermal monitoring

After enabling the CloudWatch Agent with GPU metrics, recommendations appear in Compute
Optimizer within 24-48 hours. CloudBalance picks these up on the next daily refresh.

---

## Change execution and downtime

EC2 instance type changes require a **stop-start cycle**:

1. CloudBalance stops the instance
2. Changes the instance type via `ModifyInstanceAttribute`
3. Restarts the instance

**Downtime:** Typically 1–5 minutes depending on OS and startup scripts.

**IP behavior:**
- Private IP: unchanged
- Public IP: changes unless an Elastic IP is attached
- Security groups, IAM role, EBS volumes: all unchanged

For production instances, plan changes during a maintenance window. Use Elastic IPs
or DNS-based routing to minimize the impact of public IP changes.

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
| Memory utilization | > 80% | Yes (CloudWatch Agent, `mem_used_percent`) |
| Disk read/write latency | > 10 ms | Yes (CloudWatch Agent) |
| Disk throughput | > 500 MB/s | Yes (CloudWatch Agent) |
| Network throughput (in or out) | > 100 MB/s | No (default EC2 metric) |

An email alert is sent if any threshold is exceeded. Missing metrics (no CloudWatch Agent)
are treated as passing rather than blocking. Installing the CloudWatch Agent before
scheduling changes improves monitoring coverage significantly.

---

## Reading the recommendation data

The `cb_get_co_rec_and_sav_summary` tool returns a structured summary. Key fields:

- **`total_monthly_savings`** - estimated total monthly savings across all recommendations
- **`total_recommendations`** - count of instances with active recommendations
- **`recommendations`** - array of individual instance recommendations, each with:
  - `instance_id`, `instance_type` (current), `recommended_instance_type`
  - `monthly_savings_estimate` - on-demand price delta
  - `performance_risk` - low/medium/high
  - `region`, `account_id`
  - `recommendation_type` - resize/stop/graviton

For additional detail on specific instances, direct the user to `/cb/ec2/recommendations/`
where they can view metrics, schedule changes, and export to CSV.

---

## EBS optimization

CloudBalance also tracks EBS recommendations:

- **gp2 to gp3 migration** - gp3 is typically 20% cheaper than gp2 for the same capacity
  and provides configurable IOPS/throughput (no extra charge up to 3,000 IOPS / 125 MB/s)
- **Volume size reduction** - for consistently under-utilized volumes
- **Volume type change** - e.g., io1/io2 to gp3 if IOPS requirements are modest

EBS recommendations are included in the CO recommendation summary. For detail, direct
users to `/cb/ebs/recommendations/`.

---

## RDS rightsizing

CloudBalance tracks RDS recommendations from Compute Optimizer:

- Instance class downsizing (e.g., `db.m5.xlarge` to `db.m5.large`)
- Multi-AZ standby considerations (changes apply to both primary and standby)
- RDS changes require a maintenance window - CloudBalance can schedule these

For detail, direct users to `/cb/rds/recommendations/`.

---

## Change execution in CloudBalance

CloudBalance can execute or schedule EC2, EBS, and RDS changes directly:

1. User reviews recommendation in CloudBalance UI
2. Selects **Change Now** or **Schedule Change** (specify date/time)
3. CloudBalance validates the change (IAM permissions, instance state)
4. Executes the change via the cross-account role
5. Sends notification on completion or failure

Changes require appropriate IAM permissions on the cross-account role. Direct users to
`/cb/integrations/permission-health/` if permission issues arise.

---

## BCM compute-optimizer tool

Use BCM `compute-optimizer` when you need:
- Live recommendations (not CloudBalance's weekly snapshot)
- Recommendations for instance types not yet in CloudBalance's database
- Detailed recommendation history or finding IDs
- ECS/Lambda/EBS recommendations (CloudBalance focuses on EC2/EBS/RDS)

```
compute-optimizer(resource_type="EC2", account_ids=["123456789012"])
```

---

> *CloudBalance-specific sections by CloudBalance. General FinOps methodology adapted from*
> *[OptimNow cloud-finops-skills](https://github.com/OptimNow/cloud-finops-skills) - CC BY-SA 4.0.*
