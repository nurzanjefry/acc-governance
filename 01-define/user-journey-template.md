# User Journey — Template

**Purpose:** Document the step-by-step flow from initial user action to desired outcome.

## Structure

For each primary user role, document a **happy path** and at least one **error case**.

### Happy Path: [Role Name]

| Step | Actor | Action | System Response |
|---|---|---|---|
| 1 | User | [describes initial action] | [system shows/does what?] |
| 2 | User | [next action] | [system shows/does what?] |
| 3 | User | [concluding action] | [desired outcome] |

### Error Case: [What Goes Wrong?]

| Step | Actor | Action | System Response |
|---|---|---|---|
| 1 | User | [tries action X] | [system rejects or falls back to] |
| 2 | User | [recovery action] | [system helps user recover] |

---

## Questions to Answer

- How many primary user journeys? (List them)
- Which is most critical? (Test that first)
- What's the happy path? (Main flow, no detours)
- What breaks? (Network down? Bad input? Missing permissions?)
- How do users recover from errors? (Retry? Escalate? Contact support?)

**After completing this, move to roles-and-permissions.md to define who can do what.**
