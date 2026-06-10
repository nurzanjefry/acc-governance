# Phase 5: Test & Ship (Comprehensive Testing & Deployment)

Validate, test, and release. Lock in testing strategy, tracking plan, and deployment procedures.

## Your Task

Use the ship-author agent to complete these deliverables:

- **test-plan.md** — Testing strategy (unit, integration, E2E, manual checklist)
- **tracking-plan.md** — Metrics and monitoring (what to measure post-launch)
- **deployment.md** — Release procedure, rollback plan, runbooks

## Exit Criteria

✅ All critical paths have E2E tests (happy path + error cases)
✅ Performance baselines are documented and met
✅ Monitoring/alerts are configured
✅ Rollback procedure is tested
✅ Team knows how to deploy and respond to incidents

## Reviewers

When ship-author is done, these reviewers check for issues:
- **test-strategy-reviewer** — Is test coverage adequate?
- **performance-reviewer** — Are baselines realistic?
- **monitoring-reviewer** — Are alerts actionable?
- **infrastructure-reviewer** — Is deployment automated?
- **security-reviewer** — Are secrets/access controlled?
- **observability-architect** — Can production be debugged?
- **docquality-reviewer** — Are runbooks clear?

## Next Phase

Once Phase 5 passes review → **SHIP** (merge to main, deploy to production).

---

**See governance-framework/README.md for context on the full 5-phase flow.**
