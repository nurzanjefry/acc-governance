# Deployment — Template

**Purpose:** Document the release procedure so any team member can deploy safely and roll back if needed.

## Sections to Include

### 1. Environment Overview
| Environment | URL | Purpose | Who Deploys |
|-------------|-----|---------|-------------|
| development | | local testing | developer |
| staging | | pre-release validation | PM / QA |
| production | | live users | Owner approval required |

### 2. Pre-Deploy Checklist
Must all be true before deploying to production.
- [ ] All tests pass (unit, integration, E2E)
- [ ] Security-reviewer approved
- [ ] Staging validation complete
- [ ] Owner has approved this release
- [ ] Database migrations reviewed
- [ ] Rollback plan confirmed

### 3. Deploy Steps
Exact commands or steps to deploy.

```
Step 1: 
Step 2: 
Step 3: 
```

### 4. Post-Deploy Verification
How to confirm the deploy succeeded.
- [ ] Check [URL] returns expected response
- [ ] Check metrics dashboard — no spike in errors
- [ ] Smoke test: [steps]

### 5. Rollback Procedure
How to revert if something goes wrong.

```
Step 1: 
Step 2: 
Step 3: 
```

**Rollback decision criteria:** Roll back if [condition] within [time window] of deploy.

### 6. Incident Runbook
What to do if production is degraded post-deploy.

| Symptom | Likely Cause | First Action |
|---------|-------------|--------------|
| | | |

**Escalation:** Contact [role] if not resolved within [time].

---

**After a successful deploy, log the release in PROGRESS.md.**
