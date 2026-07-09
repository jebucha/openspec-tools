## ADDED Requirements

### Requirement: User can audit a change proposal
When the user invokes the audit command, the system SHALL evaluate an existing change proposal for accuracy, completeness, and validity.

#### Scenario: User audits a specific change
- **WHEN** user runs `/opsx-audit <change-name>`
- **THEN** the system evaluates the change artifacts and reports findings

#### Scenario: User audits without specifying a change
- **WHEN** user runs `/opsx-audit` with no arguments
- **THEN** the system lists available active changes and prompts the user to select one

### Requirement: Audit checks for accuracy
The audit SHALL verify that change artifacts are consistent with each other and with the actual codebase state.

#### Scenario: Detects inconsistent capability names
- **WHEN** the proposal lists a capability that has no corresponding spec file
- **THEN** the audit reports an error finding for the missing spec

#### Scenario: Detects artifacts referencing non-existent code
- **WHEN** the design or tasks reference source files that do not exist in the codebase
- **THEN** the audit reports a warning finding with the file path

#### Scenario: Detects contradictory specs
- **WHEN** two spec files define conflicting behavior for the same capability
- **THEN** the audit reports an error finding describing the contradiction

### Requirement: Audit checks for completeness
The audit SHALL verify that all required sections are present and that specs and tasks are fully covered.

#### Scenario: Detects missing requirement scenarios
- **WHEN** a spec requirement has no associated scenarios
- **THEN** the audit reports a warning finding identifying the requirement

#### Scenario: Detects uncovered tasks
- **WHEN** a task in tasks.md has no corresponding spec requirement
- **THEN** the audit reports an info finding suggesting the task may need a spec

#### Scenario: Detects empty artifact sections
- **WHEN** a required section in an artifact is present but empty or contains only placeholder text
- **THEN** the audit reports a warning finding for the incomplete section

### Requirement: Audit checks for validity
The audit SHALL verify that artifacts follow structural conventions and contain well-formed content.

#### Scenario: Detects non-testable requirements
- **WHEN** a requirement cannot be verified by any observable behavior or test scenario
- **THEN** the audit reports a warning finding suggesting the requirement be made testable

#### Scenario: Detects broken task dependencies
- **WHEN** a task references a dependency task that does not exist
- **THEN** the audit reports an error finding for the broken dependency

#### Scenario: Detects naming convention violations
- **WHEN** a capability name does not follow kebab-case convention
- **THEN** the audit reports an info finding with the suggested correction

### Requirement: Audit reports findings with severity levels
The audit SHALL categorize each finding with a severity level: error, warning, or info.

#### Scenario: Error findings block implementation
- **WHEN** the audit produces error-level findings
- **THEN** the summary indicates that errors should be resolved before proceeding to implementation

#### Scenario: Warning findings suggest review
- **WHEN** the audit produces warning-level findings but no errors
- **THEN** the summary indicates the proposal is usable but has areas to improve

#### Scenario: Clean audit passes
- **WHEN** the audit finds no errors or warnings
- **THEN** the summary confirms the proposal is ready for implementation

### Requirement: Audit follows the command and skill pattern
The audit SHALL consist of a command file at `.opencode/commands/opsx-audit.md` and a skill file at `.opencode/skills/openspec-audit-change/SKILL.md`, following the same structure as existing commands.

#### Scenario: Command file triggers the skill
- **WHEN** the user invokes `/opsx-audit`
- **THEN** the command file directs the agent to use the openspec-audit-change skill

#### Scenario: Skill file contains the audit workflow
- **WHEN** the openspec-audit-change skill is loaded
- **THEN** the agent follows the structured audit steps to evaluate the change
