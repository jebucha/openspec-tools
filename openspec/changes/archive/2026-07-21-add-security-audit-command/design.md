## Context

The openspec-tools project provides slash commands that invoke corresponding skills for the OpenSpec workflow. Currently, 4 skills exist under `skills/`: `openspec-apply-audit`, `openspec-audit-change`, `openspec-validate-change`, and `security-audit`. The first three each have a matching command file under `commands/` (e.g., `opsx-audit.md` invokes `openspec-audit-change`). The `security-audit` skill has no corresponding command, making it undiscoverable and unusable via the standard `/opsx-*` pattern.

The `security-audit` skill is a comprehensive, multi-phase security auditing tool (borrowed from cloudflare/security-audit-skill) that guides agents through reconnaissance, hunting, validation, reporting, structured output, and independent verification. It operates on a target codebase and produces audit artifacts.

## Goals / Non-Goals

**Goals:**
- Add `commands/opsx-security-audit.md` that invokes the `security-audit` skill
- Follow the existing command pattern (frontmatter description, skill invocation, input handling)
- Deploy the command to `.opencode/commands/`
- Document the command in `README.md`

**Non-Goals:**
- Modifying the security-audit skill itself
- Adding new phases or features to the audit workflow
- Creating a separate skill — only the command wrapper is needed

## Decisions

**Command name: `opsx-security-audit`**
- Follows the `opsx-` prefix convention used by all other commands
- The `security-audit` suffix matches the skill name and clearly describes the function
- Alternatives considered: `opsx-sec-audit` (too abbreviated), `opsx-audit-security` (inconsistent with other commands that use the skill name)

**Command structure mirrors `opsx-audit.md`**
- The existing `opsx-audit.md` is the simplest command (21 lines) and serves as the best template
- Frontmatter with `description` YAML field
- Brief body describing what the command does and invoking the skill via the Skill tool
- Input handling: optional target path, with fallback to conversation context or prompt

**No additional input parameters beyond target**
- The security-audit skill itself handles target codebase and output directory setup internally
- The command should be a thin wrapper — parameter handling belongs in the skill, not the command

## Risks / Trade-offs

- [Minimal risk] The command is a thin wrapper around an existing, well-tested skill. No new logic is introduced.
- [Naming collision] The `opsx-audit` command already exists for OpenSpec artifact auditing. The distinct name `opsx-security-audit` and clear description in frontmatter should prevent confusion.
