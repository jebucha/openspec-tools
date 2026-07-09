---
name: openspec-audit-change
description: Audit an existing change proposal for accuracy, completeness, validity, and feasibility before implementation. Use after opsx-propose to review generated artifacts.
license: MIT
compatibility: Requires openspec CLI.
metadata:
  author: jebucha
  version: "1.1"
---

Audit an existing change proposal for quality issues before implementation.

I'll evaluate the change artifacts for:
- **Accuracy**: Are artifacts consistent with each other and the actual codebase?
- **Completeness**: Are all required sections present and covered?
- **Validity**: Do artifacts follow structural conventions and contain well-formed content?
- **Feasibility**: Is the design achievable given the actual codebase?
- **Coherence**: Do proposal, design, and tasks align in scope and intent?

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

   **5a. Missing required artifacts**
   - Based on the schema, determine which artifacts are required (e.g., spec-driven requires proposal, design, specs, tasks)
   - If a required artifact is entirely absent, flag as Error
   - Distinguish between "file doesn't exist" (Error) and "file exists but has gaps" (Warning)

   **5b. Missing requirement scenarios**
   - For each `### Requirement:` block in spec files, check that at least one `#### Scenario:` follows before the next `### Requirement:` or `##` header
   - Flag requirements with no scenarios

   **5c. Task-to-spec coverage**
   - Parse tasks from tasks.md (lines matching `- [ ]` or `- [x]`)
   - For each task, determine if a spec requirement covers it
   - Flag tasks that appear unrelated to any spec requirement

   **5d. Empty or placeholder sections**
   - Check each artifact for sections that are present but contain only:
     - Empty content (header with no body text before next header)
     - Placeholder text like `<!-- ... -->`, `TBD`, `TODO`, `<description>`
   - Flag incomplete sections

   Report each finding with:
   - **Error**: Missing required artifact entirely
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

7. **Run Feasibility Checks**

   Evaluate whether the design is achievable given the actual codebase state.

   **7a. Design-to-codebase compatibility**
   - Identify source files the design proposes to modify (look for "modify", "update", "extend", "refactor" language paired with file paths or module names)
   - For each target file, read it and verify:
     - The file exists
     - Functions/classes/interfaces mentioned in the design actually exist in that file
     - The proposed modification approach is compatible with the current code structure (e.g., design says "add a method to UserService" — does UserService exist? Is it a class that can accept methods?)
   - Flag mismatches between what the design assumes and what actually exists

   **7b. Dependency and import feasibility**
   - If the design references libraries, packages, or modules, verify they are available:
     - Check package.json, requirements.txt, Cargo.toml, go.mod, etc. for declared dependencies
     - If a new dependency is proposed, note it (Info) — not an error, but worth flagging
   - If the design references internal modules/imports, verify those modules exist

   **7c. Pattern consistency**
   - Read 2-3 existing files in the same area of the codebase that the change targets
   - Compare the design's proposed approach against established patterns:
     - Does the codebase use classes or functions? Does the design match?
     - Does the codebase use a specific framework pattern (MVC, repository, etc.)? Does the design follow it?
     - Does the codebase use specific error handling patterns? Does the design account for them?
   - Flag significant deviations from established patterns

   Report each finding with:
   - **Error**: Design references functions/classes that don't exist and aren't being created by this change
   - **Warning**: Design proposes patterns inconsistent with existing codebase conventions
   - **Info**: New dependencies introduced, minor pattern deviations

8. **Run Coherence Checks**

   Evaluate whether proposal, design, and tasks align in scope and intent.

   **8a. Proposal-to-design scope alignment**
   - Parse the proposal's stated scope (goals, non-goals, capabilities)
   - Review the design for components, systems, or behaviors not mentioned in the proposal
   - Flag design elements that exceed proposal scope (scope creep)
   - Flag proposal goals that have no corresponding design coverage (gaps)

   **8b. Spec-to-design consistency**
   - For each spec requirement, determine if the design describes a mechanism that would satisfy it
   - Flag requirements that have no plausible design support
   - Flag design components that serve no spec requirement and aren't infrastructure

   **8c. Task ordering and buildability**
   - Parse tasks in order and build a mental dependency graph:
     - Does task N use/import/call something that task N+M creates?
     - Are foundational tasks (creating files, interfaces, types) ordered before tasks that depend on them?
   - Flag ordering issues where a task depends on output from a later task
   - Flag tasks that are too coarse to be actionable (e.g., "implement the entire authentication system" as a single task)
   - Flag tasks that are trivially fine-grained to the point of noise (e.g., "add a blank line")

   **8d. Security surface awareness** (apply only when the change touches auth, data handling, external I/O, or user input)
   - Does the design address input validation for new entry points?
   - Are there tasks for error handling on new failure modes?
   - If new external communication is introduced, is TLS/encryption mentioned?
   - If new credentials or secrets are involved, does the design reference a secrets manager?
   - Flag omissions as Warnings — don't block, but ensure awareness

   Report each finding with:
   - **Error**: Design exceeds proposal scope significantly, task ordering makes implementation impossible
   - **Warning**: Spec requirements with no design support, security surface omissions, overly coarse tasks
   - **Info**: Minor scope observations, trivially fine-grained tasks

