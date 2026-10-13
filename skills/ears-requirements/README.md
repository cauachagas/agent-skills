# ears-requirements

Generate testable, verification-ready software requirements in EARS (Easy
Approach to Requirements Syntax) from plan files, design documents, user
stories, or an existing codebase.

## Status

Working (instructions only — no scripts).

## Provenance

Upstream: [bromanko/llm-agents](https://github.com/bromanko/llm-agents)
`main` @ `ae0c623`, path `skills/ears-requirements/`. Copied 2026-10-13.

**License note:** the upstream repo has no `LICENSE` file at this commit. This
copy is for local personal use. Confirm licensing before redistributing or
publishing it.

## Local addenda

`examples/domain-examples.md` — two worked requirement sets from a personal
"Practical Guide" draft (a checkout/payment module and autonomous emergency
braking). Both were corrected:

1. Reformatted to the canonical clause order (`While <precondition>, when
   <trigger>, ...`).
2. The emergency-braking requirement was split. The draft joined two responses
   with `and` — a compound requirement, which this skill's own anti-pattern list
   forbids.

## Re-verify

Read `SKILL.md` and `references/patterns.md`; check each example against the
quality rules in `SKILL.md` Step 4.
