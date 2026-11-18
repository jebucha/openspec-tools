# change-security-checks Specification

## Purpose

Provide a lightweight security floor across the change lifecycle. The audit checks the plan, validation checks the diff, and apply-audit remediates findings. Exhaustive analysis is escalated to the `security-audit` skill.

## Requirements

### Requirement: Audit reports a Security category
The audit SHALL evaluate change artifacts under a Security category, a peer of Accuracy, Completeness, Validity, Feasibility, and Coherence. Security findings SHALL use stable IDs prefixed `SC-`, such as `SC-1`, and the regression detection that applies to the other categories SHALL apply to them too. Coherence SHALL NOT contain security checks.

#### Scenario: Security findings use the SC- prefix
- **WHEN** the audit raises a security finding
- **THEN** the finding's ID starts with `SC-`, its Category column reads `Security`, and it counts toward the report's Summary totals

**Test Requirement**
- **ID:** T-CHANGE-SECURITY-CHECKS-001
- **File:** tests/test_skill_content.sh::assert_audit_skill_security_category
- **Command:** `bash tests/test_skill_content.sh assert_audit_skill_security_category`
- **Pass:** exit code 0

#### Scenario: Coherence no longer carries security checks
- **WHEN** the audit runs Coherence checks
- **THEN** no Coherence check evaluates security surface, and no Coherence finding concerns input validation, TLS, or secrets management

**Test Requirement**
- **ID:** T-CHANGE-SECURITY-CHECKS-002
- **File:** tests/test_skill_content.sh::assert_audit_skill_coherence_no_security
- **Command:** `bash tests/test_skill_content.sh assert_audit_skill_coherence_no_security`
- **Pass:** exit code 0

### Requirement: Always-run secrets checks at audit
The audit SHALL run two secrets checks on every change, whatever surfaces it touches. A credential-looking value in any change artifact SHALL be an Error. A design that introduces a credential without naming where it comes from at runtime, such as an environment variable or a secrets manager, SHALL be a Warning.

#### Scenario: Secret pasted into an artifact
- **WHEN** design.md contains a value matching the secret pattern set, such as a private-key header or a provider-prefixed token in an example config block
- **THEN** the audit raises an Error `SC-n` finding citing the artifact and line, even when the change is purely cosmetic

**Test Requirement**
- **ID:** T-CHANGE-SECURITY-CHECKS-003
- **File:** tests/test_skill_content.sh::assert_audit_skill_security_category
- **Command:** `bash tests/test_skill_content.sh assert_audit_skill_security_category`
- **Pass:** exit code 0

#### Scenario: Placeholder values are not secrets
- **WHEN** an artifact contains a placeholder, such as `<API_KEY>`, `${TOKEN}`, `$SECRET`, `changeme`, or a value marked `example` or `dummy`
- **THEN** no secrets-in-artifacts finding is raised for it

**Test Requirement**
- **ID:** T-CHANGE-SECURITY-CHECKS-004
- **File:** tests/test_skill_content.sh::assert_secret_pattern_set
- **Command:** `bash tests/test_skill_content.sh assert_secret_pattern_set`
- **Pass:** exit code 0

#### Scenario: Credential introduced without a stated source
- **WHEN** the proposal or design introduces an API key, token, password, or certificate and names no runtime source for it
- **THEN** the audit raises a Warning `SC-n` finding "secret handling not planned"

**Test Requirement**
- **ID:** T-CHANGE-SECURITY-CHECKS-005
- **File:** tests/test_skill_content.sh::assert_audit_skill_security_category
- **Command:** `bash tests/test_skill_content.sh assert_audit_skill_security_category`
- **Pass:** exit code 0

#### Scenario: No credentials and no secrets
- **WHEN** the change introduces no credentials and its artifacts match no secret pattern
- **THEN** the always-run checks raise no finding

**Test Requirement**
- **ID:** T-CHANGE-SECURITY-CHECKS-019
- **File:** tests/test_skill_content.sh::assert_audit_skill_security_category
- **Command:** `bash tests/test_skill_content.sh assert_audit_skill_security_category`
- **Pass:** exit code 0

