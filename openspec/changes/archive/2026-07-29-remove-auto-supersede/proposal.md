## Summary

Remove auto-supersede behavior from `opsx-audit` and `opsx-validate`. All audit and validation reports are peers — no report supersedes another on creation.

## Problem

The current auto-supersede logic (step 11a in audit, step 12a in validate) marks older reports as `Superseded` whenever a new report is created. This breaks the multi-model peer-review workflow where the user runs audits with different LLMs to compare independent findings before choosing which to apply.

```
Desired workflow:                        Current behavior:
                                         ┌──────────────────────┐
 Audit-A (claude-opus)  ──┐              │ 15:42-claude-opus   │
 Audit-B (gemini-pro)    ──┼─▶ Compare    │ Superseded by       │
 Audit-C (gpt-4o)        ──┘             │ 15:45-gemini-pro    │
                                         ├──────────────────────┤
                                         │ 15:45-gemini-pro    │
                                         │ Superseded by       │
                                         │ 15:48-gpt-4o        │
                                         ├──────────────────────┤
                                         │ 15:48-gpt-4o        │
                                         │ ← Only this one      │
                                         │    is "Pending"      │
                                         └──────────────────────┘
```

## Approach

Remove auto-supersede entirely. All reports remain `Pending` until one is resolved by `opsx-apply-audit`. Regression detection (which depends on `## Resolved` headers, not `## Superseded`) is unaffected.

## New Capabilities

None.

## Modified Capabilities

- `audit-lifecycle`: Remove auto-supersede, simplify state model from 3 states (Pending/Resolved/Superseded) to 2 states (Pending/Resolved)

## Out of Scope

- Regression detection — remains unchanged, depends on `## Resolved` headers only
- The `opsx-apply-audit` skill's ability to select from multiple pending audits — already works
- Archival or cleanup of old reports — not addressed
