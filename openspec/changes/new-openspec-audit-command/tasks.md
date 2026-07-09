## 1. Create Skill Directory Structure

- [x] 1.1 Create `.opencode/skills/openspec-audit-change/` directory
- [x] 1.2 Verify directory structure matches existing skill pattern

## 2. Write the Audit Skill

- [x] 2.1 Write `SKILL.md` frontmatter with name `openspec-audit-change`, description, license, and metadata
- [x] 2.2 Implement change selection logic: prompt for change name, list available changes, auto-select if unambiguous
- [x] 2.3 Implement accuracy audit: check capability names match spec files, verify referenced code files exist, detect contradictory specs
- [x] 2.4 Implement completeness audit: check all requirements have scenarios, verify tasks map to specs, detect empty sections
- [x] 2.5 Implement validity audit: check for non-testable requirements, verify task dependencies are valid, validate naming conventions
- [x] 2.6 Implement severity classification: categorize findings as error, warning, or info
- [x] 2.7 Implement structured output: formatted summary with findings grouped by category and severity
- [x] 2.8 Write guardrails section: read-only operation, no auto-fixes, focus on structural issues

## 3. Write the Command File

- [x] 3.1 Create `.opencode/commands/opsx-audit.md` with frontmatter description
- [x] 3.2 Write command body that delegates to the openspec-audit-change skill
- [x] 3.3 Document input handling: optional change name argument, fallback to listing changes

## 4. Verify Cross-Platform Compatibility

- [x] 4.1 Ensure all path operations in the skill use `path.join()` or `path.resolve()` patterns
- [x] 4.2 Verify no hardcoded path separators in the command or skill files

## 5. Validate Against Existing Pattern

- [x] 5.1 Compare command file structure against `opsx-propose.md` and `opsx-apply.md`
- [x] 5.2 Compare skill file structure against `openspec-propose/SKILL.md` and `openspec-apply-change/SKILL.md`
- [x] 5.3 Verify consistency in formatting, section ordering, and guardrails
