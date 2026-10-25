# executable-test-requirements Specification

## Purpose

Defines the executable test requirement convention — Test Requirement blocks attached to behavior-bearing spec scenarios and a Test Strategy section in design.md — and how the audit, apply-audit, and validate skills enforce, remediate, and execute it, so that validation is judged by exit-code evidence rather than model judgment.

## Requirements

### Requirement: Test Requirement block format
A spec scenario that describes observable runtime behavior SHALL carry a Test Requirement block with four mandatory fields: ID, File, Command, and Pass. The ID SHALL match `T-<CAPABILITY-UPPERCASE>-<NNN>`. The File field SHALL name a test file path and test ID. The Command field SHALL be the exact runnable invocation from the project root. The Pass field SHALL be a machine-checkable pass criterion.

#### Scenario: Well-formed block is recognized
- **WHEN** a scenario carries a Test Requirement block with all four fields
- **THEN** the block is recognized as a complete Test Requirement

#### Scenario: Incomplete block is flagged
- **WHEN** a scenario carries a block missing one or more of the four fields
- **THEN** the audit raises a Warning naming the missing field(s)

#### Scenario: Malformed ID is flagged
- **WHEN** a block's ID does not match `T-<CAPABILITY-UPPERCASE>-<NNN>`
- **THEN** the audit raises a Warning stating the expected format

#### Scenario: Exempt scenario needs no block
- **WHEN** a scenario describes no behavior change (docs, config, contract-preserving refactor)
- **THEN** no Test Requirement block is required and its absence produces no finding

### Requirement: Test Strategy section in design.md
Each change's design.md SHALL contain a `## Test Strategy` section declaring once per change: the test runner, the full-suite command, and prerequisites. Prerequisites SHALL be typed checkable entries in the forms `env: <VAR>`, `file: <path>`, or `cmd: <probe>`. Test Requirement blocks SHALL reference the Test Strategy rather than repeat runner or environment details.

#### Scenario: Complete Test Strategy is recognized
- **WHEN** design.md contains a `## Test Strategy` section with a runner, a full-suite command, and prerequisites
- **THEN** Test Requirement blocks may omit the runner and environment details the section declares

#### Scenario: Missing Test Strategy is noted
- **WHEN** design.md has no `## Test Strategy` section
- **THEN** the audit raises a single Info finding

### Requirement: What is not a Test Requirement
A Test Requirement block SHALL NOT be a static-only command (linter, formatter, type checker, vet, or compile check), SHALL NOT use an existential pass criterion (asserting only that a file or test exists), and SHALL NOT invoke a command unrelated to the scenario's declared behavior. A content assertion (e.g., grep or diff) that verifies the scenario's declared outcome IS a Test Requirement. Blocks that are not Test Requirements SHALL NOT count toward executable test coverage.

#### Scenario: Static-only command is rejected
- **WHEN** a block's Command is a linter, formatter, type checker, vet, or compile check
- **THEN** the block is not a Test Requirement and the audit raises a Warning

#### Scenario: Existential pass criterion is rejected
- **WHEN** a block's Pass criterion asserts only that a file or test exists
- **THEN** the block is not a Test Requirement and the audit raises a Warning

#### Scenario: Behavior-unrelated command is rejected
- **WHEN** a block's Command does not plausibly exercise the scenario's declared outcome
- **THEN** the audit raises a Warning citing the scenario's outcome and the block's Command side by side

#### Scenario: Content assertion of declared outcome is accepted
- **WHEN** a block's Command is a content assertion (grep, diff) that verifies the scenario's declared outcome
- **THEN** the block is a Test Requirement

### Requirement: Audit checks executable test requirement presence
The audit skill SHALL check each behavior-changing scenario in the change's spec files for a complete, genuine Test Requirement block, and SHALL add a Coverage Metrics row "Requirements with executable test requirements | X (Y%)" with X/Y counting requirements per its "Coverage metrics row present" scenario. File paths in Test Requirement blocks and in the Test Strategy SHALL be treated as forward references and SHALL be exempt from referenced-file existence checks.

