# Proposal

## Why

The executable-test-requirements convention runs only the change's declared per-block tests, so validation has no project-level regression signal: a change whose blocks all pass can still break tests elsewhere in the suite, and nothing runs the full-suite command the Test Strategy already declares. A forced suite run is not an option — suite cost and flakiness vary by project — so the gate must be opt-in and author-declared. Separately, when apply-audit generates or rewrites Test Requirement blocks, nothing constrains which test level the command targets: lazy generation drifts toward heavy e2e tests that cannot fit the 120s per-block timeout, while the cheapest genuine level (unit) is exactly where a fake-block pattern that patterns A–C do not catch lives — the unit under test is itself mocked, and the assertion verifies only the mock.

## What Changes

- **Test Strategy gains two optional fields**: `regression: enabled` (opt into the full-suite regression gate) and `suite-timeout: <seconds>` (override the 600s default). Absent → validation is identical to today. Neither field is required, and no skill may add them: the gate is author-set only.
- **`openspec-validate-change`**: new step 6c "Run Full-Suite Regression Gate" after step 6b — when the gate is enabled: check typed prerequisites (unmet → Error "prerequisite unmet", suite not run), run the Test Strategy's full-suite command verbatim from the project root (declared-only, read-only), 600s default timeout overridable by `suite-timeout`, non-zero exit → Error with Category `Executable: suite` (normal VD- sequence, evidence = exit code + last 20 lines), skipped tests in the suite → one Info finding with the count (not an Error), Coverage Metrics row `Full suite | Pass/Fail/Not run`. Guardrails adjusted: the 120s timeout is scoped to block commands; the suite is the sole opt-in exception to the never-broaden rule; the suite run does not count against the 25-block command cap. Gate absent → no step 6c, no row, no finding. Malformed values degrade at validate: a `regression:` value that is not exactly `enabled` is treated as absent, and a malformed `suite-timeout:` falls back to the 600s default, noted in the report.
- **`openspec-audit-change`**: step 6d gains a fourth fake-block pattern — **Pattern D (mocked subject)**: the unit under test is itself mocked or stubbed, so the assertion verifies only the mock → Warning (VL-n) "not a runtime behavior assertion", requirement excluded from the coverage numerator, evidence quoting the scenario's outcome and the mocked subject side by side; mocking only the subject's dependencies does not trigger D. 6d also raises one Info when `regression:` or `suite-timeout:` in the Test Strategy is malformed; neither field is required.
- **`openspec-apply-audit`**: level-selection rule for every block it generates or rewrites — the lowest test level that genuinely exercises the declared outcome (single function/module → unit test; process/network/persistence boundary → integration or e2e test), the generated Command expected to finish within the 120s per-block timeout (else split the scenario or flag it at the audit checkpoint); Pattern D remediation — rewrite so the subject runs for real (dependencies may stay mocked) or raise the test level; never adds `regression: enabled` on its own.
- **Practice-what-we-preach**: six new assertion functions in `tests/test_skill_content.sh`; this change's own Test Strategy enables the gate, so its validation is the first real exercise of step 6c.
- The Test Requirement block format stays at four fields (ID, File, Command, Pass); validate stays declared-only and read-only. No **BREAKING** changes: a change with no `regression: enabled` line validates exactly as today.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `executable-test-requirements`: new requirements for the opt-in full-suite regression gate (validate step 6c), the audit's malformed-gate-field check, the test-level selection rule for generated/rewritten blocks, and Pattern D fake-block detection and remediation; the Test Strategy requirement is modified for the two optional fields and the guardrails requirement is modified so the 120s timeout and the command cap apply to block commands while the suite runs under its own 600s default / `suite-timeout` override.

## Impact

- `skills/openspec-audit-change/SKILL.md` (+ its README, version bump): Pattern D in step 6d, malformed-gate-fields Info check
- `skills/openspec-apply-audit/SKILL.md` (+ its README, version bump): level-selection rule, Pattern D remediation, no auto-enable of the gate
- `skills/openspec-validate-change/SKILL.md` (+ its README, version bump): step 6c, guardrail adjustments, `Full suite` metrics row, Fail output example
- `tests/test_skill_content.sh`: six new assertion functions (forward references from this change's blocks)
- `README.md`: one line under Validate describing the opt-in gate
- Main spec `openspec/specs/executable-test-requirements/spec.md`: updated at archive
- No changes to any upstream OpenSpec step (explore, propose, apply, archive) or to any `commands/opsx-*.md` (the opsx-validate/opsx-audit wrappers stay thin); no new CLI dependencies; no CI integration
- Sequencing: `add-validation-linting` (in progress) may renumber the validate skill's top-level steps; this change adds sub-step 6c, so there is no renumbering collision — the validate tasks align step references if the linting change lands first