9. **Produce Structured Output**

   Display the audit results in a structured format:

   ```
   ## Audit Report: <change-name>

   **Schema:** <schema-name>
   **Model:** <model that performed the audit>
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

   ### Feasibility

   [List findings]

   ### Coherence

   [List findings]

   ---

   ### Verdict
   ```

   **Verdict based on findings:**
   - If errors exist: "Cannot proceed to implementation. Resolve errors first."
   - If only warnings: "Can proceed with caution. Consider addressing warnings."
   - If only info or clean: "Ready for implementation."
   - If no artifacts found: "No artifacts to audit. Create the change first."

10. **Persist the audit report**

    Save the structured output to a file within the change directory:

    ```
    openspec/changes/<name>/audits/<timestamp>-<model>.md
    ```

    - Create the `audits/` directory if it doesn't exist
    - Timestamp format: `YYYY-MM-DDTHH-MM` (e.g., `2026-07-09T15-42`)
    - Model: short identifier of the model that performed the audit (e.g., `claude-opus`, `gemini-pro`, `gpt-4o`)
    - Example: `openspec/changes/add-user-auth/audits/2026-07-09T15-42-claude-opus.md`

    The persisted file contains the full structured report exactly as displayed, enabling:
    - Multiple audits with different LLMs for comparison
    - Historical tracking across audit iterations (pre-fix, post-fix)
    - Decoupled workflow — `/opsx-apply-audit` can load from file without needing same session

    Announce: "Audit saved to `<path>`"

11. **Offer follow-up actions**

    After displaying the report, offer:
    - "Want me to help fix any of these findings?"
    - "Run `/opsx-apply-audit` to apply fixes to the artifacts."
    - "Run `/opsx-apply` to start implementing (if no blocking errors)."
    - "Run `/opsx-explore` to discuss the findings."
    - "Run `/opsx-audit` again with a different model to compare."

**Output Examples**

**Clean audit:**
```
## Audit Report: add-user-auth

**Schema:** spec-driven
**Artifacts checked:** proposal.md, design.md, specs/user-auth/spec.md, tasks.md

### Summary
- Errors: 0
- Warnings: 0
- Info: 2

### Coherence
- **[Info]** Task 3.2 has no direct spec requirement — may be implementation detail
- **[Info]** New dependency `argon2` will be introduced (not currently in package.json)

### Verdict
Ready for implementation.
```

**Audit with errors:**
```
## Audit Report: add-data-export

**Schema:** spec-driven
**Artifacts checked:** proposal.md, design.md, specs/csv-export/spec.md, tasks.md

### Summary
- Errors: 4
- Warnings: 3
- Info: 1

### Accuracy
- **[Error]** Capability `pdf-export` listed in proposal but no spec file found at `specs/pdf-export/spec.md`

### Completeness
- **[Error]** Requirement "User can filter exports" has no scenarios
- **[Warning]** Section "Goals / Non-Goals" in design.md is empty

### Feasibility
- **[Error]** Design references `ExportService.generatePdf()` in `src/services/export.ts` — file exists but no `ExportService` class found; only `exportData()` function exists
- **[Warning]** Design proposes class-based service pattern but codebase uses functional modules exclusively

### Coherence
- **[Error]** Task 2 ("Add PDF template rendering") depends on `src/templates/base.ts` which is created in Task 5
- **[Warning]** Design includes a "notification system" for export completion — not mentioned in proposal scope
- **[Warning]** No error handling tasks for the new S3 upload path introduced in design
- **[Info]** Task 4.1 ("add semicolon to line 42") is trivially fine-grained

### Verdict
Cannot proceed to implementation. Resolve errors first.
```

**Audit with only warnings:**
```
## Audit Report: add-cli-flags

**Schema:** spec-driven
**Artifacts checked:** proposal.md, design.md, specs/cli-flags/spec.md, tasks.md

### Summary
- Errors: 0
- Warnings: 2
- Info: 0

### Feasibility
- **[Warning]** Design proposes using `commander` option chaining but current CLI uses `yargs` — pattern mismatch

### Coherence
- **[Warning]** Requirement "flags are validated before execution" has no clear design mechanism described

### Verdict
Can proceed with caution. Consider addressing warnings.
```

**Guardrails**

- **Read-only** — Never modify artifacts during audit. Flag issues; don't fix them.
- **Evidence-based** — Every finding must include specific evidence (file path, line reference, quoted text)
- **Scope to referenced files** — When checking file existence, only check files explicitly mentioned in artifacts, not the entire codebase
- **Don't be prescriptive** — Focus on structural issues and inconsistencies. Use Info level for subjective observations
- **Handle missing artifacts gracefully** — If an artifact doesn't exist, note it but continue auditing what's available
- **Use path-aware tools** — Use glob for finding spec files, not hardcoded paths with forward slashes
- **Be thorough but efficient** — Check all artifacts that exist, but don't spend excessive time on large codebases
- **Feasibility checks are best-effort** — Reading source files to verify design claims is valuable but not exhaustive. Check the specific files and symbols referenced; don't audit the entire codebase.
- **Security checks are contextual** — Only apply security surface checks (8d) when the change touches auth, user input, data storage, external communication, or secrets. Don't flag security on purely cosmetic or refactoring changes.
- **Pattern checks require evidence** — When flagging pattern inconsistency, cite the existing files you read and the specific pattern observed. Don't assert conventions without checking.
