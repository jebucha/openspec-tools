## Why

The README workflow is outdated: it omits explore as the canonical starting point, excludes validate from the flow, and doesn't explain how to loop back when issues are found. This creates confusion about the full workflow and underrepresents critical quality gates.

## What Changes

- Promote explore to step 1 of the canonical workflow (recommended, not required)
- Add validate as step 6 between apply and archive
- Rename the validate command from `opsx-validate-change` to `opsx-validate` for consistency
- Add Quality Gates section explaining audit and validate as critical gates
- Add Looping Back section with diagram showing iteration paths
- Add Validation Dimensions section (matching existing Audit Categories)
- Update Typical Session to include all 7 steps
- Update Commands and Skills tables

## Capabilities

This is a documentation-only change with no spec-level behavior changes. Setting `skip_specs: true` in `.openspec.yaml`.

## Impact

- `README.md` — workflow section, commands table, skills table, typical session
- `commands/opsx-validate-change.md` → `commands/opsx-validate.md` — renamed
- `.opencode/commands/opsx-validate-change.md` → `.opencode/commands/opsx-validate.md` — renamed
