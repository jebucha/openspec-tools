## Context

The validate-change skill (step 8) currently performs static code inspection — reading source files for evidence of implemented behavior. It classifies findings as Error/Warning/Info but never executes any tooling against the code. This means lint errors, type mismatches, and formatting violations pass through undetected.

The skill modifies `.opencode/skills/openspec-validate-change/SKILL.md`, a Markdown instructions file consumed by the opencode agent at runtime. No compiled code, no new dependencies.

## Goals / Non-Goals

**Goals:**
- Auto-detect the project's linter from config files
- Prompt the user to install the linter if detected but not present
- Execute the linter against only the files changed by the current change
- Classify lint findings: style-only → Warning, semantic/runtime → Error
- Merge lint findings into the existing validation report (VD-* IDs, 50-finding cap)
- Support user override via `--lint-cmd` flag

**Non-Goals:**
- Running tests (future enhancement)
- Running type checkers separately (future enhancement)
- Running build commands (future enhancement)
- Auto-installing linters (prompt only, user executes)
- Baseline comparison against pre-implementation state
- Cross-language linter orchestration in a single run

## Decisions

**D1: Insert as new step 8, shift existing steps 8→9, 9→10**

Linting runs after spec/task checks (steps 5-7) so we know the scope of changed files, but before regression safety (current step 9). This ordering ensures lint findings don't get lost behind higher-priority semantic checks.

Alternatives considered:
- Replace step 8 entirely — rejected, static inspection catches things linters don't (dead code, pattern consistency)
- Run linting first — rejected, we need the changed file list from step 4 and context from steps 5-7

**D2: Detection via config file scanning, not language inference**

Scan for known linter config files rather than inferring from file extensions. A `.eslintrc.cjs` file is a stronger signal than a `.ts` file (which could use biome, biome, or no linter).

Detection table:
| Config file | Linter | Command |
|---|---|---|
| `.eslintrc*`, `eslint.config.*` | ESLint | `npx eslint <files>` |
| `.prettierrc*`, `prettier.config.*` | Prettier | `npx prettier --check <files>` |
| `biome.json`, `biome.jsonc` | Biome | `npx biome check <files>` |
| `pyproject.toml` (with `[tool.ruff]`) | Ruff | `ruff check <files>` |
| `.stylelintrc*` | Stylelint | `npx stylelint <files>` |
| `.markdownlint.json*` | Markdownlint | `npx markdownlint <files>` |

If multiple linters detected, run all of them.

**D3: Tool install prompt, not auto-install**

When a linter is detected from config but not found in PATH or node_modules, the skill prompts:

> "Detected ESLint config but `eslint` is not installed. Run `npm install --save-dev eslint` to continue with linting, or skip linting checks."

Rationale: Auto-installing packages is destructive and may conflict with lockfiles. Prompting gives the user control.

Alternatives considered:
- Auto-install — rejected, modifies project state during read-only validation
- Silent skip — rejected, user should know linting was skipped

**D4: Severity classification by linter type**

Different linters produce different classes of output:

| Linter | All output classified as | Rationale |
|---|---|---|
| ESLint | Rule-dependent | ESLint rules have severity (error/warn); map error→Error, warn→Warning |
| Prettier | Warning | Prettier is purely formatting; no semantic issues |
| Biome | Rule-dependent | Biome has lint/format categories; lint errors→Error, format→Warning |
| Ruff | Rule-dependent | Ruff codes indicate category (E/F→Error, W→Warning) |
| Stylelint | Warning | CSS formatting; no runtime impact |
| Unknown | Warning | Default to Warning for unrecognized linters |

**D5: Scoped to changed files only**

Pass the file list from step 4 (git diff) to the linter. This avoids surfacing pre-existing issues and keeps execution fast.

**D6: User override via `--lint-cmd`**

The user can specify a custom command: `/opsx-validate --lint-cmd "biome check"`. This bypasses auto-detection entirely.

## Risks / Trade-offs

[Risk] Linter command fails due to missing config or misconfiguration → **Mitigation**: Capture exit code + stderr, report as single Error finding with the error message, continue validation

[Risk] Linter output is verbose or unparseable → **Mitigation**: Parse line-by-line for file:line patterns; unparseable output becomes a single Info finding with truncated output

[Risk] Linter is slow on large file sets → **Mitigation**: 30-second timeout per linter command; timeout produces a Warning finding

[Risk] Multiple linters produce overlapping findings → **Mitigation**: Deduplicate by file+line; keep the higher-severity finding

[Trade-off] Style-only issues are Warnings, not Errors — this aligns with the user's intent but means formatting violations won't block archive. Acceptable: formatting is low-impact, can be fixed post-archive.

## Open Questions

- Should we support per-project lint configuration (e.g., a `.openspec-lint.json`)? Not for this iteration.
- How do we handle monorepos where the linter needs a workspace root? Detect from `package.json` workspaces or `Cargo.toml` members — defer to next iteration.
