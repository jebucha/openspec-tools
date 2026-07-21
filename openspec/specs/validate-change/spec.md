# validate-change Specification

## Purpose
TBD - created by archiving change add-opsx-validate. Update Purpose after archive.
## Requirements
### Requirement: Validate command selects change
The `/opsx-validate` command SHALL accept an optional change name and select the change to validate.

#### Scenario: Change name provided explicitly
- **WHEN** the user runs `/opsx-validate add-auth`
- **THEN** the command validates the `add-auth` change without prompting

#### Scenario: Change inferred from context
- **WHEN** the user runs `/opsx-validate` and a single active change exists
- **THEN** the command auto-selects that change and announces the selection

#### Scenario: Ambiguous selection prompts user
- **WHEN** the user runs `/opsx-validate` and multiple active changes exist
- **THEN** the command lists available changes and prompts the user to select

### Requirement: Validate reads all change artifacts
The validation skill SHALL read all available change artifacts to understand the intended implementation.

#### Scenario: All artifacts read for validation
- **WHEN** validation runs on a change with proposal, design, specs, and tasks
- **THEN** all four artifact types are read before validation begins

#### Scenario: Missing artifacts noted but validation continues
- **WHEN** validation runs on a change with incomplete artifacts
- **THEN** missing artifacts are noted as warnings, and validation proceeds with available artifacts

### Requirement: Validate checks spec compliance
The validation skill SHALL verify that each spec requirement is satisfied by the implemented code.

#### Scenario: Requirement satisfied by code
- **WHEN** a spec requirement states a behavior and the code implements that behavior
- **THEN** the requirement is marked as satisfied with evidence (file path, relevant code)

#### Scenario: Requirement not satisfied
- **WHEN** a spec requirement states a behavior but the code does not implement it
- **THEN** an Error finding is raised with the requirement description and missing evidence

#### Scenario: Requirement partially satisfied
- **WHEN** a spec requirement states a behavior and the code partially implements it
- **THEN** a Warning finding is raised describing what is missing

### Requirement: Validate checks test coverage
The validation skill SHALL verify that tests exist for new requirements and cover edge cases.

#### Scenario: Tests exist for new requirement
- **WHEN** a spec requirement has corresponding test files with relevant test cases
- **THEN** the requirement is marked as having test coverage

#### Scenario: No tests for new requirement
- **WHEN** a spec requirement has no corresponding test files
- **THEN** an Error finding is raised for missing test coverage

#### Scenario: Tests lack edge case coverage
- **WHEN** tests exist but do not cover edge cases described in spec scenarios
- **THEN** a Warning finding is raised for incomplete test coverage

### Requirement: Validate checks task completion
The validation skill SHALL verify that all tasks from tasks.md are completed and the work is reflected in the codebase.

#### Scenario: All tasks complete
- **WHEN** all tasks in tasks.md are marked `- [x]`
- **THEN** task completion passes with no findings

#### Scenario: Incomplete tasks detected
- **WHEN** tasks in tasks.md are still marked `- [ ]`
- **THEN** an Error finding is raised listing the incomplete tasks

#### Scenario: Task marked complete but code not present
- **WHEN** a task is marked `- [x]` but the expected code changes are not in the codebase
- **THEN** an Error finding is raised for the discrepancy

### Requirement: Validate detects regressions
The validation skill SHALL check for regressions against prior validation reports.

#### Scenario: Regression detected from prior validation
- **WHEN** a finding from a prior resolved validation reappears
- **THEN** a Warning finding is raised with reference to the prior validation

#### Scenario: No regression
- **WHEN** no findings match resolved findings from prior validations
- **THEN** no regression findings are raised

### Requirement: Validation report is persisted
The validation skill SHALL persist the structured report to a file for historical tracking.

#### Scenario: Report saved with timestamp and model
- **WHEN** validation completes
- **THEN** the report is saved to `openspec/changes/<name>/validations/<timestamp>-<model>.md`

#### Scenario: Older validations are superseded
- **WHEN** a new validation is written and older validation files exist
- **THEN** older files receive a `## Superseded` header pointing to the new validation

### Requirement: Validation produces structured verdict
The validation skill SHALL produce a verdict based on findings.

#### Scenario: Pass verdict
- **WHEN** validation has 0 errors
- **THEN** the verdict is "Pass" with message "Implementation validated. Ready for archive."

#### Scenario: Conditional verdict
- **WHEN** validation has 0 errors but has warnings
- **THEN** the verdict is "Conditional" with message "Proceed with caution. Review warnings before archiving."

#### Scenario: Fail verdict
- **WHEN** validation has 1 or more errors
- **THEN** the verdict is "Fail" with message "Cannot proceed. Resolve errors before archiving."

### Requirement: Validation findings use stable IDs
Each validation finding SHALL have a stable ID prefixed with `VD-`.

#### Scenario: Finding ID is deterministic
- **WHEN** the same validation runs twice on the same codebase state
- **THEN** the same findings produce the same IDs

#### Scenario: Finding ID includes evidence
- **WHEN** a finding is generated
- **THEN** the finding includes the ID, severity, description, and evidence (file path, line reference)

