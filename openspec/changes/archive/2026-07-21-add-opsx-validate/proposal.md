## Why

After `/opsx-apply` implements changes, there is no automated step to verify that the implementation actually matches what was proposed, specified, and designed. A separate model (Model C) can independently validate that all tasks were completed correctly, all spec requirements are satisfied, appropriate tests were written, and no regressions were introduced — providing confidence before archiving the change.

## What Changes

- Add a new `/opsx-validate` command that validates a completed (or in-progress) change's implementation against its proposal, specs, design, and audit findings
- Create a corresponding `openspec-validate-change` skill with the validation logic
- The validation runs independently (ideally with a different model than the one that implemented) to catch implementation gaps, missing tests, spec violations, and regressions

## Capabilities

### New Capabilities
- `validate-change`: The `/opsx-validate` command and `openspec-validate-change` skill that examine a change's implementation against its artifacts, verify spec requirements are met, check for test coverage, detect regressions, and produce a structured validation report

### Modified Capabilities
- `audit-lifecycle`: The validate report follows the same lifecycle pattern as audits (persisted files, supersede headers, regression detection against prior validations)

## Impact

- New command file: `.opencode/commands/opsx-validate.md`
- New skill file: `.opencode/skills/openspec-validate-change/SKILL.md`
- New validation reports persisted at `openspec/changes/<name>/validations/`
- The archive workflow may optionally check for a passing validation before allowing archive
- No changes to existing commands or skills
