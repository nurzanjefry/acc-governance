# Framework Metrics Guide — Interpretation & Actions

**Purpose:** How to interpret metrics, identify red flags, run queries, and use metrics to make decisions.

For JSON data schemas, see `framework-metrics-schema.md`.

---

## Metric Thresholds

### Phase Metrics

| Metric | Good | Yellow | Red | Action |
|---|---|---|---|---|
| items_completed / items_total | 100% | 80-99% | <80% | If red: investigate blockers |
| actual vs. estimated duration | <110% | 110-125% | >125% | If yellow+: phase structure issue? |
| avg_cycles_per_item | 1.0-1.5 | 1.5-2.5 | >2.5 | If red: unclear spec or reviewer bar too high |
| convergence_rate | >90% | 80-90% | <80% | If red: escalation rate too high |
| budget_utilization_percent | <100% | 100-120% | >120% | If red: reduce scope or increase budget |

### Reviewer Metrics

| Metric | Good | Yellow | Red |
|---|---|---|---|
| blocker_percentage | 10-30% | 30-40% | >40% |
| avg_review_duration | 15-25 min | 25-35 min | >35 min |
| avg_findings_per_review | 1.5-2.5 | 0.5-1.5 or 2.5-3.5 | <0.5 or >3.5 |

### Project Metrics

| Metric | Good | Yellow | Red | Action |
|---|---|---|---|---|
| total_duration_days | <60 | 60-80 | >80 | Phase structure issue |
| tokens_per_item | <10k | 10k-15k | >15k | Too many reviewers or cycles |

---

## Red Flag Patterns

**Bottleneck Reviewer:** One reviewer finds >40% of all blockers.
- Check blocker types: if all serious → OK; if many trivial → loosen reviewer bar or split role.

**Slow Reviewer:** avg_duration > 30 min (vs. ~15 min average).
- If higher findings per review → thorough; if same → consider efficiency training.

**Weak Reviewer:** avg_findings_per_review < 0.5.
- Check if other reviewers found issues in that reviewer's domain. If yes → reviewer missed them.

---

## Automatic Insight Rules

| Rule | Trigger | Recommendation |
|---|---|---|
| Bottleneck Reviewer | Reviewer found >35% blockers | Add backup or split role |
| Slow Reviewer | avg_duration > 30 min | Check quality; consider training or splitting |
| Recurring Blocker Type | Same type >3 items | Add to spec template or review checklist |
| Low Convergence | convergence < 80% | Review quality bar; adjust escalation policy |
| High Revision Cycles | avg_cycles > 2.5 | Improve spec template or reviewer rubric |
| Token Overrun | utilization > 100% | Reduce scope, tighten cycles, or increase budget |
| Long Phase | actual > estimated × 1.3 | Investigate causes; adjust future estimates |

---

## Query Commands

```bash
# Query by phase
pm-metrics query --project tallybite --phase 02-spec --metric total_blockers

# Compare across projects
pm-metrics compare --metric avg_phase_duration_days --projects tallybite,project-a

# Identify trends across phases
pm-metrics trend --project tallybite --metric blocker_count --phases 01-define,02-spec,03-build

# Forecast phase completion
pm-metrics forecast --project tallybite --phase 02-spec

# Get historical metrics from git
git show 2026-06-26:projects/tallybite/metrics/02-spec-metrics.json
git diff HEAD~1 projects/tallybite/metrics/02-spec-metrics.json
```

---

## Using Metrics to Decide on an RFC

**Scenario:** Should we add api-versioning-reviewer?

1. Query: Count "api_versioning" blockers across all projects in Phase 2
2. If total ≥ 3 occurrences across different projects → trigger threshold met
3. Estimate cost ($2k/year) vs. benefit (blockers prevented × $135/blocker)
4. If ROI positive → file RFC (see `.claude/docs/FRAMEWORK-EVOLUTION.md`)

---

## Backward Compatibility

Metrics collection is optional in Phase 1; becomes standard from Phase 2+.

If a project doesn't have metrics.json, the framework suggests collection (lazy migration; no forced change).
