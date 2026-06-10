# Phase 3: Build (Implementation & Integration)

Turn specifications into working code. Implement API, database schema, business logic, and integrate external services.

## Your Task

Use the build-author agent to complete these deliverables:

- **build-order.md** — Sequenced milestones (what to implement first, second, etc.)
- **Implementation code** — Follow coding-standards.md from Phase 2
- **Database migrations** — Schema matches data-model.md exactly
- **Tests** — Unit, integration, E2E per test-plan.md from Phase 2

## Exit Criteria

✅ All Phase 2 specs are implemented (no spec deviations)
✅ Database schema matches data-model.md
✅ API endpoints match tech-spec.md contract
✅ Tests pass (unit >80%, integration >50%, E2E happy path)
✅ Code follows coding-standards.md
✅ No TODOs remain in code

## Reviewers

When build-author is done, these reviewers check for issues:
- **code-reviewer** — Are implementations correct?
- **security-reviewer** — Are secrets, auth, isolation secure?
- **test-strategy-reviewer** — Is test coverage adequate?
- **performance-reviewer** — Are queries optimized?
- **infrastructure-reviewer** — Is deployment ready?
- **tech-debt-reviewer** — Is technical debt documented?
- **docquality-reviewer** — Are code comments clear?

## Next Phase

Once Phase 3 passes review → move to **04-reconciliation** (domain-specific logic validation) or **05-test-ship** (testing & deployment).

---

**See governance-framework/README.md for context on the full 5-phase flow.**
