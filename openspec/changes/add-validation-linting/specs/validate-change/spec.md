## ADDED Requirements

### Requirement: Validate runs executable linting on changed files
The validation skill SHALL execute the project's linter against files modified by the current change and incorporate findings into the validation report.

#### Scenario: Linting runs successfully with no issues
- **WHEN** the linter executes on changed files and exits with code 0
- **THEN** no lint findings are added to the report

#### Scenario: Linting finds issues
- **WHEN** the linter executes on changed files and reports violations
- **THEN** findings are added to the report with Category "Executable: lint", classified by severity

#### Scenario: Linting fails due to tool error
- **WHEN** the linter command fails due to misconfiguration or missing dependencies
- **THEN** a single Error finding is raised with the linter's error message

#### Scenario: No linter available
- **WHEN** no linter is detected and the user does not provide `--lint-cmd`
- **THEN** an Info finding is raised: "No linter configuration detected"
