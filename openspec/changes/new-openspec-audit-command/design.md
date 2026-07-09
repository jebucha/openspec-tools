## Context

The OpenSpec workflow provides commands for proposing changes (`opsx-propose`), implementing them (`opsx-apply`), exploring ideas (`opsx-explore`), and archiving completed work (`opsx-archive`). However, there's no command to review a generated change proposal before implementation begins. After `/opsx-propose` produces artifacts, users may want to validate that the proposal is accurate, complete, and internally consistent before investing time in implementation.

Existing commands follow a consistent pattern: a `.opencode/commands/` markdown file (triggered by slash command) delegates to a `.opencode/skills/` SKILL.md file containing the detailed workflow.

## Goals / Non-Goals

**Goals:**
- Provide a command that audits an existing change proposal for quality issues
- Detect accuracy problems: artifacts inconsistent with each other or the actual codebase
- Detect completeness gaps: missing sections, uncovered spec requirements, orphaned tasks
- Detect validity issues: non-testable requirements, broken dependency chains, naming convention violations
- Follow the established command + skill pattern used by opsx-propose, opsx-apply, etc.

**Non-Goals:**
- Modifying or auto-fixing the artifacts (that's the user's job after review)
- Auditing implemented code quality (this is pre-implementation review only)
- Replacing human judgment (the audit surfaces issues; the user decides)

## Decisions

**Decision 1: Audit as a read-only skill, not a CLI subcommand**
The audit runs entirely within the AI agent context (like explore mode), reading artifacts and codebase files to assess quality. It doesn't need a new `openspec` CLI subcommand because it's an agent-assisted review, not an automated check. This keeps the CLI surface minimal.

**Decision 2: Three-category audit structure**
Audits check three dimensions:
- **Accuracy**: Do artifacts match reality? (e.g., proposal references files that don't exist, specs contradict each other)
- **Completeness**: Is anything missing? (e.g., requirement with no scenario, task not covered by any spec)
- **Validity**: Are artifacts well-formed? (e.g., non-testable requirements, broken dependency chains in tasks)

This structure maps naturally to what users care about and produces actionable findings.

**Decision 3: Change selection mirrors opsx-apply**
If no change name is provided, the audit command lists available changes and lets the user pick. This matches the pattern used by `opsx-apply` and `opsx-archive`.

**Decision 4: Structured output with severity levels**
Findings are categorized as:
- **Error**: Blocks implementation (e.g., missing required artifact, contradictory specs)
- **Warning**: Should be addressed (e.g., vague requirement, uncovered task)
- **Info**: Observations for awareness (e.g., unconventional naming, large task scope)

## Risks / Trade-offs

**Risk: False positives in accuracy checks** → Mitigation: The audit flags potential issues with evidence, letting the user confirm. Never auto-rejects.

**Risk: Audit becomes too prescriptive** → Mitigation: Focus on structural issues (missing sections, inconsistencies) rather than style preferences. Info-level findings for subjective observations.

**Risk: Large codebases make accuracy checks slow** → Mitigation: Scope accuracy checks to files explicitly referenced in the artifacts, not the entire codebase.
