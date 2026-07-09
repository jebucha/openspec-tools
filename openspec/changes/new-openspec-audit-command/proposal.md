## Why

After running `/opsx-propose` to generate change artifacts, there's no built-in way to review the generated proposal for accuracy, completeness, and validity before committing to implementation. An audit command gives users confidence that their change specs are sound, catching issues like missing dependencies, vague requirements, or inconsistent artifacts before code is written.

## What Changes

- Add a new `opsx-audit` command (`.opencode/commands/opsx-audit.md`) that triggers an audit of an existing change proposal
- Add a new `openspec-audit-change` skill (`.opencode/skills/openspec-audit-change/SKILL.md`) with the audit workflow logic
- The audit evaluates change artifacts (proposal, design, specs, tasks) for:
  - **Accuracy**: Artifacts are consistent with each other and with the actual codebase
  - **Completeness**: No missing sections, all required artifacts present, tasks cover all spec requirements
  - **Validity**: Requirements are testable, dependencies are correct, capability names follow conventions

## Capabilities

### New Capabilities
- `opsx-audit-command`: The audit command and skill that validates change proposals for accuracy, completeness, and validity before implementation

### Modified Capabilities

## Impact

- New files: `.opencode/commands/opsx-audit.md`, `.opencode/skills/openspec-audit-change/SKILL.md`
- Follows the same pattern as existing commands: `opsx-propose`, `opsx-apply`, `opsx-explore`, `opsx-archive`
- No changes to existing CLI commands or open-spec core logic
- No new dependencies required
