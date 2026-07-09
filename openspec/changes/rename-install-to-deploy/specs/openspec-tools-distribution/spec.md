## MODIFIED Requirements

### Requirement: Tools repo contains deploy artifacts
The `~/.openspec-tools/` directory SHALL contain the audit command file, the audit skill file, and the deploy script in a known directory structure.

#### Scenario: Tools directory structure is correct
- **WHEN** the tools directory is set up via `install.sh`
- **THEN** the following paths exist relative to `~/.openspec-tools/`:
  - `command/opsx-audit.md`
  - `skill/openspec-audit-change/SKILL.md`
  - `deploy.sh`

### Requirement: Deploy script copies artifacts to target repo
The `deploy.sh` script SHALL copy the audit command and skill files into the target repo's `.opencode/` directory in the correct locations.

#### Scenario: Deploy to current directory
- **WHEN** the user runs `./deploy.sh` from within a repo that has `.opencode/`
- **THEN** the command file is placed at `.opencode/commands/opsx-audit.md`
- **THEN** the skill file is placed at `.opencode/skills/openspec-audit-change/SKILL.md`

#### Scenario: Deploy to specified path
- **WHEN** the user runs `./deploy.sh /path/to/repo`
- **THEN** the command file is placed at `/path/to/repo/.opencode/commands/opsx-audit.md`
- **THEN** the skill file is placed at `/path/to/repo/.opencode/skills/openspec-audit-change/SKILL.md`

### Requirement: Deploy script validates target has .opencode directory
The `deploy.sh` script SHALL verify the target repo has an `.opencode/` directory before proceeding, ensuring `openspec init` was run.

#### Scenario: Target lacks .opencode directory
- **WHEN** the user runs `deploy.sh` in a directory without `.opencode/`
- **THEN** the script prints an error message indicating `openspec init` should be run first
- **THEN** the script exits with a non-zero status without copying any files

### Requirement: Deploy script is idempotent
The `deploy.sh` script SHALL be safe to run multiple times, overwriting existing artifacts with the latest versions.

#### Scenario: Re-run deploy on existing artifacts
- **WHEN** the user runs `deploy.sh` in a repo that already has the audit command and skill installed
- **THEN** the existing files are overwritten with the current versions from the tools directory
- **THEN** the script reports success

### Requirement: Deploy script resolves source paths relative to script location
The `deploy.sh` script SHALL locate artifact files relative to its own directory, not the current working directory.

#### Scenario: Script invoked from different directory
- **WHEN** the user runs `~/.openspec-tools/deploy.sh /path/to/repo` from a directory other than `~/.openspec-tools/`
- **THEN** the script correctly reads artifacts from `~/.openspec-tools/command/` and `~/.openspec-tools/skill/`

## ADDED Requirements

### Requirement: Install script bootstraps tools directory
The `install.sh` script at the repo root SHALL create `~/.openspec-tools/` and copy all repo contents into it, making the tools available for deployment to other repos.

#### Scenario: Fresh install on new system
- **WHEN** the user clones the repo and runs `./install.sh` on a system without `~/.openspec-tools/`
- **THEN** the directory `~/.openspec-tools/` is created
- **THEN** all repo contents are copied into `~/.openspec-tools/`
- **THEN** the script reports success with the target path

#### Scenario: Re-install updates existing tools
- **WHEN** the user runs `./install.sh` on a system that already has `~/.openspec-tools/`
- **THEN** the existing contents of `~/.openspec-tools/` are overwritten with the current repo contents
- **THEN** the script reports success

### Requirement: Install script resolves home directory correctly
The `install.sh` script SHALL resolve the user's home directory using the `$HOME` environment variable.

#### Scenario: HOME variable is set
- **WHEN** the user runs `./install.sh` with `$HOME` set
- **THEN** the tools are installed to `$HOME/.openspec-tools/`
