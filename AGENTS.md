# AGENTS.md — dotfiles

Personal configuration for a Linux desktop (`penguix`, Bluefin/Dakota) and a
Mac (`mac`), deployed with `just` + Homebrew.
README.md has the user-facing overview; this file holds the rules. They are
constraints, not suggestions.

## Architecture

- **Host files are the entry points.** `hosts/<name>.just` defines
  `repo_root`, `host_file`, `layers`, imports exactly the layers' recipes and
  defines `setup`. Host files are named by role, not by hostname. `setup`
  must stay idempotent end to end. When the step list grows, `setup` depends
  on `[private]` phase recipes (e.g. `base`, `shell`, `desktop`) that group
  their members by intent — just expands dependencies depth-first in order,
  so the effective order is unchanged, and `[private]` keeps `just -l` showing
  only `setup`. Keep every dependency line short this way instead of letting
  one line grow without bound.
- **Layers** (`common`, `linux`, `linux/gnome`, `macos`, `work/cursor`,
  `work/midas`) share one shape: `home/`, `compose/`, `recipes/`, `brew/`,
  optional `secrets.env`. `.scripts/apply.sh` deploys them in the host's
  `layers` order; `.scripts/check.sh` (`just check`) enforces the rules
  below.
- **Desktop environments nest in their OS layer** (`linux/gnome`). A nested
  layer is a layer of its own: hosts list both (`common linux linux/gnome`),
  and its recipes may depend on its parent's (e.g. `theme-sync` uses linux's
  `user-unit`), never the other way round.
- **Keep the tree flat and recipes parametric.** Repo-wide scripts live in
  `.scripts/`. When two recipes differ only in a value, write one recipe
  with a parameter (`user-unit <unit>`) and have the specific ones depend on
  it, instead of copying the body.
- **`work/` is the private `tunix/work` submodule.** Host files import its
  recipes with `import?` and must never list a work recipe as a dependency
  (the host file would not parse before the submodule is checked out); call
  work recipes from a recipe body only when `just --summary` lists them.
- `~/.justfile` is a one-line import of the host file written by
  `just install-global`. Never copy recipes into `$HOME`.

## Red lines

1. **Nothing is layered into an OS image.** No Containerfile, RPM/COPR,
   rpm-ostree, `/etc/skel` or `/etc/dconf` writes. dconf goes through the
   user database (`dconf load /`).
2. **Everything targets `$HOME`**, except the explicit sudo recipes:
   `sysctl-ttl` (linux/gnome, macos), `change-shell` (linux),
   `solaar-udev` (linux), `update-and-reboot` (linux/gnome). Do not add
   another without a reason in the recipe comment.
3. **Software comes from Homebrew (formula / cask / `flatpak` DSL) or
   Flathub.** Pinned, checksum-verified downloads are the fallback
   (Bibata). `brew bundle` only — never `brew bundle
   upgrade`.
4. **No removal logic in `apply`.** It only creates and updates files.
   Removing what the repo no longer ships is a separate, planned design.

## Layer rules (`just check` enforces 1–4)

1. Every recipe in `linux/` and `linux/gnome/` carries `[linux]`; every
   recipe in `macos/` carries `[macos]`. Common recipes never depend on an OS
   recipe — the justfile would not parse on the other OS.
2. Numbered files use their layer's band: common `00–09`, linux/macos
   `10–19`, linux/gnome `20–29`, work/cursor `50–59`, work/midas `70–79`; any
   layer may use `90–99` for "must come last" files.
3. A compose fragment name is unique per target across the active layers.
4. Active layers never ship the same `home/` path, and a path is never both
   a `home/` file and a compose target.
5. ssh keeps the FIRST value per option: lower numbers win in
   `.ssh/config.d/`, unlike everywhere else.

## Conventions

- **Drop-in first.** If a program reads a directory (fish `conf.d`,
  `environment.d`, ssh `config.d`), give each layer its own numbered file in
  `home/`. Only programs that need a single file get `compose/` fragments.
  JSON fragments are deep-merged with jq; everything else is concatenated,
  which only works for formats where a later value wins (git, ghostty, ini).
- **No templating.** The only substitution is `@HOME@` in `*.tmpl` files,
  for files that need an absolute path (LaunchAgent plist, environment.d).
  Per-host values are drop-in fragments, not variables.
- **PATH is owned by systemd `environment.d`, not shells** (Linux):
  `10-path.conf` (linux) → `20-path-brew.conf` (linux/gnome) → user extras in
  `20-path-extra.conf` (`just add-path`, never in the repo) →
  `90-path-system.conf` (system dirs last, brew doctor). `just path-show`
  prints the result; `just path-apply` pushes it into the running user
  session. Shell configs never set PATH.
- **Secrets**: only `op://` references are committed (`secrets.env`,
  `.config/opencode/.env`). `apply` resolves `${env:NAME}` in compose
  fragments with `op read`; resolved values exist only in `$HOME`.
- **Idempotency**: every recipe fast-exits 0 with a clear "nothing to do"
  message before any prompt or privileged action when its target state is
  already in place.
- **Destructive operations are explicit recipes with `[confirm]`**
  (`ssh-reset`, `lazyvim-reset`, `lazyvim-remove`, `kube-reset`).
- **Brewfiles** must pass `just brew-check` (grep-only validator; never
  evaluate Brewfiles as Ruby). Third-party taps need `trusted: true`. A
  package used on both Homebrew hosts goes to `common/brew/`.
- Before adding a GNOME Shell extension, verify its `shell_version_map` on
  extensions.gnome.org covers the target GNOME major.
- dconf edits: change the topic file in `linux/gnome/dconf/`, never dump raw
  user state into the repo (`just dconf-backup` writes to the gitignored
  `linux/gnome/dconf/proposals/`).
- **All commits follow Conventional Commits**: `<type>(<scope>):
  <description>` with `feat`, `fix`, `docs`, `chore`, `refactor`, `test`,
  `style`, `ci`.
- **Comments are always English.**

## LazyVim ruleset

`common/lazyvim/*.lua` deploy to `~/.config/nvim/lua/plugins/` through
`just lazyvim-config`, only when LazyVim is installed (`lazyvim-install`
clones the starter into an empty `~/.config/nvim` first).

1. **`core.lua` is the single source of truth** for `colorscheme`. Plugin
   files never set it.
2. **One file per plugin** in `common/lazyvim/`, named after the plugin.
3. **Theme switching** follows the chain: `toggle-color-preferences.sh` →
   `dconf`/`defaults` → Ghostty (DEC mode 2031) → `vim.o.background` →
   `core.lua` selects the colourscheme → the plugin applies the flavour.

## Verification

- `just check` must pass.
- Test deployments against a scratch `$HOME` (`HOME=$(mktemp -d) just apply`),
  never against a live session. A second `apply` must print "nothing to do".
- Never run `sysctl-ttl`, `change-shell` or `update-and-reboot` outside an
  explicit user request.
