## ADDED Requirements

### Requirement: Tools repo contains audit artifacts
The `~/.openspec-tools/` repo SHALL contain the audit command file, the audit skill file, and the install script in a known directory structure.

#### Scenario: Repo structure is correct
- **WHEN** the tools repo is cloned
- **THEN** the following paths exist relative to the repo root:
  - `command/opsx-audit.md`
  - `skill/openspec-audit-change/SKILL.md`
  - `install.sh`

### Requirement: Install script copies artifacts to target repo
The `install.sh` script SHALL copy the audit command and skill files into the target repo's `.opencode/` directory in the correct locations.

#### Scenario: Install to current directory
- **WHEN** the user runs `./install.sh` from within a repo that has `.opencode/`
- **THEN** the command file is placed at `.opencode/commands/opsx-audit.md`
- **THEN** the skill file is placed at `.opencode/skills/openspec-audit-change/SKILL.md`

#### Scenario: Install to specified path
- **WHEN** the user runs `./install.sh /path/to/repo`
- **THEN** the command file is placed at `/path/to/repo/.opencode/commands/opsx-audit.md`
- **THEN** the skill file is placed at `/path/to/repo/.opencode/skills/openspec-audit-change/SKILL.md`

### Requirement: Install script validates target has .opencode directory
The `install.sh` script SHALL verify the target repo has an `.opencode/` directory before proceeding, ensuring `openspec init` was run.

#### Scenario: Target lacks .opencode directory
- **WHEN** the user runs `install.sh` in a directory without `.opencode/`
- **THEN** the script prints an error message indicating `openspec init` should be run first
- **THEN** the script exits with a non-zero status without copying any files

### Requirement: Install script is idempotent
The `install.sh` script SHALL be safe to run multiple times, overwriting existing artifacts with the latest versions.

#### Scenario: Re-run install on existing artifacts
- **WHEN** the user runs `install.sh` in a repo that already has the audit command and skill installed
- **THEN** the existing files are overwritten with the current versions from the tools repo
- **THEN** the script reports success

### Requirement: Install script resolves source paths relative to script location
The `install.sh` script SHALL locate artifact files relative to its own directory, not the current working directory.

#### Scenario: Script invoked from different directory
- **WHEN** the user runs `~/.openspec-tools/install.sh /path/to/repo` from a directory other than `~/.openspec-tools/`
- **THEN** the script correctly reads artifacts from `~/.openspec-tools/command/` and `~/.openspec-tools/skill/`
