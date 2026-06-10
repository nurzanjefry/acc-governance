# Phase 4: Reconciliation (Domain-Specific Logic Validation)

Validate and lock in domain-specific logic (e.g., finance reconciliation, matching algorithms, business rules).

## Your Task

Use the reconciliation-author agent to complete these deliverables:

- **reconciliation-spec.md** — Core domain logic (algorithms, state machines, edge cases)
- **finance-data-model.md** (if applicable) — Domain-specific schema or business rules
- **Validation** — Logic correctness, audit trail, compliance requirements

## Exit Criteria

✅ Domain logic is deterministic and testable
✅ All edge cases are documented
✅ Audit trail is immutable
✅ Business rules match product definition from Phase 1
✅ No contradictions with Phase 2 specs

## Reviewers

When reconciliation-author is done, these reviewers check for issues:
- **data-model-reviewer** — Is the domain schema correct?
- **security-architect** — Are business rules exploit-proof?
- **performance-reviewer** — Are algorithms efficient at scale?
- **observability-architect** — Can domain logic be monitored?
- **tech-debt-reviewer** — Are assumptions documented?
- **docquality-reviewer** — Are specs clear?

## Next Phase

Once Phase 4 passes review → move to **05-test-ship** (testing & deployment).

---

**See governance-framework/README.md for context on the full 5-phase flow.**