### Requirement: Contextual security checks at audit
When a change touches auth, user input, data storage, external communication, secrets, permissions, or crypto, the audit SHALL also run three checks. Untrusted input without planned validation, or built into shell, SQL, eval, or file paths by string concatenation, SHALL be a Warning. A weakened control without a stated rationale SHALL be a Warning. Escalation SHALL be one Info per change, raised only when the change touches auth, crypto, permissions, or secrets.

#### Scenario: Untrusted input without planned validation
- **WHEN** the design adds an entry point that accepts external input and neither design nor tasks plan validation
- **THEN** the audit raises a Warning `SC-n` finding

**Test Requirement**
- **ID:** T-CHANGE-SECURITY-CHECKS-006
- **File:** tests/test_skill_content.sh::assert_audit_skill_security_category
- **Command:** `bash tests/test_skill_content.sh assert_audit_skill_security_category`
- **Pass:** exit code 0

#### Scenario: Weakened control
- **WHEN** the design disables TLS verification, bypasses an auth check, or widens file permissions or network exposure without a stated rationale
- **THEN** the audit raises a Warning `SC-n` finding

**Test Requirement**
- **ID:** T-CHANGE-SECURITY-CHECKS-007
- **File:** tests/test_skill_content.sh::assert_audit_skill_security_category
- **Command:** `bash tests/test_skill_content.sh assert_audit_skill_security_category`
- **Pass:** exit code 0

#### Scenario: Escalation to the full security audit
- **WHEN** the change touches auth, crypto, permissions, or secrets
- **THEN** the audit raises exactly one Info `SC-n` finding recommending `/opsx-security-audit` for exhaustive analysis

**Test Requirement**
- **ID:** T-CHANGE-SECURITY-CHECKS-008
- **File:** tests/test_skill_content.sh::assert_security_escalation
- **Command:** `bash tests/test_skill_content.sh assert_security_escalation`
- **Pass:** exit code 0

#### Scenario: Non-security change skips contextual checks
- **WHEN** the change is a pure refactor or documentation change that touches none of the trigger surfaces
- **THEN** the contextual checks raise no finding, and the always-run checks still run

**Test Requirement**
- **ID:** T-CHANGE-SECURITY-CHECKS-020
- **File:** tests/test_skill_content.sh::assert_audit_skill_security_category
- **Command:** `bash tests/test_skill_content.sh assert_audit_skill_security_category`
- **Pass:** exit code 0

### Requirement: Validation scans the diff for secrets
Validation SHALL scan the change's added lines and newly added files with the same secret pattern set the audit uses. It SHALL also flag newly added credential files (`.env`, `.env.*`, `*.pem`, `*.key`, `id_rsa*`, `*.p12`, `*.pfx`). Template variants (`.env.example`, `.env.sample`, `.env.template`) SHALL be exempt. Each hit SHALL be an Error with Category `Security`.

#### Scenario: Committed credential
- **WHEN** a changed file adds a line matching the secret pattern set
- **THEN** validation raises an Error `VD-n` finding with Category `Security`, citing the file, line, and pattern type

**Test Requirement**
- **ID:** T-CHANGE-SECURITY-CHECKS-009
- **File:** tests/test_skill_content.sh::assert_validate_skill_security_check
- **Command:** `bash tests/test_skill_content.sh assert_validate_skill_security_check`
- **Pass:** exit code 0

#### Scenario: New credential file
- **WHEN** the change adds a `.env`, `*.pem`, `*.key`, `id_rsa*`, `*.p12`, or `*.pfx` file
- **THEN** validation raises an Error `VD-n` finding with Category `Security`, unless the file is a template variant (`.env.example`, `.env.sample`, `.env.template`)

**Test Requirement**
- **ID:** T-CHANGE-SECURITY-CHECKS-010
- **File:** tests/test_skill_content.sh::assert_validate_skill_security_check
- **Command:** `bash tests/test_skill_content.sh assert_validate_skill_security_check`
- **Pass:** exit code 0

