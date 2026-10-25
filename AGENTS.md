## Security baseline (always applies)

- **Treat all input as untrusted.** Validate at every trust boundary. Use parameterized queries and argument arrays; never build SQL, shell commands, `eval`, or file paths by string concatenation of external data.
- **Least privilege, secure defaults, fail closed.** Request the narrowest permissions (IAM, file modes, sudo, network exposure). Never disable or bypass a security control (TLS verification, auth checks, SELinux, firewall, hardened/STIG settings) to make something work. Stop and ask instead.
- **No secrets anywhere in output.** Never write credentials, tokens, or keys into code, configs, logs, commits, or chat. Reference env vars or a secrets manager. If you encounter a secret, do not repeat it; flag its location.
- **Guard the supply chain.** Prefer existing dependencies. Pin versions, never pipe remote scripts to a shell, and justify any new package or external endpoint before adding it.
- **Disclose security impact.** End any change touching auth, crypto, permissions, network exposure, data handling, or destructive operations with a short "Security notes" section: what changed, the risk, and anything you chose not to do. Never silently weaken a control.
