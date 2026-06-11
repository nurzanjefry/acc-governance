# Locking Protocol — Concurrency Control

> **Scope:** Multi-human-developer teams only.
> For parallel agent execution, see the **agent concurrency model** rule in `rules.md`.
> This document does not apply to agent-to-agent conflicts — those are handled by PM as sole writer.

---

## Quick Reference

| Operation | Command | Effect |
|---|---|---|
| Acquire Lock | `pm-acquire-lock --project X --item Y --reason "..."` | Lock item for developer; expires 4h |
| Release Lock | `pm-release-lock --project X --item Y --reason "..."` | Unlock item; next developer can pick up |
| Check Status | `pm-lock-status --project X --item Y` | Show owner and expiry |
| Auto-Expire | (automatic on next acquire attempt) | Lock >4h old → auto-release |

---

## Lock Schema in work-list.json

```json
{
  "id": "spec-001",
  "status": "in_progress",
  "assigned_to": "spec-author",
  "lock": {
    "locked_by": "developer-a@company.com",
    "locked_at": "2026-06-15T09:00:00Z",
    "lock_expires_at": "2026-06-15T13:00:00Z",
    "lock_reason": "Writing data-model.md for Phase 2"
  }
}
```

Items without a `lock` field are treated as unlocked.

---

## Lock Lifecycle

```
[UNLOCKED] → acquire_lock() → [LOCKED]
[LOCKED]   → release_lock() → [UNLOCKED]
[LOCKED]   → 4h timeout     → [EXPIRED] → next acquire_lock() → [LOCKED]
```

| State | Entry | Exit | Who acts |
|-------|-------|------|----------|
| UNLOCKED | Item created or lock released | Developer acquires | Any developer |
| LOCKED | acquire_lock() succeeds | release_lock() or timeout | Holding developer only |
| EXPIRED | 4h elapsed | Next acquire_lock() call | Auto-cleanup |

---

See `locking-protocol-rules.md` for detailed locking rules.
See `locking-protocol-troubleshooting.md` for conflict resolution.
