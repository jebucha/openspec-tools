## ADDED Requirements

### Requirement: Gemini auto-detection
deploy.sh SHALL detect a `.gemini/` directory in the target project and include `gemini` in the deployment environments.

#### Scenario: Gemini directory detected
- **WHEN** the target directory contains `.gemini/`
- **THEN** `gemini` is added to the list of deployment environments
- **AND** commands and skills are deployed to the gemini target

#### Scenario: No gemini directory
- **WHEN** the target directory does not contain `.gemini/` and no `--gemini` flag is passed
- **THEN** gemini is not included in the deployment environments

### Requirement: Gemini force flag
deploy.sh SHALL support a `--gemini` flag to force deployment to a gemini environment.

#### Scenario: Force gemini deployment
- **WHEN** the user passes `--gemini` as an argument
- **THEN** only the gemini environment is deployed to, regardless of directory detection

### Requirement: Commands deployed to opsx subdirectory
deploy.sh SHALL copy command files from `commands/*.md` to `.gemini/commands/opsx/<name>.toml`.

#### Scenario: Command file deployed
- **WHEN** a file `commands/opsx-propose.md` exists in the source
- **THEN** it is deployed to `.gemini/commands/opsx/propose.toml`
- **AND** the `opsx-` prefix is stripped from the filename

#### Scenario: Multiple commands deployed
- **WHEN** multiple `commands/*.md` files exist
- **THEN** each is converted and deployed to `.gemini/commands/opsx/` with the `opsx-` prefix stripped

### Requirement: Markdown to TOML conversion
deploy.sh SHALL convert markdown command files to Gemini's TOML format with `description` and `prompt` fields.

#### Scenario: Successful TOML conversion
- **WHEN** a command file `opsx-propose.md` is deployed
- **THEN** the output `.toml` file contains a `description` field with a brief description
- **AND** the output `.toml` file contains a `prompt` field with the full markdown content as a triple-quoted string

#### Scenario: Triple quotes in content are escaped
- **WHEN** the markdown content contains `"""` sequences
- **THEN** the TOML output properly escapes the content to produce valid TOML

### Requirement: Skills deployed unchanged
deploy.sh SHALL copy skill directories from `skills/*/` to `.gemini/skills/*/` without modification.

#### Scenario: Skill directory deployed
- **WHEN** a directory `skills/openspec-propose/` exists with `SKILL.md`
- **THEN** the directory is copied to `.gemini/skills/openspec-propose/`
- **AND** all files within the skill directory are preserved

### Requirement: Deployment progress output
deploy.sh SHALL print progress messages for each gemini command and skill deployed.

#### Scenario: Progress shown for commands
- **WHEN** commands are deployed to gemini
- **THEN** each command prints a line in the format `  [gemini] command: opsx/<name>.toml`

#### Scenario: Progress shown for skills
- **WHEN** skills are deployed to gemini
- **THEN** each skill prints a line in the format `  [gemini] skill: <skill-name>`
