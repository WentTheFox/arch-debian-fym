# arch-debian-fym

*fym: **f**ix **y**our **m**istake* (or, if you prefer, *f\*\*\* you mean?*)

An innocent little script that teaches you how to run these commands on Arch.

It installs itself as `apt`, `apt-get`, `apt-cache`, `service` and the other
Debian tools below (`dpkg`, `aptitude`...). When you type one of them out of habit, it shows the `pacman` or `systemctl` command you
meant, and offers to run it for you.

Set `FYM_NO_PROMPT` to skip the question and run the command straight away.
When output isn't an interactive terminal (piped, captured, run from a script
or cron), only the command is printed, on stdout. The exit status is 1 unless
the command was run.

## Install / uninstall

```sh
./install.sh              # to /usr/local/bin (uses sudo if needed)
./install.sh --uninstall
```

`/usr/local/bin/arch-debian-fym` is a symlink to `bin/arch-debian-fym` in this
checkout (so edits and `git pull` take effect immediately), and the other names
are symlinks to it. If you move the checkout, re-run `./install.sh`. `PREFIX` and `DESTDIR` are honoured.

The installer refuses to run if `pacman` can't be found (that is what makes a
machine Arch here, since derivatives don't all identify as Arch), if `systemctl`
is missing, or if you're not root and `sudo` is missing or won't let you in. It
also refuses to overwrite any `apt` that isn't this project's. Names that already
exist as real Arch commands (like `dpkg`, which Arch packages) are skipped and
never shadowed.

## Handled commands

Based on the Debian/Ubuntu column of the
[pacman Rosetta](https://wiki.archlinux.org/title/Pacman/Rosetta). Flags like
`-y` and `-s` are translated where pacman has an equivalent (`--noconfirm`,
`-p`); otherwise only package names are carried over.

| Debian | Arch |
|---|---|
| `apt update` | `sudo pacman -Syu` (a bare `-Sy` is unsupported on Arch) |
| `apt upgrade` / `full-upgrade` / `dist-upgrade` | `sudo pacman -Syu` |
| `apt install` / `reinstall` | `sudo pacman -S <pkgs>` |
| `apt install -d`, `apt download` | `sudo pacman -Sw <pkgs>` |
| `apt install -f`, `apt-get check` | `pacman -Dk` |
| `apt install pkg/release`, `-t release` | `sudo pacman -S repo/pkg` |
| `apt remove` | `sudo pacman -R <pkgs>` (`--purge`: `-Rn`) |
| `apt purge` | `sudo pacman -Rn <pkgs>` |
| `apt autoremove <pkgs>` | `sudo pacman -Rs <pkgs>` (`--purge`: `-Rns`) |
| `apt autoremove` | `pacman -Qdtq \| sudo pacman -Rs -` |
| `apt search` | `pacman -Ss <term>` |
| `apt show`, `apt-cache show/showpkg/depends`, `policy <pkg>` | `pacman -Si <pkg>` |
| `apt-cache rdepends`, `aptitude why` | `pacman -Sii <pkg>` |
| `apt-cache policy` | `cat /etc/pacman.d/mirrorlist` |
| `apt list` / `--installed` / `--upgradable` | `pacman -Sl` / `-Q` / `-Qu` |
| `apt-cache dumpavail` / `dump` / `pkgnames` | `pacman -Sl` |
| `apt-cache stats` | `ls /var/lib/pacman/local` |
| `apt-cache dotty` | `pactree --graph <pkg>` |
| `apt-cache add <file>` | `sudo cp <file> /var/cache/pacman/pkg/` |
| `apt-get changelog` | `pacman -Qc <pkg>` |
| `apt clean` / `autoclean` | `sudo pacman -Scc` / `-Sc` |
| `apt edit-sources`, `apt-cdrom`, `add-apt-repository` | `sudoedit /etc/pacman.conf` |
| `apt-get source`, `debcheckout` | `asp export <pkg>` (then `makepkg -o`) |
| `apt-get build-dep` | `makepkg -seoc` |
| `apt-mark manual` / `auto` | `sudo pacman -D --asexplicit` / `--asdeps <pkgs>` |
| `apt-mark hold` / `unhold` / `showhold` | edit `IgnorePkg` in `/etc/pacman.conf` / grep it |
| `apt-mark showmanual` / `showauto` | `pacman -Qe` / `-Qd` |
| `apt-file search` / `list` / `update` | `pacman -F` / `-Fl` / `sudo pacman -Fy` |
| `aptitude search` | `pacman -Ss`, or `-Qs` (`~i`), `-Qm` (`~o`), `-Sii` (`~D`), `-Si` (`~C`) |
| `aptitude purge '~o'` | `pacman -Qmq \| sudo pacman -Rs -` |
| `dpkg -i`, `debi` | `sudo pacman -U <files>` |
| `dpkg -r` / `-P` | `sudo pacman -R` / `-Rn <pkgs>` |
| `dpkg -l`, `dpkg-query -W` | `pacman -Q` |
| `dpkg -L`, `dpkg-query -L` | `pacman -Ql <pkg>` |
| `dpkg -s` | `pacman -Qi <pkg>` |
| `dpkg -S`, `dlocate` | `pacman -Qo <file>` |
| `dpkg -I` / `-c` | `pacman -Qp` / `-Qpl <file>` |
| `dpkg -x`, `dpkg-deb -x` | `tar -xvf <file> [-C dir]` |
| `dpkg -V`, `debsums` | `pacman -Qk [pkg]` |
| `dpkg -C` | `pacman -Dk` |
| `deborphan` | `pacman -Qtt` |
| `debuild` | `makepkg -s` |
| `lintian` | `namcap <file>` |

Not every row of the wiki has an Arch counterpart (for example `apt-cache
showsrc` and `aptitude search '~N'`); those get a "no translation" reply.

### `service`

| service | systemctl |
|---|---|
| `service foo start/stop/restart/reload/enable/disable` | `sudo systemctl <action> foo` |
| `service foo status` (or no action) | `systemctl status foo` |
| `service foo force-reload` | `sudo systemctl reload-or-restart foo` |
| `service foo condrestart` | `sudo systemctl try-restart foo` |
| `service --status-all` | `systemctl list-units --type=service` |

### Typos and sudo

Common typos of the command names (`atp`, `egt`, `sevrice`, `sevrcie`,
`sercvie`...) and of subcommands (`isntall`, `updaet`...) are understood too, and
the corrected spelling is pointed out.

If the script is started through `sudo`, its first step is to drop back to the
invoking user; the commands it suggests carry their own `sudo`.

Anything else gets a "no translation" reply and a link to the Rosetta page.

## License

[The Unlicense](LICENSE): public domain.
