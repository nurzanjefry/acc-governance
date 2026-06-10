# Framework Metrics Collection & Observability Guide

**Purpose:** Guide for collecting, interpreting, and acting on framework metrics.

**Version:** 1.0  
**Last Updated:** 2026-06-11

---

## Overview

The framework collects three types of metrics:

1. **Phase-level metrics:** Items completed, blockers found, cycles needed, tokens used
2. **Reviewer-level metrics:** Findings per reviewer, speed, effectiveness
3. **Project-level metrics:** Total time, total cost, phase comparison, trends

Metrics are collected to JSON files (framework-metrics.json) stored in git. No external database needed (state-in-files principle).

---

## Phase-Level Metrics

### What Gets Collected

After each phase completes, framework generates metrics:

```json
{
  "phase_metrics": {
    "phase_id": "02-spec",
    "status": "complete",
    "items_total": 7,
    "items_completed": 7,
    "items_blocked": 0,
    "duration": {
      "estimated_days": 14,
      "actual_days": 15,
      "estimated_completion": "2026-06-25T00:00:00Z",
      "actual_completion": "2026-06-26T00:00:00Z"
    },
    "quality_metrics": {
      "total_blockers_found": 47,
      "total_revision_cycles": 12,
      "avg_cycles_per_item": 1.7,
      "max_cycles_on_one_item": 3,
      "convergence_rate": 1.0
    },
    "token_metrics": {
      "total_tokens_used": 94000,
      "token_budget": 100000,
      "budget_utilization_percent": 94,
      "tokens_per_item": 13428
    }
  }
}
```

### Interpreting Phase Metrics

| Metric | Good | Yellow | Red | Action |
|---|---|---|---|---|
| **items_completed / items_total** | 100% (on-time) | 80-99% (slightly delayed) | <80% (blocked) | If red: investigate blockers |
| **duration actual vs. estimated** | <110% | 110-125% | >125% | If yellow+: phase structure issue? |
| **avg_cycles_per_item** | 1.0-1.5 | 1.5-2.5 | >2.5 | If red: specs unclear or reviewer bar high |
| **convergence_rate** | >90% | 80-90% | <80% | If red: escalation rate too high |
| **budget_utilization_percent** | <100% | 100-120% | >120% | If red: cost control needed |

---

## Reviewer-Level Metrics

### What Gets Collected

After each phase, framework tracks individual reviewer performance:

```json
{
  "reviewer_metrics": [
    {
      "reviewer_id": "data-model-reviewer",
      "reviews_conducted": 7,
      "blockers_found": 15,
      "blocker_percentage": 32,
      "blocker_type_distribution": {
        "missing_constraint": 8,
        "schema_normalization": 5,
        "isolation": 2
      },
      "avg_review_duration_minutes": 25,
      "avg_findings_per_review": 2.1,
      "critical_issues_found": 2
    }
  ]
}
```

### Interpreting Reviewer Metrics

| Metric | Meaning | Good | Yellow | Red |
|---|---|---|---|---|
| **blocker_percentage** | How much this reviewer contributes | 10-30% | 30-40% | >40% |
| **avg_review_duration** | How fast reviewer works | 15-25 min | 25-35 min | >35 min |
| **avg_findings_per_review** | Productivity | 1.5-2.5 | 0.5-1.5 or 2.5-3.5 | <0.5 or >3.5 |
| **critical_issues_found** | Quality/specialization | 10-20% of findings | 5-10% | <5% (not catching serious issues) |

### Red Flag Patterns

**Red flag: "Bottleneck Reviewer"**
```
data-model-reviewer found 40% of all blockers (15/47)
Interpretation: 
  Option 1: Data model is complex; reviewer is doing important work ✓
  Option 2: Reviewer is over-specializing; finding issues others miss ✓
  Option 3: Reviewer is finding trivial issues; bar too high ✗
Action: Check blocker types. If all serious → OK. If many trivial → loosen bar.
```

**Red flag: "Slow Reviewer"**
```
api-contract-reviewer takes 35 minutes/review (vs. 15 min average)
Interpretation:
  Option 1: Reviews are complex; reviewer is thorough ✓
  Option 2: Reviewer is inefficient; could be faster ✗
Action: Check findings/review ratio. If more findings → OK. If same findings → consider speedup training.
```

**Red flag: "Weak Reviewer"**
```
docquality-reviewer found 0.3 findings/review (vs. 1.8 average)
Interpretation:
  Option 1: Role is preventative; catches few issues early ✓
  Option 2: Reviewer is ineffective; not catching bugs ✗
Action: Check if other reviewers found doc issues. If yes → reviewer missed them → needs training or replacement.
```

---

## Project-Level Metrics

### What Gets Collected

After each project completes (all phases), framework generates summary:

