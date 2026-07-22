## Why

The deploy.sh script currently supports opencode, Kiro, and Claude environments but lacks support for Google Gemini CLI. Projects using `.gemini/` as their AI agent configuration directory cannot deploy openspec-tools, limiting the toolset's reach across AI development environments.

## What Changes

- Add `deploy_gemini()` function to deploy.sh that converts command files from `.md` format to Gemini's `.toml` format and deploys skills
- Add `--gemini` force flag to argument parsing
- Auto-detect `.gemini/` directory alongside existing environments
- Convert `commands/*.md` → `.gemini/commands/opsx/<name>.toml` (TOML with `description` + `prompt` fields, stripping `opsx-` prefix from filenames)
- Deploy `skills/*/` → `.gemini/skills/*/` (same structure as opencode)
- Update README.md with gemini deployment documentation

## Capabilities

### New Capabilities
- `gemini-deploy`: Deploy commands and skills to a Gemini CLI project, including markdown-to-TOML format conversion for commands

### Modified Capabilities

## Impact

- `deploy.sh`: Added `deploy_gemini()` function, `--gemini` flag, `.gemini/` auto-detection
- `README.md`: Updated installation/deployment section with gemini support
- No changes to source commands/skills — deploy.sh handles format conversion at deployment time
