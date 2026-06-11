# Error Recovery: Git Errors

**Index:** See `error-recovery-runbook.md` for the full error categorization table.

---

## ERROR 1: Git Commit Failed

### Symptoms

```
Error: git commit -m "docs(spec-001): Add data model"
   fatal: Not a git repository (or any of the parent directories): .git
```

### Root Causes

1. Not in git repo (working directory wrong)
2. Git config missing (user.email / user.name not set)
3. Bad file permissions on .git directory
4. Corrupted repo

### Recovery

**Step 1: Check you're in a git repo**
```bash
pwd && ls -la | grep .git   # Should show .git directory
```

**Step 2: Check git config**
```bash
git config user.email && git config user.name
# If missing: git config --global user.email "you@company.com"
```

**Step 3: Check credentials** — re-authenticate if token expired

**Step 4: Retry commit** — `git commit -m "..."`

**Step 5: Last resort**
```bash
git fsck --full   # Check for corruption
# If corrupted: fresh clone + restore working files from backup
```

### Prevention
- Run `git config --global user.email` once after system setup
- Keep auth tokens fresh (GitHub tokens expire after 1 year)

### Escalation
File issue: "Git commit failing; possible repo corruption"  
Contact: infrastructure-reviewer or framework-architect  
Provide: error message, `git status`, `git fsck` output

---

## ERROR 2: Git Push Failed

### Symptoms

```
fatal: unable to access 'https://github.com/...': Could not resolve host: github.com
```

OR

```
fatal: 'origin' does not appear to be a 'git' repository
```

### Root Causes

1. Network down (internet, firewall, DNS)
2. Auth failed (token expired or wrong credentials)
3. Upstream conflict (branch conflicts with main)
4. Remote not configured ("origin" doesn't exist)

### Recovery

**Step 1: Check network**
```bash
ping github.com && nslookup github.com
```

**Step 2: Check remote**
```bash
git remote -v
# If origin missing: git remote add origin https://github.com/YOUR_ORG/YOUR_REPO.git
```

**Step 3: Verify auth** — `git push origin feature/spec-001` (prompts for auth if needed)

**Step 4: Check conflicts**
```bash
git fetch origin
git rebase origin/main   # Resolve conflicts if any
```

**Step 5: Retry push** — `git push origin feature/spec-001`

### Auto-Retry

Framework retries with exponential backoff: 0s → 1s → 5s → 30s → escalate.

### Prevention
- Push frequently (don't let branch diverge >2 days)
- Keep auth tokens fresh

### Escalation

Manual options: rebase + retry, or contact IT for network issues.
