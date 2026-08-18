## Capability: docs-consistency

Ensure skill READMEs and the top-level README present consistent, accurate paths and deployment information.

### Requirement: Per-skill READMEs exclude deployment sections

Per-skill READMEs should not contain "Files" or "Deployment" sections that duplicate or contradict the top-level README.

#### Scenario: openspec-audit-change README has no deployment section
- **Given** the `skills/openspec-audit-change/README.md` file
- **When** a reader searches for "Deployment" or "Files" headings
- **Then** no such sections exist in the file

#### Scenario: openspec-apply-audit README has no files section
- **Given** the `skills/openspec-apply-audit/README.md` file
- **When** a reader searches for a "Files" heading
- **Then** no such section exists in the file

#### Scenario: openspec-validate-change README has no deployment section
- **Given** the `skills/openspec-validate-change/README.md` file
- **When** a reader searches for "Deployment" or "Files" headings
- **Then** no such sections exist in the file

### Requirement: Top-level README uses correct paths

The top-level `README.md` must use the correct `skills/` directory name in all references.

#### Scenario: Skills table uses `skills/` prefix
- **Given** the Skills table in the top-level `README.md`
- **When** a reader checks skill directory paths
- **Then** all paths use `skills/` (not `skill/`)

#### Scenario: Project Structure tree uses `skills/` prefix
- **Given** the Project Structure section in the top-level `README.md`
- **When** a reader checks the skill directory entry
- **Then** the path is `skills/` (not `skill/`)
