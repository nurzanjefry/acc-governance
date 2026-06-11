# Error Recovery: Agent Errors

**Index:** See `error-recovery-runbook.md` for the full error categorization table.

---

## ERROR 3: Agent Timeout (Reviewer Not Responding)

### Symptoms

```
state_history: under_review → (4 hours pass)
PROGRESS.md: "data-model-reviewer timeout exceeded"
```

### Root Causes

1. Agent overloaded (many tasks queued)
2. Agent crashed (Claude or human reviewer unavailable)
3. Network issue (task lost or response lost)
4. Human reviewer away

### Recovery

**Step 1:** Check `state_history` for timeout entry — confirms which reviewer timed out.

**Step 2:** Framework auto-activates fallback:
- Looks up `fallback_agents` in agent registry
- Dispatches human-dba (or configured fallback) with same task

**Step 3:** If fallback also times out — escalate to human PM:
- Contact reviewer: "Are you available for spec-001 review?"
- If no: find emergency reviewer or defer item

### Prevention
- Monitor reviewer availability before dispatch
- Distribute work evenly (don't batch 10 items on one reviewer in 1 day)

### Escalation

If both primary and fallback fail: contact PM + framework-architect.  
Options: skip review (risk), find emergency reviewer (cost), defer to next phase.

---

## ERROR 4: Agent Invalid Output

### Symptoms

```
state_history: agent_running → agent_invalid_output
PROGRESS.md: "spec-author returned output missing required fields"
```

Example — output missing required fields:
```json
{
  "status": "success",
  "deliverables": ["02-spec/spec-001.md"]
  // Missing: session_log, duration_seconds, tokens_used
}
```

### Root Causes

1. Agent bug (incomplete JSON returned)
2. Response truncated during transmission
3. Agent training issue (doesn't follow output contract)
4. Spec bug (output schema was ambiguous)

### Recovery

**Step 1:** Identify missing fields vs. expected output schema.

**Step 2:** Framework auto-retries up to 3 times:
- Each retry includes feedback: "Output was missing: session_log, duration_seconds, tokens_used"
- If cycle 3 still fails → activates fallback agent

**Step 3:** If fallback also fails — escalate to PM:
- Is this an agent problem (implementation bug)?
- Or a spec problem (ambiguous output contract)?
- Options: fix agent, clarify spec, assign human directly

### Prevention
- Keep output schema simple (only required fields)
- Test agent with edge cases before deployment

### Escalation

Contact: framework-architect + agent owner.  
Diagnose: agent problem vs. spec problem.

---

## ERROR 8: Cascading Failures (Multiple Agents Fail)

### Symptoms

```
All agents in a phase fail simultaneously:
  - spec-author: timeout
  - data-model-reviewer: invalid output
  - architecture-reviewer: timeout
  - ... (multiple failures)

PROGRESS.md: "Multiple agent failures; possible system-wide issue"
```

### Root Causes

1. Claude API down (all Claude agents fail)
2. GitHub down (all git-dependent agents fail)
3. Cascading timeout (Agent 1 blocks Agent 2, etc.)
4. System out of memory

### Recovery

**Step 1: Check system status**
```bash
curl https://api.github.com/status   # GitHub status
free -h && df -h                      # System resources
```

**Step 2: Determine scope**
- Local issue? (only our project) → probably creds/network/local
- Wide issue? (multiple projects) → probably external API down

**Step 3: External service down** — Framework auto-backs off.
- Claude API: check status page; retries pause for 10 minutes
- GitHub: wait for "All Systems Operational"; framework resumes automatically

**Step 4: Internal issue** — Check git credentials, Claude API key, network, firewall.

**Step 5: If unsolvable** — PM pauses all phases until external services recover.

### Prevention
- Monitor external services (GitHub status, Claude API status)
- Don't start major phases at service deployment windows (Tue/Wed evening)

### Escalation

Contact: infrastructure-reviewer + PM + framework-architect.  
Decision: Hold or retry? External or local? How long to wait?
