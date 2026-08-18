## Why

Skill READMEs contain inconsistent, tool-specific deployment instructions. The `openspec-audit-change` README references `kiro/` paths that don't exist, `openspec-apply-audit` has a `skill/` typo, and `openspec-validate-change` only documents opencode deployment. Since `deploy.sh` already handles all 4 tools (opencode, kiro, claude, gemini), the per-skill READMEs should not duplicate or contradict deployment instructions.

## What Changes

- Remove "Files" and "Deployment" sections from all per-skill READMEs
- Fix `skill/` → `skills/` path typos in the top-level README
- Consolidate deployment documentation in the top-level README only

## Capabilities

### New Capabilities
None — this is a documentation consistency fix, not a new capability.

### Modified Capabilities
None — no spec-level behavior changes.

## Impact

- `skills/openspec-audit-change/README.md` — removes outdated kiro-only deployment section
- `skills/openspec-apply-audit/README.md` — removes files section with typo and opencode-only paths
- `skills/openspec-validate-change/README.md` — removes opencode-only deployment section
- `README.md` — fixes `skill/` → `skills/` path inconsistencies
