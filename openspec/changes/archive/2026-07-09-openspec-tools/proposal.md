## Why

The audit command and skill developed in `new-openspec-audit-command` need to be portable across repos and machines. OpenSpec's global install scope feature is not yet implemented, so a lightweight distribution mechanism is needed to carry the audit tooling to any repo after `openspec init`.

## What Changes

- Create `~/.openspec-tools/` — a dedicated repo containing the audit command, audit skill, and an install script
- `install.sh` — copies the command and skill files into a target repo's `.opencode/` directory
- The install script validates the target has `.opencode/` (i.e., `openspec init` was run) before proceeding

## Capabilities

### New Capabilities
- `openspec-tools-distribution`: A standalone repo containing the audit command (`opsx-audit.md`), audit skill (`openspec-audit-change/SKILL.md`), and `install.sh` script to distribute them to any OpenSpec-enabled repo

### Modified Capabilities

## Impact

- New directory: `~/.openspec-tools/` (outside this workspace, created locally)
- Files: `install.sh`, `command/opsx-audit.md`, `skill/openspec-audit-change/SKILL.md`
- No changes to OpenSpec CLI code or existing repo structure
- Install script is idempotent — safe to re-run to update artifacts
