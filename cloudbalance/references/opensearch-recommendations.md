# OpenSearch Cost Optimization Reference

> OpenSearch (Amazon OpenSearch Service) domains are frequently over-provisioned — clusters
> are sized for peak load or speculative capacity that never materializes.
> CloudBalance tracks OpenSearch recommendations at `/cb/opensearch/recommendations/`.

---

## How CloudBalance analyzes OpenSearch domains

CloudBalance uses three data sources per domain:

| Source | Window | What it measures |
|---|---|---|
| CUR billing data | 30 days | Compute (instance hours), storage (EBS), data transfer costs |
| CloudWatch (`AWS/ES` namespace) | 14 days | CPU utilization, search rate, indexing rate, JVM memory pressure, free storage |
| OpenSearch `DescribeDomains` API | Current | Instance type/count, EBS config, dedicated masters, warm tier, engine version |

---

## Domain classification

| Finding | Criteria | Recommended action |
|---|---|---|
| **Idle** | Combined search + indexing rate < 1 req/s over 14 days | Delete the domain |
| **Underutilized** | Average CPU < 15% across data nodes | Downsize or migrate to Serverless |
| **Optimized** | CPU ≥ 15% and cost ≥ $25/month | No action needed |

Domains costing less than $25/month are classified as Optimized regardless of utilization —
the optimization opportunity is negligible relative to migration effort.

---

## Idle domains — deletion

A domain with < 1 req/s average over 14 days has no meaningful workload.

Before deleting:
1. Verify no application, Lambda function, Kinesis Firehose, or scheduled job depends on the domain
2. Check CloudWatch `SearchRate` and `IndexingRate` for the full 14-day window
3. If data retention is needed, take a manual snapshot to S3 first:
   ```
   PUT https://<domain>/_snapshot/<repo>/<snapshot>
   ```
4. Clean up associated resources after deletion: VPC security group rules, IAM policies,
   CloudWatch alarms, delivery streams

**Savings: 100% of domain cost (compute + EBS + data transfer)**

---

## Underutilized — downsize

Average CPU below 15% means the cluster has significant excess capacity. Two approaches:

### Vertical scaling (reduce instance type)

Move down one or two sizes within the same instance family:
- `m6g.2xlarge.search` → `m6g.xlarge.search` → `m6g.large.search`
- Check `JVMMemoryPressure` before downsizing — ensure the smaller instance has enough heap
- OpenSearch performs a **blue/green deployment** — domain stays available but the update
  takes 30–60 minutes

### Horizontal scaling (reduce node count)

- Minimum for high availability: 3 nodes (multi-AZ); 1 node acceptable for dev/single-AZ
- Before reducing: verify shard count and replica settings can be distributed across fewer nodes
- Keep node count as a multiple of AZ count for even shard distribution (e.g., 3, 6, or 9 for 3-AZ)

### Savings estimation

CloudBalance estimates underutilized domain savings conservatively:
```
savings_ratio = max(0, 1 − avg_cpu / 50)   # targets 50% CPU as operating point
savings = total_cost × savings_ratio × 0.5  # 50% safety discount for non-linear scaling
```

The 50% safety discount reflects that OpenSearch needs headroom for indexing bursts,
garbage collection, and shard rebalancing — downsizing is not perfectly proportional.

---

## Underutilized — OpenSearch Serverless

Serverless automatically scales compute for your workload and eliminates idle node costs.
CloudBalance recommends Serverless when all eligibility criteria are met:

| Criterion | Requirement |
|---|---|
| Engine type | OpenSearch only (not Elasticsearch) |
| Engine version | ≥ 2.0 |
| Data size | ≤ 1 TB |
| Current monthly cost | ≥ $350/month |

The $350/month floor reflects Serverless's minimum effective cost (~2 OCUs for indexing +
2 for search at $0.24/OCU/hour). Migration only makes economic sense when current costs
exceed this floor.

**Key Serverless limitations before recommending migration:**
- No cross-cluster replication
- No custom plugins or SQL plugin
- No ISM (Index State Management) policies — use data lifecycle policies instead
- IAM-based auth only (no fine-grained access control with internal user database)
- Migration requires creating a new collection and reindexing data

---

> *CloudBalance content. Licensed under CC BY-SA 4.0.*
> *Copyright (c) CloudBalance (https://www.cloudbalance.ai)*
