# EKS Cost Optimization Reference

> EKS cluster costs are primarily driven by EC2 node group sizing. Over-provisioned node
> groups are common — Kubernetes schedulers reserve capacity defensively, leading to
> low actual utilization across nodes.
> CloudBalance tracks EKS recommendations at `/cb/eks/recommendations/`.

---

## How CloudBalance analyzes EKS clusters

CloudBalance uses two data sources to classify each cluster:

| Source | Window | What it measures |
|---|---|---|
| CUR split cost allocation | 30 days | Actual billed cost per cluster, broken out from shared EC2 spend |
| CloudWatch Container Insights | 14 days | CPU and memory utilization at the node level |

Split cost allocation must be enabled in AWS Cost Management for per-cluster cost attribution
to work. Without it, EKS costs appear as undifferentiated EC2 spend.

---

## Cluster classification

| Finding | Criteria | Recommended action |
|---|---|---|
| **Idle** | ≥ 30% of cluster cost is unused capacity | Consolidate workloads; reduce node count significantly |
| **Underutilized** | ≥ 15% unused capacity | Reduce node count or downsize node instance type |
| **Optimized** | < 15% unused capacity | No action needed |

**Target utilization:** CloudBalance recommendations target **70% node utilization**,
leaving 30% headroom for:
- Pod scheduling flexibility (Kubernetes needs room to place new pods)
- Node-level overhead (OS, kubelet, kube-proxy, DaemonSets)
- Traffic spikes and autoscaling lag

---

## Recommended node count calculation

CloudBalance calculates the recommended node count using the higher of two approaches:

1. **Cost-based:** How many nodes does the actual billed workload justify at 70% utilization?
2. **Utilization-based:** How many nodes are needed to keep average CPU+memory below 70%?

Taking the higher of the two prevents recommendations that would cause immediate resource pressure.

**Confidence weighting:** Savings estimates are adjusted based on data availability:
- Container Insights enabled + split cost coverage: higher confidence (base 60% Idle / 35% Underutilized savings ratio)
- One source missing: lower confidence multiplier applied

---

## Cost reduction approaches

### Reduce node count (horizontal scale-in)

Most effective when clusters are running more nodes than workloads require.

1. Review current node utilization in CloudWatch Container Insights
2. Cordon and drain nodes before removal to safely reschedule pods
3. Update the node group desired capacity (or Auto Scaling min/max)
4. Monitor pod scheduling and node pressure after reduction

### Downsize node instance type (vertical scale-down)

Appropriate when node count is correct but each node is over-sized.

1. Create a new node group with a smaller instance type
2. Cordon the old nodes and allow workloads to drain to new nodes
3. Delete the old node group once all pods are rescheduled

### Enable Cluster Autoscaler or Karpenter

Autoscaling prevents persistent over-provisioning by adding nodes when needed and
removing them when idle. If the cluster isn't using autoscaling:

- **Cluster Autoscaler:** scales based on pending pod requests and node utilization
- **Karpenter:** more efficient; provisions right-sized nodes per workload requirements,
  supports consolidation (moves pods to fewer nodes and terminates excess)

---

## Enabling CUR split cost allocation

Required for accurate per-cluster cost attribution:

1. AWS Console → Cost Management → Cost Allocation Tags
2. Enable the `aws:eks:cluster-name` tag for cost allocation
3. AWS Console → Cost Management → Settings → Split cost allocation data → Enable for EKS

Split cost data appears in CUR within 24-48 hours of enabling.

---

> *CloudBalance content. Licensed under CC BY-SA 4.0.*
> *Copyright (c) CloudBalance (https://www.cloudbalance.ai)*
