# Roles & Permissions — Template

**Purpose:** Define who can do what in your system.

## User Roles

List each role with responsibilities and constraints.

| Role | Responsibilities | Can Do | Cannot Do |
|---|---|---|---|
| Role 1 | [list] | [list actions] | [list restrictions] |
| Role 2 | [list] | [list actions] | [list restrictions] |

## Permission Matrix

Cross-reference roles against key actions to ensure no gaps.

| Action | Role 1 | Role 2 | Role 3 | Notes |
|---|---|---|---|---|
| Create item | ✓ | ✗ | ✓ | Only owner/admin |
| View item | ✓ | ✓ | ✓ | All roles |
| Delete item | ✓ | ✗ | ✗ | Admin only |

## Data Isolation

Which data can each role see?
- Role 1: [scoping rules]
- Role 2: [scoping rules]

## Multi-Role Scenarios

Can a user have multiple roles? How are permissions combined?

---

**Note:** If your project has no roles, keep it simple (single user or all users equal).

After completing this, move to Phase 2 specs (stack.md, data-model.md, etc.).
