## 1. Audit resolution header (opsx-apply-audit)

- [x] 1.1 Add resolution header generation logic to `opsx-apply-audit` step 8 — format: `## Resolved`, `## Resolver`, `## Model`, `## Status`, resolved/deferred findings lists
- [x] 1.2 Implement prepend logic to write resolution header to audit file, preserving original content below `---` separator
- [x] 1.3 Update `opsx-apply-audit` step 3 to filter audits by state — prefer Pending, skip Resolved/Superseded, prompt user when no pending audits exist

## 2. Auto-supersede (opsx-audit)

- [x] 2.1 Add supersede logic to `opsx-audit` step 10 — scan `audits/` for existing files older than the new audit, prepend `## Superseded` header with filename and summary
- [x] 2.2 Implement header stacking — prepend new supersede header before any existing headers (resolved, superseded) to preserve lifecycle chain
- [x] 2.3 Parse audit summary from new report (error/warning counts) for inclusion in supersede header

## 3. Regression detection (opsx-audit)

- [x] 3.1 Add regression detection to `opsx-audit` step 9 — parse resolved findings from existing resolved audits, compare against new findings by ID
- [x] 3.2 Generate "Regressions" section in audit report when matches are found, with finding ID, description, and reference to resolved audit file
- [x] 3.3 Ensure regressions are classified as Warning severity, not Error

## 4. State derivation and backward compatibility

- [x] 4.1 Implement state derivation logic — Pending (no header, no newer file), Resolved (has header, no newer file), Superseded (has supersede header)
- [x] 4.2 Ensure legacy audits without headers are treated as Pending and function correctly with all commands
- [x] 4.3 Verify header parsing doesn't interfere with audit report content — parse only at file start, use exact header format

## 5. Documentation updates

- [x] 5.1 Update `opsx-audit` skill documentation — describe supersede behavior, regression detection, and state derivation
- [x] 5.2 Update `opsx-apply-audit` skill documentation — describe resolution header writing, pending-state requirement, and audit selection behavior
