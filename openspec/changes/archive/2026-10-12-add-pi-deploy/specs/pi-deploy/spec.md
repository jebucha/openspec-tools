# Spec Delta

## Purpose

Deploy openspec-tools commands and skills to a pi agent project, copying source files as-is into the `.pi/` directory structure (`.pi/prompts/` for commands, `.pi/skills/` for skills).

## ADDED Requirements

### Requirement: Pi auto-detection
deploy.sh SHALL detect a `.pi/` directory in the target project and include `pi` in the deployment environments.

#### Scenario: Pi directory detected
- **WHEN** the target directory contains `.pi/`
- **THEN** `pi` is added to the list of deployment environments
- **AND** commands and skills are deployed to the pi target

#### Scenario: No pi directory
- **WHEN** the target directory does not contain `.pi/` and no `--pi` flag is passed
- **THEN** pi is not included in the deployment environments

### Requirement: Pi force flag
deploy.sh SHALL support a `--pi` flag to force deployment to a pi environment.

#### Scenario: Force pi deployment
- **WHEN** the user passes `--pi` as an argument
- **THEN** only the pi environment is deployed to, regardless of directory detection

### Requirement: Commands deployed as-is
deploy.sh SHALL copy command files from `commands/*.md` to `.pi/prompts/<name>.md` without modification, preserving the original filename including the `opsx-` prefix.

#### Scenario: Command file deployed
- **WHEN** a file `commands/opsx-audit.md` exists in the source
- **THEN** it is copied to `.pi/prompts/opsx-audit.md`
- **AND** the file content, including YAML frontmatter, is unchanged

#### Scenario: Multiple commands deployed
- **WHEN** multiple `commands/*.md` files exist in the source
- **THEN** each is copied to `.pi/prompts/` with its original filename

### Requirement: Skills deployed unchanged
deploy.sh SHALL copy skill directories from `skills/*/` to `.pi/skills/*/` without modification.

#### Scenario: Skill directory deployed
- **WHEN** a directory `skills/openspec-audit-change/` exists with `SKILL.md`
- **THEN** the directory is copied to `.pi/skills/openspec-audit-change/`
- **AND** all files within the skill directory are preserved

### Requirement: Deployment progress output
deploy.sh SHALL print progress messages for each pi command and skill deployed.

#### Scenario: Progress shown for commands
- **WHEN** commands are deployed to pi
- **THEN** each command prints a line in the format `  [pi] command: <name>.md`

#### Scenario: Progress shown for skills
- **WHEN** skills are deployed to pi
- **THEN** each skill prints a line in the format `  [pi] skill: <skill-name>`
