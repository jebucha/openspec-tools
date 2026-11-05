# Spec Delta

## ADDED Requirements

### Requirement: Opt-in full-suite regression gate
Validate SHALL run the Test Strategy's full-suite command once per validation in step 6c after 6b, when the Test Strategy declares `regression: enabled`, under the declared-only, read-only guardrails. An unmet typed prerequisite SHALL stop the suite with an Error "prerequisite unmet". A non-zero exit or timeout (600s default, overridable by `suite-timeout: <seconds>`) SHALL be an Error with partial output, Category `Executable: suite`. Suite skips SHALL be one Info finding, not an Error.

#### Scenario: Gate enabled and passing
- **WHEN** the Test Strategy declares `regression: enabled` and the full-suite command exits 0 with no failures or skips
- **THEN** the Coverage Metrics row is `Full suite | Pass` and no finding is raised

**Test Requirement**
- **ID:** T-EXECUTABLE-TEST-REQUIREMENTS-005
- **File:** tests/test_skill_content.sh::assert_validate_skill_step_6c
- **Command:** `bash tests/test_skill_content.sh assert_validate_skill_step_6c`
- **Pass:** exit code 0

#### Scenario: Gate enabled and failing
- **WHEN** the full-suite command exits non-zero
- **THEN** an Error finding is raised using Category `Executable: suite` with the normal VD- sequence, with the exit code and the last 20 lines of output as evidence, and the Coverage Metrics row is `Full suite | Fail`

**Test Requirement**
- **ID:** T-EXECUTABLE-TEST-REQUIREMENTS-010
- **File:** tests/test_skill_content.sh::assert_validate_skill_step_6c
- **Command:** `bash tests/test_skill_content.sh assert_validate_skill_step_6c`
- **Pass:** exit code 0

#### Scenario: Gate timeout
- **WHEN** the suite does not complete within 600 seconds or the declared `suite-timeout`
- **THEN** it is terminated and an Error finding with partial output is recorded, and the Coverage Metrics row is `Full suite | Fail`

**Test Requirement**
- **ID:** T-EXECUTABLE-TEST-REQUIREMENTS-011
- **File:** tests/test_skill_content.sh::assert_validate_skill_step_6c
- **Command:** `bash tests/test_skill_content.sh assert_validate_skill_step_6c`
- **Pass:** exit code 0

#### Scenario: Unmet prerequisite
- **WHEN** a typed prerequisite check (env, file, cmd) fails
- **THEN** an Error finding "prerequisite unmet" is raised, the suite is not run, and the Coverage Metrics row is `Full suite | Not run`

**Test Requirement**
- **ID:** T-EXECUTABLE-TEST-REQUIREMENTS-012
- **File:** tests/test_skill_content.sh::assert_validate_skill_step_6c
- **Command:** `bash tests/test_skill_content.sh assert_validate_skill_step_6c`
- **Pass:** exit code 0

#### Scenario: Skips reported as Info
- **WHEN** the suite exits 0 but reports skipped tests
- **THEN** one Info finding with the skip count is raised, no Error is raised, and the Coverage Metrics row is `Full suite | Pass`

**Test Requirement**
- **ID:** T-EXECUTABLE-TEST-REQUIREMENTS-013
- **File:** tests/test_skill_content.sh::assert_validate_skill_step_6c
- **Command:** `bash tests/test_skill_content.sh assert_validate_skill_step_6c`
- **Pass:** exit code 0

#### Scenario: Gate absent (backward compatible)
- **WHEN** the Test Strategy does not declare `regression: enabled`
- **THEN** step 6c does not run, no finding is raised, and the `Full suite` row is not present — the validation report is identical to the pre-gate behavior

**Test Requirement**
- **ID:** T-EXECUTABLE-TEST-REQUIREMENTS-014
- **File:** tests/test_skill_content.sh::assert_validate_skill_step_6c
- **Command:** `bash tests/test_skill_content.sh assert_validate_skill_step_6c`
- **Pass:** exit code 0

#### Scenario: Suite runs even if blocks failed
- **WHEN** the gate is enabled and one or more block commands from step 6b have failed
- **THEN** the full-suite command still runs in step 6c, and the report records both the block failures and the suite result

