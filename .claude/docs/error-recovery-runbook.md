# Error Recovery Runbook — Step-by-Step Recovery Procedures

**Purpose:** Guide for developers and PMs to manually recover from framework errors.

**Version:** 1.0  
**Last Updated:** 2026-06-11  
**Target Audience:** Framework users, PM, developers

---

## Common Errors & Recovery Procedures

---

## ERROR 1: Git Commit Failed

### Symptoms

```
Error: git commit -m "docs(spec-001): Add data model"
   fatal: Not a git repository (or any of the parent directories): .git
```

### Root Causes

1. **Not in git repo:** Working directory is not a git repository
2. **Git config missing:** git user.email or user.name not set
3. **Bad file permissions:** Cannot write to .git directory
4. **Corrupted repo:** .git directory is corrupted

### Recovery Procedure

**Step 1: Check if you're in a git repo**
```bash
# Verify you're in the right directory
pwd  # Should output: .../your-project-dir/
ls -la | grep .git  # Should see ".git" directory
```

**Step 2: Check git configuration**
```bash
git config user.email
git config user.name
# Should return your email and name

# If missing, set them:
git config --global user.email "you@company.com"
git config --global user.name "Your Name"
```

**Step 3: Verify git credentials**
```bash
# Check git auth token (for HTTPS)
git credential-osxkeychain get  # macOS
git credential-manager get      # Windows

# If missing or expired, re-authenticate
git config --global credential.helper osxkeychain  # macOS
```

**Step 4: Retry commit**
```bash
git commit -m "docs(spec-001): Add data model"
# Should succeed now
```

**Step 5: If still failing**
```bash
# Check repo status
git status
git fsck --full  # Diagnostic: check for corruption

# Last resort: fresh clone
rm -rf .git
git clone <repo-url> .
# Restore your working files from backup
```

### Prevention

- Run `git config --global user.email` once after system setup
- Keep auth tokens fresh (GitHub tokens expire after 1 year)
- Don't manually edit .git directory

### Escalation

If all steps fail:
- File issue: "Git commit failing; possible repo corruption"
- Contact: infrastructure-reviewer or framework-architect
- Provide: Error message, git status output, git fsck results

---

## ERROR 2: Git Push Failed

### Symptoms

```
Error: git push origin feature/spec-001
   fatal: unable to access 'https://github.com/...': Could not resolve host: github.com
```

OR

```
Error: git push origin feature/spec-001
   fatal: 'origin' does not appear to be a 'git' repository
```

### Root Causes

1. **Network down:** Cannot reach GitHub (internet down, firewall, DNS)
2. **Auth failed:** Token expired or incorrect credentials
3. **Upstream conflict:** Your branch conflicts with main
4. **Remote not configured:** "origin" doesn't exist

### Recovery Procedure

**Step 1: Check network connectivity**
```bash
ping github.com
# If no response: network is down; try again later

# Check DNS
nslookup github.com
# If fails: check your DNS settings
```

**Step 2: Check remote configuration**
```bash
git remote -v
# Should show:
#   origin  https://github.com/YOUR_ORG/YOUR_REPO.git (fetch)
#   origin  https://github.com/YOUR_ORG/YOUR_REPO.git (push)

# If "origin" missing, add it:
git remote add origin https://github.com/YOUR_ORG/YOUR_REPO.git
```

**Step 3: Verify authentication**
```bash
# Test push to verify credentials work
git push origin feature/spec-001

# If auth error: re-authenticate
git config --global credential.helper store  # Save credentials
git push origin feature/spec-001  # Will prompt for auth
```

**Step 4: Check for conflicts**
```bash
# Fetch latest from remote
git fetch origin

# Check if your branch conflicts with main
git merge-base --is-ancestor main feature/spec-001
# If false: your branch is based on old main

# Rebase onto latest main
git rebase origin/main
# Resolve conflicts if any
git rebase --continue
```

**Step 5: Retry push**
```bash
git push origin feature/spec-001
# Should succeed now
```

### Automatic Retry

The framework automatically retries git push with exponential backoff:
- Attempt 1: Immediate
- Attempt 2: Wait 1 second, retry
- Attempt 3: Wait 5 seconds, retry
- Attempt 4: Wait 30 seconds, retry
- Attempt 5+: Escalate to human PM

If automatic retries fail, you'll see:
```
state_history entry: git_error → retrying → retrying → ... → manual_intervention
PROGRESS.md: "git push failed 4 times; escalating to PM"
```

