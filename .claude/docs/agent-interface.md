# Agent Interface Specification — Contract for Interchangeable Agents

**Purpose:** Define input/output contracts so agents can be swapped without breaking orchestration.

**Version:** 1.0  
**Last Updated:** 2026-06-11

---

## Overview

Every agent (Claude, human, executor) must follow this interface contract:
- Same input schema (all agents receive same briefing format)
- Same output schema (all agents return same JSON structure)
- Same error handling (timeouts, crashes, invalid output)

This enables **agent interchangeability**: swap Claude for human, or one reviewer for another, without code changes.

---

## Core Interface Contract

### Input Schema

Every agent receives:
```json
{
  "project": "<project-name>",
  "phase": "02-spec",
  "work_item": {
    "id": "spec-001",
    "title": "Data Model Specification",
    "description": "..."
  },
  "brief": {
    "task": "Review data model specification for ACID compliance, constraint validation, multi-tenancy isolation",
    "deliverable": "findings.md with blockers, majors, minors categorized",
    "deadline": "2026-06-15T15:00:00Z"
  },
  "context": {
    "phase": "02-spec",
    "profile": "standard",
    "applicable_adrs": ["adr-001", "adr-003"],
    "prior_deliverables": ["01-define/product-definition.md"],
    "constraints": [
      "Compliance requirement (if applicable)",
      "Critical path (if applicable)",
      "Multi-tenant isolation (if applicable)"
    ]
  }
}
```

### Output Schema (All Agents)

Every agent must return:
```json
{
  "status": "success",
  "deliverables": [
    "path/to/findings.md"
  ],
  "session_log": "path/to/session/log.md",
  "error": null,
  "duration_seconds": 1200,
  "tokens_used": 3456,
  "summary": "5 blockers found: missing company_id, no encryption for PII, api versioning unclear"
}
```

### Required Fields

| Field | Type | Required | Description | Example |
|---|---|---|---|---|
| **status** | enum | Yes | success \| partial \| failed | "success" |
| **deliverables** | array | Yes | File paths created by agent | ["findings.md"] |
| **session_log** | string | Yes | Path to session log (for debugging) | ".claude/logs/spec-001-session.md" |
| **error** | string \| null | Yes | Error message if status != success | null or "Agent timeout" |
| **duration_seconds** | number | Yes | Time spent (in seconds) | 1200 |
| **tokens_used** | number | Yes | API tokens consumed (if applicable) | 3456 |
| **summary** | string | Yes | One-line summary of what agent did | "5 blockers found" |

### Timeout Specification

- **Timeout:** 4 hours (14400 seconds) by default
- **Per agent:** Can override if specialist needs more time
- **Fallback:** If timeout exceeded, escalate to fallback agent
- **Retry:** After timeout, can retry once before escalation

---

## Agent Types & Roles

### Type 1: Producer Agents

**Role:** Create deliverables (specs, code, designs)

**Input:** Brief + context  
**Output:** Deliverable files (spec.md, code.py, etc.) + session log

**Example:** spec-author

```json
{
  "role": "Produce Phase 2 specification",
  "input": {
    "brief": "Write data model spec for receipt table, order table, customer table. Include schema, constraints, indexes, rationale.",
    "context": { "phase": "02-spec", "constraints": ["PCI-DSS", "ACID required"] }
  },
  "output": {
    "status": "success",
    "deliverables": ["02-spec/data-model.md"],
    "session_log": ".claude/logs/spec-author-02-spec-session.md"
  }
}
```

### Type 2: Reviewer Agents

**Role:** Review deliverables; find blockers/majors/minors

**Input:** Brief + deliverable to review  
**Output:** Findings (blockers, majors, minors) + session log

**Example:** data-model-reviewer

```json
{
  "role": "Review database schema",
  "input": {
    "brief": "Review 02-spec/data-model.md. Check: ACID compliance, constraint validation, multi-tenancy isolation, PCI-DSS compliance.",
    "context": { "phase": "02-spec", "constraints": ["Finance-critical", "PCI-DSS"] }
  },
  "output": {
    "status": "success",
    "deliverables": ["findings/spec-001-findings.md"],
    "summary": "5 blockers: missing company_id, no PII encryption, ..."
  }
}
```

### Type 3: Executor Agents

**Role:** Execute operations (git, build, deploy)

