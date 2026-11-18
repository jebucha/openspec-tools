## ADDED Requirements

### Requirement: Linter auto-detection from project config files
The validation skill SHALL detect the project's linter by scanning for known configuration files before executing linting.

#### Scenario: ESLint config detected
- **WHEN** the project contains `.eslintrc.*`, `eslint.config.*`, or `eslint` in `package.json` dependencies
- **THEN** the skill identifies ESLint as the linter with command `npx eslint <files>`

#### Scenario: Prettier config detected
- **WHEN** the project contains `.prettierrc.*` or `prettier.config.*`
- **THEN** the skill identifies Prettier as the linter with command `npx prettier --check <files>`

#### Scenario: Ruff config detected
- **WHEN** the project contains `pyproject.toml` with a `[tool.ruff]` section
- **THEN** the skill identifies Ruff as the linter with command `ruff check <files>`

#### Scenario: No linter config found
- **WHEN** no known linter config files exist in the project
- **THEN** the skill skips linting with an Info finding: "No linter configuration detected"

#### Scenario: Multiple linters detected
- **WHEN** multiple linter config files exist (e.g., ESLint + Prettier)
- **THEN** the skill queues all detected linters for execution

### Requirement: Tool install prompt when linter is missing
The validation skill SHALL prompt the user to install the detected linter if the binary is not available.

#### Scenario: Linter detected but not installed
- **WHEN** a linter config exists but the linter binary is not found in PATH or local dependencies
- **THEN** the skill prompts the user with the install command and asks whether to proceed without linting

#### Scenario: User chooses to install
- **WHEN** the user confirms they will install the linter
- **THEN** the skill waits for the user to complete installation before re-checking

#### Scenario: User chooses to skip
- **WHEN** the user declines to install the linter
- **THEN** the skill skips linting and records an Info finding: "Linting skipped — user declined install"

#### Scenario: Linter already installed
- **WHEN** the linter binary is available
- **THEN** the skill proceeds to execution without prompting

### Requirement: Linting executes on changed files only
The validation skill SHALL run the linter against only the files modified or created by the current change.

#### Scenario: Changed files passed to linter
- **WHEN** linting executes
- **THEN** the linter receives only the file paths identified in step 4 (git diff --name-only)

#### Scenario: No changed files to lint
- **WHEN** git diff returns no source files
- **THEN** the skill skips linting with an Info finding: "No changed files to lint"

#### Scenario: Linter command times out
- **WHEN** the linter command does not complete within 30 seconds
- **THEN** the skill terminates the command and records a Warning finding with the timeout message

### Requirement: Lint findings classified by severity
The validation skill SHALL classify lint findings as Error or Warning based on the linter type and rule severity.

#### Scenario: ESLint error-level rule violation
- **WHEN** ESLint reports a rule violation at severity 2 (error)
- **THEN** the finding is classified as Error

#### Scenario: ESLint warning-level rule violation
- **WHEN** ESLint reports a rule violation at severity 1 (warn)
- **THEN** the finding is classified as Warning

#### Scenario: Prettier formatting issue
- **WHEN** Prettier reports a formatting difference
- **THEN** the finding is classified as Warning (style-only)

#### Scenario: Ruff error code violation
- **WHEN** Ruff reports a violation with an E or F prefix code
- **THEN** the finding is classified as Error

#### Scenario: Ruff warning code violation
- **WHEN** Ruff reports a violation with a W prefix code
- **THEN** the finding is classified as Warning

### Requirement: Lint findings merge into validation report
The validation skill SHALL integrate lint findings into the structured validation report with VD-* IDs.

#### Scenario: Lint findings appear in findings table
- **WHEN** linting produces findings
- **THEN** findings appear in the report with Category "Executable: lint" and stable VD-* IDs

#### Scenario: Lint findings count toward cap
- **WHEN** total findings (spec + task + lint) exceed 50
- **THEN** findings are capped at 50, prioritized by severity (Errors first)

#### Scenario: Lint errors affect verdict
- **WHEN** linting produces one or more Error findings
- **THEN** the verdict is Fail (unless overridden by style-only classification)

#### Scenario: Style-only warnings do not block verdict
- **WHEN** linting produces only Warning findings
- **THEN** the verdict is Conditional or Pass (depending on other findings)

### Requirement: User override via lint-cmd flag
The validation skill SHALL accept a `--lint-cmd` flag to specify a custom linter command.

#### Scenario: Custom lint command provided
- **WHEN** the user runs `/opsx-validate --lint-cmd "biome check"`
- **THEN** the skill bypasses auto-detection and executes the provided command against changed files

#### Scenario: Custom command fails
- **WHEN** the custom lint command exits with a non-zero code
- **THEN** the skill captures the output and generates findings from the error messages
