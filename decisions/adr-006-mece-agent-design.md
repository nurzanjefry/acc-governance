# ADR-006: MECE Agent Design — Mutually Exclusive, Collectively Exhaustive

**Date:** 2026-06-11
**Status:** Accepted
**Deciders:** Framework Owner

---

## Context

As the framework's agent roster grows — 30 framework agents plus project-specific agents — two failure modes emerge:

1. **Overlap (not ME):** Two agents review the same concern. Findings duplicate. Revision rounds conflict. Time is wasted.
2. **Gap (not CE):** A concern falls between agents. Nobody reviews it. Issues ship undetected.

The framework needed a governing principle that prevents both failure modes when agents are added, removed, or modified — and a decision protocol that enforces the principle before any new agent is created.

---

## Decision

The acc-governance agent roster is designed to be **MECE: Mutually Exclusive and Collectively Exhaustive.**

- **Mutually Exclusive:** Each agent owns a distinct, non-overlapping concern. No two agents review the same dimension. Overlap between agents is a design defect, not a feature.
- **Collectively Exhaustive:** Together, all agents cover every dimension required for a complete quality pass on a work item. A gap — something nobody reviews — is also a design defect.

This principle is enforced via a mandatory two-step check before any new agent is created:

1. **ME check (before creating):** Does an existing agent already cover this need, even partially? If yes, stop — extend the brief, not the roster.
2. **CE check (after adding):** Does the updated roster cover everything it should? Does the new agent close a real gap, or is it a duplicate with a different name?

---

## Rationale

- **Prevents bloat:** Without ME enforcement, the roster grows with redundant agents that add noise but no signal. Reviewer count increases; signal-to-noise ratio drops.
- **Prevents blind spots:** Without CE enforcement, concerns fall through the cracks. A gap discovered post-ship is more expensive than a gap discovered at the design table.
- **Forces clarity on scope:** The ME check requires naming what the agent's concern is, precisely. Vague agents fail the ME check because their concern cannot be distinguished from existing ones.
- **Scales to projects:** MECE applies to project agents too — project agents must not overlap with framework agents or each other. The principle is the same; the scope is the project folder.

---

## Alternatives Considered

- **No formal principle, just add agents as needed:** Simple. Rejected — without a governing principle, the roster grows through accretion. By 50 agents, no one knows which reviewer owns what, and conflicts are unresolvable without reading every agent definition.
- **Hard cap on agent count:** Limit the roster to N agents. Rejected — arbitrary cap ignores real coverage gaps. MECE is more principled: the roster should be exactly as large as it needs to be to cover all concerns, and no larger.

---

## Consequences

**Positive:**
- New agent requests have a clear gate: pass ME + CE check or don't proceed
- Overlapping agents can be identified and merged using this principle as justification
- The roster stays minimal and legible — every agent has a reason to exist

**Negative:**
- MECE check adds a step to agent creation — cannot just write the file and be done
- CE is hard to verify exhaustively; it requires explicit enumeration of all concerns the roster must cover (see agents/README.md Reviewer Matrix for the current enumeration)

---

## How to Apply

**Before adding any agent (framework or project):**
1. Name the concern precisely: "This agent reviews ___."
2. Scan the Reviewer Matrix in `.claude/agents/README.md`: does any existing agent review this?
   - If yes → stop. Adjust the PM brief to use the existing agent.
   - If no → proceed to step 3.
3. Confirm it closes a real gap: has this concern caused a missed issue in a real work item? Or is it a theoretical concern with no evidence of need?
4. Add the agent. Update the Reviewer Matrix. Verify no overlap was introduced.

**When modifying an existing agent:**
- Check if expanding its scope creates overlap with another agent
- If yes → either narrow the scope or merge the overlapping agents

---

## References

- `.claude/agents/README.md` — Reviewer Matrix (current CE enumeration)
- `.claude/docs/maintain-mode.md` — When to add a framework agent
- `.claude/docs/use-mode.md` — When to add a project agent
- `ADR-003` — PM sole orchestrator (companion: same principle of single ownership per concern)
