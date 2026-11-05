# Tasks

## 1. Audit skill (skills/openspec-audit-change)

- [x] 1.1 Add fake-block **Pattern D (mocked subject)** to step 6d: the unit under test is itself mocked or stubbed, so the assertion verifies only the mock → Warning (VL-n) "not a runtime behavior assertion", with the requirement excluded from the "Requirements with executable test requirements" numerator; evidence quotes the scenario's outcome and the mocked subject side by side; mocking only the subject's dependencies does not trigger Pattern D; verify by re-reading the 6d fake-block list and confirming all four patterns are named, with the dependency exception and the side-by-side evidence rule present
- [x] 1.2 Add the regression-gate-field check to 6d: a `regression:` entry not exactly `enabled`, or a `suite-timeout:` that is not an integer number of seconds → one Info finding naming the malformed field; neither field is required — absence produces no finding; verify by re-reading 6d and confirming the check is Info-only and explicitly does not require either field
- [x] 1.3 Bump skill version 1.3 → 1.4 in the frontmatter and update `skills/openspec-audit-change/README.md` (Pattern D, gate-field Info); verify frontmatter and README reflect 1.4

## 2. Apply-audit skill (skills/openspec-apply-audit)

- [x] 2.1 Add the test-level selection rule to the 6d remediation, applying to both the missing-block generation branch and the fake-block rewrite branch: choose the lowest test level that genuinely exercises the declared outcome — a single function or module → unit test; a process, network, or persistence boundary → integration or e2e test; the generated Command is expected to finish within the 120-second per-block timeout, otherwise split the scenario or flag it for the human at the audit checkpoint; the level is a generation rule, not a block field; verify by re-reading the 6d remediation section and confirming the rule is named for both branches, with the boundary test and the 120s fit
- [x] 2.2 Add Pattern D remediation: rewrite the block so the subject runs for real (dependencies may remain mocked), or raise the test level; verify by re-reading the fake-block remediation bullet and confirming both options
- [x] 2.3 State that creating the `## Test Strategy` section never adds `regression: enabled` or `suite-timeout:` — the apply-audit instance of the general rule that no skill may require, add, or modify the gate fields (both are author-set only); verify the Test Strategy creation instruction carries the prohibition
- [x] 2.4 Bump skill version 1.1 → 1.2 in the frontmatter and update `skills/openspec-apply-audit/README.md`; verify frontmatter and README reflect 1.2

## 3. Validate skill (skills/openspec-validate-change)

- [x] 3.1a Insert step 6c "Run Full-Suite Regression Gate" between 6b and step 7: run only when the Test Strategy declares `regression: enabled` (malformed value → treated as absent, no finding); check typed prerequisites (env/file/cmd) first — unmet → Error "prerequisite unmet", suite not run; run the full-suite command verbatim from the project root, declared-only and read-only; if `add-validation-linting` has landed, align step references with its renumbering; verify by re-reading step 6c's execution section and confirming every element above (group 4's `assert_validate_skill_step_6c` locks this in)
- [x] 3.1b Add the suite timeout handling: 600-second default timeout overridable by `suite-timeout: <seconds>` (malformed → 600s, noted in evidence), timeout → Error with partial output; verify by re-reading step 6c and confirming the 600s default, the `suite-timeout` override, and the malformed-value fallback
- [x] 3.1c Add the suite findings: non-zero exit → Error, Category `Executable: suite`, normal VD- sequence, evidence = exit code + last 20 lines of output; suite skips → one Info finding with the count; verify by re-reading step 6c and confirming the category, the VD- sequence, and the one-Info skip rule
- [x] 3.1d Add the `Full suite | Pass/Fail/Not run` Coverage Metrics row semantics (Not run = gate enabled, suite not run for an unmet prerequisite) and the gate-absent no-op (no step, no row, no finding); verify by re-reading step 6c and confirming the row states and the no-op
- [x] 3.2 Adjust the guardrails: the 120-second timeout and the 25-command cap are scoped to block commands; the suite is the sole opt-in exception to the never-broaden rule; the suite run does not count against the cap; verify by re-reading the guardrail bullets and confirming the scoping and the suite's 600s default
- [x] 3.3 Add the `Full suite` row to the Coverage Metrics table in the report template and add an "Executable: suite" Error row to the Fail output example (a non-zero suite exit, citing the exit code and last 20 lines of output as evidence); verify the row and the category appear in the template and the Fail example via grep
- [x] 3.4 Bump skill version 1.1 → 1.2 in the frontmatter and update `skills/openspec-validate-change/README.md` (opt-in gate, 600s suite timeout, `Executable: suite` category); verify frontmatter and README reflect 1.2

