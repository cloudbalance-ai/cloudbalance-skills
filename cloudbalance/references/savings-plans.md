# Savings Plans and Reserved Instances Reference

> CloudBalance tracks SP and RI commitments daily from CUR data and AWS APIs.
> Use `cb_get_commitment_performance` to access coverage, utilization, and savings data.
> For live CE data specifically, use BCM `sp-performance` or `ri-performance`.

---

## Commitment types tracked by CloudBalance

### Savings Plans

| Type | Covers | Flexibility |
|---|---|---|
| Compute SP | Any EC2 instance (any family, size, region, OS), Fargate, Lambda | Highest - auto-applies across all compute |
| EC2 Instance SP | Specific EC2 instance family in a specific region | Medium - flexible on size and OS within the family/region |
| SageMaker SP | SageMaker compute (training, inference, processing) | SageMaker only |

**Commitment structure:** Hourly commitment spend (USD/hr). AWS bills at the SP rate for
usage up to the commitment; usage beyond the commitment reverts to on-demand.

**Term options:** 1-year or 3-year. Payment options: No Upfront, Partial Upfront, All Upfront.
Longer terms and larger upfront payments yield higher discount rates.

### Reserved Instances

| Type | Covers | Flexibility |
|---|---|---|
| EC2 RI | Specific EC2 instance family, region | Convertible RIs allow family/region changes; Standard RIs do not |
| RDS RI | Specific RDS instance class, engine, region | Less flexible than EC2 RIs |

**Commitment structure:** Reservation of a specific instance type for 1 or 3 years.
Capacity reservation is optional (zonal RIs reserve capacity; regional RIs do not).

---

## Coverage vs utilization - the critical distinction

These two metrics measure different things and diagnose different problems:

### Coverage rate (0..1 in CloudBalance)

> Of all eligible on-demand spend, what fraction is covered by a commitment?

- **Low coverage** means commitment spend is not keeping up with actual usage
- Causes: AWS usage growing faster than commitments, new services/regions not covered
- Fix: purchase additional SPs or RIs

**Example:** EC2 coverage of 0.62 (62%) means 38% of EC2 usage is paying on-demand rates.

### Utilization rate (0..1 in CloudBalance)

> Of the commitment you purchased, what fraction are you actually using?

- **Low utilization** means you purchased more commitment than you're consuming
- Causes: workloads shut down, instance types changed, services migrated away
- Fix: sell unused RIs on the Marketplace (Standard RIs only), or let commitments expire;
  cannot cancel SPs (they run their full term)

**Example:** SP utilization of 0.91 (91%) means 9% of SP commitment spend is going to waste
(paying for SP capacity that isn't consumed).

### Target ranges

| Metric | Healthy | Needs attention |
|---|---|---|
| Coverage | 70-85% | <60% (leaving savings on the table) |
| Utilization | 90-100% | <85% (wasting commitment spend) |

---

## How CloudBalance tracks commitment performance

CloudBalance's `cb_get_commitment_performance` tool returns:

- **Per-commitment records**: ARN, type (SP/EC2/RDS/ECACHE/OS/RS), start/end dates, commitment amount
  (hourly for SPs, instance count for RIs), estimated total savings
- **Performance data** (when `include_performance=True`): monthly breakdown of utilization,
  coverage, and actual savings for each commitment over the requested time range

**Rate fields are fractions (0..1) - always convert to percentages for user display.**

Key performance fields:
- `utilization_percentage` - fraction of commitment consumed (0..1)
- `coverage_percentage` - fraction of eligible spend covered (0..1)
- `net_savings_amount` - actual savings achieved vs on-demand equivalent
- `amortized_commitment_spend` - what was paid for the commitment in the period

---

## Amortized vs unblended cost

When analyzing SP/RI cost impact:

- **Unblended cost** - cash flow view; shows upfront RI payments in the month they're charged
- **Amortized cost** - economic view; spreads upfront fees across the commitment term

For commitment performance analysis, **amortized cost** gives a clearer picture of the
effective rate. Use `cost_type="amortized"` in `cb_get_cost_summary` when analyzing the
true cost of committed workloads.

---

## Commitment expiration awareness

Always check for upcoming expirations when reviewing commitments:

```
cb_get_commitment_performance(active_only=False, include_performance=True)
```

Look for commitments with `end_date` within the next 60-90 days. Expired commitments
that aren't renewed result in usage reverting to on-demand rates - a common cause of
unexpected cost increases.

CloudBalance displays commitment expiration dates on `/cb/commitment/commitment-performance/`.

---

## Commitment planning in CloudBalance

For purchasing recommendations:
- **`/cb/commitment/commitment-recommendations/`** - CloudBalance's purchase recommendations
  based on current usage patterns
- **`/cb/commitment/commitment-planning/`** - what-if planning tool to model different
  commitment sizes and payment options
- **`/cb/commitment/commitment-scenarios/`** - saved planning scenarios for comparison

---

## When to use BCM sp-performance / ri-performance

Use BCM tools when:
- Need live CE API data (not CloudBalance's daily snapshot)
- Analyzing coverage/utilization at a dimension not in CloudBalance
  (e.g., specific linked account, specific service within SP)
- Need CE's built-in recommendation engine output

```
sp-performance(operation="getSavingsPlansCoverage",
  start_date="2025-02-01", end_date="2025-03-01",
  granularity="MONTHLY")
```

```
ri-performance(operation="getReservationUtilization",
  start_date="2025-02-01", end_date="2025-03-01",
  granularity="MONTHLY")
```

---

## Common commitment questions and how to answer them

**"Why did my costs go up this month?"**
1. `cb_get_cost_summary` - check if EC2/compute spend increased
2. `cb_get_commitment_performance(include_performance=True)` - check if coverage dropped
3. If coverage dropped: check for expired commitments (`active_only=False`)

**"Should I buy more Savings Plans?"**
1. `cb_get_commitment_performance(include_performance=True)` - check current utilization
2. If utilization >90% and coverage <70%: yes, capacity to add commitments
3. Direct to `/cb/commitment/commitment-planning/` for modeling

**"Are my commitments being used efficiently?"**
1. `cb_get_commitment_performance(include_performance=True, time_range="last 3 months")`
2. Look for utilization <85% - indicates over-purchased commitments
3. Look for commitments expiring soon - flag for renewal review

---

> *CloudBalance-specific sections by CloudBalance. General SP/RI methodology adapted from*
> *[OptimNow cloud-finops-skills](https://github.com/OptimNow/cloud-finops-skills) - CC BY-SA 4.0.*