### Requirement: Secret scanning never installs tools
Validation SHALL treat the built-in pattern set as the baseline scan. It MAY add findings from a secret scanner already on PATH, run only with that scanner's redaction enabled. It SHALL NOT install, download, or update a scanner. A missing scanner SHALL NOT produce a finding.

#### Scenario: Scanner not installed
- **WHEN** no secret scanner is on PATH
- **THEN** validation runs the built-in pattern scan only, installs nothing, and raises no finding about the missing scanner

**Test Requirement**
- **ID:** T-CHANGE-SECURITY-CHECKS-011
- **File:** tests/test_skill_content.sh::assert_validate_skill_no_scanner_install
- **Command:** `bash tests/test_skill_content.sh assert_validate_skill_no_scanner_install`
- **Pass:** exit code 0

### Requirement: Validation checks code-level security and plan follow-through
Validation SHALL raise Warnings with Category `Security` on files the change touches in these cases: untrusted input concatenated into shell, SQL, eval, or file paths; disabled TLS verification or auth checks; new dependencies without pinned versions; remote scripts piped to a shell; and code that does not deliver a secret source or validation the design promised, or an unresolved `SC-` finding from the latest audit.

#### Scenario: Disabled TLS verification in the diff
- **WHEN** a changed file disables certificate verification
- **THEN** validation raises a Warning `VD-n` finding with Category `Security`

**Test Requirement**
- **ID:** T-CHANGE-SECURITY-CHECKS-012
- **File:** tests/test_skill_content.sh::assert_validate_skill_security_check
- **Command:** `bash tests/test_skill_content.sh assert_validate_skill_security_check`
- **Pass:** exit code 0

#### Scenario: Design promise not delivered
- **WHEN** design.md states that a credential is read from an environment variable and the implementation reads it from a literal or a committed config file
- **THEN** validation raises a Warning `VD-n` finding with Category `Security` that quotes the design statement and cites the code location

**Test Requirement**
- **ID:** T-CHANGE-SECURITY-CHECKS-013
- **File:** tests/test_skill_content.sh::assert_validate_skill_security_check
- **Command:** `bash tests/test_skill_content.sh assert_validate_skill_security_check`
- **Pass:** exit code 0

#### Scenario: Escalation at validate
- **WHEN** the changed files touch auth, crypto, permissions, or secrets
- **THEN** validation raises exactly one Info `VD-n` finding with Category `Security` recommending `/opsx-security-audit`

**Test Requirement**
- **ID:** T-CHANGE-SECURITY-CHECKS-014
- **File:** tests/test_skill_content.sh::assert_security_escalation
- **Command:** `bash tests/test_skill_content.sh assert_security_escalation`
- **Pass:** exit code 0

### Requirement: Secret values are never reproduced
No audit, validation, or apply-audit output, whether displayed or persisted, SHALL contain any part of a detected secret value. Findings SHALL cite the file, line, and pattern type only.

#### Scenario: Persisted report omits the value
- **WHEN** a secrets finding is written to `audits/` or `validations/`
- **THEN** the report contains the file path, line number, and pattern type, and no character of the matched value

**Test Requirement**
- **ID:** T-CHANGE-SECURITY-CHECKS-015
- **File:** tests/test_skill_content.sh::assert_skills_never_reproduce_secrets
- **Command:** `bash tests/test_skill_content.sh assert_skills_never_reproduce_secrets`
- **Pass:** exit code 0

### Requirement: Apply-audit remediates Security findings
Apply-audit SHALL remediate `SC-` findings. For a secret in an artifact, it SHALL replace the literal with an environment-variable or secrets-manager reference and tell the user to rotate the exposed credential. For secret handling and untrusted input, it SHALL add design and task coverage. For a weakened control, it SHALL ask the user whether to justify or remove it. Escalation Info needs no fix.

