## 1. Rename install.sh to deploy.sh

- [x] 1.1 Rename `~/.openspec-tools/install.sh` to `~/.openspec-tools/deploy.sh`
- [x] 1.2 Verify `deploy.sh` still works: test deploying to a target repo with `.opencode/`
- [x] 1.3 Test `deploy.sh` with explicit path argument
- [x] 1.4 Test `deploy.sh` error path: target without `.opencode/`

## 2. Create install.sh at repo root

- [x] 2.1 Create `install.sh` at the repo root with `set -euo pipefail`
- [x] 2.2 Implement SCRIPT_DIR resolution and `$HOME`-based target path
- [x] 2.3 Implement `mkdir -p ~/.openspec-tools/` and `cp -r * ~/.openspec-tools/`
- [x] 2.4 Add success message with target path
- [x] 2.5 Make script executable with `chmod +x install.sh`

## 3. Verify end-to-end workflow

- [x] 3.1 Test fresh install: remove `~/.openspec-tools/`, run `./install.sh`, verify all files are present
- [ ] 3.2 Test re-install: run `./install.sh` again, verify files are overwritten cleanly
- [ ] 3.3 Test full workflow: run `./install.sh`, then `~/.openspec-tools/deploy.sh` to a target repo, verify artifacts land correctly
