# GreenOps and Cloud Carbon Optimization

> Practical guidance for measuring, reducing, and governing cloud carbon emissions.
> Covers carbon measurement tooling (native and open source), FinOps-to-GreenOps
> integration, workload shifting strategies (temporal and spatial), region selection,
> and reporting alignment with GHG Protocol and EU/SEC regulations.

---

## Context and scale

Data centers consumed approximately 415 TWh globally in 2024 - roughly 1.5% of world
electricity. The IEA projects this could reach 945 TWh by 2030, driven by AI workloads.

**GreenOps is not a separate discipline.** It is FinOps with a carbon column added.
Every tagging, rightsizing, or idle resource cleanup that reduces cost also reduces
emissions. The marginal effort to add carbon tracking to a mature FinOps program is low.

---

## Measurement foundation

### Native cloud carbon tools

| Tool | Scope | Granularity | Limitations |
|---|---|---|---|
| AWS CCFT (updated Jan 2025) | Scope 1, 2, 3 | Regional, by service | Lagged data |
| GCP Carbon Footprint | Scope 1, 2, 3 | Region + service | Most granular of the three |
| Azure Emissions Impact Dashboard | Scope 1, 2, 3 | Service-level | Relies on market-based method (RECs) |

**Important:** Market-based measurement uses RECs and can mask actual grid carbon
intensity. For optimization decisions, prefer location-based data.

### Cloud Carbon Footprint (CCF) - open source

Estimates energy and carbon emissions at the service level using actual CPU utilization.
Covers AWS, Azure, and GCP in a single dashboard. Includes embodied emissions (hardware).
Generates rightsizing and idle resource recommendations with projected carbon savings.

Repository: https://www.cloudcarbonfootprint.org/

### Carbon Aware SDK (Green Software Foundation)

Provides real-time and forecast grid carbon intensity data for workload shifting.
Integrates with Kubernetes, batch schedulers, cron jobs, and CI/CD pipelines.
Enables temporal shifting (delay to cleaner grid window) and spatial shifting (route
to lower-carbon region).

Repository: https://github.com/Green-Software-Foundation/carbon-aware-sdk

---

## FinOps-to-GreenOps integration

GreenOps reuses FinOps infrastructure. The same tagging, showback, and governance
patterns that surface cost waste also surface carbon waste. The practical starting
point: add one column - gCO2e - to existing cost reports.

| FinOps phase | GreenOps equivalent |
|---|---|
| Inform | Learn and Measure: enable dashboards, establish baseline |
| Optimize | Reduce: rightsize, shut down idle, shift to cleaner regions |
| Operate | Govern and Report: set carbon KPIs, add gCO2e to team reviews |

---

## Region selection for carbon reduction

Region selection is the single highest-impact optimization available. Location-shifting
can reduce carbon emissions by up to 75% for a given workload.

### Lower-carbon regions (indicative)
- **AWS:** us-east-1 (Virginia), us-east-2 (Ohio), eu-west-1 (Ireland) - 100% renewable matched
- **GCP:** Montreal, Toronto, Santiago (90%+ carbon-free energy)
- **Azure:** Nordics, Ireland, parts of Canada

Carbon region selection applies primarily to batch and async workloads, dev/test, CI/CD,
and ML training jobs. Latency and data residency requirements limit flexibility.

---

## Workload shifting

**Temporal shifting:** Delay execution to a time window when the grid runs on cleaner
energy. Carbon reduction potential: ~15%.

**Spatial shifting:** Route workloads to a data center region with lower current grid
carbon intensity. Potential: up to 50%+ when combined with temporal shifting.

Workloads suitable for shifting: ML training, batch data processing, CI/CD builds,
database backups, report generation.

Not suitable: user-facing latency-sensitive apps, real-time streaming, stateful SLA workloads.

---

## Immediate wins

1. **Shut down idle and unused resources** - eliminates both spend and emissions immediately
2. **Rightsize overprovisioned compute** - CPU utilization consistently below 20% is a candidate
3. **Schedule non-production resources** - dev/test/staging don't run 24/7 (saves 65-70% of hours)
4. **Move cold data to lower-carbon storage tiers** - reduces energy for hot storage
5. **Eliminate multi-cloud duplication** - audit cross-cloud replication for operational justification

**Expected impact:** 20-40% carbon footprint reduction and 15-40% cost savings simultaneously.

---

## Reporting and compliance

### GHG Protocol scopes
- **Scope 2:** Your cloud workloads (indirect emissions from purchased electricity)
- **Scope 3:** Embodied emissions of cloud hardware - increasingly required in reporting

### Regulatory context
- **EU CSRD:** Large companies must report Scope 1, 2, and 3 with third-party verification
- **EU Energy Efficiency Directive:** European data centers must report energy use, PUE, renewables
- **SEC Climate Disclosures:** Material climate risks and GHG emissions for US public companies

Use location-based data for optimization decisions. Understand which method (location-based
vs. market-based) your auditors require for external reporting.

---

## Key tools

| Tool | Type | Use case |
|---|---|---|
| AWS Customer Carbon Footprint Tool | Native | AWS Scope 1/2/3 reporting |
| GCP Carbon Footprint | Native | GCP emissions, most granular |
| Azure Emissions Impact Dashboard | Native | Azure Scope 1/2/3 reporting |
| Cloud Carbon Footprint (CCF) | Open source | Multi-cloud, workload optimization |
| Carbon Aware SDK (GSF) | Open source | Workload shifting, carbon-aware scheduling |
| Kepler (CNCF) | Open source | Per-pod power and carbon metrics in Kubernetes |
| Electricity Maps | Data provider | Real-time and forecast grid carbon intensity |
| Climatiq API | Commercial | Embed carbon estimates in custom tooling |

---

> *Cloud FinOps Skill by [OptimNow](https://optimnow.io) - licensed under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).*
