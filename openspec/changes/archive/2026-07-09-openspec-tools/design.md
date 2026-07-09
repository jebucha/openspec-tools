## Context

The audit command (`opsx-audit.md`) and skill (`openspec-audit-change/SKILL.md`) live in individual repos today, created by `openspec init` or manually. To use them across repos, they need to be copied into each repo's `.opencode/` directory. OpenSpec's planned `installScope: 'global'` feature would solve this natively, but it's not yet implemented.

The `~/.openspec-tools/` repo serves as a distribution hub: a single source of truth for the audit artifacts, with a shell script to install them into any OpenSpec-enabled repo.

## Goals / Non-Goals

**Goals:**
- Provide a single repo containing the canonical audit command and skill files
- Ship a `install.sh` script that copies artifacts into a target repo's `.opencode/` directory
- The script validates the target repo has `.opencode/` (i.e., `openspec init` was run)
- The script is idempotent — re-running updates artifacts in place
- Usage is simple: `openspec init` in target repo, then `~/.openspec-tools/install.sh`

**Non-Goals:**
- Cross-platform support for `install.sh` (bash only — macOS/Linux; Windows users can copy manually)
- Versioning or changelog management of distributed artifacts
- Automatic updates when the tools repo changes
- Contributing the audit command upstream to OpenSpec

## Decisions

**Decision 1: Flat directory structure**
The tools repo uses a simple layout: `command/`, `skill/`, `install.sh`. No build step, no package manager, no dependencies. This keeps it trivially portable — just clone and run.

**Decision 2: install.sh takes target as argument, defaults to current directory**
`install.sh` with no args installs into the current repo. `install.sh /path/to/repo` installs into a specific repo. This supports both "I'm already in the repo" and "I want to install from elsewhere" workflows.

**Decision 3: Script uses SCRIPT_DIR for source paths**
`SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"` ensures the script works regardless of where it's invoked from, as long as the files are in the expected locations relative to the script.

## Risks / Trade-offs

**Risk: Manual update burden** → When the audit skill or command is improved, you need to re-run `install.sh` in each repo. Mitigation: the script is idempotent; keep a mental note to re-run after updating the tools repo.

**Risk: Bash-only on Linux/macOS** → Windows users can't use `install.sh`. Mitigation: Windows users can manually copy files, or use Git Bash/WSL. This is acceptable since the primary use case is Unix-like systems.

**Risk: Drift from upstream OpenSpec** → If OpenSpec changes its command/skill format, the distributed artifacts may become incompatible. Mitigation: the tools repo is small and easy to update.