#### Scenario: Secret in artifact remediated
- **WHEN** apply-audit processes an Error `SC-n` finding for a secret in design.md
- **THEN** the literal is replaced by a reference such as `$SERVICE_API_KEY`, the user is told to rotate the credential, and the value is not echoed in any output

**Test Requirement**
- **ID:** T-CHANGE-SECURITY-CHECKS-016
- **File:** tests/test_skill_content.sh::assert_apply_audit_security_remediation
- **Command:** `bash tests/test_skill_content.sh assert_apply_audit_security_remediation`
- **Pass:** exit code 0

#### Scenario: Weakened control requires a human decision
- **WHEN** apply-audit processes a weakened-control `SC-n` finding
- **THEN** apply-audit asks the user whether to add a rationale to the design or remove the weakening, and does not decide on its own

**Test Requirement**
- **ID:** T-CHANGE-SECURITY-CHECKS-017
- **File:** tests/test_skill_content.sh::assert_apply_audit_security_remediation
- **Command:** `bash tests/test_skill_content.sh assert_apply_audit_security_remediation`
- **Pass:** exit code 0

### Requirement: Documentation lists six audit categories
The top-level README and the audit skill README SHALL describe six audit categories, including Security. The validate skill README SHALL describe the Security check.

#### Scenario: README tables updated
- **WHEN** a reader opens the Audit Categories table in `README.md`
- **THEN** it lists six categories, including a Security row, and the Coherence row no longer mentions security surface

**Test Requirement**
- **ID:** T-CHANGE-SECURITY-CHECKS-018
- **File:** tests/test_skill_content.sh::assert_readme_security_category
- **Command:** `bash tests/test_skill_content.sh assert_readme_security_category`
- **Pass:** exit code 0

#### Scenario: Validate README describes the Security check
- **WHEN** a reader opens `skills/openspec-validate-change/README.md`
- **THEN** it lists six validation dimensions, including a Security row

**Test Requirement**
- **ID:** T-CHANGE-SECURITY-CHECKS-021
- **File:** tests/test_skill_content.sh::assert_readme_security_category
- **Command:** `bash tests/test_skill_content.sh assert_readme_security_category`
- **Pass:** exit code 0

### Requirement: Shared secret pattern set
The audit and validate skills SHALL share one secret pattern set, duplicated verbatim in each standalone-deployed skill. The set SHALL match: private-key headers, strictly matched as `-----BEGIN[A-Z ]*PRIVATE KEY-----`; provider-prefixed tokens, e.g. `AKIA`, `ghp_`, `github_pat_`, `xox[baprs]-`, `sk_live_`, `sk-ant-`; credential-named assignments (`password`, `secret`, `token`, `api_key`, `private_key`) with literal values of 8+ characters; and embedded-credential URLs (`scheme://user:pass@`).

#### Scenario: Both skills carry the same pattern set
- **WHEN** the deployed audit and validate skills are compared
- **THEN** every pattern marker appears in both, verbatim

**Test Requirement**
- **ID:** T-CHANGE-SECURITY-CHECKS-022
- **File:** tests/test_skill_content.sh::assert_secret_pattern_set
- **Command:** `bash tests/test_skill_content.sh assert_secret_pattern_set`
- **Pass:** exit code 0

### Requirement: Shared placeholder exemptions
The shared pattern set SHALL NOT match these placeholders: `<…>`, `${…}`, `$VAR`, environment lookups, `changeme`, and values containing `example`, `dummy`, `xxx`, or `redacted`. The exemption list SHALL be duplicated verbatim in each skill.

#### Scenario: Both skills carry the same exemption list
- **WHEN** the deployed audit and validate skills are compared
- **THEN** every placeholder exemption appears in both, verbatim

**Test Requirement**
- **ID:** T-CHANGE-SECURITY-CHECKS-023
- **File:** tests/test_skill_content.sh::assert_secret_pattern_set
- **Command:** `bash tests/test_skill_content.sh assert_secret_pattern_set`
- **Pass:** exit code 0
