# Agent Fallback, Error Handling & SLA

**Part of the agent interface system. See `agent-interface.md` for the core contract.**

---

## Fallback Strategy

### When an Agent Fails

If the primary agent fails (timeout, crash, invalid output):

1. Detect failure: agent returns error status or doesn't respond after timeout
2. Check fallback list from agent registry
3. Dispatch fallback: send same task to first fallback agent
4. Log substitution: record in state_history which agent was used

```json
{
  "primary_agent": "data-model-reviewer",
  "primary_status": "timeout",
  "timeout_seconds": 14400,
  "fallback_agents": ["human-dba"],
  "fallback_dispatched": true,
  "fallback_agent": "human-dba",
  "fallback_status": "success"
}
```

### Fallback Chain

```
Attempt 1: Primary agent
  ↓ (timeout/crash/invalid output)
Attempt 2: Fallback agent #1
  ↓ (timeout/crash/invalid output)
Attempt 3: Fallback agent #2
  ↓ (timeout/crash/invalid output)
Escalate: No more fallbacks → Human PM decides
```

---

## Error Handling

### Status Codes

| Status | Meaning | Recovery |
|---|---|---|
| success | Agent completed task | No action |
| partial | Completed most; some issues | Review + manual fix or escalate |
| failed | Failed; no usable output | Retry or escalate to fallback |
| timeout | No response within deadline | Activate fallback |
| error | Agent crashed | Check error message; activate fallback |

### Error Reporting

Agents must report errors in JSON, not as exceptions:

```json
{
  "status": "failed",
  "error": "Out of memory while processing large spec",
  "error_code": "OOM",
  "recovery_suggestion": "Split spec into smaller files; retry"
}
```

---

## Substitution Logic

To swap agents in the PM loop (registry-driven dispatch — forward-looking):

```python
# Agent-aware dispatch
primary_agent = agent_registry["data-model-reviewer"]
result = dispatch_agent(primary_agent, task)
if result["status"] != "success":
    for fallback in primary_agent["fallback_agents"]:
        result = dispatch_agent(fallback, task)
        if result["status"] == "success":
            break
```

No code changes needed to swap agents — update the registry only.

---

## Service Level Agreement (SLA)

| Agent Type | Timeout | Fallback | SLA |
|---|---|---|---|
| Claude (producer) | 4 hours | human-expert | 99.9% uptime |
| Claude (reviewer) | 4 hours | human-reviewer | 99.9% uptime |
| Human reviewer | 24 hours | Escalate | Best effort |
| Executor (git) | 30 seconds | Retry + escalate | 99.5% uptime |

**If agent unavailable >4 hours:** Options: wait, use fallback, skip review (PM approval required), or escalate to governance committee.
