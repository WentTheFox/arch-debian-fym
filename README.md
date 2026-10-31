# arch-debian-fym

*fym: **f**ix **y**our **m**istake* (or, if you prefer, *f\*\*\* you mean?*)

An innocent little script that teaches you how to run these commands on Arch.

It installs itself as `apt`, `apt-get`, `apt-cache` and `service`. When you type
one of them out of habit, it shows the `pacman` or `systemctl` command you
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
also refuses to overwrite any `apt` that isn't this project's.

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
`-y` are dropped; only package names are carried over.

## License

[The Unlicense](LICENSE): public domain.
