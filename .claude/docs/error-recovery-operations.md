# Error Recovery: Operations Errors

**Index:** See `error-recovery-runbook.md` for the full error categorization table.

---

## ERROR 5: Lock Conflict

### Symptoms

```
Git merge conflict in: projects/tallybite/work-list-tallybite.json
Developer B: git push origin feature/spec-002
  → CONFLICT (both A and B modified work-list)
```

### Root Causes

1. Both developers acquired locks at nearly the same time
2. Developer didn't check for existing lock
3. Git race condition (both pushed before seeing each other's commits)

### Recovery

**Step 1: Identify the conflict** — Git shows conflict markers in work-list.json.

**Step 2: Check who owns each lock** — Compare `locked_at` timestamps in the conflict.

**Step 3: Apply locking rule — Older lock wins (whoever acquired first gets item).**

**Step 4: Resolve conflict** — Keep winning lock, remove losing lock.

**Step 5: Complete merge**
```bash
git add projects/your-project/work-list-your-project.json
git commit -m "merge: resolve lock conflict; developer-a owns spec-001"
git push origin feature/spec-002
```

**Step 6: Log in PROGRESS.md** — Record who won, who switched, merge outcome.

### Prevention
- Check lock status before acquiring
- If locked by someone else: wait or pick a different item

### Escalation

Contact PM with: work-list conflict section + timestamps.  
PM decides: who should win? Switch items? Force-release?

---

## ERROR 6: Network Timeout During Large Operation

### Symptoms

```
Error: Network timeout waiting for response from server
  Timeout after 30 seconds
  Operation: Pushing 100MB artifact
```

### Root Causes

1. Large file (artifact too big for network)
2. Slow or flaky connection
3. GitHub/CI system temporarily down
4. Firewall blocking push

### Recovery

**Step 1: Check network + artifact size**
```bash
ping github.com            # Should respond <50ms
find . -size +10M -type f  # Check for large files
```

**Step 2: Reduce artifact size** — Compress before adding, or move large files to S3/GCS and reference via symlink.

**Step 3: Auto-retry** — Framework retries with exponential backoff (0s → 1s → 5s → 30s → escalate).

**Step 4: Manual retry**
```bash
git push origin feature/spec-001 --verbose
# See detailed output; try --force-with-lease if needed
```

### Prevention
- Keep repos lean (use .gitignore for large binaries)
- Test push on a good connection before deadlines

### Escalation

Contact: infrastructure-reviewer.  
Provide: error message + network diagnostics.  
Request: investigate firewall rules, GitHub status.

---

## ERROR 7: Reviewer Escalation (After 5 Revision Cycles)

### Symptoms

```
state_history: revision_cycle_5 → escalated
PROGRESS.md: "spec-001 hit 5 revision cycles; escalating to human PM"
Item status: ESCALATED (hard gate)
```

### Meaning

Item has gone through the maximum revision cycles with reviewers still finding blockers. Indicates: unclear spec, fundamental architectural flaw, or reviewer bar too high.

### Recovery

**Step 1: Classify the blocker pattern**
- Same blocker repeated across cycles? → Author not fixing it, or explanation unclear
- New blocker each cycle? → Spec fundamentally unclear or architecture flawed
- Minor style issues? → Reviewer bar too high

**Step 2: PM chooses one of three options:**

| Option | When | Action | Risk |
|--------|------|--------|------|
| **A: Reject & Redesign** | Architecture fundamentally flawed | Send back for full redesign | Major delay |
| **B: Defer Blockers** | Blockers are nice-to-haves | Pass with "known-issues.md" | Technical debt |
| **C: Escalate to Committee** | Unclear if spec or reviewer problem | Governance committee reviews | 1-week delay |

**Step 3: Log decision in state_history + PROGRESS.md.**

### Prevention
- Cycle 1-2: Clarify spec early
- Cycle 3: Consider redesign (don't wait for cycle 5)
- Cycle 4: Hard decision — pass with conditions, or redesign?

### Escalation

Framework has already escalated to human PM. PM decides using Option A/B/C.

---

## Quick Reference: Error Categorization

| Error | Severity | Auto-Retry | Escalate | Typical Recovery Time |
|---|---|---|---|---|
| Git commit fails | Medium | Yes (3×) | Yes | 5–30 min |
| Git push fails | Medium | Yes (4× backoff) | Yes | 30 min – 2 hours |
| Agent timeout | High | Auto (fallback) | Yes | 2–4 hours |
| Invalid output | Medium | Yes (3×) | Yes | 15–60 min |
| Lock conflict | Low | No (manual) | No | 5–15 min |
| Network timeout | Low | Yes (backoff) | Yes | 1–30 min |
| Revision cycle 5 | High | No (design decision) | Yes | 1–7 days |
| Cascading failures | Critical | Auto (backoff) | Yes | 15 min – 8 hours |
