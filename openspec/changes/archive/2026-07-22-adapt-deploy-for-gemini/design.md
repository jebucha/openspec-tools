## Context

deploy.sh currently deploys openspec-tools to three AI agent environments: opencode (`.opencode/`), Kiro (`.kiro/`), and Claude (`.claude/`). Each environment has distinct directory structures and file formats for commands and skills. Google Gemini CLI uses `.gemini/` with its own conventions:
- Commands: `.gemini/commands/opsx/<name>.toml` (TOML format with `description` and `prompt` fields)
- Skills: `.gemini/skills/<name>/SKILL.md` (YAML frontmatter + markdown, same as opencode)

Source command files in `commands/` are plain markdown. Gemini requires TOML conversion at deploy time.

## Goals / Non-Goals

**Goals:**
- Deploy commands and skills to `.gemini/` directory structure
- Convert markdown commands to Gemini's TOML format automatically
- Auto-detect `.gemini/` directory alongside existing environments
- Support `--gemini` force flag
- Maintain consistency with existing deploy patterns

**Non-Goals:**
- Modifying source command files
- Adding new commands or skills
- Supporting other AI agent environments

## Decisions

**1. Format conversion at deploy time, not build time**
- Source commands remain as `.md` files in `commands/`
- deploy.sh converts to TOML during deployment
- Rationale: Single source of truth; adding a new environment only requires a new deploy function, not new source files

**2. TOML structure mirrors existing gemini commands**
- `description` = first line of the markdown file (trimmed)
- `prompt` = entire markdown content wrapped in triple-quoted string
- Filename: strip `opsx-` prefix, change extension to `.toml`
- Rationale: Matches existing `.gemini/commands/opsx/` layout observed in the repo

**3. Skills deployment is identical to opencode**
- Copy `skills/*/` → `.gemini/skills/*/`
- Rationale: Gemini skills use the same SKILL.md format as opencode

**4. Auto-detection follows existing pattern**
- Check for `.gemini/` directory in target
- Add `gemini` to ENVS list if found
- Rationale: Consistent with how opencode, kiro, and claude are detected

## Risks / Trade-offs

- **TOML escaping** → Markdown content may contain characters that break TOML (e.g., `"""` in the content). Mitigation: escape triple quotes in the prompt value.
- **Description extraction** → First line may not always be a good description. Mitigation: use the first non-empty, non-heading line as fallback.
- **Missing gemini commands** → Not all source commands have gemini equivalents yet. Mitigation: deploy all available source commands; gemini users get the full set.

## Migration Plan

No migration needed — this is additive. Existing deploy targets are unaffected. Users with `.gemini/` in their project will automatically receive the deployment on next `deploy.sh` run.
