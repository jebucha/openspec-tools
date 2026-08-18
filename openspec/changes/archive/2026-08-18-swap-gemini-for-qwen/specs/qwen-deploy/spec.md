## Purpose

Deploy openspec-tools commands and skills to a Qwen Code project, copying source files as-is into the `.qwen/` directory structure.

## ADDED Requirements

### Requirement: Qwen auto-detection
deploy.sh SHALL detect a `.qwen/` directory in the target project and include `qwen` in the deployment environments.

#### Scenario: Qwen directory detected
- **WHEN** the target directory contains `.qwen/`
- **THEN** `qwen` is added to the list of deployment environments
- **AND** commands and skills are deployed to the qwen target

#### Scenario: No qwen directory
- **WHEN** the target directory does not contain `.qwen/` and no `--qwen` flag is passed
- **THEN** qwen is not included in the deployment environments

### Requirement: Qwen force flag
deploy.sh SHALL support a `--qwen` flag to force deployment to a qwen environment.

#### Scenario: Force qwen deployment
- **WHEN** the user passes `--qwen` as an argument
- **THEN** only the qwen environment is deployed to, regardless of directory detection

### Requirement: Commands deployed as-is
deploy.sh SHALL copy command files from `commands/*.md` to `.qwen/commands/<name>.md` without modification, preserving the original filename including the `opsx-` prefix.

#### Scenario: Command file deployed
- **WHEN** a file `commands/opsx-audit.md` exists in the source
- **THEN** it is copied to `.qwen/commands/opsx-audit.md`
- **AND** the file content, including YAML frontmatter, is unchanged

#### Scenario: Multiple commands deployed
- **WHEN** multiple `commands/*.md` files exist
- **THEN** each is copied to `.qwen/commands/` with its original filename

### Requirement: Skills deployed unchanged
deploy.sh SHALL copy skill directories from `skills/*/` to `.qwen/skills/*/` without modification.

#### Scenario: Skill directory deployed
- **WHEN** a directory `skills/openspec-audit-change/` exists with `SKILL.md`
- **THEN** the directory is copied to `.qwen/skills/openspec-audit-change/`
- **AND** all files within the skill directory are preserved

### Requirement: Deployment progress output
deploy.sh SHALL print progress messages for each qwen command and skill deployed.

#### Scenario: Progress shown for commands
- **WHEN** commands are deployed to qwen
- **THEN** each command prints a line in the format `  [qwen] command: <name>.md`

#### Scenario: Progress shown for skills
- **WHEN** skills are deployed to qwen
- **THEN** each skill prints a line in the format `  [qwen] skill: <skill-name>`
