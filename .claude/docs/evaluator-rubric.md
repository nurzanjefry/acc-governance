# Evaluator rubric — human approval gate

Applied at the **human approval gate** (Step 7 of orchestration protocol), after automated reviewers reach `PASS` or hit the revision-round cap. PM fills the scorecard from producer output + reviewer findings + verification evidence; **the Owner sets the final verdict.**

Score each dimension **0–2**: `0` = absent/failing, `1` = partial, `2` = solid.

| Dimension | Question (docs phase → build phase) | Score | Notes |
|---|---|---|---|
| **Correctness** | Does the output match the request and the 9-step flow / the spec it implements? | | |
| **Verification** | Was "done" actually demonstrated? Docs: exit criteria met, reviewers PASS, cross-refs resolve. Build: tests/commands ran with recorded evidence. | | |
| **Scope discipline** | Did it stay inside the phase folder and the defined scope — no drift, no leakage? | | |
| **Reliability** | Does it hold up on reread/rerun without repair? Docs: no dangling refs/placeholders. Build: survives restart. | | |
| **Maintainability** | Glossary-correct, clear, ADRs recorded — legible to the next agent? | | |
| **Handoff** | Can a fresh session continue from artifacts alone (`PROGRESS.md` + `work-list.json` updated)? | | |

**Total: __ / 12**

## Verdict (→ gate action)

- **Accept** — output is final; advance to the next item/phase.
- **Request changes** — feed the gaps back into the revision loop.
- **Reject** — discard and restart the producer from scratch.

Guidelines:
- Any dimension at `0` → **not** Accept.
- **Verification at `0` is an automatic Request changes/Reject** regardless of total — a passing automated review is not the same as demonstrated work.

## Required follow-up
- Missing evidence:
- Required fixes:
- Next review trigger:

---

**PM:** After Owner decides, write a DECISION record to `logs/<item-id>.md`. See `.claude/docs/log-format.md`.
