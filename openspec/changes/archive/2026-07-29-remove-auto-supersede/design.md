## Design Decisions

### Remove auto-supersede from both skills

**Decision:** Delete step 11a/11b from `opsx-audit` and step 12a from `opsx-validate`.

**Rationale:** Auto-supersede assumes sequential re-audits (fix → re-check). The peer-review workflow (run with multiple models → compare → choose) is equally valid. Removing supersede supports both:
- Sequential: user runs audit, applies fixes, runs again — both reports are Pending, apply-audit picks the latest
- Peer-review: user runs with 3 models — all 3 are Pending, apply-audit lists all 3 for selection

### State model simplification

**Before:** 3 states — Pending, Resolved, Superseded
**After:** 2 states — Pending, Resolved

```
Before:                          After:
┌──────────┐                     ┌──────────┐
│ Pending  │                     │ Pending  │
│ (default)│                     │ (default)│
└────┬─────┘                     └────┬─────┘
     │                                │
     │ opsx-apply-audit               │ opsx-apply-audit
     │ resolves findings              │ resolves findings
     ▼                                ▼
┌──────────┐                     ┌──────────┐
│ Resolved │                     │ Resolved │
└──────────┘                     └──────────┘

┌──────────┐
│ Superseded│  ← REMOVED
│ (auto on  │
│ new audit)│
└──────────┘
```

### Impact on apply-audit

The `opsx-apply-audit` skill already handles multiple Pending audits:
> "If multiple Pending audits exist, list them with timestamp, model, and summary... let the user select"

No change needed to the core selection logic. Only the state derivation needs updating:
- Remove "Superseded" from the state derivation rules in step 3a
- Remove the "no pending audits" message that fires when all audits are Superseded

### Files to modify

**Skill files (1 copy each):**

| Skill | Location |
|-------|----------|
| `openspec-audit-change/SKILL.md` | `skills/` |
| `openspec-validate-change/SKILL.md` | `skills/` |
| `openspec-apply-audit/SKILL.md` | `skills/` |

**Main specs (2 files):**

| Spec | Path |
|------|------|
| `audit-lifecycle/spec.md` | `openspec/specs/audit-lifecycle/spec.md` |
| `validate-change/spec.md` | `openspec/specs/validate-change/spec.md` |

**Delta specs:**
- `specs/audit-lifecycle/spec.md` in the change directory

### Changes per file

**`opsx-audit` skill:**
- Remove step 11a (auto-supersede older audit files)
- Remove step 11b (header stacking)
- Update guardrails: remove "Supersede is timestamp-based" and "Header parsing is position-sensitive" guardrails that reference Superseded
- Update step 12 follow-up to remove supersede-related language

**`opsx-validate` skill:**
- Remove step 12a (auto-supersede older validation files)
- Update guardrails: remove "Supersede is timestamp-based" and "Header parsing is position-sensitive" guardrails that reference Superseded

**`opsx-apply-audit` skill:**
- Step 3a: Remove "Superseded" from state derivation — only Pending and Resolved remain
- Step 3a: Update "no pending audits" message — only mention Resolved, not Superseded
- Guardrails: Remove "Audit state is derived" guardrail reference to Superseded
- Guardrails: Update "Header parsing is position-sensitive" to reference only Resolved

**`audit-lifecycle/spec.md` (main):**
- Remove "Auto-supersede older audits" requirement and its scenarios
- Update "Audit state derived from headers" — remove Superseded scenario, simplify to Pending/Resolved
- Update "Apply-audit requires pending state" — remove Superseded references
- Update "Validation reports follow audit lifecycle" — remove validation supersede scenarios
- Update "Backward compatibility" — remove Superseded from legacy audit scenario

**`validate-change/spec.md` (main):**
- Remove "Older validations are superseded" scenario from the "Validation report is persisted" requirement