**Test Requirement**
- **ID:** T-EXECUTABLE-TEST-REQUIREMENTS-015
- **File:** tests/test_skill_content.sh::assert_validate_skill_step_6c
- **Command:** `bash tests/test_skill_content.sh assert_validate_skill_step_6c`
- **Pass:** exit code 0

#### Scenario: Malformed regression value degrades to absent
- **WHEN** the `regression:` value is not exactly `enabled`
- **THEN** validate treats the gate as absent: no suite run and no validate finding — the audit's Info is the correction point

**Test Requirement**
- **ID:** T-EXECUTABLE-TEST-REQUIREMENTS-016
- **File:** tests/test_skill_content.sh::assert_validate_skill_step_6c
- **Command:** `bash tests/test_skill_content.sh assert_validate_skill_step_6c`
- **Pass:** exit code 0

#### Scenario: Malformed suite-timeout falls back to default
- **WHEN** the gate is enabled and `suite-timeout:` is not an integer number of seconds
- **THEN** the suite runs under the 600-second default, with the fallback noted in the report

**Test Requirement**
- **ID:** T-EXECUTABLE-TEST-REQUIREMENTS-017
- **File:** tests/test_skill_content.sh::assert_validate_skill_step_6c
- **Command:** `bash tests/test_skill_content.sh assert_validate_skill_step_6c`
- **Pass:** exit code 0

### Requirement: Regression gate fields are validated at audit
The audit step 6d SHALL raise one Info finding when `regression:` or `suite-timeout:` in the Test Strategy is malformed. Neither field SHALL be required; their absence SHALL NOT produce a finding. Apply-audit SHALL NOT add `regression: enabled` or `suite-timeout:` on its own: both fields are author-set only.

#### Scenario: Malformed gate field is noted
- **WHEN** the Test Strategy contains a malformed `regression:` or `suite-timeout:` entry
- **THEN** the audit raises one Info finding naming the malformed field

**Test Requirement**
- **ID:** T-EXECUTABLE-TEST-REQUIREMENTS-006
- **File:** tests/test_skill_content.sh::assert_audit_skill_regression_fields
- **Command:** `bash tests/test_skill_content.sh assert_audit_skill_regression_fields`
- **Pass:** exit code 0

#### Scenario: Absent gate fields produce no finding
- **WHEN** the Test Strategy declares neither `regression:` nor `suite-timeout:`
- **THEN** no finding is raised for their absence

**Test Requirement**
- **ID:** T-EXECUTABLE-TEST-REQUIREMENTS-018
- **File:** tests/test_skill_content.sh::assert_audit_skill_regression_fields
- **Command:** `bash tests/test_skill_content.sh assert_audit_skill_regression_fields`
- **Pass:** exit code 0

#### Scenario: Gate not enabled by remediation
- **WHEN** apply-audit creates a `## Test Strategy` section while remediating a missing block
- **THEN** the section it creates includes neither `regression: enabled` nor `suite-timeout:`

**Test Requirement**
- **ID:** T-EXECUTABLE-TEST-REQUIREMENTS-019
- **File:** tests/test_skill_content.sh::assert_apply_audit_level_rule
- **Command:** `bash tests/test_skill_content.sh assert_apply_audit_level_rule`
- **Pass:** exit code 0

### Requirement: Test-level selection rule
When apply-audit generates or rewrites a Test Requirement block, it SHALL choose the lowest test level that genuinely exercises the declared outcome: a single function or module targets a unit test; a process, network, or persistence boundary targets an integration or e2e test. The generated Command SHALL be expected to finish within the 120-second per-block timeout, otherwise the scenario SHALL be split or flagged at the audit checkpoint. The level is a generation rule, not a block field.

#### Scenario: Single-module outcome targets a unit test
- **WHEN** the scenario's declared outcome is produced by a single function or module
- **THEN** the generated block targets a unit test

