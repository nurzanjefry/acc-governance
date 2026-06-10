# Locking Protocol — Concurrency Control in work-list.json

**Purpose:** Enable 2+ developers to work in parallel on the same project without merge conflicts.

**Version:** 1.0  
**Last Updated:** 2026-06-11  
**Status:** Specification Complete; Ready for Implementation

---

## Quick Reference

| Operation | Command | Effect |
|---|---|---|
| **Acquire Lock** | `pm-acquire-lock --project X --item Y --reason "..."` | Lock item Y for developer; expires after 4 hours |
| **Release Lock** | `pm-release-lock --project X --item Y --reason "..."` | Unlock item Y; next developer can pick it up |
| **Check Status** | `pm-lock-status --project X --item Y` | Show who owns lock, when it expires |
| **Auto-Expire** | (automatic, happens on next acquire attempt) | If lock >4 hours old, auto-release |

---

## Lock Schema in work-list.json

### Item Structure (With Lock Fields)

```json
{
  "id": "spec-001",
  "phase": "02-spec",
  "title": "Data Model Specification",
  "status": "in_progress",
  "assigned_to": "spec-author",
  
  "lock": {
    "locked_by": "developer-a@company.com",
    "locked_at": "2026-06-15T09:00:00Z",
    "lock_expires_at": "2026-06-15T13:00:00Z",
    "lock_reason": "Writing data-model.md for Phase 2"
  },
  
  "dependencies": ["fdef-001"],
  "exit_criteria": [
    "Data model documented",
    "Schema reviewed"
  ],
  "estimated_days": 2,
  "verified_by": [],
  "evidence": "",
  "artifact": ""
}
```

### Field Details

| Field | Type | Required | Description | Example |
|---|---|---|---|---|
| **locked_by** | email | Yes | Developer holding the lock | "developer@company.com" |
| **locked_at** | ISO 8601 | Yes | When lock was acquired | "2026-06-15T09:00:00Z" |
| **lock_expires_at** | ISO 8601 | Yes | When lock auto-expires (4h default) | "2026-06-15T13:00:00Z" |
| **lock_reason** | string | Yes | Why lock was acquired (for logging) | "Writing data-model.md for Phase 2" |

### Backward Compatibility

Old work-list.json items without "lock" field are treated as unlocked. When first locked, field is added automatically.

---

## Lock Lifecycle

### State Machine

```
                    [UNLOCKED]
                        │
                        │ Developer calls acquire_lock()
                        ▼
                    [LOCKED]
                   /         \
                  │           │
    Developer calls        4 hours pass
    release_lock()         (timeout)
       │                        │
       ▼                        ▼
    [UNLOCKED] ←──────── [EXPIRED]
                          │
                          │ Next developer calls acquire_lock()
                          ▼
                          [UNLOCKED] → [LOCKED] (new holder)
```

### Lifecycle Rules

| State | Entry | Exit | Duration | Action |
|---|---|---|---|---|
| **UNLOCKED** | Item created OR lock released | Developer acquires | Days/weeks | Any developer can pick up |
| **LOCKED** | acquire_lock() succeeds | release_lock() called OR timeout | ≤4 hours | Holding developer has exclusive access |
| **EXPIRED** | 4 hours elapsed | Next developer acquires | (immediate) | Auto-cleanup; no action needed |

---

## Locking Rules

### Rule 1: Acquire Lock

**When:** Developer wants to start work on an item

**Command:**
```bash
pm-acquire-lock --project tallybite --item spec-001 \
  --reason "Writing data-model specification"
```

**What Happens:**

1. PM checks current lock state:
   - No lock → Create new lock (proceed)
   - Locked by you → Return "already_own" (no action needed)
   - Locked by other → Check expiration
     - Not expired → Return "conflict" (must wait or switch)
     - Expired → Auto-release old, create new (proceed)

2. Create lock in work-list.json:
   ```json
   {
     "lock": {
       "locked_by": "developer-b@company.com",
       "locked_at": "2026-06-15T09:30:00Z",
       "lock_expires_at": "2026-06-15T13:30:00Z",
       "lock_reason": "Writing data-model specification"
     }
   }
   ```

3. Commit to git:
   ```bash
   git commit -m "lock: acquire spec-001 for developer-b@company.com"
   ```

4. Return success:
   ```json
   {
     "status": "acquired",
     "lock": { ... },
     "message": "Lock acquired; expires at 13:30"
   }
   ```

**Error Cases:**

| Scenario | Response | Action |
|---|---|---|
| No such item | error | Check item ID spelling |
| Already own lock | already_own | Just start working; lock is yours |
| Someone else locked (not expired) | conflict | Wait, or pick different item |
| Someone locked, but expired | acquired | Auto-expired old holder; you now own it |

