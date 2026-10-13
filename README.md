# agent-skills

Personal Agent Skills — instructions that make an agent use a toolchain well
instead of guessing.

This repo is the source of truth. The harness reads it directly from disk via
the `skills` key in `opencode.json`; nothing is copied or symlinked, so
editing a file here changes agent behaviour on the next session.

## Layout

```text
agent-skills/
└── skills/
    └── <skill-id>/
        ├── SKILL.md        # required. The only file the model loads.
        ├── README.md       # for humans: status, provenance, how to re-verify
        ├── references/     # loaded on demand, only when SKILL.md points at it
        └── scripts/        # executable, run only when the agent invokes them
```

A skill is a folder whose name is its **ID**. `name` in the frontmatter is
only a display label. Keep the ID lowercase kebab-case and equal to the folder
name.

## Skills

| ID | What it does |
| --- | --- |
| [`asd-ste100`](skills/asd-ste100/) | Rewrite dense/ambiguous English into ASD-STE100 Simplified Technical English — short sentences, active voice, no hedges guessed away |
| [`ears-requirements`](skills/ears-requirements/) | Generate testable EARS (Easy Approach to Requirements Syntax) requirements from plans, docs, or code |
| [`explore`](skills/explore/) | Token-efficient filesystem exploration: `eza`, `fd`, `rg`, `ast-grep`, `bat`, `jq`, `yq`, `delta`, `tokei`, `fzf` |

## Adding a skill

1. Create `skills/<id>/SKILL.md`.
2. Write the `description` last. It is the **only** field the model reads
   during discovery, and it competes with every other installed skill for a
   limited slice of the context window. It needs WHAT the skill does, WHEN to
   reach for it, and the keywords a user would actually type. Keep it dense.
3. Write the body for what the model *would get wrong or miss*, not for what it
   already knows from training data. Standard library usage and documented API
   behaviour belong nowhere in a skill.
4. Commit. Nothing else to register.

Two rules learned the hard way here:

- **Verify every command before it goes in.** See
  [`explore/README.md`](skills/explore/README.md#verification-status) — a
  listing tool that exits 0 with no output is indistinguishable from an empty
  directory, and several "obvious" flags simply do not exist.
- **Progressive disclosure.** The body is injected into context on every use.
  Keep `SKILL.md` under ~200 lines and push reference material to
  `references/`. A skill is not documentation.

## Installing into a harness

This repo is the source of truth. Each harness reads skills from a different
directory, so "install" means "make the harness look at this folder". opencode
pointed at the repo reads new skills automatically; the others need one symlink
per skill.

| Harness | Skills directory it reads | What to do |
| --- | --- | --- |
| **opencode** | the `skills` array in `~/.config/opencode/opencode.json` | nothing — already points here |
| **Claude Code** | `~/.claude/skills/` | symlink each skill in |
| **Antigravity** (`agy`) | `~/.gemini/config/skills/` | symlink each skill in |

Use a **symlink, not a copy**, so `git pull` and edits here show up in every
harness with no re-install. Run this once per new skill (`<id>` = the folder
name, e.g. `asd-ste100`):

```sh
id=asd-ste100   # the skill folder name
for dir in ~/.claude/skills ~/.gemini/config/skills; do
  mkdir -p "$dir"
  ln -sfn "$HOME/Projects/agent-skills/skills/$id" "$dir/$id"
done
```

Verify the links resolve to a real `SKILL.md`:

```sh
for dir in ~/.claude/skills ~/.gemini/config/skills; do
  for id in asd-ste100 ears-requirements; do
    test -f "$dir/$id/SKILL.md" && echo "OK  $dir/$id" || echo "MISSING $dir/$id"
  done
done
```

Then start a **new** session in that harness — skills are discovered at startup,
not mid-session.

To remove a skill from a harness: `rm ~/.claude/skills/<id>` (deletes only the
link; the repo copy stays).

### opencode

The repo is wired in as a skills source. In `~/.config/opencode/opencode.json`:

```jsonc
{
  "skills": ["~/Projects/agent-skills/skills"]
}
```

`~/` paths resolve from your home directory. Sources in the `skills` array have
the highest precedence, so a skill here overrides one of the same ID in
`~/.config/opencode/skills` or in a project's `.claude/skills` / `.agents/skills`.

To try a skill without installing it, load it by ID: `/skill explore`.

### Fallback: copy instead of symlink

If a harness ignores symlinks, replace `ln -sfn` with a copy. You must re-run it
after every change here:

```sh
id=asd-ste100
cp -R "$HOME/Projects/agent-skills/skills/$id" ~/.claude/skills/
```

### Note: the `npx skills` hub

Skills installed with the `skills` CLI land in `~/.agents/skills/` and are
symlinked from there into each harness dir (see `~/.agents/.skill-lock.json`).
The `set -e` loop above links straight to this repo instead. Do not point both
mechanisms at the same skill ID — the later link wins and hides the other.
