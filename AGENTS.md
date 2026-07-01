# AGENTS.md — dotfiles

## Quickstart

```bash
ansible-playbook penguix.yml   # Linux desktop
ansible-playbook mac.yml       # macOS
ansible-playbook pi5.yml       # Raspberry Pi 5
```

Requires `ansible` installed first. All playbooks target `localhost`.

## Architecture

- **Ansible-based personal dotfiles**. Three playbooks (`penguix.yml`, `mac.yml`, `pi5.yml`) each set vars and include roles.
- **7 roles**: `brew` (macOS Homebrew), `configuration` (shell, git, editor, etc.), `flatpak`, `gnome`, `linux`, `mac`, `work` (git submodule — private, `git@github.com:tunix/work.git`).
- **`ansible.cfg`** sets `hash_behaviour=merge` — hash vars merge across playbook and role defaults instead of overriding.
- **Playbooks are the source of truth** for which roles run and what vars differ from role defaults. Role defaults are in `roles/*/defaults/main.yml`.

## Important conventions

- **Variables are merged** (not overridden) due to `hash_behaviour=merge`. A var in a playbook merges into the role default rather than replacing it.
- **Templates (.j2)** for files needing variable substitution; static files live in `roles/<role>/files/`.
- **Color management** uses `toggle-color-preferences.sh` (light/dark toggle across ghostty, zellij, k9s, bat, lunarvim). macOS also has a LaunchAgent for automatic toggle.
- **SSH task** (`configuration/tasks/ssh.yml`) **deletes** `~/.ssh` then recreates it — be careful.
- **Work role** (`midas.yml`) also **deletes** `~/.kube` before regenerating kubeconfigs.
- **ignore_errors: true** on brew packages, flatpak apps, and linux package install — transient failures expected.
- **bat cache rebuild** via handler triggered on config change.
- **Maven config** is gated on `configure.maven: true` (set in `mac.yml`/`penguix.yml`).
- **All commits must follow Conventional Commits**: `<type>(<scope>): <description>`. Types: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `style`, `ci`.

## Key entrypoints

| File | Purpose |
|------|---------|
| `penguix.yml` | Linux desktop (roles: linux, gnome, configuration, work) |
| `mac.yml` | macOS (roles: brew, configuration, mac, work) |
| `pi5.yml` | Raspberry Pi 5 (roles: linux, configuration) |
| `roles/configuration/tasks/main.yml` | Tool config orchestration (includes conditional sub-tasks) |
| `roles/work/tasks/midas.yml` | Work-specific k8s, git, maven, aws, just config |

## Submodules

```bash
git submodule update --init
```

`roles/work` is a private submodule. The midas work role is gated on `work.midas: true` (set in playbooks).