## 4. Dogfood test harness (tests/test_skill_content.sh)

- [x] 4.1 Add `assert_validate_skill_step_6c` (step 6c heading, `Executable: suite` category, 600s default, `suite-timeout`, `Full suite` metrics row, skips-as-one-Info, gate-absent no-op) and `assert_audit_skill_regression_fields` (one Info on malformed gate fields, no finding when absent); register both in `ALL_TESTS`; verify `bash tests/test_skill_content.sh assert_validate_skill_step_6c assert_audit_skill_regression_fields` exits 0
- [x] 4.2 Add `assert_apply_audit_level_rule` (lowest-genuine-level rule, process/network/persistence boundary, 120s fit, applies to both branches, no auto-enable of the gate) and `assert_audit_skill_pattern_d` (Pattern D named, side-by-side evidence, dependency exception, numerator exclusion); register both; verify `bash tests/test_skill_content.sh assert_apply_audit_level_rule assert_audit_skill_pattern_d` exits 0
- [x] 4.3 Add `assert_apply_audit_pattern_d_remediation` (rewrite so the subject runs for real, dependencies may remain mocked, or raise the test level); register it; verify `bash tests/test_skill_content.sh assert_apply_audit_pattern_d_remediation` exits 0
- [x] 4.4 Add `assert_no_skill_writes_gate_fields` (content assertion that none of the three skills — audit-change, apply-audit, validate-change — instructs the agent to write or modify `regression:` or `suite-timeout:` in a Test Strategy section); register it in `ALL_TESTS`; verify `bash tests/test_skill_content.sh assert_no_skill_writes_gate_fields` exits 0

## 5. README

- [x] 5.1 Add one line under the Validate section of `README.md` describing the opt-in full-suite regression gate (step 6c, enabled by `regression: enabled` in the Test Strategy, 600s default suite timeout); verify the line appears in `README.md`'s validation section

## 6. Integration

- [x] 6.1 Run all ten assertions — the six new plus the four existing — via `bash tests/test_skill_content.sh` (all), and each of the six new ones by name; confirm exit 0
- [x] 6.2 Run the full suite `bash tests/deploy_test.sh && bash tests/test_skill_content.sh` and verify both exit 0 — the deploy regression confirms the edited skill files still deploy byte-for-byte unchanged to all targets
- [x] 6.3 Cross-check the artifacts against the convention: re-read this change's spec delta and verify the twenty-two Test Requirement blocks (T-EXECUTABLE-TEST-REQUIREMENTS-005…026) have all four fields with matching File/Command pairs, and that design.md's Test Strategy declares `regression: enabled` and its full-suite command is exactly what task 6.2 runs

## Workflow follow-up

- Run `/opsx-audit add-regression-gate-and-test-levels` in a fresh session — first real exercise of Pattern D and the malformed-gate-field Info against this change's own artifacts (the six block paths are forward references, exempt from the 4b referenced-file existence check; unblocked behavior-bearing scenarios in this change's own spec are expected to draw 6d "missing test requirement" Warnings — the convention is demonstrated on the declared blocks, not fully self-applied)
- Run `/opsx-validate add-regression-gate-and-test-levels` in a fresh session with a model that did not write the code — first real exercise of step 6c: this change's own Test Strategy declares `regression: enabled`, so the gate runs the full suite once under the 600s default alongside the six declared blocks