```json
{
  "project_metrics": {
    "project_id": "tallybite",
    "total_duration_days": 60,
    "total_duration_weeks": 9,
    "status": "complete",
    "phases_completed": 5,
    "total_items": 21,
    "total_blockers": 87,
    "total_revision_cycles": 23,
    "token_efficiency": {
      "total_tokens": 284000,
      "budget": 300000,
      "efficiency_percent": 95,
      "tokens_per_item": 13523,
      "tokens_per_blocker_resolved": 3264
    },
    "phase_breakdown": {
      "01-define": { "items": 3, "blockers": 12, "days": 7 },
      "02-spec": { "items": 7, "blockers": 47, "days": 14 },
      "03-build": { "items": 7, "blockers": 20, "days": 20 },
      "04-reconciliation": { "items": 2, "blockers": 5, "days": 7 },
      "05-test-ship": { "items": 2, "blockers": 3, "days": 12 }
    },
    "bottleneck_detection": {
      "slowest_phase": "03-build (20 days)",
      "most_blockers_phase": "02-spec (47 blockers)",
      "slowest_reviewer": "infrastructure-reviewer (30 min avg)"
    }
  }
}
```

### Interpreting Project Metrics

| Metric | Good | Yellow | Red | Action |
|---|---|---|---|---|
| **total_duration_days** | <60 | 60-80 | >80 | If red: phase structure issue |
| **tokens_per_item** | <10k | 10k-15k | >15k | If red: too many reviewers or cycles |
| **phase_breakdown** (time per phase) | Balanced | One phase 30% over | One phase 50% over | Rebalance phases or add resources |

---

## Cross-Project Comparison

### What to Compare

```json
{
  "cross_project_comparison": {
    "projects": ["tallybite", "project-a"],
    "metrics": {
      "avg_phase_duration_days": {
        "tallybite": 14,
        "project-a": 10,
        "difference_percent": "+40%"
      },
      "avg_revision_cycles": {
        "tallybite": 1.7,
        "project-a": 1.2,
        "difference_percent": "+42%"
      },
      "blocker_density": {
        "tallybite": 6.7,
        "project-a": 4.2,
        "difference_percent": "+59%"
      }
    },
    "interpretation": "TallyBite has longer phases and higher blocker density; likely due to higher complexity or more rigorous review"
  }
}
```

### Learning Transfer

When Project-A (MVP) completes faster than TallyBite (Standard):

```
Analysis:
- Project-A Phase 2: 10 days, 5 reviewers, 1.2 avg cycles
- TallyBite Phase 2: 14 days, 11 reviewers, 1.7 avg cycles

Hypothesis: Fewer reviewers = faster phase? Or smaller scope?

Findings:
- Project-A scope: 3 specs (vs. TallyBite's 7)
- Project-A reviewers: 5 (vs. TallyBite's 11)
- Project-A profile: MVP (vs. TallyBite's Standard)

Conclusion: MVP profile IS faster (by design). Cost-quality trade-off working as intended.

Learning for next projects:
- If similar scope to Project-A → use MVP profile
- If similar complexity to TallyBite → use Standard profile
```

---

## Metrics-Driven Insights & Recommendations

### Automatic Insight Engine

Framework generates recommendations based on metric thresholds:

**Insight Rules:**

| Rule | Trigger | Insight | Recommendation |
|---|---|---|---|
| **Bottleneck Reviewer** | Reviewer found >35% blockers | Reviewer is critical; single point of failure | Add backup or split role |
| **Slow Reviewer** | avg_duration > 30 min | Reviewer is slow (inefficient or thorough) | Check quality; consider training or splitting |
| **Recurring Blocker Type** | Same type >3 items | Pattern suggests process gap | Add to spec template or review checklist |
| **Low Convergence** | convergence < 80% | Items not reaching gate | Review quality bar; consider escalation policy |
| **High Revision Cycles** | avg_cycles > 2.5 | Specs unclear or reviewer feedback unclear | Improve spec template or reviewer rubric |
| **Token Overrun** | utilization > 100% | Tokens exceeded budget | Reduce scope, tighten cycles, or increase budget |
| **Long Phase** | actual > estimated × 1.3 | Phase 30% over schedule | Investigate causes; adjust future estimates |

### Example Recommendations

**Recommendation 1: Bottleneck Detected**
```
TITLE: data-model-reviewer is a bottleneck

SEVERITY: High

DATA:
- data-model-reviewer found 32% of all blockers (15/47)
- Second-highest: architecture-reviewer (26%)
- Recommendation: Consider split or backup

IMPACT: If reviewer unavailable, 32% of issues undetected

ACTION:
- Option A: Add backup data-model-reviewer (mentor junior DBA)
- Option B: Split role: data-model-reviewer (schema) + constraints-reviewer (validation)
- Option C: Monitor metrics; if finds 0 blockers, consider removal

OWNER: framework-architect
PRIORITY: Medium (doesn't block phase; plan for future)
```

**Recommendation 2: Blocker Pattern**
```
TITLE: "missing_constraint_validation" blocker appears 8 times

SEVERITY: Medium

DATA:
- Constraint blocker type: 17% of all blockers
- Appears in: spec-001, spec-002, spec-003
- Resolution time: ~45 min per blocker
- Total waste: ~6 hours across 3 items

INSIGHT: Spec authors not thinking about constraint validation

ACTION:
- Add constraint validation checklist to spec-author brief
- Update data-model-reviewer rubric to include constraint checklist
- Expected benefit: Reduce blocker count by 15%; save 6 hours/phase

OWNER: TallyBite PM
PRIORITY: High (quick fix; high ROI)
```