**Input:** Brief + context  
**Output:** Execution results + session log

**Example:** git-author

```json
{
  "role": "Git commit and push",
  "input": {
    "brief": "git commit -m 'docs(spec-001): Add data model spec'; git push origin feature/spec-001",
    "context": { "project": "tallybite", "branch": "feature/spec-001" }
  },
  "output": {
    "status": "success",
    "summary": "Committed a1b2c3d; pushed to origin/feature/spec-001",
    "duration_seconds": 30
  }
}
```

---

## Interchangeability Rules

### Two agents are interchangeable if:

1. ✅ **Same role** (both producer, both reviewer, or both executor)
2. ✅ **Same input schema** (accept same brief format)
3. ✅ **Same output schema** (return findings in same format)
4. ✅ **Same specialization domain** (both understand databases, OR both understand security)

### Example: Interchangeable

```
data-model-reviewer (Claude) ↔ human-dba (Expert)
- Both roles: Reviewer
- Both input: Review data model spec
- Both output: Findings with blockers
- Both specialization: Database schema
→ INTERCHANGEABLE
```

### Example: NOT Interchangeable

```
spec-author (Producer) ↔ data-model-reviewer (Reviewer)
- Different roles: One produces, one reviews
- Different input: One writes spec, one reviews spec
- Different output: One returns deliverable, one returns findings
→ NOT INTERCHANGEABLE
```

---

## Fallback Strategy

### When Agent Fails

If primary agent fails (timeout, crash, invalid output):

1. **Detect failure:** Agent returns error status or doesn't respond after timeout
2. **Check fallback list:** Look up fallback_agents in agent registry
3. **Dispatch fallback:** Send same task to first fallback agent
4. **Log substitution:** Record in state_history which agent was used

**Example:**

```json
{
  "primary_agent": "data-model-reviewer (Claude)",
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
| **success** | Agent completed task successfully | No action needed |
| **partial** | Agent completed most of task; some issues | Review what's incomplete; manual fix or escalate |
| **failed** | Agent failed; no usable output | Retry or escalate to fallback |
| **timeout** | Agent didn't respond within deadline | Activate fallback |
| **error** | Agent crashed or errored | Check error message; activate fallback |

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

NOT:
```
Exception: MemoryError: ...
Traceback: ...
```

### Validation

Framework validates output schema after agent returns:

```python
def validate_agent_output(agent_id, output, expected_schema):
    required_fields = ["status", "deliverables", "session_log", "error", "duration_seconds", "tokens_used"]
    
    for field in required_fields:
        if field not in output:
            return False, f"Missing required field: {field}"
    
    if output["status"] not in ["success", "partial", "failed", "timeout", "error"]:
        return False, f"Invalid status: {output['status']}"
    
    if not isinstance(output["deliverables"], list):
        return False, f"deliverables must be list, got {type(output['deliverables'])}"
    
    return True, "Valid"
```

---

## Substitution Logic

### How to Swap Agents in PM Loop

**Scenario:** data-model-reviewer is unavailable; use human-dba instead

**Before:** (Hard-coded)
```python
dispatch_agent("data-model-reviewer", task)
```

**After:** (Agent-aware)
```python
agent_registry = load_registry("agent-registry.json")
primary_agent = agent_registry["data-model-reviewer"]

result = dispatch_agent(primary_agent, task)

if result["status"] != "success":
    # Activate fallback
    for fallback in primary_agent["fallback_agents"]:
        result = dispatch_agent(fallback, task)
        if result["status"] == "success":
            break
```

### Registry-Driven Dispatch

All agent info stored in `agent-registry.json`:
- Who is primary? → dispatch_agent(primary)
- Who is fallback? → dispatch_agent(fallback) if primary fails
- What schema? → validate output against schema
- What timeout? → use agent-specific timeout

No code changes needed to swap agents. Just update registry.

---

## Service Level Agreement (SLA)

### Per Agent Type

| Agent Type | Timeout | Availability | Fallback | SLA |
|---|---|---|---|---|
| **Claude (producer)** | 4 hours | 99.9% | human-expert | 99.9% uptime |
| **Claude (reviewer)** | 4 hours | 99.9% | human-reviewer | 99.9% uptime |
| **Human reviewer** | 24 hours | 95% (shared) | None (escalate) | Best effort |
| **Executor (git)** | 30 seconds | 99.5% | Retry + escalate | 99.5% uptime |

### Downtime Handling

If agent unavailable >4 hours:
```
state_history: agent_unavailable → escalated
PROGRESS.md: "data-model-reviewer unavailable; escalating to governance committee for decision"
Options:
  1. Wait for agent (risk: delay)
  2. Use fallback (if available; cost: higher)
  3. Skip review (risk: bugs; only if PM approves)
  4. Escalate to committee (decision: defer item or find alternative)
