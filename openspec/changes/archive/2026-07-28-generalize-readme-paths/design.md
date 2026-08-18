## Context

The repo has 4 per-skill READMEs with deployment instructions. The source of truth is `skills/` and `commands/` at repo root, with `deploy.sh` handling deployment to all 4 tools (opencode, kiro, claude, gemini). The per-skill READMEs contradict this:

- `openspec-audit-change/README.md`: references `kiro/` paths that don't exist, Kiro-only deployment
- `openspec-apply-audit/README.md`: has `skill/` typo (should be `skills/`), opencode-only paths
- `openspec-validate-change/README.md`: opencode-only deployment section
- Top-level `README.md`: has `skill/` vs `skills/` inconsistencies (Skills table lines 51-52, Project Structure line 108)

## Goals / Non-Goals

**Goals:**
- Remove deployment sections from per-skill READMEs
- Fix path typos in top-level README
- Leave deployment documentation solely in top-level README

**Non-Goals:**
- Restructuring the top-level README
- Adding deployment info to skill READMEs
- Changing `deploy.sh` behavior

## Decisions

- **Per-skill READMEs document only their skill** — no deployment, no file location tables. Deployment is a cross-cutting concern covered by the top-level README.
- **Top-level README is the single source of truth for deployment** — already documents `deploy.sh` with all 4 tools.

## Risks / Trade-offs

- **Readers unfamiliar with the repo** won't find deployment info in the skill README — mitigated by the top-level README being the natural entry point.