---

### Rule 2: Hold Lock

**While:** Developer is working on item

**Constraints:**
- Lock cannot be transferred to another developer
- Lock expires after 4 hours automatically (no manual extension)
- Developer can hold lock through multiple commits (lock persists across git ops)

**Timeline Example:**

```
09:00 - Developer acquires lock (expires 13:00)
09:30 - Developer reading requirements
10:00 - Developer writing spec-001.md
10:30 - Developer commits: "draft of spec-001.md"
        (Lock still held; another dev cannot pick up)
11:00 - Developer pushing to remote
11:30 - Developer still revising
13:00 - Lock expires (developer took exactly 4 hours)
13:05 - Second developer can now acquire same lock
```

**Note:** Developer can make multiple commits while holding lock. Lock is tied to work-list.json item, not to individual commits.

---

### Rule 3: Release Lock

**When:** Developer finishes with item (ready for review or switching)

**Command:**
```bash
pm-release-lock --project tallybite --item spec-001 \
  --reason "Completed spec-001 draft; ready for review"
```

**What Happens:**

1. PM verifies ownership:
   - Is lock owned by current user? Yes → proceed
   - Is lock owned by someone else? → error "You don't hold this lock"

2. Remove lock from work-list.json:
   ```json
   {
     "lock": null    // or omit the field entirely
   }
   ```

3. Commit to git:
   ```bash
   git commit -m "lock: release spec-001 from developer-b@company.com; spec-001 draft complete"
   ```

4. Log to PROGRESS.md:
   ```markdown
   ## Lock Release Event

   **2026-06-15T11:00 - spec-001 lock released**
   - Previous holder: developer-b@company.com
   - Reason: Completed spec-001 draft; ready for review
   - Lock held for: 1 hour 30 minutes (of 4-hour max)
   ```

5. Return success:
   ```json
   {
     "status": "released",
     "message": "Lock released on spec-001; next developer can acquire"
   }
   ```

---

### Rule 4: Auto-Cleanup (Lock Expiration)

**When:** Lock timeout exceeded (4 hours)

**Trigger:** Automatic check during next acquire_lock() attempt by any developer

**What Happens:**

1. Developer A's lock was acquired at 09:00 (expires 13:00)
2. Developer A disappears (machine crash, gone for lunch, etc.)
3. Developer B tries to acquire same item at 13:05:
   - PM checks: lock exists, but timestamp shows 09:00 < 13:05
   - Conclusion: Lock expired
   - Action: Auto-release Developer A's lock
   - Action: Create new lock for Developer B

4. Log expiration to PROGRESS.md:
   ```markdown
   ## Lock Expiration Event

   **2026-06-15T13:05 - spec-001 lock expired**
   - Previous holder: developer-a@company.com
   - Lock age: 4 hours 5 minutes (exceeded 4-hour max)
   - Action: Auto-released; Developer B (developer-b@company.com) now owns lock
   - Possible reasons for expiration:
     - Developer was interrupted and forgot to release
     - Developer's machine crashed
     - Developer is on break/lunch
   ```

5. **No manual intervention needed.** Automatic cleanup prevents deadlock.

---

### Rule 5: Conflict Resolution

**When:** Developer B wants to lock item, but Developer A already holds it (not expired)

**Scenario:**
```
09:00 - Developer A: pm-acquire-lock spec-001 (expires 13:00)
        Result: ACQUIRED

09:30 - Developer B: pm-acquire-lock spec-001
        Result: CONFLICT
        Message: "Item locked by developer-a@company.com until 13:00 (2h 30m remaining)"
```

**Options for Developer B:**