```

---

## Examples: Interchangeable Agents

### Example 1: Claude → Human (Reviewer Swap)

**Primary:** Claude data-model-reviewer  
**Fallback:** human-dba (on-call expert)

**Scenario:**
```
09:00 - Dispatch data-model-reviewer (Claude) for spec-001 review
13:05 - Timeout: Claude didn't respond after 4 hours
13:10 - Fallback activated: human-dba notified
13:15 - human-dba accepts task; starts review
14:30 - human-dba completes review; findings submitted
        (Slight delay, but review completed)
```

Both return:
```json
{
  "status": "success",
  "deliverables": ["findings/spec-001-findings.md"],
  "summary": "5 blockers found: ..."
}
```

### Example 2: Claude → Cheaper Claude Variant (Cost Optimization)

**Primary:** Claude Opus (expensive, most capable)  
**Fallback:** Claude Haiku (cheap, faster)

**Scenario:**
```
09:00 - Dispatch security-architect (Opus) for threat modeling
        Cost: $12 per review
        Expected quality: Highest
        Timeout: 2 hours
        
OR use Haiku variant:
09:00 - Dispatch security-architect-haiku (Haiku variant)
        Cost: $3 per review
        Expected quality: Good
        Timeout: 1 hour
        Fallback: Upgrade to Opus if quality insufficient
```

### Example 3: Agent Upgrade (Version 1 → Version 2)

**Current:** api-contract-reviewer v1 (finds ~8 blockers per review)  
**New:** api-contract-reviewer v2 (better prompt; finds ~10 blockers per review)

**Migration:**
```
Profile v1.0: Uses api-contract-reviewer v1
Profile v1.1: Uses api-contract-reviewer v2

For new projects:
  - Start with v1.1 (better reviewer)

For existing projects:
  - Optionally upgrade (re-review Phase 2 with v2)
  - Or stay on v1.0 (no change needed)
```

---

## Agent Lifecycle

### Development

1. **Specification:** Define agent interface (input, output, timeout)
2. **Implementation:** Code agent implementation (Claude prompt or human procedure)
3. **Testing:** Verify output matches schema; verify fallback works
4. **Registration:** Add to agent-registry.json
5. **Deployment:** Deploy with governance profile

### Operation

1. **Dispatch:** PM loop dispatches agent for task
2. **Execution:** Agent completes work; returns output
3. **Validation:** Framework validates output schema
4. **Logging:** Log to state_history + PROGRESS.md
5. **Archival:** Commit session log to git for audit trail

### Evolution

1. **Monitoring:** Track agent performance (speed, quality, cost)
2. **Feedback:** Collect findings from reviewers who use agent output
3. **Improvement:** Refine agent (better prompt, clearer spec)
4. **Version bump:** Create v2 agent with improvements
5. **Migration:** Gradually move projects to v2 (backward compatible)

---

## Testing Interchangeability

### Test Procedure

**Hypothesis:** Agent A and Agent B are interchangeable

**Setup:**
1. Define test task (review a spec, write a document)
2. Create test data (same input to both agents)
3. Define success criteria (output schema matches, findings reasonable)

**Execution:**
```
Run 1: Dispatch Agent A
  Input: Same test task
  Output: Findings from Agent A
  
Run 2: Dispatch Agent B
  Input: Same test task  
  Output: Findings from Agent B
```

**Validation:**
```
Check 1: Both outputs match schema ✓
Check 2: Both findings reasonable (not wildly different) ✓
Check 3: Quality similar (Agent A finds 8 blockers, Agent B finds 7) ✓
Check 4: Time similar (Agent A takes 1 hour, Agent B takes 1.5 hours) ✓
Conclusion: INTERCHANGEABLE ✓
```

**If not interchangeable:**
- Find specific differences
- Document why they're not swappable
- Use only one in fallback chain

---

**End of Agent Interface Specification**
