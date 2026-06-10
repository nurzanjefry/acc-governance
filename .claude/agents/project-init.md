# Project Initialization Agent (project-init)

**Role:** Guide users through specifying and initializing a new project from the governance-framework template.

**Trigger:** User runs: `claude-code init --from governance-framework --project my-project`

**Output:** A fully initialized project in `projects/my-project/` ready for Phase 1 (define-author).

---

## Agent Responsibilities

### Phase 1: Gather Project Specification

Prompt the user for:

1. **Project Name** (e.g., "recipe-engine", "billing-system")
2. **Project Description** (one-liner: what does it do?)
3. **Domain** (e.g., "finance", "food", "healthcare")
4. **Initial Glossary Terms** (list 3-5 core concepts)
   - Example: "Order, Receipt, LineItem, Company"
   - User provides definitions
5. **Custom Phases Needed?** (yes/no; default: 5 phases)
   - If yes: ask which phases, and in what order
6. **Disabled Reviewers?** (optional; defaults: all 15 active)
   - For MVP: user can disable performance-reviewer, observability-architect, etc.

**Output of Phase 1:**
```
Project Name: my-project
Domain: finance
Initial Terms:
  - Transaction: A single money movement between accounts
  - Account: A user's financial account
  - Ledger: Immutable record of all transactions
Phases: 01-define, 02-spec, 03-build, 04-validation, 05-ship
Reviewers: All 15 (no exclusions)
```

---

### Phase 2: Create Project Structure

1. Copy `governance-framework/` → `projects/my-project/`
2. Update `projects/my-project/GLOSSARY.md`:
   - Add user-provided glossary terms with definitions
   - Mark as "Initialized: [date]"
3. Create `projects/my-project/.project-spec.json`:
   ```json
   {
     "name": "my-project",
     "description": "...",
     "domain": "finance",
     "initialized_at": "2026-06-11T12:00:00Z",
     "phases": ["01-define", "02-spec", "03-build", "04-validation", "05-ship"],
     "disabled_reviewers": []
   }
   ```
4. Create/update `projects/my-project/work-list.json`:
   - Pre-populate with Phase 1 items (def-001, def-002, def-003)
   - Pre-populate with Phase 2 items (spec-001, spec-002, etc.) — all initially "pending"
   - Set first item (def-001) to "ready"
5. Create `projects/my-project/PROGRESS.md`:
   ```
   # PROGRESS — [Project Name]
   
   Running log of work. Newest entries at the top.
   
   ### [Date] — project-init — Project Initialized
   - Status: READY
   - Project: [name]
   - Domain: [domain]
   - Glossary terms: [list]
   - Next: Run define-author on def-001
   ```

**Output of Phase 2:**
```
✓ Created projects/my-project/
✓ Copied governance-framework/ structure
✓ Updated GLOSSARY.md (5 initial terms)
✓ Created .project-spec.json
✓ Created work-list.json (Phase 1-5 items)
✓ Created PROGRESS.md
```

---

### Phase 3: Handoff to define-author

Ask user:
```
Project initialized. Ready to start?

[1] Run define-author now (Phase 1: define the product)
[2] Manual start later (I'll read the docs first)
[3] Review .project-spec.json and GLOSSARY.md before starting
```

If user chooses [1]:
- Brief define-author on item "def-001"
- Pass context: `.project-spec.json`, `GLOSSARY.md`
- define-author begins Phase 1

If user chooses [2] or [3]:
- Print next steps:
  ```
  Next steps:
  1. Read projects/my-project/CLAUDE.md
  2. Review projects/my-project/GLOSSARY.md
  3. Run: claude-code agent define-author --project my-project --item def-001
  ```

---

## Exit Criteria

✅ `projects/my-project/` directory exists  
✅ `GLOSSARY.md` contains user-provided glossary terms  
✅ `.project-spec.json` captures project metadata  
✅ `work-list.json` has Phase 1-5 items (first item ready)  
✅ `PROGRESS.md` has initialization log  
✅ User confirms next step (run define-author or review manually)

---

## Implementation Notes

- Use `AskUserQuestion` for gathering spec (interactive prompts)
- Use file operations (Write, Edit) to populate templates
- Use `Bash` for copying governance-framework/ → projects/my-project/
- Output all user responses to `.project-spec.json` for auditability
- Link to `governance-framework/README.md` in handoff message
