# Spec Delta

## ADDED Requirements

### Requirement: Top-level README attributes authorship

The top-level `README.md` SHALL state in its introduction that the toolset was developed by its author (JB, `jebucha`) and present it as an independent project that extends the OpenSpec workflow, so a reader does not mistake it for an official OpenSpec artifact. The statement SHALL be consistent with the `LICENSE` copyright holder and the `author` field in the skill frontmatter.

#### Scenario: Introduction names the developer

- **WHEN** a first-time reader reads the top-level `README.md` introduction
- **THEN** it names the developer as JB (jebucha) and states the toolset is an independent extension of the OpenSpec workflow

#### Scenario: Attribution matches other project metadata

- **WHEN** a reader compares the README attribution with the `LICENSE` copyright holder and the skill frontmatter `author` values
- **THEN** all three identify the same author, because the README attribution names both forms of the name ("JB (jebucha)") and the `LICENSE` holder "JB" and the frontmatter "jebucha" are those two forms

### Requirement: Top-level README explains why Mixture of Models matters

The top-level `README.md` SHALL state — in the Principles or Quality Checkpoints area, not only in the Typical Session section — why the audit (step 3) and validate (step 6) checkpoints are run by models that did not write what they review: that different models have different blind spots, so cross-model review catches issues a single model's self-review would miss.

#### Scenario: Importance stated outside the Typical Session section

- **WHEN** a reader reads the Principles or Quality Checkpoints section of the top-level `README.md`
- **THEN** it contains a statement of why mixing models at the audit and validate checkpoints matters (model diversity catches what self-review misses), not merely how fresh sessions are staffed

### Requirement: Top-level README documents context isolation at model switches

The top-level `README.md` SHALL state that switching to the auditor or validator role starts a session with cleared context: the model brings no conversational context from the authoring session, and the persisted change artifacts (proposal, design, specs, tasks) are the state it inherits. The statement SHALL NOT claim the four artifacts are the auditor's exclusive input, since feasibility checks also read referenced source files.

#### Scenario: Audit and validate sessions start cold

- **WHEN** a reader reads the Principles or Quality Checkpoints section of the top-level `README.md`
- **THEN** it states that the auditor's and validator's sessions start without the authoring conversation, grounded in the persisted change artifacts

#### Scenario: Change directory is the shared state

- **WHEN** a reader reads the README statement about model switches
- **THEN** it presents the change directory — not the prior conversation — as what the new model inherits

#### Scenario: Statement does not overclaim the auditor's input

- **WHEN** a reader compares the README's description of what the auditor reviews with the audit skill's feasibility checks
- **THEN** the README does not claim the four artifacts are the auditor's exclusive input, since feasibility checks also read referenced source files
