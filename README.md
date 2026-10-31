# arch-debian-fym

*fym: **f**ix **y**our **m**istake* (or, if you prefer, *f\*\*\* you mean?*)

Installs itself as `apt`, `apt-get`, `apt-cache` and `service` on Arch Linux.
When you type one of them out of habit, it tells you "this is arch, btw." and
prints the `pacman` or `systemctl` command you meant. **It never runs anything**, and always exits
with status 1.

```
$ apt install firefox vlc
this is arch, btw. (you typed: apt install firefox vlc)
fym? fix your mistake.

run this instead:
    sudo pacman -S firefox vlc

nothing was run. this is arch-debian-fym, not debian.
```

## Install / uninstall

```sh
./install.sh              # to /usr/local/bin (uses sudo if needed)
./install.sh --uninstall
```

The script is installed as `arch-debian-fym`; the other names are symlinks to
it. `PREFIX` and `DESTDIR` are honoured. The installer refuses to run without
`pacman`, and refuses to overwrite any `apt` that isn't this project's.

## Handled commands

| apt | pacman |
|---|---|
| `update` | `sudo pacman -Syu` (a bare `-Sy` is unsupported on Arch) |
| `upgrade`, `full-upgrade`, `dist-upgrade` | `sudo pacman -Syu` |
| `install`, `reinstall` | `sudo pacman -S <pkgs>` |
| `remove` | `sudo pacman -R <pkgs>` |
| `purge` | `sudo pacman -Rns <pkgs>` |
| `autoremove` | `sudo pacman -Rns $(pacman -Qdtq)` |
| `search` | `pacman -Ss <term>` |
| `show`, `info`, `policy`, `depends` | `pacman -Si <pkg>` |
| `list` / `--installed` / `--upgradable` | `pacman -Sl` / `-Q` / `-Qu` |
| `clean`, `autoclean` | `sudo pacman -Sc` |
| `download` | `sudo pacman -Sw <pkgs>` |
| `edit-sources` | `sudoedit /etc/pacman.conf` |

### `service`

| service | systemctl |
|---|---|
| `service foo start/stop/restart/reload/enable/disable` | `sudo systemctl <action> foo` |
| `service foo status` (or no action) | `systemctl status foo` |
| `service foo force-reload` | `sudo systemctl reload-or-restart foo` |
| `service foo condrestart` | `sudo systemctl try-restart foo` |
| `service --status-all` | `systemctl list-units --type=service` |

Anything else gets a scolding and a link to the
[pacman Rosetta](https://wiki.archlinux.org/title/Pacman/Rosetta). Flags like
`-y` are dropped; only package names are carried over. `NO_COLOR` is respected.

## License

[The Unlicense](LICENSE): public domain.
