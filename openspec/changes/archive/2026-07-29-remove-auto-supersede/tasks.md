## 1. Update audit skill — remove auto-supersede

- [x] 1.1 Remove step 11a (auto-supersede older audit files) from `openspec-audit-change/SKILL.md`
- [x] 1.2 Remove step 11b (header stacking) from `openspec-audit-change/SKILL.md`
- [x] 1.3 Update guardrails: remove "Supersede is timestamp-based" guardrail
- [x] 1.4 Update guardrails: update "Header parsing is position-sensitive" to remove Superseded references
- [x] 1.5 Update step 12 follow-up actions to remove supersede-related language
- [x] 1.6 Re-number steps (11 becomes final persist step, 12 becomes follow-up)

## 2. Update validate skill — remove auto-supersede

- [x] 2.1 Remove step 12a (auto-supersede older validation files) from `openspec-validate-change/SKILL.md`
- [x] 2.2 Update guardrails: remove "Supersede is timestamp-based" guardrail
- [x] 2.3 Update guardrails: update "Header parsing is position-sensitive" to remove Superseded references
- [x] 2.4 Re-number steps (13 becomes follow-up)

## 3. Update apply-audit skill — remove Superseded state

- [x] 3.1 Step 3a: Remove "Superseded" from state derivation rules
- [x] 3.2 Step 3a: Update "no pending audits" message to reference only Resolved
- [x] 3.3 Guardrails: update "Audit state is derived" to remove Superseded reference
- [x] 3.4 Guardrails: update "Header parsing is position-sensitive" to reference only Resolved

## 4. Update main specs

- [x] 4.1 `openspec/specs/audit-lifecycle/spec.md`: Remove "Auto-supersede older audits" requirement and scenarios
- [x] 4.2 `openspec/specs/audit-lifecycle/spec.md`: Update "Audit state derived from headers" — remove Superseded scenario
- [x] 4.3 `openspec/specs/audit-lifecycle/spec.md`: Update "Apply-audit requires pending state" — remove Superseded references
- [x] 4.4 `openspec/specs/audit-lifecycle/spec.md`: Remove "Validation reports follow audit lifecycle" supersede scenarios
- [x] 4.5 `openspec/specs/audit-lifecycle/spec.md`: Update "Backward compatibility" — remove Superseded from legacy audit scenario
- [x] 4.6 `openspec/specs/validate-change/spec.md`: Remove "Older validations are superseded" scenario
- [x] 4.7 Verify regression detection still resolves `## Resolved` headers from prior audits/validations (no dependency on `## Superseded`)

## 5. Sync to all skill copies

- [x] 5.1 Copy updated `openspec-audit-change/SKILL.md` to `skills/`
- [x] 5.2 Copy updated `openspec-validate-change/SKILL.md` to `skills/`
