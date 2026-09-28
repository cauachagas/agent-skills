---
name: explore
description: 'Token-efficient filesystem exploration with eza, fd, rg, ast-grep, bat, jq, yq, delta, tokei, fzf. Use when listing, reading, searching, counting, diffing, or measuring code, and when parsing JSON/YAML so only filtered fields reach the context window.'
---

# Explore

Read, search, and measure the filesystem with a curated CLI stack so results stay small, structured, and grounded in real paths.

## When to Use This Skill

- Surveying an unfamiliar repo: size, languages, layout
- Finding files by name/glob, or text by pattern
- Reading a file's contents, or a slice of a large one
- Counting matches, lines, or occurrences before deciding to read
- Comparing two files, branches, or outputs
- Extracting specific fields from JSON/YAML before printing

## Do Not Use This Skill

- Plain single-file reads and single-pattern searches when the harness already
  provides native read/search/glob tools — those are cheaper than a shell call.
  This stack earns its keep on **bulk, counted, filtered, and piped** work.
- Anything requiring reasoning about code semantics. This skill finds and
  measures; it does not understand.

## Core Rules

1. **Count before enumerating.** A count decides whether reading is worth it.
   A 20 ms `rg -c` replaces a 30 s dump of thousands of lines.

   ```sh
   tokei --output json src/ | jq -r '.Rust.code, .TypeScript.code'
   fd -e rs src/ | wc -l                 # count files by extension
   rg -c "fn new" --type rust src/      # per-file counts, scoped
   rg "fn new" --type rust src/ | wc -l  # only if the count justified it
   ```

2. **Scope every search.** Always pass a path. A bare `rg PATTERN --type py`
   walks `.venv`, `node_modules`, and symlink loops; it can hang for a minute
   and return nothing useful. Scoped `rg PATTERN --type py src/` returns in
   milliseconds.

3. **Filter before the context window, not after.** Pipe through `jq`, `yq`,
   `rg -m`, `head`, or `wc`. Raw output entering the transcript is the cost
   this whole skill exists to avoid.

4. **Prefer structured flags.** Every tool here has a machine-readable mode;
   JSON with `jq` beats regex over text.

   | Tool | Flag |
   | --- | --- |
   | `rg` | `--json` (one JSON object per line) |
   | `ast-grep` | `--json=compact` or `--json=stream` |
   | `tokei` | `--output json` |
   | `jq` / `yq` | native |

   `eza` and `fd` have no JSON output. Never invent a flag — check `--help`
   before building a pipeline on one.

5. **Regex for text, AST for code.** `rg` matches inside strings, comments, and
   docstrings and breaks on whitespace. For functions, classes, call sites,
   decorators, imports, and type annotations, use `ast-grep`.

6. **Write `~`, not `/Users/<name>`.** In commands you author, docs, reports,
   configs, and skill files, use `~/` or `$HOME`. Absolute `/Users/<name>/...`
   paths break on any other machine and leak a username. Inside a command you
   run right now, plain relative paths from the project root are best.

## Tool Selection

Always pass an explicit path to `eza` — see the gotcha below.

| Need | Command |
| --- | --- |
| Detailed directory view | `eza -l -a --group-directories-first .` |
| Structural overview | `eza --tree --level=2 .` |
| Quiet one-line-per-entry view | `eza --oneline .` |
| Read a short file | `bat --paging=never` |
| Read part of a large file | `bat --paging=never --line-range 1:200` |
| Find files by name | `fd -t f -e rs -e ts` |
| Find files ignoring `.gitignore` | `fd -I -t f pattern` |
| Search text | `rg -m 20 --type ts -n pattern src/` |
| Search code structure | `ast-grep -l ts -p 'foo($A, $$$)' src/` |
| JSON | `jq -r '.data[].name'` |
| YAML | `yq -o=json '.' file.yaml \| jq` |
| Readable diff | `delta` (set as git pager) |
| Code size by language | `tokei --output json` |
| Code size of one language | `tokei -t Rust --output json src/` |
| Extract from a URL or API | `curl -s <url> \| jq -r '"\(.name) \(.id)"'` |
| Word-boundary search | `rg -w -n pattern src/` |
| Interactive pick from a list | `fzf -m` |

Pre-flight once per session, then trust the result:

```sh
for t in eza bat fd rg ast-grep jq yq delta tokei fzf; do
  command -v "$t" >/dev/null || echo "MISSING: $t"
done
```

Or run `scripts/check-tools.sh`, which prints install hints for each missing
tool, including the binary names that differ from the package name
(`batcat`, `fdfind`). Fall back silently when a tool is absent: `eza`→`ls -la`,
`bat`→`cat`, `rg`→`grep -r`, `fd`→`find`, `ast-grep`→`rg`. For `yq` with no
binary, convert to JSON with Ruby's stdlib (ships with macOS), then use `jq`:

```sh
ruby -ryaml -rjson -e 'puts JSON.generate(YAML.load_file(ARGV[0]))' f.yaml | jq -r '.a.b'
```

## Gotchas

