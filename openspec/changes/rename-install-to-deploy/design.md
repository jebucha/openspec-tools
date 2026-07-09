## Context

Currently, `~/.openspec-tools/` is a standalone git repo (created outside the main OpenSpec repo) containing `command/`, `skill/`, and `install.sh`. The `install.sh` script deploys tool artifacts to a target repo's `.opencode/` directory. Because `~/.openspec-tools/` is a dot-folder, it can't live inside a regular git repo, requiring manual cloning and setup on each machine.

The goal is to make the main OpenSpec repo the single source of truth for tool distribution, so that cloning the repo and running one script sets everything up.

## Goals / Non-Goals

**Goals:**
- Cloning the repo and running `./install.sh` bootstraps `~/.openspec-tools/` with all tool artifacts
- The deploy script (renamed from `install.sh` to `deploy.sh`) retains its existing behavior of deploying artifacts to a target repo
- The new `install.sh` is idempotent — safe to re-run to update tools

**Non-Goals:**
- Migrating `~/.openspec-tools/` into the main repo as a submodule or nested repo
- Windows support for the install scripts (bash-only, same as current)
- Modifying the deploy script's functionality

## Decisions

**Decision 1: New `install.sh` uses `cp -r` to copy all repo contents to `~/.openspec-tools/`**

The install script creates `~/.openspec-tools/` and copies all repo files into it using `cp -r * ~/.openspec-tools/`. This is simple, portable, and ensures all artifacts (commands, skills, deploy.sh) are kept in sync. If `~/.openspec-tools/` already exists as a git repo, re-running `install.sh` will overwrite files with the latest versions.

**Decision 2: Rename `install.sh` to `deploy.sh` in the tools directory**

The existing `install.sh` (which deploys to a target repo) is renamed to `deploy.sh` to avoid confusion with the new bootstrap `install.sh`. The deploy script's logic remains unchanged — only the filename changes.

**Decision 3: `install.sh` lives at the repo root**

The new `install.sh` sits at the root of the cloned repo, making it the first thing users see and can run immediately after cloning.

## Risks / Trade-offs

**Risk: Existing users reference `~/.openspec-tools/install.sh`** → Mitigation: The rename to `deploy.sh` is a breaking change for anyone who has the old path in scripts or aliases. Update any documentation that references the old name.

**Risk: `cp -r` overwrites local modifications in `~/.openspec-tools/`** → Mitigation: Acceptable trade-off. The tools directory is meant to be managed from the repo, not customized locally. Users with local changes should back them up before re-running install.
