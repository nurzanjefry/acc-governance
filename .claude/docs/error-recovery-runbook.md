# Error Recovery Runbook — Index

**Purpose:** Guide for PMs to recover from framework errors. Each error category has a dedicated file.

---

## Quick Reference

| Error | Severity | Auto-Retry | Escalate | Recovery Time | File |
|---|---|---|---|---|---|
| Git commit fails | Medium | Yes (3×) | Yes | 5–30 min | [error-recovery-git.md](error-recovery-git.md) |
| Git push fails | Medium | Yes (4× backoff) | Yes | 30 min – 2 hours | [error-recovery-git.md](error-recovery-git.md) |
| Agent timeout | High | Auto (fallback) | Yes | 2–4 hours | [error-recovery-agent.md](error-recovery-agent.md) |
| Invalid output | Medium | Yes (3×) | Yes | 15–60 min | [error-recovery-agent.md](error-recovery-agent.md) |
| Lock conflict | Low | No (manual) | No | 5–15 min | [error-recovery-operations.md](error-recovery-operations.md) |
| Network timeout | Low | Yes (backoff) | Yes | 1–30 min | [error-recovery-operations.md](error-recovery-operations.md) |
| Revision cycle 5 | High | No (design decision) | Yes | 1–7 days | [error-recovery-operations.md](error-recovery-operations.md) |
| Cascading failures | Critical | Auto (backoff) | Yes | 15 min – 8 hours | [error-recovery-agent.md](error-recovery-agent.md) |

---

## Sub-Documents

| File | Contents |
|------|----------|
| `error-recovery-git.md` | ERROR 1 (Git Commit Failed), ERROR 2 (Git Push Failed) |
| `error-recovery-agent.md` | ERROR 3 (Agent Timeout), ERROR 4 (Invalid Output), ERROR 8 (Cascading Failures) |
| `error-recovery-operations.md` | ERROR 5 (Lock Conflict), ERROR 6 (Network Timeout), ERROR 7 (Reviewer Escalation) |

---

## When Things Go Wrong (PM Decision Tree)

1. **Identify error** — match symptoms to Quick Reference table above
2. **Open sub-doc** — follow the recovery procedure for that error
3. **If procedure fails** — escalate using contacts in the sub-doc
4. **Log to PROGRESS.md** — always document what happened and how it was resolved
