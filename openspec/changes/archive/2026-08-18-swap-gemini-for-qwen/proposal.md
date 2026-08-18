## Why

deploy.sh currently ships the audit tooling to four AI agent environments (opencode, kiro, claude, gemini). The team has moved to Qwen Code as its agent environment, and Gemini CLI support is no longer needed. Qwen Code uses the same plain-markdown command format as opencode (`.qwen/commands/*.md` with YAML frontmatter, `.qwen/skills/<name>/SKILL.md`), so the toolset can be deployed there with no format conversion.

## What Changes

- Add `qwen` as a deployment target: auto-detect `.qwen/` in the target project, add a `--qwen` force flag, and deploy `commands/*.md` as-is to `.qwen/commands/` and `skills/*/` as-is to `.qwen/skills/` (opencode-style copy, no conversion)
- **BREAKING** Remove `gemini` as a deployment target: drop the `--gemini` flag, `.gemini/` auto-detection, and `deploy_gemini()` (including the markdown-to-TOML conversion)
- Update `README.md` deployment docs (detection list, force-flag examples, project structure tree)
- Update `.gitignore`: replace `.gemini/` with `.qwen/` (consistent with the other deploy targets)
- Remove the `gemini-deploy` spec capability; add a `qwen-deploy` spec capability

Not changed: `gemini-pro` references in audit-report filename examples (model identifiers, not deploy targets), archived changes under `openspec/changes/archive/`, and `install.sh` (it copies only non-hidden entries, so deploy targets are unaffected).

## Capabilities

### New Capabilities

- `qwen-deploy`: Deploy commands and skills to a Qwen Code project — `.qwen/` auto-detection, `--qwen` force flag, as-is command and skill copy, and progress output

### Modified Capabilities

- `gemini-deploy`: All requirements removed — the gemini deployment target is dropped entirely

## Impact

- `deploy.sh`: argument parsing, environment auto-detection, `deploy_gemini()` replaced by `deploy_qwen()`, error/usage messages, deployment loop
- `openspec/specs/gemini-deploy/spec.md`: removed (via REMOVED delta); `openspec/specs/qwen-deploy/spec.md`: added on archive
- `README.md`: deployment section, force-flag examples, project structure tree
- `.gitignore`: `.gemini/` entry replaced by `.qwen/`
- Existing projects with `.gemini/` will no longer be detected as deploy targets; `--gemini` invocations will fail with an "Unknown option" error (unknown `--` flags are rejected explicitly)
