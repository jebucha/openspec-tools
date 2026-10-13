# Proposal

## Why

`deploy.sh` supports four agent environments (opencode, kiro, claude, qwen) but not the pi coding agent. Projects using pi cannot receive the openspec-tools commands and skills through the standard deployment path, so pi users must copy files by hand.

## What Changes

- `deploy.sh` gains a fifth deployment target, `pi`:
  - Auto-detection of a `.pi/` directory in the target project (alongside the existing four).
  - A `--pi` force flag, consistent with `--opencode`, `--kiro`, `--claude`, `--qwen`.
  - Commands from `commands/*.md` are copied as-is to `.pi/prompts/<name>.md` (pi prompt templates; filename becomes the `/command` name).
  - Skills from `skills/*/` are copied unchanged to `.pi/skills/*/`.
  - Progress lines in the existing `  [pi] command: <name>` / `  [pi] skill: <name>` format.
  - Error and hint messages updated to include `.pi/` and `--pi`.
- `tests/deploy_test.sh` gains a pi test block mirroring the qwen block (auto-detection, force flag, as-is content, skills unchanged, progress output) and updates the error-message assertions.
- `README.md` deployment section lists `.pi/` detection and the `--pi` flag.
- `.gitignore` adds `.pi/` for consistency with the other four deploy-target directories.

## Capabilities

### New Capabilities

- `pi-deploy`: Deploy openspec-tools commands and skills to a pi agent project, copying source files as-is into the `.pi/` directory structure (`.pi/prompts/` for commands, `.pi/skills/` for skills).

### Modified Capabilities

(none — no existing spec's requirements change)

## Impact

- Code: `deploy.sh` (argument parsing, environment detection, new `deploy_pi()` function, dispatch, messages), `tests/deploy_test.sh`.
- Docs: `README.md` (deployment section).
- Repo hygiene: `.gitignore`.
- No changes to source `commands/` or `skills/` content — pi's prompt template and Agent Skills formats are compatible with the existing files as-is (verified against pi 1.1.0 docs: `description:` frontmatter, `$@` argument substitution, and the skill frontmatter fields `name`, `description`, `license`, `compatibility`, `metadata` are all supported).
