## Why

The `skills/security-audit/` skill (borrowed from cloudflare/security-audit-skill) exists but has no corresponding slash command to trigger it. Other skills in the project (`openspec-audit-change`, `openspec-apply-audit`, `openspec-validate-change`) each have a command in `commands/` that invokes their skill. The security-audit skill is invisible to users because there's no `/opsx-security-audit` command to discover and invoke it.

## What Changes

- Add `commands/opsx-security-audit.md` — a new slash command that invokes the `security-audit` skill
- Deploy the command via `deploy.sh` (covers `.opencode/`, `.kiro/`, and `.claude/` targets automatically)
- Update `README.md` to document the new command in the commands table and workflow

## Capabilities

### New Capabilities
- `security-audit-command`: Slash command that triggers the security-audit skill, accepting an optional target codebase path and output directory from the user

### Modified Capabilities
- None — README documentation of the new command is covered by the `security-audit-command` capability

## Impact

- `commands/opsx-security-audit.md` — new file
- Deployed copies via `deploy.sh` — `.opencode/commands/`, `.kiro/prompts/`, `.claude/commands/opsx/` (automatic; the script globs `commands/*.md`)
- `README.md` — updated commands table and workflow documentation
