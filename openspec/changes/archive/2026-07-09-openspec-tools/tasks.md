## 1. Create tools repo structure

- [x] 1.1 Create `~/.openspec-tools/` directory and initialize as git repo
- [x] 1.2 Create `command/` directory and copy `opsx-audit.md` from the audit change
- [x] 1.3 Create `skill/openspec-audit-change/` directory and copy `SKILL.md` from the audit change

## 2. Write install script

- [x] 2.1 Create `install.sh` with `set -euo pipefail` and SCRIPT_DIR resolution
- [x] 2.2 Implement target directory validation (check for `.opencode/`)
- [x] 2.3 Implement file copying: command to `.opencode/commands/`, skill to `.opencode/skills/openspec-audit-change/`
- [x] 2.4 Add success message with target path
- [x] 2.5 Make script executable (`chmod +x install.sh`)

## 3. Verify installation

- [x] 3.1 Test install in a repo with `openspec init` — verify files land in correct locations
- [x] 3.2 Test install with explicit path argument — verify remote target works
- [x] 3.3 Test install in a repo without `.opencode/` — verify error message and non-zero exit
- [x] 3.4 Test idempotency — re-run install and verify files are overwritten cleanly
