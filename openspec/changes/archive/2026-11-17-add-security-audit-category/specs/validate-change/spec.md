# Spec Delta

## ADDED Requirements

### Requirement: Validate checks security
The validation skill SHALL run a best-effort Security check on the files the change touches, as defined by the change-security-checks capability. Its findings SHALL use the `VD-` sequence with Category `Security` and SHALL contribute to the verdict like any other finding. A secret hit is an Error and blocks archive.

#### Scenario: Security check runs on every validation
- **WHEN** validation runs on a change with code changes
- **THEN** the Security check runs on the changed files after the code quality check, and its findings appear in the Findings table with Category `Security`

**Test Requirement**
- **ID:** T-VALIDATE-CHANGE-001
- **File:** tests/test_skill_content.sh::assert_validate_skill_security_check
- **Command:** `bash tests/test_skill_content.sh assert_validate_skill_security_check`
- **Pass:** exit code 0

#### Scenario: Secret hit fails the verdict
- **WHEN** the Security check raises an Error for a committed secret
- **THEN** the verdict is Fail

**Test Requirement**
- **ID:** T-VALIDATE-CHANGE-002
- **File:** tests/test_skill_content.sh::assert_validate_skill_security_check
- **Command:** `bash tests/test_skill_content.sh assert_validate_skill_security_check`
- **Pass:** exit code 0
