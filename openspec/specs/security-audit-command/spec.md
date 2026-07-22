# security-audit-command Specification

## Purpose
TBD - created by archiving change add-security-audit-command. Update Purpose after archive.
## Requirements
### Requirement: Security audit command exists
A command file `commands/opsx-security-audit.md` SHALL exist that invokes the `security-audit` skill.

#### Scenario: Command file is present
- **WHEN** a user looks for the security audit command
- **THEN** `commands/opsx-security-audit.md` exists with valid YAML frontmatter and a description

#### Scenario: Command invokes the correct skill
- **WHEN** the `/opsx-security-audit` command is triggered
- **THEN** the agent invokes the `security-audit` skill via the Skill tool

### Requirement: Command follows naming convention
The command file SHALL use the `opsx-` prefix and kebab-case naming consistent with existing commands.

#### Scenario: Command name matches convention
- **WHEN** listing command files in `commands/`
- **THEN** the file is named `opsx-security-audit.md`, matching the `opsx-<skill-name>.md` pattern

### Requirement: Command includes frontmatter description
The command file SHALL include a YAML frontmatter block with a `description` field.

#### Scenario: Frontmatter is parseable
- **WHEN** the command file is read
- **THEN** the frontmatter contains `description:` with a concise summary of the command's purpose

### Requirement: Command accepts optional target input
The command SHALL accept an optional argument specifying the target codebase to audit.

#### Scenario: Target provided as argument
- **WHEN** the user runs `/opsx-security-audit /path/to/project`
- **THEN** the target path is passed to the security-audit skill

#### Scenario: Target omitted with context fallback
- **WHEN** the user runs `/opsx-security-audit` without a target and the current working directory is the intended target
- **THEN** the skill uses the current working directory as the target

### Requirement: Command deployed to .opencode
The command SHALL be deployed to `.opencode/commands/opsx-security-audit.md` by `deploy.sh`.

#### Scenario: Deploy script copies command
- **WHEN** `deploy.sh` runs against a project with `.opencode/`
- **THEN** `commands/opsx-security-audit.md` is copied to the target's `.opencode/commands/`

### Requirement: Command documented in README
The `README.md` SHALL list `opsx-security-audit.md` in the commands table.

#### Scenario: README commands table includes new command
- **WHEN** a user reads the README commands section
- **THEN** `opsx-security-audit.md` appears with a description of its purpose

### Requirement: Default output path is repo-relative
The security-audit skill SHALL default audit artifacts to `<repo-root>/security-audits/run-<N>`, where `<repo-root>` is the target codebase directory and `<N>` is the next unused integer.

#### Scenario: Default path uses repo subfolder
- **WHEN** the user runs a security audit without specifying an output directory
- **THEN** audit artifacts are written to `<repo-root>/security-audits/run-<N>` where `<N>` is the next available integer

#### Scenario: Output directory is created if missing
- **WHEN** the default output directory does not exist
- **THEN** the skill creates the directory before writing artifacts

#### Scenario: Run numbering increments
- **WHEN** a previous run directory `run-0` already exists under `<repo-root>/security-audits/`
- **THEN** the next run uses `run-1`, and so on

### Requirement: Prior runs are discovered from repo-relative path
The skill SHALL check `<repo-root>/security-audits/` for prior run directories to load previous findings.

#### Scenario: Prior runs found in repo subfolder
- **WHEN** `<repo-root>/security-audits/` contains previous run directories with `findings.json`
- **THEN** the skill reads prior findings to skip known issues and target gaps

#### Scenario: No prior runs in new location
- **WHEN** `<repo-root>/security-audits/` does not exist or is empty
- **THEN** the skill notes that no prior runs exist and recommends additional runs for coverage

### Requirement: User can override output path
The skill SHALL allow the user to specify a custom output directory, overriding the default.

#### Scenario: User provides custom output path
- **WHEN** the user specifies an output directory
- **THEN** audit artifacts are written to the specified directory instead of the default

