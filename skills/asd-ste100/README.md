# asd-ste100

Rewrite dense or ambiguous English into short, single-meaning, active-voice
sentences, following the rule categories of ASD-STE100 Issue 9. Written for text
an agent or downstream system must parse without a human to resolve ambiguity.

## Status

Working. `scripts/ste-lint.py --selftest` exits 0.

## Provenance

Upstream: [danyuchn/asd-ste100-skill](https://github.com/danyuchn/asd-ste100-skill)
`master` @ `32511c6`, MIT (see `LICENSE`). Copied 2026-10-13; this repo owns the
copy, not a git submodule.

## Local addenda (this is a fork, not a mirror)

Two edits on top of upstream:

1. `examples/domain-examples.md` — error-message and tool-description worked
   examples taken from a personal "Practical Guide" draft. The draft's two rule
   errors are corrected there: it upgraded a hedge (`may have occurred` →
   `failed`), and it stated active voice is always required. Both are wrong for
   the agent-reader use case; see the file for the corrected rewrites.
2. `SKILL.md` — added the `80%` / `Karpathy mode` aliases for the existing
   `STE-flavored` mode (that mode *is* the "80% of the way to STE" heuristic the
   draft names; it is a heuristic, not part of the standard).

## How to re-verify

```sh
python3 scripts/ste-lint.py --selftest            # linter sanity check
python3 scripts/ste-lint.py <file-to-rewrite>     # lint real target text
```

Do not point the linter at this skill's own files. They are documentation and
deliberately exceed the caps (they *quote* bad examples), so they fail the lint
by design — the same as upstream.

## Updating from upstream

`git fetch` the upstream repo, diff `SKILL.md` against the copy here, and re-apply
the two addenda above. The addenda are deliberately small and confined to the
`## Two Modes` section and the `## Additional Resources` list.
