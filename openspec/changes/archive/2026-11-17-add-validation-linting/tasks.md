## 1. Insert new step 8 into SKILL.md

- [ ] 1.1 Add step 8 "Executable Linting" after step 7 (Task Completion), renumber existing steps 8→9, 9→10, 10→11, 11→12, etc.
- [ ] 1.2 Write step 8a: Detect linter — scan for config files (`.eslintrc*`, `eslint.config.*`, `.prettierrc*`, `prettier.config.*`, `biome.json`, `pyproject.toml` with `[tool.ruff]`, `.stylelintrc*`, `.markdownlint.json*`), build tool manifest
- [ ] 1.3 Write step 8b: Verify linter installed — check binary in PATH / `npx --yes` availability; if missing, prompt user with install command and wait for response
- [ ] 1.4 Write step 8c: Execute linter — run detected linter against changed files from step 4, capture stdout/stderr/exit code, enforce 30s timeout
- [ ] 1.5 Write step 8d: Classify findings — parse linter output, map to Error/Warning by linter type (ESLint severity, Prettier→Warning, Ruff codes, Biome categories), deduplicate by file+line
- [ ] 1.6 Write step 8e: Merge into report — assign VD-* IDs, set Category "Executable: lint", include in findings table and summary counts

## 2. Add user override support

- [ ] 2.1 Add `--lint-cmd` flag documentation to step 1 (Select the change) — describe the flag and its behavior
- [ ] 2.2 Add logic in step 8a: if `--lint-cmd` provided, skip auto-detection, use provided command

## 3. Update guardrails

- [ ] 3.1 Add guardrail: "Linting is scoped — only changed files are linted. Pre-existing issues outside the change scope are not reported."
- [ ] 3.2 Add guardrail: "Linting timeout — each linter command has a 30-second timeout. Timeout produces a Warning, not an Error."
- [ ] 3.3 Add guardrail: "Tool install is opt-in — never auto-install packages. Prompt the user and wait."

## 4. Update output examples

- [ ] 4.1 Add a lint finding to the Pass verdict example (e.g., `VD-4 | Executable: lint | Warning | Trailing whitespace in auth.ts`)
- [ ] 4.2 Add a lint finding to the Fail verdict example (e.g., `VD-3 | Executable: lint | Error | Unused variable 'result' in export.ts:23`)

## 5. Update spec file

- [ ] 5.1 Add "Requirement: Validate runs executable linting on changed files" with 4 scenarios to `openspec/specs/validate-change/spec.md`

## 6. Create linting-verification spec file

- [ ] 6.1 Create `openspec/specs/linting-verification/spec.md` with requirements for: auto-detection, tool install prompt, scoped execution, severity classification, report merge, user override