#### Scenario: Behavior-changing scenario missing block
- **WHEN** a behavior-changing scenario has no Test Requirement block
- **THEN** the audit raises a Warning (VL-n): "missing test requirement"

#### Scenario: Fake block excluded from coverage
- **WHEN** a scenario's block fails the Test Requirement definition
- **THEN** the audit raises a Warning (VL-n): "not a runtime behavior assertion", and the scenario is excluded from the metrics numerator

#### Scenario: Coverage metrics row present
- **WHEN** the audit report is produced
- **THEN** Coverage Metrics includes "Requirements with executable test requirements | X (Y%)" where X counts requirements whose every behavior-changing scenario carries a complete, genuine block, and Y counts requirements with at least one behavior-changing scenario

**Test Requirement**
- **ID:** T-EXECUTABLE-TEST-REQUIREMENTS-001
- **File:** tests/test_skill_content.sh::assert_audit_skill_step_6d
- **Command:** `bash tests/test_skill_content.sh assert_audit_skill_step_6d`
- **Pass:** exit code 0

#### Scenario: Forward-reference exemption applies
- **WHEN** a block's File path or a Test Strategy file reference does not exist yet
- **THEN** no referenced-file existence finding is raised for it

### Requirement: Apply-audit remediates test requirement findings
Apply-audit SHALL remediate audit findings for missing, incomplete, or fake Test Requirement blocks. For a missing block it SHALL generate one from the scenario's WHEN/THEN, deriving File and Command from the Test Strategy's runner and naming conventions. For a fake block it SHALL either replace it with a genuine assertion or delete it when the scenario is actually exempt. When generating blocks and no Test Strategy section exists, it SHALL create the section first.

#### Scenario: Missing block generated from scenario
- **WHEN** an audit finding reports a missing block for a behavior-changing scenario
- **THEN** a complete block is added under the scenario with File and Command derived from the Test Strategy

**Test Requirement**
- **ID:** T-EXECUTABLE-TEST-REQUIREMENTS-002
- **File:** tests/test_skill_content.sh::assert_apply_audit_remediation
- **Command:** `bash tests/test_skill_content.sh assert_apply_audit_remediation`
- **Pass:** exit code 0

#### Scenario: Fake block replaced
- **WHEN** a block is not a Test Requirement but the scenario has runtime behavior
- **THEN** the block is rewritten with a genuine command and pass criterion

#### Scenario: Fake block deleted for exempt scenario
- **WHEN** the scenario is actually exempt (docs, config, contract-preserving refactor)
- **THEN** the block is removed and the exemption noted

#### Scenario: Test Strategy created before blocks
- **WHEN** block remediation runs and design.md has no Test Strategy section
- **THEN** the section is created before any block is generated

### Requirement: Validate runs declared test commands
The validation skill SHALL execute each Test Requirement block in the change's spec files: check typed prerequisites from the Test Strategy, verify the declared file and test ID exist, run the Command verbatim from the project root, and classify the result by the declared Pass criterion (default: exit code 0 with no skipped tests). Failures SHALL be Error findings whose evidence includes the exit code and the last 20 lines of output.

#### Scenario: Block satisfied
- **WHEN** the declared command exits 0 and reports no skipped or xfail tests
- **THEN** the block is Satisfied and no finding is raised

#### Scenario: Failing command
- **WHEN** the declared command exits non-zero
- **THEN** an Error finding is raised citing the requirement and the exit code, with the last 20 lines of output as evidence

#### Scenario: Skipped test is an error
- **WHEN** the run reports any skipped or xfail test
- **THEN** an Error finding is raised — a skipped test asserts nothing, so the requirement is not satisfied

#### Scenario: Missing file or test ID
- **WHEN** the declared test file or test ID does not exist
- **THEN** an Error finding is raised, reported distinctly from a test failure

