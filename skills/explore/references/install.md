# Installing the Explore toolchain

Verified against: Homebrew formula sources, Debian `Contents-amd64`
(bookworm = stable, trixie = testing), and the Arch package file lists.
Load this only when `scripts/check-tools.sh` reports a MISSING tool.

## All at once

```sh
# macOS
brew install eza bat fd ripgrep ast-grep jq yq git-delta tokei fzf

# Debian 13+ (trixie) — all of it is packaged
sudo apt install eza bat fd-find ripgrep jq yq git-delta tokei fzf
# ast-grep is not packaged on Debian; build it with cargo
cargo install ast-grep

# Debian 12 (bookworm) — eza, git-delta and tokei are NOT packaged
sudo apt install bat fd-find ripgrep jq yq fzf
cargo install ast-grep git-delta tokei

# Arch — all of it is packaged
sudo pacman -S eza bat fd ripgrep ast-grep jq yq git-delta tokei fzf
```

## Matrix

`Bin.` is the command you actually type. It is often **not** the package name.

| Tool | macOS | Debian | Arch | Bin. | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `eza` | `brew install eza` | `apt install eza` | `pacman -S eza` | `eza` | Debian: trixie+ only. Arch also ships a compat `exa` |
| `bat` | `brew install bat` | `apt install bat` | `pacman -S bat` | `bat` / **`batcat`** on Debian | Debian renames the binary to avoid a clash |
| `fd` | `brew install fd` | `apt install fd-find` | `pacman -S fd` | `fd` / **`fdfind`** on Debian | `apt install fd` gives you **fdclone**, a different program |
| `rg` | `brew install ripgrep` | `apt install ripgrep` | `pacman -S ripgrep` | `rg` | |
| `ast-grep` | `brew install ast-grep` | `cargo install ast-grep` | `pacman -S ast-grep` | **`ast-grep`** | Not packaged on Debian. Homebrew also links a deprecated `sg` shim |
| `jq` | `brew install jq` | `apt install jq` | `pacman -S jq` | `jq` | macOS ships an old one at `/usr/bin/jq`; check the version |
| `yq` | `brew install yq` | `apt install yq` | `pacman -S yq` | `yq` | **Two incompatible tools share this name** — see below |
| `delta` | `brew install git-delta` | `apt install git-delta` | `pacman -S git-delta` | `delta` | Debian: trixie+ only, otherwise `cargo install git-delta` |
| `tokei` | `brew install tokei` | `apt install tokei` | `pacman -S tokei` | `tokei` | Debian: trixie+ only, otherwise `cargo install tokei` |
| `fzf` | `brew install fzf` | `apt install fzf` | `pacman -S fzf` | `fzf` | Arch also ships `fzf-tmux` |

## The three traps

### 1. `sg` is deprecated, or something else entirely

| Platform | `sg` is |
| :--- | :--- |
| Homebrew | A deprecated shim that forwards to `ast-grep` and prints a warning banner to stderr on every call. The formula installs both binaries: `ast-grep` (51 MB) and `sg` (415 KB) |
| Debian | The setgid command, from the `admin/login` source package |
| Arch | Not installed by `shadow` or `util-linux` at all |

`ast-grep` is the only name that is correct everywhere and carries no banner.
Using `sg` on Homebrew happens to work, which makes it the most dangerous
option: it looks fine locally and breaks on a Debian box.

### 2. `yq` is two different tools

| | Homebrew | Debian / Arch |
| :--- | :--- | :--- |
| Project | mikefarah/yq (Go) | kislyuk/yq (Python) |
| Debian/Arch version | — | 3.4.3 (Debian) / 4.3.0 (Arch) |
| Query | `yq '.a.b' f.yaml` | `yq -r '.a.b' f.yaml` |
| Emit | `yq -o=json` | n/a — it is a jq wrapper, so pipe |
| Compose | `yq select(...)` | plain jq filters and pipes |

Homebrew declares the collision explicitly: `conflicts_with "python-yq"`.
Check with `yq --version` before writing a command. If the mikefarah syntax is
required on Linux, install it from source or use the release binary — the
distro package will not give it to you.

### 3. The binary name is not the package name

Debian renames two binaries to avoid clashes: `bat` → `batcat`, `fd` →
`fdfind`. Symlink them if you want the short names:

```sh
sudo ln -s /usr/bin/fdfind /usr/local/bin/fd
sudo ln -s /usr/bin/batcat /usr/local/bin/bat
```

## Shell configuration

```sh
# delta as the git pager
git config --global core.pager delta
git config --global interactive.diffFilter "delta --dark --paging=always"

# rg: see gitignored and hidden files when that is what you want
alias rga='rg -uu'
```

## Platform notes

- **macOS ships BSD userland.** `sed`, `find`, and `grep` differ from GNU
  versions. Prefer the tools in this table; if you need a GNU-only flag,
  install `coreutils` (`brew install coreutils`) and use `ggrep`.
- **Homebrew binaries here are a custom build.** Some report a `+git` suffix
  and link a nonstandard `libgit2`. Verify a tool's behaviour once after
  installing rather than assuming upstream semantics — see the `eza` note in
  `SKILL.md`.
- **ast-grep language coverage is fixed.** An unsupported `-l` value is a hard
  error, but an unrecognized file extension is skipped in silence when `-l` is
  omitted. Always pass `-l`, and check the scan report on an empty result:

  ```sh
  ast-grep --inspect summary -l rust -p 'fn $NAME($$$)' src/
  ```
