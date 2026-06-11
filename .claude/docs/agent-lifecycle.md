# Agent Lifecycle & Interchangeability

**Part of the agent interface system. See `agent-interface.md` for the core contract, `agent-fallback.md` for fallback and error handling.**

---

## Agent Lifecycle

### Development
1. Specification: define agent interface (input, output, timeout)
2. Implementation: code agent implementation (Claude prompt or human procedure)
3. Testing: verify output matches schema; verify fallback works
4. Registration: add to agent-registry.json (forward-looking)
5. Deployment: deploy with governance profile

### Operation
1. Dispatch: PM loop dispatches agent for task
2. Execution: agent completes work; returns output
3. Validation: framework validates output schema
4. Logging: log to state_history + PROGRESS.md
5. Archival: commit session log to git for audit trail

### Evolution
1. Monitoring: track agent performance (speed, quality, cost)
2. Feedback: collect findings from reviewers who use agent output
3. Improvement: refine agent (better prompt, clearer spec)
4. Version bump: create v2 agent with improvements
5. Migration: gradually move projects to v2 (backward compatible)

---

## Interchangeability Examples

### Example 1: Claude → Human (Reviewer Swap)

```
09:00 - Dispatch data-model-reviewer (Claude)
13:05 - Timeout: no response after 4 hours
13:10 - Fallback: human-dba notified
14:30 - human-dba completes review; findings submitted
```

Both return the same output schema — the PM loop doesn't change.

### Example 2: Cost Optimization (Opus → Haiku)

Primary: security-architect (Opus) — $12/review, highest quality  
Fallback: security-architect-haiku (Haiku) — $3/review, good quality  
PM selects based on phase risk profile.

### Example 3: Version Upgrade (v1 → v2)

```
Profile v1.0: Uses api-contract-reviewer v1 (~8 blockers per review)
Profile v1.1: Uses api-contract-reviewer v2 (~10 blockers per review)
```

Existing projects stay on v1.0. New projects start with v1.1. Optional upgrade path.

---

## Testing Interchangeability

**To verify Agent A and Agent B are interchangeable:**

1. Define test task (same input to both)
2. Run Agent A — capture output
3. Run Agent B — capture output
4. Check: both outputs match schema, findings are reasonable, quality is similar, time is similar

**If not interchangeable:** document why they can't be swapped and exclude from fallback chain.
