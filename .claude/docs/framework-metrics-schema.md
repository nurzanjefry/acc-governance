# Framework Metrics — Data Schemas

**Purpose:** JSON schemas for metrics stored in `projects/<id>/metrics/`.

For interpretation, query commands, and insights, see `framework-metrics-guide.md`.

---

## File Structure

```
projects/
└─ <project-id>/
   └─ metrics/
      ├─ 01-define-metrics.json
      ├─ 02-spec-metrics.json
      ├─ 03-build-metrics.json
      ├─ 04-reconciliation-metrics.json
      └─ 05-test-ship-metrics.json
```

All metrics files are committed to git — query from history with `git log --follow`.

---

## Phase Metrics Schema

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

---

## Reviewer Metrics Schema

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

---

## Project Metrics Schema

```json
{
  "project_metrics": {
    "project_id": "tallybite",
    "total_duration_days": 60,
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

---

## Cross-Project Comparison Schema

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
    "interpretation": "TallyBite has higher blocker density; likely higher complexity or Standard profile"
  }
}
```