**Test Requirement**
- **ID:** T-EXECUTABLE-TEST-REQUIREMENTS-020
- **File:** tests/test_skill_content.sh::assert_apply_audit_level_rule
- **Command:** `bash tests/test_skill_content.sh assert_apply_audit_level_rule`
- **Pass:** exit code 0

#### Scenario: Cross-boundary outcome targets integration or e2e
- **WHEN** the scenario's declared outcome crosses a process, network, or persistence boundary
- **THEN** the generated block targets an integration or e2e test

**Test Requirement**
- **ID:** T-EXECUTABLE-TEST-REQUIREMENTS-007
- **File:** tests/test_skill_content.sh::assert_apply_audit_level_rule
- **Command:** `bash tests/test_skill_content.sh assert_apply_audit_level_rule`
- **Pass:** exit code 0

#### Scenario: Rule applies to both generation branches
- **WHEN** apply-audit generates a missing block or rewrites a fake block
- **THEN** the level selection rule applies to both

**Test Requirement**
- **ID:** T-EXECUTABLE-TEST-REQUIREMENTS-021
- **File:** tests/test_skill_content.sh::assert_apply_audit_level_rule
- **Command:** `bash tests/test_skill_content.sh assert_apply_audit_level_rule`
- **Pass:** exit code 0

### Requirement: Mocked-subject fake-block pattern (Pattern D)
Audit step 6d SHALL treat a block as fake when the unit under test is mocked or stubbed, so the assertion checks only the mock. It SHALL be a Warning (VL-n) "not a runtime behavior assertion", excluding the requirement from the coverage numerator, with evidence quoting the scenario's outcome and the mocked subject side by side. Mocking only the subject's dependencies SHALL NOT trigger this pattern. Apply-audit SHALL remediate by rewriting so the subject runs for real, or raising the test level.

#### Scenario: Subject-mocked block is flagged
- **WHEN** the unit under test is itself mocked or stubbed and the assertion verifies only the mock
- **THEN** the audit raises a Warning (VL-n) "not a runtime behavior assertion", the requirement is excluded from the coverage numerator, and the evidence quotes the scenario's outcome and the mocked subject side by side

**Test Requirement**
- **ID:** T-EXECUTABLE-TEST-REQUIREMENTS-008
- **File:** tests/test_skill_content.sh::assert_audit_skill_pattern_d
- **Command:** `bash tests/test_skill_content.sh assert_audit_skill_pattern_d`
- **Pass:** exit code 0

#### Scenario: Dependency mocking produces no finding
- **WHEN** only the subject's dependencies are mocked and the subject itself runs for real
- **THEN** no Pattern D finding is raised

**Test Requirement**
- **ID:** T-EXECUTABLE-TEST-REQUIREMENTS-022
- **File:** tests/test_skill_content.sh::assert_audit_skill_pattern_d
- **Command:** `bash tests/test_skill_content.sh assert_audit_skill_pattern_d`
- **Pass:** exit code 0

#### Scenario: Remediation runs the subject for real
- **WHEN** a Pattern D finding is remediated
- **THEN** apply-audit rewrites the block so the subject runs for real (dependencies may remain mocked), or raises the test level

**Test Requirement**
- **ID:** T-EXECUTABLE-TEST-REQUIREMENTS-009
- **File:** tests/test_skill_content.sh::assert_apply_audit_pattern_d_remediation
- **Command:** `bash tests/test_skill_content.sh assert_apply_audit_pattern_d_remediation`
- **Pass:** exit code 0

## MODIFIED Requirements

### Requirement: Test Strategy section in design.md
Each change's design.md SHALL contain a `## Test Strategy` section declaring once per change: the test runner, the full-suite command, and prerequisites. Prerequisites SHALL be typed checkable entries in the forms `env: <VAR>`, `file: <path>`, or `cmd: <probe>`. The section MAY additionally declare `regression: enabled` to opt into the full-suite regression gate and `suite-timeout: <seconds>` to override the default suite timeout. Both fields SHALL be optional. No skill SHALL require them, and no skill SHALL add or modify them; they are author-set only. Test Requirement blocks SHALL reference the Test Strategy rather than repeat runner or environment details.

