# Framework Evolution

This is the **living policy document** for how the framework evolves after v1.0.

For the full specification (RFC process, governance committee charter, backward-compatibility guarantee, and implementation checklist), see:

`.claude/governance-improvement/02-framework-spec/fspec-007-framework-evolution.md`

---

## When Does the Framework Evolve?

| Trigger | Signal | Action |
|---------|--------|--------|
| Recurring blocker type | Same blocker class found 3+ times | File an RFC to add/improve a reviewer |
| Slow phase | Phase consistently >125% estimated time | Investigate parallelization or phase split |
| Low convergence | Convergence rate < 80% | Tighten spec-author brief or loosen reviewer bar |
| High token overrun | >20% over budget | Reduce reviewer count or cap revision cycles |
| New compliance requirement | New regulation | Enhance or add compliance reviewer |

---

## How to Propose a Change

1. Identify the trigger (from table above) with supporting data
2. Draft an RFC at `.claude/governance-improvement/rfcs/RFC-{NUMBER}-{TITLE}.md`
3. Submit to governance committee for bi-weekly review
4. If approved (4/5 consensus): implement via governance-improvement pipeline

---

## Backward Compatibility

- Existing projects stay on their pinned `framework_version`
- New features are opt-in; no forced migration
- See fspec-007 for the full backward-compatibility guarantee
