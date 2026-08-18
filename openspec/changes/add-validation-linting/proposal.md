## Why

The validate-change skill currently performs static code inspection — reading files for evidence of implemented behavior. This is attestation, not validation. It can't detect lint errors, type mismatches, or build failures that would surface immediately in a developer's workflow. Adding executable linting closes this gap: validation now catches real code quality issues, not just missing patterns.

## What Changes

- **New step in validate-change skill**: After spec/task checks, run executable linting on changed files
- **Tool detection**: Auto-detect linter from project config files (eslint, prettier, ruff, biome, etc.)
- **Tool install prompt**: If detected linter is not installed, prompt the user to install before proceeding
- **Severity classification**: Distinguish style-only issues (Warning) from semantic/runtime issues (Error)
- **Scoped execution**: Lint only files changed by the current change, not the entire codebase
- **User override**: Support `--lint-cmd` flag to specify custom linter command

## Capabilities

### New Capabilities
- `linting-verification`: Detect project linter, verify installation, execute linting on changed files, classify findings by severity, and integrate results into the validation report

### Modified Capabilities
- `validate-change`: Adds linting verification as a new step in the validation pipeline; lint errors contribute to verdict (style-only → Warning, semantic → Error)

## Impact

- `.opencode/skills/openspec-validate-change/SKILL.md`: New step inserted into validation pipeline
- `openspec/specs/validate-change/spec.md`: New requirement for linting verification
- `openspec/specs/linting-verification/spec.md`: New spec file for the linting capability
- No runtime dependencies added — linters are project-local, detected at validation time
