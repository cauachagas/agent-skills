#!/usr/bin/env bash
# check-tools.sh — report which Explore tools are available and how to install
# the missing ones.
#
# Usage: bash scripts/check-tools.sh
# Exit:  0 always (informational, not a gate). Missing tools are printed to stdout.

set -u

declare -a TOOLS=(
  "eza|brew install eza|apt install eza|pacman -S eza"
  "bat|brew install bat|apt install bat -> binary is batcat|pacman -S bat"
  "fd|brew install fd|apt install fd-find -> binary is fdfind|pacman -S fd"
  "rg|brew install ripgrep|apt install ripgrep|pacman -S ripgrep"
  "ast-grep|brew install ast-grep|cargo install ast-grep (not packaged)|pacman -S ast-grep"
  "jq|brew install jq|apt install jq|pacman -S jq"
  "yq|brew install yq (mikefarah)|apt install yq (kislyuk)|pacman -S yq (kislyuk)"
  "delta|brew install git-delta|cargo install git-delta (trixie+ has apt)|pacman -S git-delta"
  "tokei|brew install tokei|cargo install tokei (trixie+ has apt)|pacman -S tokei"
  "fzf|brew install fzf|apt install fzf|pacman -S fzf"
)

os() {
  case "$(uname -s)" in
    Darwin) echo "macOS (Homebrew)";;
    Linux)  echo "Linux (apt / pacman)";;
    *)      echo "unknown";;
  esac
}

echo "Explore tool check — $(os), $(uname -m)"
echo

for row in "${TOOLS[@]}"; do
  IFS='|' read -r tool mac deb arch <<<"$row"
  path="$(command -v "$tool" 2>/dev/null)"
  if [ -n "$path" ]; then
    printf '  ok      %-9s %s\n' "$tool" "$path"
  else
    printf '  MISSING %-9s %s\n' "$tool" "mac: $mac | deb: $deb | arch: $arch"
  fi
done

cat <<'EOF'

Traps:
  Use `ast-grep`, not `sg`. On Homebrew sg is a deprecated shim that warns on
    every call; on Debian/Arch sg is the setgid command (Debian: admin/login).
  Debian renames binaries: bat -> batcat, fd -> fdfind.
    `apt install fd` gives you fdclone, a different program.
  Two different `yq` tools. Homebrew is mikefarah (Go: -o=json, select).
    Debian and Arch are kislyuk (jq wrapper: -r, no -o). Check `yq --version`.
  Always pass an explicit path to eza. With no path argument and non-TTY
    stdout it can print nothing and still exit 0, which reads as an empty
    directory.

Set delta as the git pager once:
  git config --global core.pager delta
  git config --global interactive.diffFilter "delta --dark --paging=always"
EOF