#### Option 1: Wait for Expiration
- Time until lock expires: 2h 30m
- Decision: Wait until 13:00
- At 13:05: Try again with `pm-acquire-lock spec-001`
- Result: Should succeed (Developer A's lock auto-expired)

#### Option 2: Switch to Different Item
- Pick another item: `pm-acquire-lock spec-002`
- If available: Developer B locks spec-002, continues work
- Development doesn't block; just working on different item
- Developer A and B work in parallel on different items

#### Option 3: Negotiate
- Contact Developer A: "Can you release spec-001? I need it ASAP"
- Developer A calls: `pm-release-lock spec-001 --reason "Giving to Bob"`
- Developer B can then acquire: `pm-acquire-lock spec-001`
- Risk: Social coordination required

**Recommended Strategy:** Option 2 (switch items). Prevents blocking; parallel work continues.

**Lock Ownership Rule:** First developer to acquire lock owns it. Older lock takes precedence. Newer developer must wait or switch.

---

## Timeout Handling

### Lock Timeout Duration

**4 hours is chosen based on:**

| Duration | Rationale | Pros | Cons |
|---|---|---|---|
| **1 hour** | Lunch break | Fast recovery from crashes | Expires during legitimate work |
| **2 hours** | Afternoon meeting | Reasonable work session | Still might interrupt |
| **4 hours (CHOSEN)** | Half-day work | Covers normal work session | Risk: might fail silently for 4 hours |
| **8 hours** | Full workday | Very safe | Long wait if dev crashes; deadlock risk |
| **24 hours** | Very conservative | Never expires | Indefinite deadlock if dev goes offline |

**4 hours balances:**
- Normal work session can complete (developer unlikely to take >4 hours on single item)
- Reasonable recovery time if developer crashes (not waiting all day)
- Accommodates lunch breaks and meetings within 4-hour window

### Configuration

In `config.yaml`:
```yaml
defaults:
  lock_timeout_hours: 4  # Global default
  
projects:
  - name: tallybite
    lock_timeout_hours: 4  # Can override per project if needed
```

### What Happens When Lock Expires

**Scenario 1: Developer Still Working**

```
09:00 - Developer A acquires lock (expires 13:00)
09:30 - Developer A working on spec-001
12:45 - Developer B tries to acquire spec-001
        Lock status: A still has it; expires in 15 minutes
        Developer B: I'll wait 15 minutes
        
13:01 - Developer B: pm-acquire-lock spec-001
        Result: ACQUIRED (A's lock auto-expired)
        
13:05 - Developer A: pm-release-lock spec-001
        Error: "Lock no longer yours; it expired and B has it now"
        Developer A must contact B to resolve:
        - B finished first → no problem
        - B still working → must coordinate
```

**Scenario 2: Developer Disappeared**

```
09:00 - Developer A acquires lock (expires 13:00)
09:30 - Developer A's machine crashes
        (Lock still in work-list.json; A can't release)
        
12:00 - Developer B checks status: can I work on spec-001?
        Answer: No, A's lock still active (1 hour until expiry)
        
13:05 - Developer B tries again: can I work on spec-001?
        Answer: YES (A's lock expired automatically)
        Developer B: pm-acquire-lock spec-001
        Result: ACQUIRED
        
13:10 - Developer A's machine boots
        A reads work-list: "spec-001 lock is gone??"
        A reads PROGRESS.md: "Lock auto-expired at 13:05; B acquired it"
        A contacts B: "I was working on spec-001; I see you have the lock now"
        A/B coordinate: A picks different item or waits for B to finish
```

---

## Conflict Detection & Recovery

### Merge Conflict in work-list.json

If two developers both try to modify work-list.json simultaneously:

```bash
Developer A: git push origin feature/spec-001
            → SUCCESS (first push)

Developer B: git push origin feature/spec-002
            → CONFLICT in projects/tallybite/work-list-tallybite.json
            → Git merge conflict detected
```

**Conflict Resolution:**

1. **PM explains the conflict:**
   ```
   MERGE CONFLICT in projects/tallybite/work-list-tallybite.json
   
   Possible causes:
   1. Lock field collision: both devs modified same item's lock
   2. Item order change: both devs reordered items
   3. Status change: both devs updated same item status
   
   Locking rule: Older lock wins (whoever acquired first)
   ```

2. **Developer B resolves:**
   - Check: Who acquired the lock first (locked_at timestamp)?
   - If Developer A's timestamp < Developer B's: Developer B loses
   - Developer B: Rebase their change, take Developer A's version
   - Developer B: If you also need that item, wait for Developer A to release (or pick different item)

3. **Escalation:** If conflict seems like a bug (not a lock issue):
   - Flag it: This shouldn't happen with locking in place
   - File issue: "Unexpected merge conflict in work-list.json"

---

## Helper Functions Reference

### Function 1: acquire_lock()

```
acquire_lock(project, item_id, user_email, reason, timeout_hours=4)

Input:
  project: "tallybite"
  item_id: "spec-001"
  user_email: "developer-b@company.com"
  reason: "Writing data-model specification"
  timeout_hours: 4

Output:
  {
    "status": "acquired" | "conflict" | "already_own" | "error",
    "lock": { locked_by, locked_at, lock_expires_at, lock_reason },
    "message": "Human-readable result"
  }

Cases:
  - No lock exists → Create new → Return "acquired"
  - Lock exists, owned by user → Return "already_own"
  - Lock exists, owned by other, not expired → Return "conflict"
  - Lock exists, owned by other, expired → Auto-release, create new → Return "acquired"
```

### Function 2: release_lock()

```
release_lock(project, item_id, user_email, reason="")

Input:
  project: "tallybite"
  item_id: "spec-001"
  user_email: "developer-b@company.com"
  reason: "Completed spec-001 draft; ready for review"

Output:
  {
    "status": "released" | "not_locked" | "not_owner" | "error",
    "message": "Human-readable result"
  }

Cases:
  - Not locked → Return "not_locked"
  - Locked by other → Return "not_owner"
  - Locked by user → Remove lock, commit → Return "released"
```

### Function 3: check_lock_expired()

```
check_lock_expired(project, item_id) → Boolean

Input:
  project: "tallybite"
  item_id: "spec-001"

Output:
  True if lock is expired (or doesn't exist)
  False if lock still valid

Usage: Called before every lock check to auto-expire old locks
```

---

## Best Practices

### When to Acquire

✅ **Good:** Acquire lock right before starting work
```bash
09:00 - Developer: "I'm about to work on spec-001"
        pm-acquire-lock --project tallybite --item spec-001 --reason "Starting work on data model"
```

❌ **Bad:** Acquire lock days before starting work
```bash
2026-06-10 - Developer: "I might work on spec-001 next week"
             (Lock held for 7 days; blocks others)
```

### When to Release

✅ **Good:** Release lock when you finish work (even if not fully done)
```bash
11:00 - Developer: "My draft is done; ready for code review"
        pm-release-lock --project tallybite --item spec-001
        (If you want to make revisions later, re-acquire)
```

✅ **Good:** Release lock if you're taking a long break
```bash
12:00 - Developer: "Going to lunch for 1 hour; releasing lock so others can work"
        pm-release-lock --project tallybite --item spec-001
```

❌ **Bad:** Hold lock while on vacation
```bash
Developer acquired 2026-06-15, goes on vacation 2026-06-17
Lock expires naturally after 4 hours (good), but holding it anyway is bad form
```

### Conflict Prevention

✅ **Good:** Different developers work on different items
```
Developer A: pm-acquire-lock --item spec-001 ✓
Developer B: pm-acquire-lock --item spec-002 ✓
(No conflict; parallel work)
```

✅ **Good:** If conflict inevitable, have discussion first
```
Developer A: "I need spec-001; I'm starting now"
Developer B: "OK, I'll work on spec-002 instead"
(Coordinate before acquiring)
```

❌ **Bad:** Multiple developers try to grab same item
```
Developer A: pm-acquire-lock --item spec-001 ✓
Developer B: pm-acquire-lock --item spec-001 ✗ CONFLICT
(Now B is blocked; should have picked different item)
```

---

## Logging & Monitoring

All lock events logged to PROGRESS.md for transparency:

- **Lock Acquired:** Who, when, why, expiration time
- **Lock Released:** Who, when, why, how long held
- **Lock Expired:** Previous holder, auto-released for new holder
- **Lock Conflict:** Who wanted it, who has it, wait time

Example PROGRESS.md entry:
```markdown
## 2026-06-15 Lock Events (TallyBite)

**09:00 - spec-001 locked by developer-b@company.com**
- Reason: Writing data-model specification
- Expires: 13:00 (4-hour timeout)

**10:30 - developer-a@company.com tried spec-001**
- Result: CONFLICT (developer-b owns it; expires in 2h 30m)
- Resolution: developer-a locked spec-002 instead

**11:00 - developer-b@company.com released spec-001**
- Reason: Completed draft; ready for review
- Lock held: 1 hour 30 minutes (of 4-hour max)

**11:05 - developer-a@company.com acquired spec-001**
- Reason: Adding review notes to spec-001
- Expires: 15:05 (4-hour timeout)
```

---

## Troubleshooting

### "Item locked by developer-a@company.com until 13:00"

**Problem:** You want to work on an item but someone else locked it.

**Solutions:**
1. **Wait:** Let their lock expire (4 hours max)
2. **Switch:** Work on different item instead (recommended)
3. **Negotiate:** Message developer-a: "Can you release this? I need it"
4. **Escalate:** If developer-a is completely gone (days), contact PM to force-release

### "You don't own the lock on this item"

**Problem:** You tried to release a lock but you don't own it.

**Cause:** Someone else is working on this item, or lock expired and reassigned.

**Solution:**
- Check who owns it: `pm-lock-status --project X --item Y`
- Wait for them to release, or pick different item

### "Lock has expired; you can now acquire"

**Problem:** You've been waiting for lock to expire.

**Action:**
- Call: `pm-acquire-lock --project X --item Y`
- Should succeed now

### Deadlock (Lock Not Releasing)

**Problem:** Developer disappeared with lock; it's been 4 hours.

**Automatic Solution:**
- Lock expires automatically after 4 hours
- Next developer to call acquire_lock() will auto-cleanup old lock
- **No manual intervention needed**

**Manual Escalation (if needed):**
- If truly stuck: Contact PM/framework-architect
- Provide: project, item_id, current lock holder
- PM can force-release if critical

---

**End of Locking Protocol Document**