#### Scenario: Unmet prerequisite
- **WHEN** a typed prerequisite check (env, file, cmd) fails
- **THEN** an Error finding "prerequisite unmet" is raised, reported distinctly from a test failure

#### Scenario: Declared Pass criterion is authoritative
- **WHEN** the Pass criterion declares an output condition
- **THEN** that condition is evaluated against the full captured output; for an unrecognized runner, evaluation falls back to the exit code only, noted in the evidence

#### Scenario: Executable step defined in the skill
- **WHEN** the validate skill's instructions specify the validation pipeline
- **THEN** an executable test requirement step is defined between structural test coverage and task completion

**Test Requirement**
- **ID:** T-EXECUTABLE-TEST-REQUIREMENTS-003
- **File:** tests/test_skill_content.sh::assert_validate_skill_step_6b
- **Command:** `bash tests/test_skill_content.sh assert_validate_skill_step_6b`
- **Pass:** exit code 0

### Requirement: Validate maintains backward compatibility with structural coverage
Scenarios without a Test Requirement block SHALL be verified by the existing structural test coverage check, unchanged. A change whose spec files contain no Test Requirement blocks at all SHALL be validated structurally as before, with one Info finding noting that no executable test requirements are declared.

#### Scenario: Structural fallback for unblocked scenario
- **WHEN** a behavior-changing scenario has no Test Requirement block
- **THEN** the existing structural coverage check applies to it as before

#### Scenario: Zero-block change
- **WHEN** the change's spec files contain no blocks and at least one behavior-changing scenario exists
- **THEN** validation proceeds structurally with one Info finding: "No executable test requirements declared"

### Requirement: Validate reports executable test results
The validation report SHALL include a Coverage Metrics row "Executable tests passed | X/Y (Z%)" where Y is the number of declared blocks executed. Executable test findings SHALL use Category "Executable: tests" with the normal VD- finding sequence, so regression detection against prior validations continues to work.

#### Scenario: Metrics row present
- **WHEN** at least one block is executed
- **THEN** the report includes "Executable tests passed | X/Y (Z%)"

#### Scenario: Stable finding IDs
- **WHEN** executable test findings are generated
- **THEN** they use the normal VD- sequence and appear in the findings table with Category "Executable: tests"

#### Scenario: Verdict impact
- **WHEN** any executable test finding is an Error
- **THEN** the verdict is Fail per the existing verdict rules

### Requirement: Executable runs guardrails
Executable test runs SHALL be declared-only: commands are copied verbatim from Test Requirement blocks, never synthesized or broadened. The validator SHALL remain read-only with respect to the codebase: no dependency installs, no config or environment edits. Each command SHALL have a hard 120-second timeout producing an Error with partial output, and at most 25 commands SHALL run per execution, prioritized by spec order, with the remainder summarized.

#### Scenario: Declared-only execution
- **WHEN** a block names a single test
- **THEN** the validator runs exactly that command and never broadens it to a full-suite run

#### Scenario: No codebase mutation
- **WHEN** running a block would require installing a dependency or editing config or environment state
- **THEN** the validator does not do so and reports the unmet prerequisite instead

#### Scenario: Timeout enforced
- **WHEN** a declared command does not complete within 120 seconds
- **THEN** it is terminated and an Error finding with partial output is recorded

#### Scenario: Command cap enforced
- **WHEN** more than 25 blocks are declared
- **THEN** the first 25 in spec order are executed and the remainder is summarized in the report

#### Scenario: Guardrail section updated
- **WHEN** the validate skill's guardrails are read
- **THEN** the structural-only test guardrail ("Test checks are structural") is absent and an executable-runs guardrail block is present

**Test Requirement**
- **ID:** T-EXECUTABLE-TEST-REQUIREMENTS-004
- **File:** tests/test_skill_content.sh::assert_validate_skill_guardrails
- **Command:** `bash tests/test_skill_content.sh assert_validate_skill_guardrails`
- **Pass:** exit code 0
