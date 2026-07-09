---
name: openspec-audit-change
description: Audit an existing change proposal for accuracy, completeness, and validity before implementation. Use after opsx-propose to review generated artifacts.
license: MIT
compatibility: Requires openspec CLI.
metadata:
  author: jebucha
  version: "1.0"
---

Audit an existing change proposal for quality issues before implementation.

I'll evaluate the change artifacts for:
- **Accuracy**: Are artifacts consistent with each other and the actual codebase?
- **Completeness**: Are all required sections present and covered?
- **Validity**: Do artifacts follow structural conventions and contain well-formed content?

---

**Input**: The argument after `/opsx-audit` is the change name (kebab-case). If omitted, check if it can be inferred from conversation context. If vague or ambiguous, prompt for available changes.

**Steps**

1. **Select the change**

   If a name is provided, use it. Otherwise:
   - Infer from conversation context if the user mentioned a change
   - Auto-select if only one active change exists
   - If ambiguous, run `openspec list --json` to get available changes and use the **AskUserQuestion tool** to let the user select

   Always announce: "Auditing change: <name>" and how to override (e.g., `/opsx-audit <other>`).

2. **Check change status**
   ```bash
   openspec status --change "<name>" --json
   ```
   Parse the JSON to understand:
   - `schemaName`: The workflow being used (e.g., "spec-driven")
   - `artifacts`: Which artifacts exist and their status
   - `isComplete`: Whether all artifacts are created

   **If no artifacts exist yet:** Report that the change has no artifacts to audit. Suggest using `/opsx-propose` or `/opsx-apply` first.

3. **Read all available artifact files**

   Read every artifact file that exists for the change:
   - `openspec/changes/<name>/proposal.md`
   - `openspec/changes/<name>/design.md`
   - `openspec/changes/<name>/specs/**/*.md` (use glob to find all spec files)
   - `openspec/changes/<name>/tasks.md`

   Skip files that don't exist — their absence will be flagged during the audit.

4. **Run Accuracy Checks**

   Evaluate whether artifacts are consistent with each other and the actual codebase.

   **4a. Capability name consistency**
   - Parse the proposal's "New Capabilities" and "Modified Capabilities" sections
   - For each listed capability, verify a corresponding spec file exists at `openspec/changes/<name>/specs/<capability>/spec.md`
   - For modified capabilities, verify the base spec exists at `openspec/specs/<capability>/spec.md`

   **4b. Referenced file existence**
   - Scan the design.md and tasks.md for references to source code files (paths like `src/`, `lib/`, `tests/`, etc.)
   - For each referenced file, check if it exists in the workspace
   - Use glob to verify — do not assume file existence from memory

   **4c. Spec contradictions**
   - If multiple spec files exist, check for requirements that define conflicting behavior
   - Look for requirements in different specs that address the same behavior with different rules
   - Compare requirement descriptions and scenarios for logical contradictions

   Report each finding with:
   - **Error**: Missing spec for listed capability, contradictory specs
   - **Warning**: Referenced source file does not exist

5. **Run Completeness Checks**

   Evaluate whether required sections are present and content is fully covered.

   **5a. Missing requirement scenarios**
   - For each `### Requirement:` block in spec files, check that at least one `#### Scenario:` follows before the next `### Requirement:` or `##` header
   - Flag requirements with no scenarios

   **5b. Task-to-spec coverage**
   - Parse tasks from tasks.md (lines matching `- [ ]` or `- [x]`)
   - For each task, determine if a spec requirement covers it
   - Flag tasks that appear unrelated to any spec requirement

   **5c. Empty or placeholder sections**
   - Check each artifact for sections that are present but contain only:
     - Empty content (header with no body text before next header)
     - Placeholder text like `<!-- ... -->`, `TBD`, `TODO`, `<description>`
   - Flag incomplete sections

   Report each finding with:
   - **Warning**: Missing scenarios, empty sections
   - **Info**: Tasks without clear spec coverage

6. **Run Validity Checks**

   Evaluate whether artifacts follow structural conventions and contain well-formed content.

   **6a. Non-testable requirements**
   - Review each requirement for testability
   - A requirement is non-testable if it cannot be verified by observable behavior (e.g., "the system should be fast", "the code should be clean")
   - Flag requirements lacking measurable or observable criteria

   **6b. Task dependency chains**
   - If tasks reference other tasks by number (e.g., "depends on 2.1"), verify the referenced task exists
   - Flag broken cross-references

   **6c. Naming convention compliance**
   - Verify capability names use kebab-case (e.g., `user-auth`, not `userAuth` or `user_auth`)
   - Verify change name uses kebab-case
   - Flag violations with suggested corrections

   Report each finding with:
   - **Error**: Broken task dependencies
   - **Warning**: Non-testable requirements
   - **Info**: Naming convention violations

7. **Produce Structured Output**

   Display the audit results in a structured format:

   ```
   ## Audit Report: <change-name>

   **Schema:** <schema-name>
   **Artifacts checked:** <list of artifacts that were read>

   ### Summary
   - Errors: <count>
   - Warnings: <count>
   - Info: <count>

   ---

   ### Accuracy

   [List findings, prefixed with severity]
   - **[Error]** <description> — <evidence>
   - **[Warning]** <description> — <evidence>

   ### Completeness

   [List findings]

   ### Validity

   [List findings]

   ---

   ### Verdict
   ```

   **Verdict based on findings:**
   - If errors exist: "Cannot proceed to implementation. Resolve errors first."
   - If only warnings: "Can proceed with caution. Consider addressing warnings."
   - If only info or clean: "Ready for implementation."
   - If no artifacts found: "No artifacts to audit. Create the change first."

8. **Offer follow-up actions**

   After displaying the report, offer:
   - "Want me to help fix any of these findings?"
   - "Run `/opsx-apply` to start implementing (if no blocking errors)."
   - "Run `/opsx-explore` to discuss the findings."

**Output Examples**

**Clean audit:**
```
## Audit Report: add-user-auth

**Schema:** spec-driven
**Artifacts checked:** proposal.md, design.md, specs/user-auth/spec.md, tasks.md

### Summary
- Errors: 0
- Warnings: 0
- Info: 1

### Validity
- **[Info]** Task 3.2 has no direct spec requirement — may be implementation detail

### Verdict
Ready for implementation.
```

**Audit with errors:**
```
## Audit Report: add-data-export

**Schema:** spec-driven
**Artifacts checked:** proposal.md, specs/csv-export/spec.md, tasks.md

### Summary
- Errors: 2
- Warnings: 1
- Info: 0

### Accuracy
- **[Error]** Capability `pdf-export` listed in proposal but no spec file found at `specs/pdf-export/spec.md`

### Completeness
- **[Error]** Requirement "User can filter exports" has no scenarios
- **[Warning]** Section "Goals / Non-Goals" in design.md is empty

### Verdict
Cannot proceed to implementation. Resolve errors first.
```

**Guardrails**

- **Read-only** — Never modify artifacts during audit. Flag issues; don't fix them.
- **Evidence-based** — Every finding must include specific evidence (file path, line reference, quoted text)
- **Scope to referenced files** — When checking file existence, only check files explicitly mentioned in artifacts, not the entire codebase
- **Don't be prescriptive** — Focus on structural issues and inconsistencies. Use Info level for subjective observations
- **Handle missing artifacts gracefully** — If an artifact doesn't exist, note it but continue auditing what's available
- **Use path-aware tools** — Use glob for finding spec files, not hardcoded paths with forward slashes
- **Be thorough but efficient** — Check all artifacts that exist, but don't spend excessive time on large codebases
