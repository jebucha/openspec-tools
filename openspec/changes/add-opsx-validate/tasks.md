## 1. Create command file

- [x] 1.1 Create `.opencode/commands/opsx-validate.md` with command metadata, input handling, and step-by-step instructions
- [x] 1.2 Define the command flow: select change → read artifacts → run validation → persist report → show verdict

## 2. Create skill file

- [x] 2.1 Create `.opencode/skills/openspec-validate-change/` directory
- [x] 2.2 Create `SKILL.md` with skill metadata (name: `openspec-validate-change`, description, compatibility)
- [x] 2.3 Implement change selection logic (explicit name, context inference, auto-select, prompt)
- [x] 2.4 Implement artifact reading step (proposal, design, specs, tasks)
- [x] 2.5 Implement spec compliance validation (check each requirement against code)
- [x] 2.6 Implement test coverage validation (check tests exist for requirements)
- [x] 2.7 Implement task completion validation (verify all tasks marked complete and code exists)
- [x] 2.8 Implement regression detection (compare against prior validations)
- [x] 2.9 Implement structured report output with findings table, coverage metrics, and verdict
- [x] 2.10 Implement report persistence to `openspec/changes/<name>/validations/`
- [x] 2.11 Implement supersede logic for older validation files

## 3. Create validation report format

- [x] 3.1 Define report template: header (change, schema, model, artifacts checked), summary (errors/warnings/info), findings table (ID, category, severity, description, evidence), coverage metrics, verdict
- [x] 3.2 Define finding ID format: `VD-N` with deterministic numbering
- [x] 3.3 Define verdict rules: Pass (0 errors), Conditional (warnings only), Fail (1+ errors)

## 4. Wire command to skill

- [x] 4.1 Ensure command file instructs the LLM to invoke the `openspec-validate-change` skill
- [x] 4.2 Add follow-up action suggestions: fix findings, re-validate, proceed to archive