## Context

Current README shows a 5-step workflow starting with propose and ending with archive. It treats explore as "Additional" and omits validate entirely. The validate command exists but is named `opsx-validate-change`, inconsistent with shorter names of other commands.

## Goals / Non-Goals

**Goals:**
- Present the full 7-step workflow as the canonical path
- Make explore the recommended starting point
- Make validate a first-class quality gate
- Show how to iterate when issues are found

**Non-Goals:**
- Changing any command or skill behavior
- Adding new commands or skills
- Modifying the deploy.sh or install.sh scripts

## Decisions

- **Explore as step 1, not required**: Marked "recommended before proposing" to encourage thinking without blocking trivial changes.
- **Validate between apply and archive**: Positioned as the gate before finalizing, matching its purpose of verifying implementation.
- **Rename to `opsx-validate`**: Shorter, consistent with `opsx-audit`, `opsx-apply`, `opsx-archive`.
- **ASCII diagram for looping**: Visual representation of iteration paths is clearer than prose alone.
- **Quality Gates and Validation Dimensions sections**: Document audit and validate as critical gates and list the five validation dimensions, mirroring the existing Audit Categories section.

## Risks / Trade-offs

- **Backward compatibility**: The rename from `opsx-validate-change` to `opsx-validate` means anyone who memorized the old name will need to adjust. Mitigation: the skill name stays `openspec-validate-change`, only the command file is renamed.
