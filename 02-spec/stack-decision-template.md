# Technology Stack — Template

**Purpose:** Document why you chose each technology layer.

## Technology Choices

For each layer, document the choice and rationale.

| Layer | Technology | Why This? | Alternatives Considered |
|---|---|---|---|
| Frontend | [e.g., React] | [rationale] | [alternatives] |
| Backend | [e.g., Node.js] | [rationale] | [alternatives] |
| Database | [e.g., PostgreSQL] | [rationale] | [alternatives] |
| Storage | [e.g., S3] | [rationale] | [alternatives] |
| Deployment | [e.g., Docker] | [rationale] | [alternatives] |

## Constraints

What constraints drove your choices?
- Performance: [target latency, throughput]
- Scale: [expected users, requests/sec]
- Cost: [budget, per-user economics]
- Compliance: [regulations, audit requirements]
- Team: [language expertise, tooling familiarity]

## System Architecture (ASCII Diagram)

```
[Client] → [API Gateway] → [Backend] → [Database]
   ↓                                        ↓
[Cache]                                [Logs]
```

---

**After documenting stack choices, move to data-model.md to design your schema.**
