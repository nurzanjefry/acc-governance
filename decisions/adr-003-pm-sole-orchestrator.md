# ADR-003: PM as Sole Orchestrator — No Peer-to-Peer Agent Coordination

**Date:** 2026-06-11
**Status:** Accepted
**Deciders:** Framework Owner

---

## Context

In a multi-agent system, agents can coordinate in different ways: peer-to-peer (agents call each other directly), hub-and-spoke (one coordinator manages all agents), or emergent (agents self-organize via shared state). The framework needed to choose a coordination model.

---

## Decision

One PM (the main Claude session) orchestrates all agents. Agents never call other agents. Agents never dispatch reviewers. Agents return JSON to PM and stop. PM decides what happens next.

---

## Rationale

- **Determinism:** With one orchestrator, execution order is explicit and auditable. The 8-step loop is always the same — no emergent behavior.
- **Human control:** The Owner only needs to interact with the PM. If agents called each other, the Owner would need to track multiple decision chains.
- **Debuggability:** When something goes wrong, the PM is the single point of investigation. No need to trace peer-to-peer call chains.
- **Cost control:** PM decides which agents to run and when. Agents cannot spawn unbounded sub-agents that accumulate cost.
- **Quality gate:** All reviewer findings flow through PM before reaching the Owner. PM synthesizes, filters, and presents — agents don't present directly.

---

## Alternatives Considered

- **Peer-to-peer agents:** Agent A reviews Agent B's work directly. Rejected — creates hidden execution chains, unclear ownership, hard to audit.
- **Emergent coordination via shared state:** Agents self-coordinate by reading/writing shared flags. Rejected — non-deterministic, race conditions, hard to reason about.
- **Multi-PM model:** Different PMs for different phases. Rejected — state handoff between PMs is lossy; one PM reading PROGRESS.md is simpler.

---

## Consequences

**Positive:**
- Single clear entry point for every action
- Owner interacts with one entity (PM), not a swarm
- Execution is always reproducible from PROGRESS.md

**Negative:**
- PM is a bottleneck — all work flows through one session
- PM context window grows as work accumulates (mitigation: PROGRESS.md as external memory)

---

## References

- `CLAUDE.md` — Role Definition section
- `.claude/docs/orchestration-protocol.md` — 8-step loop
- `.claude/agents/README.md` — PM responsibilities