- **Use `ast-grep`, never `sg`.** Homebrew's `ast-grep` formula installs *both*
  `ast-grep` (51 MB) and `sg` (415 KB). The `sg` shim does work, but it is
  deprecated and prints a three-line warning banner to **stderr** on every
  invocation. On Debian and Arch, `sg` is not ast-grep at all — it is the setgid
  command (Debian ships it in `admin/login`; Arch does not install it). Since
  stderr is surfaced in tool output, always use the `ast-grep` name, which
  exists on every platform with no banner.
- **Two incompatible tools are both called `yq`.** Homebrew gives mikefarah/yq
  (Go): `yq '.a.b' f.yaml`, `yq -o=json`, `yq select(...)`. Debian and Arch
  give kislyuk/yq, a jq wrapper: `yq -r '.a.b'`, jq filters and pipes, no
  `-o`. Check `yq --version` before writing a command. Homebrew declares the
  collision: `conflicts_with "python-yq"`.
- **The binary name is often not the package name.** Debian ships `bat` as
  **`batcat`** and `fd` as **`fdfind`**. Worse, `apt install fd` installs
  `fdclone` — a different program that is not fd at all. Install `fd-find`.
- **`eza` can exit 0 with no output.** Verified on eza v0.23.5 (a `+git`
  Homebrew build): with **no path argument** it lists nothing and returns
  success whenever **stdout is not a TTY**. `eza -l` → 0 lines through a pipe
  or a script, but the same command in an interactive terminal works, and
  `eza -l .` works in both. Empty output then reads as "the directory is
  empty", which is a hallucination. **Always pass an explicit path**, and
  confirm with `ls -la .` before concluding a directory has no entries.
  Interactive `ls` aliases hide this bug; scripts and agents hit it.
- **`eza -h` is `--header`, not `--human-readable`.** `-H` is `--links`. There
  is no human-readable size flag; the portable spelling is
  `--group-directories-first` plus `-l`.
- **`ast-grep` silently skips files it cannot type.** Without `-l`, it infers
  the language from the extension and skips anything unrecognized — zero
  results that read as "not found". Pass `-l` explicitly, and debug with
  `ast-grep --inspect summary ...`, which reports `scannedFileCount` /
  `skippedFileCount` on **stderr**. An unsupported `-l` value is a loud error,
  so a silent skip means the *extension*, not the language.
- **`ast-grep` metavariables bind positionally.** `fn $N($$$) { $$$ }` matches
  any function; `fn $N($$$A, $$$B) { $$$ }` requires two or more arguments.
  Repeat `$$$` to constrain arity, and use `$$$ARGS` when you need to capture
  the tail. Do **not** try `...` mid-pattern (`{ ... $P: $V ... }` matches
  nothing) and do **not** name a metavariable that the pattern does not bind.
  `$` is only special when it prefixes a name inside a pattern, so a pattern
  with no metavariables behaves as an exact match.
- **`fd` respects `.gitignore` by default.** Generated, vendored, or dotfile
  sources are invisible without `-I` / `--hidden`.
- **`bat` paginates.** In a non-interactive agent shell, always pass
  `--paging=never` or the output blocks or is truncated.
- **`.git` and `node_modules` are noise, not signal.** `eza` hides dotfiles by
  default; `fd`/`rg` skip gitignored paths. Add `--hidden` / `-uu` only when
  you specifically need them, and expect a much larger result.
- **`rg -m N` caps matches per file, not repo-wide.** Verified: `rg -m 2` over
  two files with 3 and 1 matches returns 3. For a hard global cap, pipe to
  `head -N`.

## Troubleshooting

| Symptom | Cause and fix |
| --- | --- |
| `sg: command not found`, or `sg` switches users | `sg` is setgid on Debian/Arch. Use `ast-grep`. On Homebrew `sg` exists but is a deprecated shim that warns on every call. |
| `yq` reports "must be a jq filter" | kislyuk/yq is installed. Use `-r` and jq syntax, or install mikefarah/yq. |
| A directory listing is empty but should not be | `eza` with no path argument and non-TTY stdout. Re-run with an explicit path, and confirm with `ls -la .`. |
| `eza -lah` shows no sizes | `-h` is `--header` in eza. Use `-l` alone for long listing. |
| `fd`/`bat` "not found" after `apt install fd` / `bat` | Debian renames the binaries: `fdfind`, `batcat`. `apt install fd` gives fdclone. |
| Search hangs, then times out | Unscoped search. Add a path: `rg PATTERN src/`. |
| Search returns 0 hits but the code exists | The file is gitignored or a dotfile. Add `-uu`, or drop `.gitignore` filters. |
| `fd` finds nothing | Pattern is a glob, not a regex: `fd -g '*.rs'`. |
| `bat` output truncated or empty | Pager. Add `--paging=never`. |
| `ast-grep` finds 0 matches for a construct you can see | File was skipped for an unknown extension. Pass `-l` explicitly, then `ast-grep --inspect summary ...`. |
| File listed but unreadable | Binary or non-UTF-8. Use `file`, or `rg -a`. |

## References

- `references/install.md` — per-distro install commands for every tool
- `scripts/check-tools.sh` — pre-flight check with install hints
