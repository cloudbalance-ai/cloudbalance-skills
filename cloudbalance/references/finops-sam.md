# FinOps for SaaS Asset Management (SAM)

> SaaS management as a FinOps capability: discovery, license optimization, renewal governance,
> SaaS Management Platforms (SMPs), shadow IT detection, and the connection to AI transition
> readiness. 6 sprawl patterns for diagnosing waste and building optimization roadmaps.

---

## Why SAM matters for FinOps

SaaS has become one of the largest and least visible cost categories in most organizations.
The State of FinOps 2026 survey confirms that "SaaS is now firmly within the FinOps scope:
90% of respondents manage SaaS or plan to (up from 65% in 2025)." Licensing management has
grown to 64% (up from 49%).

Gartner predicts that "by 2028, over 70% of organizations will centralize SaaS management
using a SaaS Management Platform (SMP), up from less than 30% in 2025." Organizations that
fail to centralize will overspend by at least 25% due to unused entitlements and overlapping tools.

---

## SaaS Sprawl Patterns (6)

**Unused or Underutilized Licenses (Shelfware)**
Licenses allocated to users who have not logged in within 30, 60, or 90 days. Often the
single largest source of SaaS waste. Implement automated license reharvesting after a
defined inactivity threshold. Track reharvested licenses as a KPI per quarter.

**Overlapping and Redundant Applications**
Multiple tools serving the same function across different teams. Conduct application
rationalization: map tools to business functions, identify overlaps, consolidate to one
tool per function where possible.

**Shadow SaaS**
Applications purchased without IT or procurement approval. Introduces security, compliance,
and cost risk. Deploy continuous discovery using multiple methods; create an approved app
catalog with a fast-track process for low-cost tools. "Shadow IT is often a signal of
innovation - govern it, do not crush it."

**Auto-Renewal Without Review**
SaaS contracts that renew automatically without usage review or renegotiation. Maintain a
centralized renewal calendar with alerts at 90, 60, and 30 days before renewal. Require
usage review and business justification before every renewal above a spend threshold.

**Tier Mismatch**
Users assigned premium-tier licenses when standard-tier suffices. Analyze feature-level
usage; implement a default-to-lowest-tier policy for new users; review tier assignments
quarterly.

**Missing Contract Metadata**
SaaS contracts managed without structured tracking of renewal dates, notice periods,
escalation clauses, and exit strategies. Store all contract metadata centrally. Track:
renewal date, notice period, price-lock expiry, data portability provisions, and owner.

---

## Discovery Methods

No single discovery method provides complete visibility. Layer multiple methods:

| Method | Strengths | Limitations |
|---|---|---|
| SSO / Identity Provider Logs | Reliable view of sanctioned apps | Only covers SSO-integrated apps |
| Financial and Expense Records | Reveals what is paid for, including shadow SaaS | Only shows paid tools, monthly lag |
| API Connectors (Direct Integrations) | Deep feature-level usage data | Only for known apps |
| Cloud Access Security Broker (CASB) | Network-level shadow SaaS detection | Misses remote/BYOD users |
| Browser Extensions | Granular usage regardless of network | Privacy concerns, requires managed browser |
| Email-Based Discovery | Retroactive, covers all authentication methods | Privacy considerations |

**Recommended approach:** Layer SSO + financial records as the foundation. Add browser
extensions or CASB for shadow SaaS detection. Use API connectors for deep usage data on
high-spend apps.

---

## Core SAM Capabilities Within FinOps

### Inform
- **Inventory and Discovery** - continuous identification of all SaaS applications in use
- **Cost Allocation** - map 100% of SaaS spend to cost centers and application owners
- **SaaS Taxonomy** - segment by function and criticality; apply tiered governance

### Optimize
- **License Optimization** - rightsize license tiers, reharvest unused seats, eliminate shelfware
- **Renewal Management** - centralized tracking of all renewal dates, notice periods, contract terms
- **Build vs. Buy Decisions** - data-driven TCO comparison

### Operate
- **Contract Lifecycle Management** - track full lifecycle including exit strategies
- **Unit Economics** - link SaaS costs to business metrics (cost per transaction, per customer)
- **Governance and Policy** - approved app catalog, procurement policies, shadow IT response

---

## SMP Landscape (Gartner MQ 2025)

Key vendors: **Zylo** (manages $40B+ in SaaS spend, Leader), **Flexera** (recognized in
both SaaS MQ and Cloud FinOps MQ, Leader), **BetterCloud** (SaaS lifecycle management,
$35B+ contracts on platform, Leader), **Torii** (discovery-first, MCP-compatible agentic
capabilities launched 2025), **SAP LeanIX** (natural fit for SAP organizations).

---

## SAM Maturity Model

| Indicator | Crawl | Walk | Run |
|---|---|---|---|
| SaaS inventory | Spreadsheet, quarterly | SMP with multi-source discovery | Continuous, real-time |
| Spend visibility | Partial | 80%+ tracked | 95%+ allocated |
| Shadow IT detection | Reactive | Periodic scans | Continuous multi-signal |
| License optimization | Manual, annual | Quarterly, some automation | Automated reharvesting |
| Renewal management | Ad hoc, often missed | Centralized calendar | Data-backed review for every renewal |

---

## Key Metrics

| Metric | Target |
|---|---|
| % of SaaS spend under management | >90% |
| License utilization rate | >85% |
| Shelfware rate | <15% |
| Renewal review coverage (top spend) | 100% |
| Time to deprovision (after departure) | <1 day |

---

Sources: FinOps Foundation (Licensing & SaaS capability; State of FinOps 2026), Gartner MQ for
SaaS Management Platforms (July 2025), Halit Oener "The SaaSocalypse" (March 2026).

*Cloud FinOps Skill by [OptimNow](https://optimnow.io) - licensed under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).*
