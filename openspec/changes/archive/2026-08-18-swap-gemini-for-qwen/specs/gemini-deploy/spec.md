## REMOVED Requirements

### Requirement: Gemini auto-detection
**Reason**: Gemini CLI is no longer a supported deployment target; the team has moved to Qwen Code.
**Migration**: Use a Qwen Code project with a `.qwen/` directory (or the `--qwen` flag) instead.

### Requirement: Gemini force flag
**Reason**: Gemini CLI is no longer a supported deployment target; the team has moved to Qwen Code.
**Migration**: Use the `--qwen` flag instead of `--gemini`.

### Requirement: Commands deployed to opsx subdirectory
**Reason**: Gemini CLI is no longer a supported deployment target; the team has moved to Qwen Code.
**Migration**: Commands are now deployed as-is to `.qwen/commands/<name>.md` for Qwen Code projects.

### Requirement: Markdown to TOML conversion
**Reason**: Gemini CLI is no longer a supported deployment target; Qwen Code uses the same plain-markdown command format as opencode, so no conversion is needed.
**Migration**: No conversion occurs; command files are copied unchanged to `.qwen/commands/`.

### Requirement: Skills deployed unchanged
**Reason**: Gemini CLI is no longer a supported deployment target; the team has moved to Qwen Code.
**Migration**: Skills are now copied to `.qwen/skills/*/` for Qwen Code projects.

### Requirement: Deployment progress output
**Reason**: Gemini CLI is no longer a supported deployment target; the team has moved to Qwen Code.
**Migration**: Progress lines use the `[qwen]` prefix for Qwen Code deployments.
