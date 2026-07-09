---
description: Apply audit findings to an OpenSpec change's artifacts (Experimental)
---

Apply audit findings and recommendations to an OpenSpec change's artifacts.

**Store selection:** If the user names a store (a store is a standalone OpenSpec repo registered on this machine) or the work lives in one, run `openspec store list --json` to discover registered store ids, then pass `--store <id>` on the commands that read or write specs and changes (`new change`, `status`, `instructions`, `list`, `show`, `validate`, `archive`, `doctor`, `context`). Other commands do not take the flag. Hints printed by commands already carry the flag; keep it on follow-ups. Without a store, commands act on the nearest local `openspec/` root.

**Input**: Optionally specify a change name (e.g., `/opsx-apply-audit add-auth`). If omitted, check if it can be inferred from conversation context. If vague or ambiguous you MUST prompt for available changes.

**Steps**

1. **Select the change**

   If a name is provided, use it. Otherwise:
   - Infer from conversation context if the user mentioned a change
   - Auto-select if only one active change exists
   - If ambiguous, run `openspec list --json` to get available changes and use the **AskUserQuestion tool** to let the user select

   Always announce: "Applying audit findings to change: <name>" and how to override (e.g., `/opsx-apply-audit <other>`).

2. **Check change status**
   ```bash
   openspec status --change "<name>" --json
   ```
   Parse the JSON to understand:
   - `schemaName`: The workflow being used (e.g., "spec-driven")
   - `artifacts`: Which artifacts exist and their status
   - `changeRoot`: Path to the change directory

   **If no artifacts exist yet:** Report that the change has no artifacts to fix. Suggest using `/opsx-propose` first.

3. **Locate the audit report**

   Look for the most recent audit output. Check:
   - Conversation context for a prior `/opsx-audit` run in this session
   - If no audit is available in context, run the audit inline:
     ```bash
     # Inform the user
     ```
     Then suggest: "No audit report found in this session. Want me to run `/opsx-audit <name>` first?"

   **If the audit verdict is clean** (0 errors, 0 warnings): Report that no fixes are needed. Suggest proceeding with `/opsx-apply`.

4. **Read all change artifact files**

   Read every artifact file that exists for the change:
   - `openspec/changes/<name>/proposal.md`
   - `openspec/changes/<name>/design.md`
   - `openspec/changes/<name>/specs/**/*.md` (use glob to find all spec files)
   - `openspec/changes/<name>/tasks.md`

5. **Plan remediation from audit findings**

   For each audit finding, determine the appropriate fix:

   **Errors (must fix):**
   - Missing spec for listed capability → Create the spec file with proper structure
   - Contradictory specs → Resolve the conflict by aligning to proposal intent
   - Missing requirement scenarios → Add scenarios that validate the requirement
   - Broken task dependencies → Fix cross-references

   **Warnings (should fix):**
   - Referenced source file does not exist → Update path references or remove stale refs
   - Non-testable requirements → Rewrite with measurable/observable criteria
   - Empty or placeholder sections → Fill in content based on proposal context
   - Missing scenarios → Add meaningful scenarios

   **Info (optional, apply if straightforward):**
   - Naming convention violations → Rename to kebab-case
   - Tasks without spec coverage → Add note or link to relevant requirement

   Present the remediation plan to the user before applying.

6. **Apply fixes (loop through findings)**

   For each finding being remediated:
   - Show which finding is being fixed
   - Make the artifact change
   - Keep changes minimal, consistent with existing artifact style
   - Announce completion of each fix

   **Pause if:**
   - A fix is ambiguous (multiple valid resolutions) → ask user to choose
   - A fix would significantly alter the design intent → confirm with user
   - Fixing one issue would create a new inconsistency → flag it

7. **Re-validate after fixes**

   After all fixes are applied, perform a quick consistency check:
   - Verify capability names still align between proposal and specs
   - Verify task references are intact
   - Verify no new empty sections were introduced

   If new issues are found, report them and offer to fix.

8. **Show summary and next steps**

   Display:
   - Findings resolved this session
   - Any remaining warnings or info items not addressed
   - Suggest: "Run `/opsx-apply` to start implementing."

**Output During Remediation**

```
## Applying Audit Fixes: <change-name>

### Remediation Plan
- [Error] Missing spec for `pdf-export` → Will create specs/pdf-export/spec.md
- [Error] Requirement "User can filter exports" has no scenarios → Will add scenarios
- [Warning] Section "Goals / Non-Goals" in design.md is empty → Will populate

Proceeding with fixes...

Fixing 1/3: Creating specs/pdf-export/spec.md...
✓ Spec created with requirement structure from proposal

Fixing 2/3: Adding scenarios to "User can filter exports"...
✓ 2 scenarios added (happy path + edge case)

Fixing 3/3: Populating "Goals / Non-Goals" in design.md...
✓ Section populated based on proposal scope
```

**Output On Completion**

```
## Audit Fixes Applied: <change-name>

**Schema:** <schema-name>
**Findings resolved:** 3/3

### Fixed This Session
- ✓ [Error] Created missing spec: specs/pdf-export/spec.md
- ✓ [Error] Added 2 scenarios to "User can filter exports"
- ✓ [Warning] Populated "Goals / Non-Goals" section

### Remaining (not addressed)
- [Info] Task 3.2 has no direct spec requirement (implementation detail — no fix needed)

### Quick Validation
✓ Capability names consistent
✓ Task references intact
✓ No new empty sections

Ready for implementation. Run `/opsx-apply` to start.
```

**Output On Pause (Ambiguous Fix)**

```
## Remediation Paused: <change-name>

**Progress:** 2/3 findings fixed

### Ambiguous Finding
**[Error]** Contradictory specs: `user-auth/spec.md` says sessions expire in 30m, `admin-panel/spec.md` says sessions expire in 8h.

**Options:**
1. Align both to 30m (stricter)
2. Use 30m for users, 8h for admins (role-based)
3. Defer to user — what's the intended behavior?

What would you like to do?
```

**Guardrails**
- Always present the remediation plan before making changes
- Never alter design intent — fixes should align artifacts to stated goals, not rewrite goals
- Keep changes minimal and scoped to each finding
- If a fix is ambiguous, pause and ask — don't guess at intent
- Maintain existing artifact style and formatting
- Do not introduce new capabilities or requirements not present in the proposal
- After fixing, validate that fixes don't create new inconsistencies
- Only address findings from the audit — don't expand scope

**Fluid Workflow Integration**

This skill supports the "actions on a change" model:

- **Can be invoked anytime** after an audit has been run
- **Pairs with `/opsx-audit`**: audit identifies issues, apply-audit resolves them
- **Iterative**: Can be run multiple times if new issues surface after fixes
- **Gates `/opsx-apply`**: Ensures artifacts are clean before implementation begins
