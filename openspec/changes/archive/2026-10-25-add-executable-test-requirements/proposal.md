# Proposal

## Why

The validate step currently attests to tests instead of validating them: it checks that test *files exist* and a guardrail explicitly forbids running them ("Test checks are structural — Don't run tests"). Under that posture, a lint command dressed up as a test and a genuine behavior assertion are indistinguishable — both "pass" the structural check. The sibling change `add-validation-linting` closed this exact gap for linting and explicitly deferred "running tests (future enhancement)". This change closes it for tests by introducing an artifact-level convention that moves model judgment from the archive gate (where it is least trustworthy) to the audit checkpoint (where it is advisory and human-reviewed), leaving validate with a purely mechanical job: run the declared command, read the exit code.

## What Changes

- **New artifact convention**: a **Test Requirement** block (ID / File / Command / Pass) attaches to each spec scenario that describes observable runtime behavior; a **`## Test Strategy`** section in design.md declares once per change the runner, full-suite command, and typed prerequisites. Upstream steps (propose, apply) read and write these as ordinary markdown — no upstream step or command is modified.
- **`openspec-audit-change`**: new step 6d "Executable test requirement presence" — behavior-changing scenario missing a complete block → Warning (VL-n); block present but not a genuine runtime-behavior assertion (static-only command, existential pass criterion, behavior-unrelated command) → Warning, and fake blocks are excluded from the new Coverage Metrics row "Requirements with executable test requirements"; design.md missing `## Test Strategy` → Info. Test-file paths in blocks and Test Strategy are forward references, exempt from the 4b referenced-file existence check.
- **`openspec-apply-audit`**: remediation path for 6d findings — generate a missing block from the scenario's GIVEN/WHEN/THEN (runner and command shape from Test Strategy); for a fake block, either replace it with a genuine assertion or delete it when the scenario is actually exempt.
- **`openspec-validate-change`**: new step 6b "Run Executable Test Requirements" between structural coverage (step 6, renamed 6a) and task completion (step 7) — parse blocks, check prerequisites, run each declared command verbatim (declared-only execution, hard 120s timeout, at most 25 commands), classify by exit code and skip markers (evidence: exit code + last 20 lines of output); missing file/test ID → Error; non-zero exit or any skipped test → Error; unmet prerequisite → distinct Error. Scenarios without blocks fall back to the existing structural check (backward compatible); a change with no blocks at all gets one Info finding. New Coverage Metrics row "Executable tests passed | X/Y (Z%)". The "Test checks are structural" guardrail is replaced with an executable-runs guardrail block, and the "Non-destructive" workflow note is reconciled with it.
- **Practice-what-we-preach**: this change's own spec carries Test Requirement blocks and design.md carries a Test Strategy; a new `tests/test_skill_content.sh` harness (named-function dispatch, ok/bad assertion style mirroring `tests/deploy_test.sh`) provides the per-test commands, and the full suite (`deploy_test.sh` + `test_skill_content.sh`) is run as a regression gate. This change's own blocks point at test functions that do not exist until apply — its audit is the first exercise of the forward-reference exemption.

## Capabilities

### New Capabilities

- `executable-test-requirements`: The artifact convention (Test Requirement block format, Test Strategy section, exemption rules, what is *not* a Test Requirement) and its enforcement and execution across the three owned skills — audit presence/fake detection, apply-audit remediation, and validate declared-only execution.

### Modified Capabilities

- `validate-change`: The "Validate checks test coverage" requirement changes — scenarios with a Test Requirement block are verified by execution (step 6b) instead of structural inspection; scenarios without a block retain the existing structural check unchanged.

## Impact

- `skills/openspec-audit-change/SKILL.md` (+ `README.md`): step 6d, 4b exemption note, Coverage Metrics row, version bump
- `skills/openspec-apply-audit/SKILL.md` (+ `README.md`): remediation path for 6d findings, version bump
- `skills/openspec-validate-change/SKILL.md` (+ `README.md`): step 6b, guardrail replacement, Coverage Metrics row, output examples, version bump
- `tests/test_skill_content.sh` (new): dogfood harness with per-test dispatch
- No changes to any upstream OpenSpec step (explore, propose, apply, archive) or to any `commands/opsx-*.md`; no new CLI dependencies; no CI integration
- Sequencing: `add-validation-linting` (in progress) inserts a new top-level step 8 into the same validate SKILL.md; this change inserts sub-step 6b, so there is no renumbering collision, but the linting change should land first so this one diffs against the renumbered file
