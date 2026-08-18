## 1. Swap gemini for qwen in deploy.sh

- [x] 1.1 Replace the `--gemini` force flag with `--qwen` in the argument parsing case statement
- [x] 1.2 Replace the `.gemini/` directory check with a `.qwen/` check in the auto-detection block
- [x] 1.3 Update the error message: list `.qwen/` instead of `.gemini/` in expected directories, use `openspec init → creates .qwen/` in the init hints, and list `--qwen` instead of `--gemini` in the force-target line
- [x] 1.4 Replace `deploy_gemini()` with `deploy_qwen()`: copy `commands/*.md` as-is to `.qwen/commands/` (preserving filenames) and `skills/*/` as-is to `.qwen/skills/*/`, printing `  [qwen] command: <name>.md` and `  [qwen] skill: <skill-name>` progress lines
- [x] 1.5 Replace `gemini) deploy_gemini ;;` with `qwen) deploy_qwen ;;` in the deployment loop
- [x] 1.6 Reject unknown `--` flags (e.g. `--gemini`) with an "Unknown option" error listing the valid flags, instead of silently absorbing them as the target path

## 2. Update README.md

- [x] 2.1 Replace the `.gemini/` detection bullet in the deployment section with a `.qwen/` bullet (commands to `.qwen/commands/`, skills to `.qwen/skills/`) and replace the `--gemini` example with `--qwen`
- [x] 2.2 Replace the `.gemini/` entry in the Project Structure tree with a `.qwen/` entry (commands + skills, no TOML note)

## 3. Update .gitignore

- [x] 3.1 Replace the `.gemini/` entry with `.qwen/`

## 4. Verify

- [x] 4.1 Run `bash -n deploy.sh` to confirm the script parses
- [x] 4.2 Run `./deploy.sh --qwen .` in this repo and confirm all 4 commands land in `.qwen/commands/` and all 4 skills in `.qwen/skills/` with `[qwen]` progress lines
- [x] 4.3 Run `./deploy.sh` in an empty temp directory and confirm the error message lists `.qwen/` / `--qwen` and contains no reference to gemini
- [x] 4.4 Grep the repo (excluding `openspec/changes/archive/`) for remaining gemini deploy references and confirm only model-identifier examples (`gemini-pro` audit filenames) remain
- [x] 4.5 Run `openspec validate "swap-gemini-for-qwen"` and confirm it passes

## 5. Test harness

- [x] 5.1 Add `tests/deploy_test.sh` covering the five qwen-deploy spec requirements (auto-detection, force flag, as-is commands, unchanged skills, progress output), unknown-flag rejection, and regression sanity for the opencode/kiro/claude targets
- [x] 5.2 Run `bash tests/deploy_test.sh` and confirm all assertions pass
