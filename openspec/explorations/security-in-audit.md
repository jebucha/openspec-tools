# Exploration: Security in opsx-audit

**Date:** 2026-07-28
**Status:** Open exploration — no decision made

## Motivation

The `opsx-audit` skill (`openspec-audit-change`) has a lightweight security check buried under Coherence as section 8d ("Security surface awareness"). It fires conditionally when a change touches auth, data handling, external I/O, or user input, and covers 4 checks (input validation, error handling, TLS, secrets).

As a security engineer, the question is: does this belong as its own top-level category, and if so, what does design-time security auditing look like?

## Core Tension

```
┌──────────────────────────────────────────────────────────────────┐
│                    TWO DIFFERENT REGIMES                         │
├──────────────────────────────────┬───────────────────────────────┤
│  security-audit skill            │  opsx-audit skill             │
│                                  │                               │
│  Target: Running code            │  Target: Design proposals     │
│  Goal: Find exploitable bugs     │  Goal: Catch design flaws     │
│  Method: Adversarial, dynamic    │  Method: Structural, static   │
│  Depth: 6 phases, 8-12 agents    │  Depth: Single pass           │
│  Output: CRITICAL/HIGH/MED/LOW   │  Output: Error/Warning/Info   │
└──────────────────────────────────┴───────────────────────────────┘
```

Cannot port the security-audit skill's approach into opsx-audit — no code to exploit, no runtime to test, no dynamic confirmation. But design-time security questions are uniquely answerable at proposal stage.

## What Design-Time Security Could Check

Questions answerable from artifacts alone, before code exists:

- **Trust boundaries** — "The design crosses from untrusted input to database write. Where is the gate?"
- **Data flow protection** — "PII flows from API to cache to DB. Is the cache encrypted? Same trust zone?"
- **AuthZ completeness** — "New endpoint modifies User A's data but design only mentions authentication, not authorization"
- **Failure mode exposure** — "No error handling for external API 500 — does that leak internals?"
- **Privilege escalation paths** — "Task 3 creates admin flag, Task 7 lets users submit config. Path from 7 to 3?"
- **Attack surface expansion** — "Change adds 3 new public endpoints. Does design acknowledge expanded surface?"

## Constraints

Design-time security should be a caliper, not a chainsaw:

| security-audit skill | Design-time SE- check |
|---|---|
| "Can I exploit this?" | "Did the design think about this?" |
| Multi-agent, dynamic | Single-pass, artifact reading |
| Exploitable vulns | Design omissions |
| CRITICAL to INFO | Warning, Info only |
| Blocks deployment | Never blocks, raises awareness |

**Key constraint: SE- findings should never be Errors.** At design time, you're surfacing things the designer may not have considered, not finding bugs. A missing mention of input validation is "hey, think about this," not "your design is wrong."

## Structural Options

```
Option A: Stay under Coherence (current)
├── 8d. Security surface awareness
│   └── 4 checks, conditional
│   Problem: Undervalued. Security is not about coherence.

Option B: New top-level category, expanded
├── 9. Security (SE-)
│   ├── 9a. Trust boundary awareness
│   ├── 9b. Data flow protection
│   ├── 9c. AuthZ completeness
│   ├── 9d. Attack surface acknowledgment
│   └── 9e. Failure mode safety
│   Problem: Adds 5th category, more scope, risk of noise

Option C: Promote from Coherence, keep it lean (Preferred)
├── 9. Security (SE-)
│   └── Same guardrail: only when change touches
│        auth, data, I/O, or user input
│   └── 6-8 focused checks
│   └── Warnings and Info only, never Errors
```

## Risks

The security-audit skill's own anti-patterns are the trap here:

> *"Listing everything that deviates from OWASP as a finding."*
> *"Padding the report with LOW findings to look thorough."*

Most changes don't touch security-sensitive surfaces. If the guardrail ("only when change touches auth/data/I/O/input") works, the checks fire rarely and meaningfully. If the guardrail is too loose, every audit gets boilerplate SE- Info findings and nobody reads them.

## Open Questions

1. **Scope** — How many checks feel right? 4 (current) vs 6-8 (expanded)?
2. **Severity** — Warnings only, or should design-time security ever surface as an Error?
3. **Trigger** — Keep the conditional ("only when change touches X"), or always run and let the checks self-filter?
4. **Naming** — "Security surface awareness" vs "Security considerations" vs something else?
