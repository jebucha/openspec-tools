## ADDED Requirements

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
