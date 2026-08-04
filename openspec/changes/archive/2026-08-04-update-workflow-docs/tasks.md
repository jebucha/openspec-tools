## 1. Rename validate command

- [x] 1.1 Rename `commands/opsx-validate-change.md` to `commands/opsx-validate.md`
- [x] 1.2 Rename `.opencode/commands/opsx-validate-change.md` to `.opencode/commands/opsx-validate.md`

## 2. Update README workflow section

- [x] 2.1 Replace the 5-step workflow diagram with the 7-step workflow including explore and validate
- [x] 2.2 Update the workflow table with all 7 steps and descriptions
- [x] 2.3 Add Quality Gates subsection explaining audit and validate as critical gates
- [x] 2.4 Add Looping Back subsection with ASCII diagram showing iteration paths

## 3. Update README commands and skills tables

- [x] 3.1 Update Commands table to include opsx-validate.md in source commands
- [x] 3.2 Update Commands table to include opsx-validate.md in deployed commands
- [x] 3.3 Update Skills table to include openspec-validate-change in source skills (using the `skills/` path prefix, not `skill/`)
- [x] 3.4 Update Skills table to include openspec-validate-change in deployed skills (correct the path reference from `.kiro/skills/` to `.opencode/skills/`)

## 4. Add Validation Dimensions section

- [x] 4.1 Add new Validation Dimensions section with table of 5 dimensions
- [x] 4.2 Add findings severity descriptions (Error, Warning, Info)
- [x] 4.3 Add verdict descriptions (Pass, Conditional, Fail)

## 5. Update Typical Session

- [x] 5.1 Add explore as step 1 with example
- [x] 5.2 Add validate as step 6 with example
- [x] 5.3 Add looping back guidance after validation
