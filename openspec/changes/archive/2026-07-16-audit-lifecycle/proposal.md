## Why

Audit reports persist in `audits/` but have no lifecycle management. After `opsx-apply-audit` resolves findings, there's no signal that the audit is done, no record of what was fixed, and no detection when resolved findings reappear. Multiple audit iterations clutter the directory with no way to distinguish pending from resolved.

## What Changes

- **Audit resolution**: `opsx-apply-audit` prepends a resolution header to the audit file, tracking which findings were addressed and which were deferred
- **Auto-supersede**: `opsx-audit` automatically tags older audits as superseded when a new audit is created, including a summary of the newer audit
- **Regression detection**: `opsx-audit` compares new findings against previously resolved findings, flagging regressions when the same issue reappears
- **Stateless lifecycle**: Audits derive state from headers and timestamps — no external state tracking required

## Capabilities

### New Capabilities
- `audit-lifecycle`: Stateless audit lifecycle management — resolution tracking, auto-supersede, and regression detection for persisted audit reports

### Modified Capabilities
(No existing capabilities modified)

## Impact

- `opsx-audit` skill: Add supersede logic (step 10) and regression detection (step 9)
- `opsx-apply-audit` skill: Add resolution header writing (step 8), pending-state requirement (step 3)
- Audit files gain prepend-only headers; original content remains unchanged
- No new dependencies or external state
