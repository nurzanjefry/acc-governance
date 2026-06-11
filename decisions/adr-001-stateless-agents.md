# ADR-001: Stateless Agents — No Persistent Memory

**Date:** 2026-06-11
**Status:** Accepted
**Deciders:** Framework Owner

---

## Context

The framework needs agents that can be spawned, do work, and be discarded — without carrying state between sessions. The question was whether agents should maintain memory across invocations (e.g., remembering prior conversations, accumulated context, learned preferences) or reconstruct all context from files on every run.

---

## Decision

All agents are stateless. Every agent spawn is a clean slate. Agents reconstruct all context by reading files passed in their brief. No agent remembers anything from a prior run.

---

## Rationale

- **Determinism:** A stateless agent given the same files produces the same output. This makes the system auditable and debuggable — if an output is wrong, you can reproduce it.
- **Resumability:** Any session can resume mid-project by reading `PROGRESS.md` and `work-list.json`. No context is lost to memory decay or session expiry.
- **Parallelism:** Stateless agents can run in parallel without coordination. No shared mutable state means no race conditions on agent memory.
- **Replaceability:** Any agent can be swapped, upgraded, or replaced without migration. State lives in files, not in the agent.

---

## Alternatives Considered

- **Persistent memory per agent:** Agents accumulate context across sessions. Rejected — memory decay, non-determinism, and inability to reproduce results make this unsuitable for a governed framework.
- **Shared agent context store:** Agents read/write a central context object. Rejected — introduces concurrency conflicts and tight coupling between agents.

---

## Consequences

**Positive:**
- Any session can pick up exactly where the last one stopped
- Agent failures don't corrupt state — files are the source of truth
- Easier to debug: replay any agent run with the same input files

**Negative:**
- PM must pass sufficient context in every brief — if context is omitted, agent produces incomplete output
- Agents cannot learn or adapt from prior runs within the same project

---

## References

- `.claude/docs/orchestration-protocol.md` — Core Principles section
- `.claude/docs/rules.md` — Agent concurrency model rule
