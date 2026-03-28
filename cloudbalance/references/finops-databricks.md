# FinOps on Databricks

> Databricks-specific optimization patterns covering compute clusters, jobs, storage, and configuration. 18 inefficiency patterns for diagnosing waste and building optimization roadmaps.

---

## Compute Optimization Patterns (15)

**1. Inefficient Query Design**
Poor Spark and SQL practices like unfiltered joins and missing broadcast joins increase resource utilization. Solutions include enabling Adaptive Query Execution and applying early filtering.

**2. Inefficient Photon Engine Usage**
"Photon is enabled by default on many Databricks compute configurations." While beneficial for certain workloads, it may not justify increased costs. Recommendation: disable by default and enable selectively.

**3. Lack of Workload Segmentation**
Running different workload types on shared clusters creates inefficiencies. Solutions: use separate cluster types for SQL, ML, and ETL; employ job clusters for batch workloads.

**4. Photon Overuse in Non-Production**
Development and testing environments often have Photon enabled unnecessarily. Disable by default in dev/test via workspace settings or policies.

**5. Poorly Configured Autoscaling**
Autoscaling often lacks proper configuration. Guidance: use autoscaling for variable workloads with appropriate min/max ranges; consider fixed-size clusters for predictable jobs.

**6. Underuse of Serverless for Short Workloads**
"Many organizations continue running short-lived or low-intensity SQL workloads...on traditional clusters." Migration to Databricks SQL Serverless is recommended.

**7. Inefficient BI Queries**
Dashboards with excessive auto-refresh and full dataset scans drive unnecessary compute. Solutions: refactor queries, materialize results, reduce refresh frequency.

**8. Inefficient Autotermination Configuration**
Interactive clusters left running between sessions incur idle charges. Lower autotermination thresholds using workspace policies.

**9. Inefficient Interactive Cluster Usage**
Running scheduled jobs on interactive clusters causes unnecessary idle costs. Solution: reassign to ephemeral job clusters.

**10. Missing Auto-Termination Policy**
Forgotten clusters accumulate costs indefinitely. "Enable auto-termination for all clusters that do not require persistent runtime."

**11. Oversized Worker/Driver Nodes**
High-cost instance types exceed workload requirements. Implement compute policies restricting node sizes.

**12. Underuse of Serverless for Jobs/Notebooks**
Serverless Compute offers significant cost reduction for short-running workloads. Pilot adoption through templates.

**13. Lack of Graviton Usage**
AWS Graviton instances offer cost advantages comparable to x86 performance. Reconfigure default templates toward Graviton adoption.

**14. On-Demand Only in Non-Production**
Teams defaulting to on-demand nodes in dev/test forego cost savings. Enable spot instances with fallback capabilities.

**15. Suboptimal On-Demand Usage**
"For non-production workloads...high availability is often unnecessary." Implement policies capping on-demand percentages.

---

## Storage Optimization Patterns (1)

**Missing Delta Optimization Features**
Large tables without partitioning and Z-Ordering cause excessive data scanning. Apply partitioning and Z-Ordering on filtered columns; use OPTIMIZE and VACUUM.

---

## Other Patterns (2)

**Inefficient Job Cluster Usage in Workflows**
Multiple tasks on separate job clusters create unnecessary overhead. Consolidate into shared clusters when compute requirements align.

**Lack of Functional Cost Attribution**
"Databricks cost optimization begins with visibility." Break down costs by DBUs (orchestration), compute (VM types), and storage (lifecycle policies).

---

> *Cloud FinOps Skill by [OptimNow](https://optimnow.io) - licensed under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).*
