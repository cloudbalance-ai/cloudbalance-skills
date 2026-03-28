# FinOps Methodology

> A reasoning lens for approaching cloud cost and AI cost problems.
> Use these principles to shape the angle, depth, and priorities of every response —
> not as content to recite.

---

## Core principles

### Diagnose before prescribing

Understand the organization's current state before recommending anything. A maturity
assessment — even a quick one — changes what is appropriate to recommend. A team at
Crawl maturity needs visibility, not commitment discounts. A team at Run maturity needs
automation, not manual reviews.

The right question is not "what is best practice?" but "what is the right next step for
this organization at this stage?"

### Visibility before optimization

Cost visibility is a prerequisite, not a phase. You cannot rightsize what you cannot see.
You cannot allocate savings to a team that has no cost attribution. This principle prevents
the common mistake of jumping to optimization before the foundation is in place.

Corollary: **physical tagging must precede virtual tagging**. Virtual tagging (applying
metadata in the billing layer without changing resource tags) is powerful but fragile if
physical tags are absent or inconsistent. Fix the source before adding an abstraction layer.

### Connect cost to value, not just utilization

The goal of FinOps is not to minimize cloud spend. It is to maximize the business value
delivered per dollar spent. A recommendation to cut costs that degrades a revenue-generating
system is a bad recommendation, regardless of the savings number.

Every optimization recommendation should answer: what business outcome does this protect
or improve?

### Showback before chargeback

Allocating costs for visibility (showback) requires only data and tooling. Allocating costs
for financial accountability (chargeback) requires organizational readiness, cultural change,
and executive sponsorship. Attempting chargeback before organizations are ready produces
resistance, not accountability.

The sequence matters: show teams their costs first, build awareness and ownership, then
introduce financial accountability when the organization is prepared for it.

### Rapid value delivery

Early momentum matters. Organizations that wait for a perfect FinOps implementation before
showing results lose executive sponsorship and team engagement. Quick wins demonstrate value
and build the credibility needed for structural change.

Quick wins are not shortcuts. They are the first step of a progressive approach that
moves from visible savings to embedded governance.

### Challenge assumptions, not just costs

The most impactful FinOps interventions often question whether a workload, architecture,
or AI feature should exist in its current form — not just whether it can be made cheaper.
Sometimes the right answer is to eliminate a feature, redesign a pipeline, or stop a
commitment before optimizing it.

---

## FinOps maturity sequence

| Phase | Focus | Common mistake to avoid |
|---|---|---|
| Crawl | Visibility, tagging, cost allocation | Jumping to optimization before attribution is complete |
| Walk | Rightsizing, waste elimination, commitment coverage | Committing to infrastructure before rightsizing it |
| Run | Automation, unit economics, governance at scale | Building complexity before simpler approaches are exhausted |

---

## What good FinOps advice looks like

- Connects spend to a business outcome
- Recommends the simplest action that delivers the result
- Sequences steps correctly (visibility → waste → commitments)
- Acknowledges uncertainty rather than claiming false precision
- Adapts to the organization's current maturity, not an idealized future state

---

> *Derived from FinOps Foundation principles and open-source FinOps methodology.*
> *Cloud FinOps Skill by [OptimNow](https://optimnow.io) — licensed under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).*
