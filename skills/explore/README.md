# explore

Token-efficient filesystem exploration. Teaches an agent to *measure before
reading* and to keep raw output out of the context window.

The model loads `SKILL.md`; the README you are reading is for maintainers.

## Files

| File | Loaded by the model? | Purpose |
| --- | --- | --- |
| `SKILL.md` | Yes, on every use | The directives |
| `references/install.md` | Only when a tool is missing | Per-distro install, verified |
| `scripts/check-tools.sh` | Only when invoked | Pre-flight check with install hints |

## Status

Verified on macOS 26 (arm64) against eza 0.23.5, bat 0.26.1, fd 10.5.0,
ripgrep 15.2.0, ast-grep 0.45.3, jq 1.8.2, yq 4.53.6, git-delta 0.19.2,
tokei 15.0.0, fzf 0.74.4. Every command in `SKILL.md` was executed, not
assumed. Cross-distro package and binary names were checked against Debian
`Contents-amd64` (bookworm and trixie) and the Arch package file lists.

Three claims in the first draft were **wrong** and were found by running the
tools, not by reading docs:

- `tokei -l <lang>` is wrong: `-l` is `--languages` and conflicts with input
  paths. The flag is `-t/--types`.
- `eza -l` with no path argument prints nothing and exits 0 whenever stdout is
  not a TTY. Interactive use hides this; scripts and agents hit it, and an
  empty listing reads as an empty directory.
- "`sg` is never ast-grep" was too strong. Homebrew installs *both* `ast-grep`
  and a deprecated `sg` shim that works, so `sg` looks fine locally. The rule
  that survives contact with other machines is "use `ast-grep`, which is
  correct everywhere", not "`sg` never works".

`fd --json` and `eza --json` do not exist. Both are easy to assume and fail
loudly enough that they are documented as non-existent rather than tested.

## Re-verifying after a tool upgrade

Tool flags change. Re-run the table rather than trusting this document:

```sh
cd skills/explore
for inv in 'eza -l -a .' 'eza --tree --level=2 .' 'eza --oneline .' \
           'bat --paging=never SKILL.md' 'fd -t f -e md .' 'fd -I -t f -g "*.md"' \
           'rg -m 20 -n --type md -e Gotcha .' 'ast-grep -l md -p "# $TITLE" .' \
           'tokei -t Markdown --output json . | jq -c keys' \
           'jq -n 1' 'printf "b\na\n" | fzf --filter=a -m'; do
  n=$(eval "$inv" 2>&1 | wc -l); printf '%-44s %s lines\n' "$inv" "$n"
done

# binary identities that differ from package names, plus the sg shim
command -v ast-grep sg fdfind fd batcat bat yq delta tokei
ast-grep --version && yq --version
```

Two artifacts will fool a naive `wc -l` check: `tokei --output json` emits a
single line with no trailing newline, and `fzf` needs input piped in. Both
otherwise show as zero lines. Zero lines where you expect *content* is the real
signal to investigate — that is how the `eza` bug surfaced.

## Maintenance notes

- The gotcha list in `SKILL.md` is the highest-signal part of this skill. When
  the agent draws a wrong conclusion, add a gotcha. Do not add prose.
- Keep `SKILL.md` under ~200 lines. If it grows past that, move material to
  `references/install.md` and link to it.
- `scripts/check-tools.sh` prints install hints for the missing case only. It
  exits 0 always; it is informational, not a gate.
