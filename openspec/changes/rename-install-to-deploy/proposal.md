## Why

The `~/.openspec-tools/` directory is a dot-folder outside the main repo, making it impossible to track in git and requiring manual setup on each machine. Moving the tool distribution into the main repo allows cloning once and running a single install script to set up the tools directory on any system.

## What Changes

- Rename the existing `install.sh` (which deploys artifacts to a target repo) to `deploy.sh`
- Create a new `install.sh` at the repo root that bootstraps `~/.openspec-tools/` by creating the directory and copying all tool artifacts into it
- The workflow becomes: clone repo → run `./install.sh` → tools available at `~/.openspec-tools/` → run `~/.openspec-tools/deploy.sh /path/to/target-repo`

## Capabilities

### New Capabilities

### Modified Capabilities
- `openspec-tools-distribution`: The install script is renamed to `deploy.sh` and a new `install.sh` is added that bootstraps the tools into `~/.openspec-tools/` from the repo root

## Impact

- `~/.openspec-tools/install.sh` renamed to `~/.openspec-tools/deploy.sh`
- New `install.sh` at repo root that creates `~/.openspec-tools/` and copies artifacts
- Existing deploy workflow unchanged — only the script name changes from `install.sh` to `deploy.sh`
