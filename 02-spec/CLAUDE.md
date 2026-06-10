# Phase 2: Spec (Technical Architecture & Specification)

Turn product definition into architecture. Lock in tech stack, data model, API design, and implementation roadmap.

## Your Task

Use the spec-author agent to complete these deliverables:

- **stack.md** — Technology choices (frontend, backend, database, deployment) + rationales
- **data-model.md** — Entity definitions, relationships, constraints, multi-tenancy
- **tech-spec.md** — System architecture, API endpoints, data flows, security model
- **receipt-pipeline.md** (if applicable) — Domain-specific pipeline or workflow
- **coding-standards.md** — Language, tooling, naming, testing, code review process

Update **GLOSSARY.md** and create **ADRs** (decisions/) for non-obvious choices.

## Exit Criteria

✅ All technology choices have explicit rationale (no defaults)
✅ Data model is normalized and supports audit logging
✅ API contract is versioned and backward-compatible
✅ All ADRs for major decisions are recorded
✅ No contradictions between stack.md, data-model.md, tech-spec.md

## Reviewers

When spec-author is done, these reviewers check for issues:
- **architecture-reviewer** — Is the system design coherent?
- **data-model-reviewer** — Is the schema correct and scalable?
- **api-contract-reviewer** — Is the API backward-compatible?
- **security-architect** — Are auth, secrets, isolation secure?
- **performance-reviewer** — Are queries fast? Scaling realistic?
- **observability-architect** — Can production be debugged?
- **decisions-reviewer** — Are all choices ADR-recorded?
- **docquality-reviewer** — Are specs readable and linked?

## Next Phase

Once Phase 2 passes review → move to **03-build** (implementation).

---

**See governance-framework/README.md for context on the full 5-phase flow.**
