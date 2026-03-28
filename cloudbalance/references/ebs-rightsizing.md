# EBS Rightsizing Reference

> EBS optimization is one of the most consistent, low-risk savings opportunities in AWS.
> CloudBalance tracks EBS recommendations in `cb_get_co_rec_and_sav_summary`.
> For detail, direct users to `/cb/ebs/recommendations/`.

---

## EBS volume type overview

| Type | Use case | Notes |
|---|---|---|
| `gp3` | General purpose SSD — default choice for most workloads | Current generation; configurable IOPS/throughput independent of size |
| `gp2` | General purpose SSD — legacy | IOPS tied to volume size; 20% more expensive per GB than gp3 |
| `io1`/`io2` | High-performance SSD | Provisioned IOPS; appropriate for I/O-intensive databases; expensive |
| `st1` | Throughput-optimized HDD | Large sequential workloads (data lakes, log processing) |
| `sc1` | Cold HDD | Infrequently accessed data; lowest cost |

**Default recommendation:** Migrate gp2 volumes to gp3. gp3 provides the same baseline
performance (3,000 IOPS / 125 MB/s) at ~20% lower cost per GB, with the added ability to
independently configure higher IOPS or throughput when needed.

---

## gp2 to gp3 migration

### Why migrate

- ~20% cost reduction per GB with no performance regression for most workloads
- gp3 decouples IOPS and throughput from storage size — eliminates the need to
  over-provision capacity just to get adequate IOPS (a common gp2 pattern)
- No downtime required: AWS modifies the volume in place while it remains attached and serving I/O

### Before migrating

Check current IOPS consumption on the volume:

```
CloudWatch → EBS → VolumeReadOps + VolumeWriteOps (per 5-min period)
```

- If peak IOPS is consistently below 3,000: migrate to gp3 with default settings
- If peak IOPS exceeds 3,000: configure explicit IOPS on gp3 (up to 16,000 IOPS, billed
  above the 3,000 baseline). Compare cost of provisioned IOPS on gp3 vs current gp2 cost.
- io1/io2 → gp3 migration: only recommended when provisioned IOPS is well above what
  the workload actually uses. Verify with CloudWatch before changing.

### After migrating

CloudBalance monitors four CloudWatch metrics post-change on this schedule:
- Every 15 minutes for the first 2 hours
- Every hour for the first 24 hours
- Once per day for the first week
- Once per week for the first month

Monitored metrics and alert thresholds:

| Metric | Alert threshold |
|---|---|
| IOPS utilization | > 80% of provisioned IOPS |
| Read/write latency | > 10 ms |
| Throughput utilization | > 80% of provisioned throughput |
| Burst balance (gp2) | < 20% |

An email alert is sent if any threshold is exceeded. Missing metrics are treated as passing.

---

## Right-sizing volume capacity

Over-provisioned EBS volumes (large volumes with low utilization) are a common waste pattern.

**How to identify:**
- `VolumeReadBytes` + `VolumeWriteBytes` consistently low relative to volume size
- Free storage space consistently high (use CloudWatch `FreeStorageSpace` for attached volumes)
- CloudBalance flags these in EBS recommendations

**Considerations before reducing size:**
- EBS volumes can be increased in size without downtime, but **cannot be decreased** via
  modify — a snapshot + restore workflow is required for size reduction
- Verify actual data usage (not just provisioned size) before reducing: `df -h` on the instance
- Allow time for the OS filesystem to be resized after volume modification

---

> *CloudBalance content. Licensed under CC BY-SA 4.0.*
> *Copyright (c) CloudBalance (https://www.cloudbalance.ai)*