---

## Query Tools & Commands

### Query by Phase

```bash
pm-metrics query --project tallybite --phase 02-spec --metric total_blockers
# Output: 47

pm-metrics query --project tallybite --phase 02-spec --metric avg_cycles_per_item
# Output: 1.7
```

### Compare Across Projects

```bash
pm-metrics compare --metric avg_phase_duration_days --projects tallybite,project-a
# Output:
# tallybite: 14 days
# project-a: 10 days  
# Difference: +40% (TallyBite takes longer; likely due to Standard profile)
```

### Identify Trends

```bash
pm-metrics trend --project tallybite --metric blocker_count --phases 01-define,02-spec,03-build
# Output:
# 01-define: 12 blockers
# 02-spec: 47 blockers (+292%)
# 03-build: 20 blockers (-57%)
# Trend: Blocker count peaks in Phase 2 (architecture most scrutinized); decreases in build
```

### Forecast Phase Completion

```bash
pm-metrics forecast --project tallybite --phase 02-spec
# Output:
# Items completed: 5/7 (71%)
# Days elapsed: 5/14 (36%)
# Burn rate: 1 item/day
# Est. completion: +2 days (2026-06-17 projected)
# Confidence: 85%
```

---

## Metrics Storage & Versioning

### File Structure

```
projects/
└─ tallybite/
   └─ metrics/
      ├─ 01-define-metrics.json
      ├─ 02-spec-metrics.json
      ├─ 03-build-metrics.json
      ├─ 04-reconciliation-metrics.json
      └─ 05-test-ship-metrics.json
```

### Historical Data

All metrics files committed to git. Query from history:

```bash
# Get metrics from all TallyBite phases (from git history)
git log --follow projects/tallybite/metrics/*.json

# Get specific version (e.g., as of 2026-06-26)
git show 2026-06-26:projects/tallybite/metrics/02-spec-metrics.json

# Compare metrics across time
git diff HEAD~1 projects/tallybite/metrics/02-spec-metrics.json
```

---

## Dashboards & Visualization

### Dashboard Template (Markdown)

```markdown
# Framework Metrics Dashboard — TallyBite Phase 02-spec

**Generated:** 2026-06-26T23:59:59Z  
**Phase:** 02-spec  
**Status:** Complete

---

## Phase Progress
- Items Complete: 7/7 (100%)
- In Progress: 0
- Blocked: 0
- Est. Duration: 14 days
- Actual Duration: 15 days (+7%)
- Status: ON TRACK (slight overrun)

## Quality Metrics
- Total Blockers Found: 47
- Avg Cycles Per Item: 1.7
- Convergence Rate: 100%
- Escalations: 0

## Token Usage
- Used: 94,000 / 100,000 (94%)
- Per Item: 13,428 tokens
- Budget Status: GREEN (under budget)

## Top Reviewers by Impact
1. data-model-reviewer: 15 blockers (32%)
2. architecture-reviewer: 12 blockers (26%)
3. api-contract-reviewer: 8 blockers (17%)

## Blocker Distribution
- missing_constraint: 8 (17%) — Recurring pattern
- api_versioning: 6 (13%)
- security_design: 4 (9%)

## Recommendations
1. Add constraint checklist to spec template (save 6h/phase)
2. Consider splitting data-model-reviewer role (single point of failure)
3. Phase 2 took 15 days vs. 14 estimated; adjust Phase 3 estimate?

## Historical Comparison
- Phase 01-define: 12 blockers, 7 days (lower risk)
- Phase 02-spec: 47 blockers, 15 days (high scrutiny)
- Phase 03-build: 20 blockers, 20 days (implementation)
- Trend: Blocker count peaks in spec phase (by design)
```

---

## Metrics-Driven Decision Making

### Example: Use Metrics to Decide on RFC

**Scenario:** Should we add api-versioning-reviewer?

**Data Analysis:**
```
Query: Count "api_versioning" blockers across all projects in Phase 2

Results:
  TallyBite Phase 2: 6 blockers about API versioning
  Project-A Phase 2: 3 blockers about API versioning
  Project-B Phase 2: 2 blockers about API versioning
  Total: 11 blockers in same class

Analysis:
  - 11 occurrences across 3 projects ≥ 3 (trigger threshold)
  - Pattern: API versioning is blind spot
  - Cost: ~$2k/year for new reviewer
  - Benefit: 11 blockers prevented = ~$1.5k value

Decision: File RFC to add api-versioning-reviewer
```

---

## Backward Compatibility

Metrics collection is optional in Phase 1; becomes standard from Phase 2+.

If project doesn't have metrics.json:
- Framework detects and suggests collection
- Lazy migration; no forced change

---

**End of Framework Metrics Guide**
