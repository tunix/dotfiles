# dotfiles

Personal configuration for my machines — Linux desktop (Bluefin / Dakota)
and macOS — deployed with [`just`](https://just.systems) and Homebrew. No
Ansible, no image layering. The former
[penguix](https://github.com/tunix/penguix) repo (Linux desktop) lives here as
the `linux/gnome` layer.

## First run

| Machine | Command |
|---|---|
| macOS | `curl -fsSL https://raw.githubusercontent.com/tunix/dotfiles/main/.scripts/bootstrap-mac.sh \| bash` |
| Linux desktop | `git clone https://github.com/tunix/dotfiles.git ~/Projects/dotfiles && just -f ~/Projects/dotfiles/hosts/penguix.just setup` |

`.scripts/bootstrap-mac.sh` installs only Homebrew and just (Homebrew's
installer brings the Xcode Command Line Tools, and with them git), clones the
repo and runs `setup`. On the Linux desktop brew and just ship with the
image.

`setup` is idempotent: every step reports what it did and says so when its
target state is already in place, so it is safe to re-run at any time.

## Daily use

`setup` ends with `just install-global`, which writes a `~/.justfile` that
imports this machine's host file and, run bare, lists its recipes. After that,
every recipe runs from anywhere under `$HOME` **without** `-g`:

```sh
just              # list this host's recipes
just apply        # redeploy files after editing the repo
just brew-sync    # install what the Brewfiles declare
just check        # validate the repo rules
```

- A project's own justfile wins inside that project. If it contains
  `set fallback := true`, recipes it does not define fall through to these.
- Nothing is copied: new recipes in the repo show up immediately. Re-run
  `just install-global` only if the machine's host file changes or the repo
  moves.
- Outside `$HOME` (`/tmp`, `/opt`, …) use `just -g <recipe>`.
- On GNOME the colour scheme follows local sunrise/sunset
  (`penguix-sun-scheduler` user timer, located via Night Light). `setup` and
  `just sun-scheduler` apply the current answer immediately, and the dconf
  topic files never set `color-scheme`, so `just apply` cannot flip it back.

## Output

Every step prints one line — status, step, what happened — so a run reads
top to bottom:

```
  ok   flatpak-remote      flathub user remote present
  ok   brew-sync           66 packages in 8 Brewfiles, all present
  ok   apply               nothing to do
  upd  dconf-apply         4 dconf files loaded, settings changed
  skip aws-session-manager AWS CLI not installed
  upd  install-global      2 files written
                           ~/.justfile -> ~/Projects/dotfiles/hosts/penguix.just

setup  17 step(s) · 2 changed (dconf-apply, install-global) · 2 skipped
       log out/in (or restart GNOME Shell) for the dconf and extension
       changes to apply fully
```

| Status | Meaning |
|---|---|
| `ok` | the target is already in place, nothing changed |
| `upd` | the step changed something |
| `skip` | the step does not apply on this machine |
| `warn` | something was off, the step carried on |
| `fail` | the step failed (setup stops there) |

Details (files deployed, packages installed, services enabled) are indented
under their step, and the closing tally counts the run.

- The output of the commands a step runs is kept in
  `~/.cache/dotfiles/logs/<step>.log`, printed when a command fails, and
  echoed live with `just setup-verbose` (or `DOTFILES_VERBOSE=1 just setup`).
- A failing step prints its log and stops `setup`; the step's line in the
  tally tells you what to re-run.
- `just status`, `path-show`, `extensions-list` and `dconf-vs-defaults` print
  reports of their own, not step lines.

## Layout

```
hosts/        one entry justfile per machine
  penguix.just  layers: common linux linux/gnome
  mac.just      layers: common macos work/cursor work/midas
.scripts/     apply.sh (deploy engine), check.sh (rules), ui.sh (output +
              logs), summary.sh (setup tally), bootstrap-mac.sh,
              validate-brewfiles.sh, install-gnome-extension.sh, dconf-vs-defaults.py
common/       every machine
linux/        every Linux machine: OS/device/CLI state (Brewfiles, flatpaks,
              PATH via environment.d, login shell, user units, udev rules)
  gnome/      GNOME-only on top of linux: dconf, shell extensions, timers
macos/        macOS: Homebrew packages, LaunchAgent, sysctl
work/         private submodule (tunix/work): work/cursor, work/midas
```

A desktop environment is a layer nested in its OS layer (`linux/gnome`): a
host lists both, and only hosts that import it see its recipes. A new
machine is a new host file listing the layers it needs.

A nested layer owns only what is specific to it: `linux/gnome/` holds only
what reads or writes a GNOME-only interface (dconf/gsettings, GNOME Shell
extensions, GNOME-integration helpers). A file that would work unchanged
without GNOME belongs in `linux/`.

Every layer has the same shape:

| Path | Meaning |
|---|---|
| `home/` | Copied to the same path under `$HOME`. `*.tmpl` files get `@HOME@` replaced. |
| `compose/<target>/NN-name.ext` | Fragments merged into one `$HOME/<target>` (see below). |
| `recipes/main.just` | Recipes, imported by the host files that use the layer. |
| `brew/*.Brewfile` | Installed by `brew-sync` for every active layer. |
| `secrets.env` | `NAME=op://…` references for `${env:NAME}` placeholders (work layers). |

## Layers and drop-ins

A host's `layers` line decides what is active and in which order. Files are
numbered by layer, so later layers override earlier ones:

| Layer | Numbers |
|---|---|
| `common` | `00`–`09` |
| `linux`, `macos` | `10`–`19` |
| `linux/gnome` | `20`–`29` |
| `work/cursor` | `50`–`59` |
| `work/midas` | `70`–`79` |
| any layer, "must come last" | `90`–`99` |

- **Programs that read a directory** (fish `conf.d`, systemd
  `environment.d`, ssh `config.d`) get one numbered file per layer in
  `home/`; the program applies them in name order.
- **Programs that need one file** (`.gitconfig`, ghostty, Cursor's
  `settings.json` / `mcp.json`, aws config, …) get fragments under
  `compose/<target>/`. `just apply` sorts the fragments of all active layers
  by file name and merges them: JSON is deep-merged (later keys win), every
  other format is concatenated (later values win in git/ghostty/ini).
  `.mode` sets the file mode of the result, `.keep-existing` merges JSON on
  top of the current file so app-written keys survive.
- ssh is the exception: it keeps the **first** value per option, so a lower
  number wins there.

## Linux vs. macOS

Each host file imports only its own layers, so another OS's recipes are
neither listed nor runnable. On top of that, every recipe in an OS layer
carries `[linux]` or `[macos]`, and common recipes never depend on OS
recipes — otherwise the justfile would not even parse on the other OS.
`just check` enforces both.

## Recipes by layer

**common** — `apply`, `check`, `install-global`, `brew-sync`, `brew-check`,
`update-brew-casks` (`ubc`), `bashrc-dircolors`, `bat-cache`,
`lazyvim-install` / `-config` / `-update` / `-backup` / `-reset` /
`-remove` / `-reinstall`, `ssh-init`, `ssh-reset`

**linux** — `add-path <dir>`, `path-show`, `path-apply`, `change-shell`
(`chsh`), `user-unit <unit>`, `solaar-udev`, `flatpak-remote`,
`install-jetbrains-toolbox`, `aws-session-manager`, `brave-1password-fix`,
`sysctl-ttl`, `update-and-reboot`, `clean-containers`, `status`

**linux/gnome** — `dconf-apply`, `dconf-backup`, `dconf-reset KEY`,
`dconf-vs-defaults`, `extensions`, `extension-install` / `-disable` /
`-uninstall UUID`, `extensions-list`, `theme-sync`, `sun-scheduler`,
`bibata`

**macos** — `sysctl-ttl`, `aws-session-manager`, `work-submodule`

**work** — `cursor-legacy-cleanup`, plus the midas recipes (argo, aws, k8s,
kube, teleport, vault, 1password)

**host** — `setup` (bring the machine to the repo state, through its private
`base`/`shell`/`gnome` phases), `setup-verbose` (the same, with every step's
raw command output)

## Requirements

- just ≥ 1.27 (`source_directory()`)
- jq (JSON fragments) — in `common/brew/cli.Brewfile`
- The work layers need the 1Password CLI (`op`) signed in for `just apply`