### Prevention

- Push frequently (don't let branch diverge >2 days from main)
- Verify network before starting work
- Keep auth tokens fresh (refresh monthly)

### Escalation

If manual retry still fails:
- State: state_history shows "manual_intervention" needed
- PM reviews: What's preventing push?
- Options:
  - Force push (if safe): `git push -f origin feature/spec-001` (last resort)
  - Rebase + retry: `git rebase origin/main; git push`
  - Request review: Merge locally, have PM push
  - Network escalation: Contact IT if network issues

---

## ERROR 3: Agent Timeout (Reviewer Not Responding)

### Symptoms

```
state_history: under_review → (4 hours pass)
PROGRESS.md: "data-model-reviewer timeout exceeded"
```

### Root Causes

1. **Agent overloaded:** Reviewer has many tasks queued
2. **Agent crashed:** Claude or human reviewer unavailable
3. **Network issue:** Reviewer didn't receive task or response lost
4. **Reviewer away:** Human reviewer on break/vacation

### Recovery Procedure

**Step 1: Check state_history**
```json
{
  "timestamp": "2026-06-15T15:00:00Z",
  "to_state": "agent_timeout",
  "actor": "system",
  "reason": "data-model-reviewer did not respond within 4 hours",
  "details": {
    "reviewer": "data-model-reviewer",
    "timeout_seconds": 14400,
    "expected_response": "2026-06-15T15:00:00Z"
  }
}
```

**Step 2: Check PROGRESS.md for escalation note**
```markdown
## Agent Timeout Event

**2026-06-15T15:00 - data-model-reviewer timeout exceeded**
- Item: spec-001
- Agent: data-model-reviewer (Claude)
- Timeout: 4 hours (14400 seconds)
- Expected response: 15:00
- Action: Escalating to fallback agent (human-dba)
```

**Step 3: Fallback agent should activate**

The framework automatically activates fallback agents:
1. Check agent registry: `data-model-reviewer.fallback_agents` → `["human-dba"]`
2. Dispatch human-dba with same task
3. Human-dba (on-call) receives notification
4. Human-dba completes review (slower, but completes)

**Step 4: If fallback also times out**

```markdown
## Agent Timeout (Fallback)

**2026-06-15T17:00 - human-dba timeout exceeded**
- Primary agent: data-model-reviewer (timeout at 15:00)
- Fallback agent: human-dba (timeout at 17:00)
- No more fallbacks available
- Action: Escalate to human PM
```

**Action for PM:**
- Contact human-dba: "Are you available for spec-001 review?"
- If yes: Re-dispatch with fresh task
- If no: Find emergency reviewer or defer item to next phase

### Prevention

- Monitor reviewer availability (check metrics; see if reviewer overloaded)
- Distribute work evenly (don't dump 10 items on one reviewer in 1 day)
- For known unavailability: Plan ahead (assign backup reviewer)

### Escalation

If both primary and fallback fail:
- Contact: PM + framework-architect
- Decision needed:
  - Skip review (risk: approve without review)
  - Find emergency reviewer (cost: higher pay, delay)
  - Defer to next phase (delay: ship later)

---

## ERROR 4: Agent Invalid Output

### Symptoms

```
state_history: agent_running → agent_invalid_output
PROGRESS.md: "spec-author returned output missing required fields"
```

Example error:
```json
{
  "status": "success",
  "deliverables": ["02-spec/spec-001.md"],
  // Missing: session_log, duration_seconds, tokens_used
}
```

### Root Causes

1. **Agent bug:** Agent returned incomplete JSON
2. **Network issue:** Response truncated during transmission
3. **Agent training issue:** Agent doesn't follow output contract
4. **Spec bug:** Output schema was ambiguous

### Recovery Procedure

**Step 1: Check what's missing**

Expected output schema:
```json
{
  "status": "success",
  "deliverables": [],
  "session_log": "path/to/log",
  "error": null,
  "duration_seconds": 123,
  "tokens_used": 4567
}
```

Actual output:
```json
{
  "status": "success",
  "deliverables": [],
  // Missing: session_log, error, duration_seconds, tokens_used
}
```

**Step 2: Framework automatically retries**

The framework retries up to 3 times:
```
Attempt 1: Fails (missing fields)
  → Log to state_history
  → Wait 1 second
  
Attempt 2: Retry with feedback
  → Brief includes: "Output was missing: session_log, duration_seconds, tokens_used"
  → Agent should fix and return complete output
  
Attempt 3: If still failing
  → Escalate to fallback agent
```

**Step 3: If 3 retries fail**

```
state_history: invalid_output → retrying → retrying → retrying → agent_fallback
PROGRESS.md: "spec-author failed 3 times; activating fallback (human-spec-expert)"
```

Fallback agent dispatched with same task.

**Step 4: If fallback also fails**

Escalate to human PM:
- What's wrong with agent output?
- Is agent broken or is spec ambiguous?
- Options:
  - Fix agent implementation
  - Clarify output spec
  - Assign human reviewer directly
  - Abandon this approach; try different reviewer

### Prevention

- Keep agent output schema simple (only required fields)
- Test agent with edge cases before deployment
- Document output schema clearly

### Escalation

If cannot get valid output:
- Contact: framework-architect + agent owner
- Diagnose: Is this an agent problem or a spec problem?
- Fix: Update agent or update spec

---

## ERROR 5: Lock Conflict

### Symptoms

```
Git merge conflict in: projects/tallybite/work-list-tallybite.json
Developer B: git push origin feature/spec-002
  → CONFLICT (both A and B modified work-list)
```

### Root Causes

1. **Lock timing issue:** Both developers acquired locks at nearly same time
2. **Process issue:** Developer didn't check for existing lock
3. **Git race condition:** Both pushed before seeing each other's commits

### Recovery Procedure

**Step 1: Identify the conflict**

Git will show:
```
Auto-merging projects/your-project/work-list-your-project.json
CONFLICT (content): Merge conflict in projects/your-project/work-list-your-project.json
Automatic merge failed; fix conflicts and then commit.
```

**Step 2: Check who owns each lock**

Open work-list.json and look for conflict markers:
```json
<<<<<<< HEAD (your changes)
"lock": {
  "locked_by": "alice@company.com",
  "locked_at": "2026-06-15T09:00:00Z"
}
=======
"lock": {
  "locked_by": "bob@company.com",
  "locked_at": "2026-06-15T09:01:00Z"
}
>>>>>>> origin/feature/spec-001
```

**Step 3: Apply locking rule**

Rule: **Older lock wins** (whoever acquired first gets item).

Compare timestamps:
- Alice: 09:00:00 (acquired first) ← WINNER
- Bob: 09:01:00 (acquired second) ← LOSES

**Step 4: Resolve conflict**

If you are Alice (won):
```json
"lock": {
  "locked_by": "developer-a@company.com",
  "locked_at": "2026-06-15T09:00:00Z",
  "lock_expires_at": "2026-06-15T13:00:00Z",
  "lock_reason": "Writing data-model.md"
}
```

If you are Bob (lost):
- Option 1: Remove the lock entirely (release it) and let Alice own it
- Option 2: Take Alice's lock from the conflict (accept Alice's version)
- Option 3: Switch to different item

**Step 5: Complete merge**

```bash
# After resolving conflict:
git add projects/your-project/work-list-your-project.json
git commit -m "merge: resolve lock conflict; developer-a owns spec-001"
git push origin feature/spec-002
```

**Step 6: Log what happened**

Add note to PROGRESS.md:
```markdown
## Lock Conflict Resolution

**2026-06-15 10:00 - Lock conflict detected**
- Item: spec-001
- Developer A (developer-a): acquired 09:00:00 ← WINNER
- Developer B (developer-b): acquired 09:01:00 ← LOSES
- Conflict: Both tried to push simultaneously
- Resolution: Alice wins (older timestamp)
- Action: Bob switched to spec-002 instead
- Merge successful
```

### Prevention

- Check `pm-lock-status` before acquiring: `pm-lock-status --project X --item Y`
- If locked by someone else: Wait or pick different item
- Don't push multiple times to same branch (increases conflict risk)

### Escalation

If conflict resolution unclear:
- Contact: PM
- Provide: work-list conflict section + timestamps
- PM decides: Who should win? Switch to different item? Force-release?

---

## ERROR 6: Network Timeout During Large Operation

### Symptoms

```
Error: Network timeout waiting for response from server
  Timeout after 30 seconds
  Operation: Pushing 100MB artifact
```

### Root Causes

1. **Large file:** Artifact too big for network
2. **Slow network:** Connection is flaky or slow
3. **Server down:** GitHub/CI/CD system temporarily down
4. **Firewall:** Network filtering blocking push

### Recovery Procedure

**Step 1: Check network status**
```bash
# Test connection speed
ping github.com
# Should respond in <50ms

# Test actual push size
du -h projects/tallybite/  # Check directory size
git count-objects -v       # Check repo size
```

**Step 2: Reduce artifact size if possible**

Large files slow down git:
```bash
# Check what's large
find . -size +10M -type f

# If artifacts too large:
# 1. Compress before adding to git
# 2. Move to external storage (S3, GCS)
# 3. Reference with symlink
```

**Step 3: Retry with exponential backoff**

Framework automatically retries network timeouts:
```
Attempt 1: Immediate
Attempt 2: Wait 1s, retry
Attempt 3: Wait 5s, retry
Attempt 4: Wait 30s, retry
Attempt 5+: Escalate
```

**Step 4: Manual retry**
```bash
# If automatic retry didn't work:
git push origin feature/spec-001 --verbose
# See detailed output of what's failing

# If timeout again:
git push --force-with-lease  # Safe force (only if needed)
```

**Step 5: Escalation**

```
state_history: pushed_to_remote → network_timeout → retrying → ... → manual_intervention
PROGRESS.md: "Network timeout during push; human PM intervention needed"
```

Contact PM:
- Check server status: Is GitHub down?
- Check network: Is firewall blocking?
- Options:
  - Retry from different network
  - Split artifact into smaller chunks
  - Escalate to infrastructure team

### Prevention

- Keep repos lean (don't add large binaries)
- Use .gitignore to exclude big files
- Test push on good connection before working on deadline

### Escalation

If network issue persistent:
- Contact: infrastructure-reviewer
- Provide: Error message + network diagnostics
- Request: Investigate firewall rules, GitHub status

---

## ERROR 7: Reviewer Escalation (After 5 Revision Cycles)

### Symptoms

```
state_history: revision_cycle_5 → escalated
PROGRESS.md: "spec-001 hit 5 revision cycles; escalating to human PM"
Item status: ESCALATED (hard gate failed)
```

### Meaning

Item has gone through revision cycle 5 (max). Reviewers still finding blockers. Suggests:
1. Spec was too unclear from the start
2. Architecture has fundamental flaw
3. Reviewer bar is too high (expecting perfection)

### Recovery Procedure

**Step 1: Analyze the blockers**

Read state_history for cycle 5:
```json
{
  "timestamp": "2026-06-15T20:00:00Z",
  "from_state": "under_review",
  "to_state": "needs_revision",
  "reason": "Reviewers found blockers in cycle 5",
  "details": {
    "cycle_number": 5,
    "blockers": [
      {
        "reviewer": "data-model-reviewer",
        "issue": "Table schema still missing company_id for isolation"
      },
      {
        "reviewer": "security-architect",
        "issue": "No mention of how to rotate encryption keys"
      }
    ]
  }
}
```

**Step 2: Classify the issue**

Is this:
- **Same blocker repeated?** (e.g., "missing company_id" mentioned in cycles 1, 2, 3, 4, 5)
  - Root cause: Author isn't actually fixing it, or explanation unclear
- **New blocker in each cycle?** (different issues each time)
  - Root cause: Spec is fundamentally unclear or architecture flawed
- **Reviewer nitpicking?** (minor style issues, not real blockers)
  - Root cause: Reviewer bar too high; needs relaxation

**Step 3: PM Decision**

PM now has 3 options:

**Option A: Reject and Redesign**
- Issue: Architecture fundamentally flawed
- Action: Send spec back for redesign (not incrementalfix)
- Timeline: May require 1-2 weeks redesign
- Risk: Major delay
- Example: "User auth flow has fundamental security flaw; redesign needed"

**Option B: Defer Remaining Blockers**
- Issue: Blockers are nice-to-haves, not critical
- Action: Allow spec to pass with "known issues" doc
- Timeline: Ship now; fix in v1.1
- Risk: Technical debt incurred
- Example: "Key rotation workflow is nice-to-have; defer to v1.1"

**Option C: Escalate to Committee**
- Issue: Unclear if problem is spec or reviewer
- Action: Governance committee reviews blocker + spec
- Timeline: 1 week committee review
- Risk: Delay, but could unblock if reviewer bar wrong
- Example: "Committee: Is this blocker real or over-engineering?"

**Step 4: Implement Decision**

If **A (Reject):**
```markdown
state_history: escalated → not_started (restart)
PROGRESS.md: "spec-001 escalated; rejected for redesign. Restarting Phase 2 with new architecture."
```

If **B (Defer):**
```markdown
state_history: escalated → passing_with_conditions
evidence: spec-001.md + known-issues.md (list deferred issues for v1.1)
PROGRESS.md: "spec-001 passed with deferred issues (see known-issues.md). Ship as-is."
```

If **C (Committee):**
```markdown
state_history: escalated → committee_review
PROGRESS.md: "spec-001 sent to governance committee for review. Awaiting decision (expected 2026-06-20)."
```

### Prevention

- **Cycle 1-2:** Clarify spec, get early feedback from reviewers
- **Cycle 3:** If still many blockers, consider redesign (don't wait until cycle 5)
- **Cycle 4:** Hard decision needed: pass with conditions, or redesign?
- **Cycle 5:** Should never reach this if process working well

### Escalation

State is already escalated. Framework has transferred decision to human PM. PM now decides using Option A/B/C above.

---

## ERROR 8: Cascading Failures (Multiple Agents Fail)

### Symptoms

```
All agents in a phase fail simultaneously:
  - spec-author: timeout
  - data-model-reviewer: invalid output
  - architecture-reviewer: timeout
  - ... (everyone failed)

state_history shows: agent_timeout, agent_timeout, agent_invalid_output, ...
PROGRESS.md: "Multiple agent failures; possible system-wide issue"
```

### Root Causes

1. **Claude API down:** All Claude agents fail
2. **GitHub down:** All agents depending on GitHub fail
3. **Cascading timeout:** Agent 1 times out, blocking Agent 2, which times out, etc.
4. **Memory issue:** System running out of memory, killing agents

### Recovery Procedure

**Step 1: Check system status**

```bash
# Check if Claude API is down
curl https://api.openai.com/v1/models
# If fails: Claude API is down (check OpenAI status page)

# Check if GitHub is down
curl https://api.github.com/status
# If fails: GitHub is down (wait for recovery)

# Check system resources
free -h        # Memory usage
df -h          # Disk space
```

**Step 2: Determine scope**

Is this:
- **Local issue?** (only our project failing)
  - Probably our system (network, creds, local issue)
- **Wide issue?** (multiple projects failing)
  - Probably external (Claude API down, GitHub down)

**Step 3: Wait for external services to recover**

If Claude API is down:
```
Framework automatically backs off
Retries pause for 10 minutes
Check status page: https://status.openai.com
Once recovered, framework resumes automatically
```

If GitHub is down:
```
Framework automatically backs off
Wait for GitHub status page to show "All Systems Operational"
Once recovered, framework resumes automatically
```

**Step 4: Manual escalation if internal issue**

If system is up but agents still failing:
```
Contact: infrastructure-reviewer + framework-architect
Provide: 
  - State history showing all failures
  - timestamps of failures (all at same time?)
  - system resource logs
  
Action:
  - Check git credentials (expired token?)
  - Check Claude API credentials (expired key?)
  - Check network connectivity
  - Check firewall rules
```

**Step 5: If unsolvable, escalate**

If cannot determine cause:
```
PM decision: Pause all phases until external services recover
Option: Manually complete work (developers write specs directly, bypass agents)
Option: Schedule for tomorrow when hopefully issue resolved
```

### Prevention

- Monitor external services (GitHub status, Claude API status)
- Batch important work for times when services are stable
- Don't start major phase at service deployment window (usually Tue/Wed evening)

### Escalation

Contact: infrastructure-reviewer + PM + framework-architect  
Decision: Hold or retry? External service issue or local? How long to wait?

---

## Quick Reference: Error Categorization

| Error | Severity | Retry | Escalate | Typical Recovery Time |
|---|---|---|---|---|
| Git commit fails | Medium | Yes (3x) | Yes | 5-30 min |
| Git push fails | Medium | Yes (4x backoff) | Yes | 30 min - 2 hours |
| Agent timeout | High | Auto (fallback) | Yes | 2-4 hours |
| Invalid output | Medium | Yes (3x) | Yes | 15-60 min |
| Lock conflict | Low | No (manual resolution) | No | 5-15 min |
| Network timeout | Low | Yes (backoff) | Yes | 1-30 min |
| Revision cycle 5 | High | No (design decision) | Yes | 1-7 days |
| Cascading failures | Critical | Auto (backoff) | Yes | 15 min - 8 hours |

---

**End of Error Recovery Runbook**
