## Context

The security-audit skill currently defaults to `~/security-audit-skill/<repo-name>/run-<N>` for storing audit artifacts. This path lives outside the repository, making findings disconnected from the code they audit — harder to version-control, harder to share, and harder to discover during code review. The skill also checks this external path for prior runs to avoid redundant findings.

The change moves the default to `<repo-root>/security-audits/run-<N>`, keeping artifacts co-located with the repository. The `<repo-root>` is the target codebase directory (from user input or current working directory). The `run-<N>` numbering and artifact filenames remain unchanged.

## Goals / Non-Goals

**Goals:**
- Change the default output path in the skill's Setup section to `<repo-root>/security-audits/run-<N>`
- Update the prior-runs lookup path to match the new location
- Preserve all existing behavior: user can still override the output path, `run-<N>` numbering works the same, artifact filenames are unchanged

**Non-Goals:**
- Modifying the command file or deploy script
- Adding a `.gitignore` entry for the output directory (out of scope; teams may or may not want to track findings)
- Changing any other skill behavior or phase logic

## Decisions

**Default to repo-relative path, not absolute**
- The new default `<repo-root>/security-audits/run-<N>` derives from the target codebase directory, which is already established in the Setup section
- Alternatives considered: `./.security-audits/run-<N>` (too hidden), `./audit-results/run-<N>` (less descriptive), `./security-reports/run-<N>` (longer, no benefit)
- The `security-audits` folder name is explicit and matches the skill name (pluralized to indicate it contains multiple runs)

**Preserve user override capability**
- The skill already says "Ask the user if not specified, or default to..." — the default changes, but the ability to specify a custom path remains
- No change to the command interface is needed

**Update prior-runs path to match**
- The prior-runs check currently looks at `~/security-audit-skill/<repo-name>/`. It must be updated to `<repo-root>/security-audits/` to discover previous runs in the new location

## Risks / Trade-offs

- [Audit output in repo] Storing findings inside the repo may surface sensitive information if the repo is shared broadly. Teams should `.gitignore` the `security-audits/` directory if findings contain sensitive details. This is a trade-off: co-location enables version control and team visibility, but requires conscious decisions about what gets committed.
- [Prior runs from old location] Existing audits stored at `~/security-audit-skill/` won't be automatically discovered. This is acceptable — the new default applies to new runs, and users can reference old runs manually if needed.
