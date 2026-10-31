# arch-debian-fym

*fym: **f**ix **y**our **m**istake* (or, if you prefer, *f\*\*\* you mean?*)

Installs itself as `apt`, `apt-get`, `apt-cache` and `service` on Arch Linux.
When you type one of them out of habit, it tells you "this is arch, btw." and
prints the `pacman` or `systemctl` command you meant. It only runs the command if you say yes at a prompt.

```
$ apt install firefox vlc
<fish> this is arch, btw. run this instead:
<fish> sudo pacman -S firefox vlc
<fish> run it? [y/N]
<went> yup
```

In a terminal, the reply is formatted as chat lines from your own shell (the
name of `$SHELL`) and typed out character by character with a short delay
between characters. Set `FYM_NO_DELAY` to skip the delay.

After suggesting a complete command it asks `run it? [y/N]`. Pressing `y` echoes a random
yes (`yes`, `yeah`, `yure`, `ye`, `y not`, `yus`, `yup`) as `<you> ...` (your
`$USER`) and runs the command, exiting with its status. Anything else
(including Ctrl+C) echoes a random no (`nvm`, `nope`, `nah`, `no ty`,
`no thanks`, `nevermind`) and exits with status 1 without running anything. The prompt only appears when stdin, stdout and stderr
are all terminals, and `FYM_NO_PROMPT` disables it.

When output isn't an interactive terminal (piped, captured, run from a script
or cron), only the command is printed, on stdout, with no chat decoration:

```
$ apt install firefox vlc | cat
sudo pacman -S firefox vlc
```

If there's no complete command to suggest (e.g. `apt install` with no package),
nothing goes to stdout and a one-line error goes to stderr. Unless you answer
`y` to the prompt, the exit status is always 1.

## Install / uninstall

```sh
./install.sh              # to /usr/local/bin (uses sudo if needed)
./install.sh --uninstall
```

`/usr/local/bin/arch-debian-fym` is a symlink to `bin/arch-debian-fym` in this
checkout (so edits and `git pull` take effect immediately), and the other names
are symlinks to it. If you move the checkout, re-run `./install.sh`. `PREFIX` and `DESTDIR` are honoured. The installer refuses to run without
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
`-y` are dropped; only package names are carried over.

## License

[The Unlicense](LICENSE): public domain.