#### Scenario: Complete Test Strategy is recognized
- **WHEN** design.md contains a `## Test Strategy` section with a runner, a full-suite command, and prerequisites
- **THEN** Test Requirement blocks may omit the runner and environment details the section declares

#### Scenario: Optional gate fields are recognized
- **WHEN** the `## Test Strategy` section declares `regression: enabled` or `suite-timeout: <seconds>` in addition to the runner, full-suite command, and prerequisites
- **THEN** the optional fields are recognized as a gate opt-in and a suite-timeout override, and the section is still recognized as complete

**Test Requirement**
- **ID:** T-EXECUTABLE-TEST-REQUIREMENTS-023
- **File:** tests/test_skill_content.sh::assert_validate_skill_step_6c
- **Command:** `bash tests/test_skill_content.sh assert_validate_skill_step_6c`
- **Pass:** exit code 0

#### Scenario: No skill adds or modifies gate fields
- **WHEN** any skill creates or edits a Test Strategy section
- **THEN** it does not add or change `regression:` or `suite-timeout:`

**Test Requirement**
- **ID:** T-EXECUTABLE-TEST-REQUIREMENTS-026
- **File:** tests/test_skill_content.sh::assert_no_skill_writes_gate_fields
- **Command:** `bash tests/test_skill_content.sh assert_no_skill_writes_gate_fields`
- **Pass:** exit code 0

#### Scenario: Missing Test Strategy is noted
- **WHEN** design.md has no `## Test Strategy` section
- **THEN** the audit raises a single Info finding

### Requirement: Executable runs guardrails
Executable test runs SHALL be declared-only: commands are copied verbatim from Test Requirement blocks, never synthesized or broadened; the Test Strategy's full-suite command is the sole exception to the never-broaden rule and runs only when the regression gate is enabled. The validator SHALL remain read-only with respect to the codebase: no dependency installs, no config or environment edits. Each block command SHALL have a hard 120-second timeout producing an Error with partial output, and the full-suite command SHALL have a 600-second default timeout overridable by `suite-timeout: <seconds>`, with a timeout producing an Error with partial output. At most 25 block commands SHALL run per execution, prioritized by spec order, with the remainder summarized; the opt-in suite run does not count against this cap.

#### Scenario: Declared-only execution
- **WHEN** a block names a single test
- **THEN** the validator runs exactly that command and never broadens it to a full-suite run

#### Scenario: Suite is the sole never-broaden exception
- **WHEN** the regression gate is enabled and a block declares a single test
- **THEN** the validator still runs exactly the block's declared command — the Test Strategy's full-suite command is never used to broaden a block run and executes only once, in step 6c

**Test Requirement**
- **ID:** T-EXECUTABLE-TEST-REQUIREMENTS-024
- **File:** tests/test_skill_content.sh::assert_validate_skill_guardrails
- **Command:** `bash tests/test_skill_content.sh assert_validate_skill_guardrails`
- **Pass:** exit code 0

#### Scenario: Suite run is exempt from the block cap
- **WHEN** the regression gate is enabled and more than 25 blocks are declared
- **THEN** the first 25 block commands in spec order are executed and the opt-in suite run still takes place without counting against the cap

**Test Requirement**
- **ID:** T-EXECUTABLE-TEST-REQUIREMENTS-025
- **File:** tests/test_skill_content.sh::assert_validate_skill_guardrails
- **Command:** `bash tests/test_skill_content.sh assert_validate_skill_guardrails`
- **Pass:** exit code 0

#### Scenario: No codebase mutation
- **WHEN** running a block would require installing a dependency or editing config or environment state
- **THEN** the validator does not do so and reports the unmet prerequisite instead

#### Scenario: Timeout enforced
- **WHEN** a declared block command does not complete within 120 seconds
- **THEN** it is terminated and an Error finding with partial output is recorded

#### Scenario: Command cap enforced
- **WHEN** more than 25 blocks are declared
- **THEN** the first 25 in spec order are executed and the remainder is summarized in the report

#### Scenario: Guardrail section updated
- **WHEN** the validate skill's guardrails are read
- **THEN** the structural-only test guardrail ("Test checks are structural") is absent and an executable-runs guardrail block is present
