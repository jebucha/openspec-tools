## Why

The security-audit skill defaults to writing audit artifacts to `~/security-audit-skill/<repo-name>/run-<N>`, placing results outside the repository. This makes findings harder to track with version control, share with teammates, and reference in future audits. Storing output as a subfolder of the repo (e.g., `<repo-root>/security-audits/run-<N>`) keeps findings co-located with the code they audit.

## What Changes

- Update the security-audit skill's default output path from `~/security-audit-skill/<repo-name>/run-<N>` to `<repo-root>/security-audits/run-<N>`
- Update the "prior runs" lookup path accordingly so the skill still discovers previous audit results
- The output directory name pattern `run-<N>` and artifact file names remain unchanged

## Capabilities

### New Capabilities
- None

### Modified Capabilities
- `security-audit-command`: The default output path and prior-runs discovery path change from a user-home location to a repo-relative subfolder

## Impact

- `skills/security-audit/SKILL.md` — updated Setup section: default output path and prior runs lookup path
- No command files, deploy scripts, or README changes required — the skill's internal default changes, but the command interface remains the same
