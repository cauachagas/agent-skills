# Domain Examples (local addenda)

Provenance: practice examples from the original "Practical Guide to SKILLS" draft.
The draft's rewrites are kept; its two rule errors are not — see `../README.md`.

These examples exist because the upstream `examples/before-after.md` is generic.
They show the two cases the upstream skill is most often reached for: an error
string an agent must parse, and a tool description an agent must call correctly.

## Error message / log line — keep the hedge

**Before:**

> An unexpected error may have occurred during the processing of your request
> due to a potential format mismatch in the payload received by the server,
> which could possibly be caused by an outdated client version or temporary
> network instability.

**Wrong rewrite (do not copy this habit):**

> Your request failed.

The draft used this. It upgrades `may have occurred` to a fact the source never
asserted. A hedge is the author's confidence, and confidence is content.

**Correct rewrite:**

> Your request may have failed.
> The server received a payload with a format that it does not accept.
> An outdated client version or network instability can cause this problem.
> Check your client version and try again.

**Rules applied:** three stacked hedges (`may have`, `potential`, `could
possibly`) reduced to the one that carries the real uncertainty; 38 words split
into four sentences of 14 or fewer; passive made active; imperative verb for the
corrective action. Modality preserved — `may have failed` stays `may have
failed`.

## Tool / function description — keep the branch, drop the vagueness

**Before:**

> This function will attempt to synchronize the state across all configured
> cloud storage backends, and if any data conflict is detected it might
> automatically try to resolve it depending on the setting, or otherwise it
> will surface the error back for human intervention.

**After:**

> This tool synchronizes state across all configured cloud backends.
> If the tool finds a data conflict, it reads the configured strategy.
> If the strategy permits automatic resolution, the tool resolves the conflict.
> If the tool cannot resolve the conflict, it returns an error to the user.

**Rules applied:** `might automatically try ... depending on the setting` is a
real branch, not a hedge — it becomes an explicit `If`/`then`, which makes the
decision flow deterministic for a calling agent. Phrasal and vague verbs
(`surface back for human intervention`) become the concrete action (`returns an
error to the user`).
