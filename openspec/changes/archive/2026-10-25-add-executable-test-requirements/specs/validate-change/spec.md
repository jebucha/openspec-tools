# Spec Delta

## MODIFIED Requirements

### Requirement: Validate checks test coverage
The validation skill SHALL verify that tests exist for new requirements and cover edge cases. A spec scenario that carries a Test Requirement block is verified by executing that block per the executable-test-requirements capability; structural inspection of test files alone is not sufficient for such scenarios.

#### Scenario: Tests exist for new requirement
- **WHEN** a spec requirement has no Test Requirement block and has corresponding test files with relevant test cases
- **THEN** the requirement is marked as having test coverage

#### Scenario: No tests for new requirement
- **WHEN** a spec requirement has no Test Requirement block and has no corresponding test files
- **THEN** an Error finding is raised for missing test coverage

#### Scenario: Tests lack edge case coverage
- **WHEN** a spec requirement has no Test Requirement block and its tests exist but do not cover edge cases described in spec scenarios
- **THEN** a Warning finding is raised for incomplete test coverage

#### Scenario: Scenario has a Test Requirement block
- **WHEN** a spec scenario carries a Test Requirement block
- **THEN** its test coverage is determined by executing the block rather than by structural inspection, and the structural check for that scenario is not applied
