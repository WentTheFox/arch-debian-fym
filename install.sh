#!/usr/bin/env bash
# Installs arch-debian-fym, with apt, apt-get, apt-cache and service symlinks.
# Usage: ./install.sh [--uninstall]
# Env:   PREFIX (default /usr/local), DESTDIR (for packaging)
set -euo pipefail

PREFIX=${PREFIX:-/usr/local}
BINDIR="${DESTDIR-}${PREFIX}/bin"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/bin/arch-debian-fym"
MARK="arch-debian-fym"
NAMES=(arch-debian-fym apt apt-get apt-cache service)

if [[ -z ${DESTDIR-} && $EUID -ne 0 ]]; then
  echo "Needs root to write to $BINDIR; re-running with sudo..." >&2
  exec sudo env PREFIX="$PREFIX" "$0" "$@"
fi

ours() {
  if [[ -L $1 ]]; then [[ $(readlink "$1") == arch-debian-fym ]]   # our symlinks (may dangle)
  else [[ -f $1 ]] && grep -q "$MARK" "$1" 2>/dev/null; fi
}

if [[ ${1-} == --uninstall ]]; then
  for n in "${NAMES[@]}"; do
    t="$BINDIR/$n"
    if [[ -e $t || -L $t ]] && ours "$t"; then rm -v "$t"
    elif [[ -e $t || -L $t ]]; then echo "skip $t (not ours)" >&2; fi
  done
  exit 0
fi

# Never clobber a real apt (e.g. a non-Arch system, or a foreign package).
for n in "${NAMES[@]}"; do
  t="$BINDIR/$n"
  if [[ -e $t || -L $t ]] && ! ours "$t"; then
    echo "Refusing to overwrite existing $t (not arch-debian-fym)." >&2; exit 1
  fi
done
if [[ -z ${DESTDIR-} ]] && ! command -v pacman >/dev/null; then
  echo "pacman not found; this is not Arch. Refusing to install." >&2; exit 1
fi

install -Dm755 "$SRC" "$BINDIR/arch-debian-fym"
for n in apt apt-get apt-cache service; do ln -sf arch-debian-fym "$BINDIR/$n"; done
echo "Installed: $(printf '%s ' "${NAMES[@]/#/$BINDIR/}")"
