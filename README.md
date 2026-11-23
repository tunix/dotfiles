# dotfiles

Personal configuration for every machine I use — Linux desktop (Bluefin /
Dakota), Raspberry Pi and macOS — deployed with [`just`](https://just.systems)
and Homebrew. No Ansible, no image layering. The former
[penguix](https://github.com/tunix/penguix) repo (Linux desktop) lives here as
the `gnome` layer.

## First run

| Machine | Command |
|---|---|
| macOS | `curl -fsSL https://raw.githubusercontent.com/tunix/dotfiles/main/hosts/mac.sh \| bash` |
| Raspberry Pi 5 | `git clone https://github.com/tunix/dotfiles.git ~/dotfiles && ~/dotfiles/hosts/pi5.sh` |
| Linux desktop | `git clone https://github.com/tunix/dotfiles.git ~/dotfiles && just --justfile ~/dotfiles/hosts/penguix.just setup` |

`hosts/mac.sh` installs only Homebrew and just (Homebrew's installer brings
the Xcode Command Line Tools, and with them git), clones the repo and runs
`setup`. `hosts/pi5.sh` installs a pinned, checksum-verified just release
into `~/.local/bin` (the Pi has no Homebrew). On the Linux desktop brew and
just ship with the image.

`setup` is idempotent: every step fast-exits with "nothing to do" when its
target state is already in place, so it is safe to re-run at any time.

## Daily use

`setup` ends with `just install-global`, which writes a one-line
`~/.justfile` importing this machine's host file. After that, every recipe
runs from anywhere under `$HOME` **without** `-g`:

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

## Layout

```
hosts/        one entry justfile per machine (+ first-run scripts)
  penguix.just  layers: common linux gnome
  pi5.just      layers: common linux pi
  mac.just      layers: common macos work/cursor work/midas
  mac.sh, pi5.sh
lib/          apply.sh (deploy engine), check.sh (rules), validate-brewfiles.sh
common/       every machine
linux/        every Linux machine (PATH via environment.d, login shell)
gnome/        Linux desktop: dconf, GNOME extensions, flatpaks, desktop services
pi/           Raspberry Pi: apt packages and repositories
macos/        macOS: Homebrew packages, LaunchAgent, sysctl
work/         private submodule (tunix/work): work/cursor, work/midas
```

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
| `gnome`, `pi` | `20`–`29` |
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
(`chsh`)

**gnome** — `dconf-apply`, `dconf-backup`, `dconf-reset KEY`,
`dconf-vs-defaults`, `extensions`, `extension-install` / `-disable` /
`-uninstall UUID`, `extensions-list`, `theme-sync`, `sun-scheduler`,
`bibata`, `brave-1password-fix`, `flatpak-remote`,
`install-jetbrains-toolbox`, `aws-session-manager`, `sysctl-ttl`,
`update-and-reboot`, `clean-containers`, `status`

**pi** — `apt-repos`, `apt-packages`

**macos** — `sysctl-ttl`, `aws-session-manager`, `work-submodule`

**work** — `cursor-legacy-cleanup`, plus the midas recipes (argo, aws, k8s,
kube, teleport, vault, 1password)

## Requirements

- just ≥ 1.27 (`source_directory()`); the Pi pins 1.59.0
- jq (JSON fragments) — in `common/brew/cli.Brewfile` and the Pi's apt list
- The work layers need the 1Password CLI (`op`) signed in for `just apply`
