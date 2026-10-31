#!/usr/bin/env bash
# Installs arch-debian-fym, with apt, apt-get, apt-cache and service symlinks.
# Usage: ./install.sh [--uninstall]
# Links to the script in this checkout, so keep the checkout where it is.
# Env:   PREFIX (default /usr/local), DESTDIR (for packaging)
set -euo pipefail

PREFIX=${PREFIX:-/usr/local}
BINDIR="${DESTDIR-}${PREFIX}/bin"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/bin/arch-debian-fym"
MARK="arch-debian-fym"
NAMES=(arch-debian-fym apt apt-get apt-cache service)

# Refuse unless the commands we suggest actually exist. Having pacman is what
# makes a machine "arch" for our purposes (derivatives don't all say so in
# /etc/os-release). Uninstalling and DESTDIR staging are always fine.
if [[ ${1-} != --uninstall && -z ${DESTDIR-} ]]; then
  missing=()
  tools=(pacman systemctl); (( EUID != 0 )) && tools+=(sudo)
  for c in "${tools[@]}"; do command -v "$c" >/dev/null || missing+=("$c"); done
  if [[ " ${missing[*]} " == *" pacman "* ]]; then
    echo "<${SHELL##*/}> this is not arch, btw" >&2
    exit 1
  elif (( ${#missing[@]} )); then
    echo "<${SHELL##*/}> can't find ${missing[*]}, btw" >&2
    exit 1
  fi
  # Installing needs root (and so do most of the commands we suggest): make sure
  # sudo actually lets this user in. On a terminal this may ask for your password
  # once; without one we only refuse if sudo says "not allowed" (a missing
  # password alone isn't proof of no rights).
  if (( EUID != 0 )); then
    if [[ -t 0 ]]; then
      sudo -v || no_sudo=1
    elif ! out=$(sudo -n -v 2>&1) && [[ $out != *"password is required"* ]]; then
      no_sudo=1
    fi
    if [[ -n ${no_sudo-} ]]; then
      echo "<${SHELL##*/}> you don't have sudo rights, btw" >&2
      exit 1
    fi
  fi
fi

if [[ -z ${DESTDIR-} && $EUID -ne 0 ]]; then
  echo "Needs root to write to $BINDIR; re-running with sudo..." >&2
  exec sudo env PREFIX="$PREFIX" "$0" "$@"
fi

ours() {
  if [[ -L $1 ]]; then   # our symlinks (may dangle): to the repo script or to the main name
    case $(readlink "$1") in arch-debian-fym|*/bin/arch-debian-fym) return 0 ;; *) return 1 ;; esac
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

# Symlink to the repo's script so edits (and git pulls) take effect immediately.
# Keep the repo in place; if you move it, re-run this installer.
chmod +x "$SRC"
mkdir -p "$BINDIR"
ln -sf "$SRC" "$BINDIR/arch-debian-fym"
for n in apt apt-get apt-cache service; do ln -sf arch-debian-fym "$BINDIR/$n"; done
echo "Installed: $(printf '%s ' "${NAMES[@]/#/$BINDIR/}")"
