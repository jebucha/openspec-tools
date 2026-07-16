## Context

Currently, `opsx-audit` persists audit reports to `audits/<timestamp>-<model>.md` within each change directory. `opsx-apply-audit` reads these reports, fixes findings, but leaves the audit files untouched. There's no signal distinguishing a pending audit from a resolved one, no record of what was fixed, and no detection when resolved findings reappear after artifacts are edited outside the workflow.

**Current state:**
- `opsx-audit` (step 10): Writes audit report to `audits/`, no lifecycle awareness
- `opsx-apply-audit` (step 3): Reads any audit file, no state filtering
- `opsx-apply-audit` (step 8): Reports fixes, no persistence to audit file

**Constraints:**
- Stateless design — no external state, no database, no sidecar files
- Prepend-only mutations — original audit content must remain intact
- Backward compatible — audits without headers must still work

## Goals / Non-Goals

**Goals:**
- Provide visual signal of audit state (pending, resolved, superseded)
- Preserve resolution history inline with the audit report
- Auto-supersede older audits when new ones are created
- Detect regressions when resolved findings reappear
- Maintain backward compatibility with existing audit files

**Non-Goals:**
- Stateful lineage tracking across audit cycles
- Full audit history dashboard or querying
- Blocking on regressions — they are warnings, not errors
- Migration of existing audit files

## Decisions

### Inline headers over sidecar files

**Chosen:** Prepend resolution/supersede headers to the audit markdown file.

**Alternatives considered:**
- Sidecar `.status` files: Clean separation but adds file management overhead
- Separate `audits/archive/` directory: Loses inline context, requires directory management
- JSON metadata: Inconsistent with markdown-first workflow

**Rationale:** Single file is simpler, git-diffable, and the append-only prepend pattern preserves original content while adding lifecycle metadata.

### Stateless derived state

**Chosen:** State is derived from headers and timestamps, not stored explicitly.

**Alternatives considered:**
- Explicit `## Status: Resolved` field: Fragile, can drift from reality
- Stateful linking between audits: Complex, requires cross-file parsing

**Rationale:** Deriving state from observable properties (headers, timestamps) eliminates state drift. A newer file always supersedes older ones.

### Regression detection as warnings

**Chosen:** Regressions are flagged as Warnings in the new audit report, not Errors.

**Rationale:** The user may have intentionally reverted a fix. Warnings inform without blocking. If the user wants to block on regressions, that's a future enhancement.

### Supersede includes summary

**Chosen:** `## Superseded: <filename> (<N> errors, <N> warnings)`

**Rationale:** Provides at-a-glance context about why the audit was superseded without requiring the user to open the newer file.

## Risks / Trade-offs

| Risk | Mitigation |
|------|-----------|
| Header parsing ambiguity if audit content contains `## Resolved` | Use exact header format; parse only at file start |
| Large audit files with many stacked headers | Unlikely — typical audit cycle is 2-3 iterations |
| Regression detection false positives | Same finding ID + same description = regression; soft warning, not blocking |
| Existing audits without headers | Backward compatible — absence of header = pending state |

## Open Questions

- Should `opsx-apply-audit` allow re-applying a resolved audit if user explicitly requests it? (Currently: no, pending-only)
- Should superseded audits be hidden from `opsx-apply-audit` selection by default?
