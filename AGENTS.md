# AGENTS.md

## What this repo is

A ** chezmoi ** dotfiles repository managing my home environment on a CachyOS (Arch-based) machine.
It deploys config into `~` — it is **not** application source code, so there is no build system, test runner, linter, or CI to run here. Don't look for them.

## How changes get deployed

- Everything in `~` comes from `chezmoi apply` (repo root). Files at the root are rendered and materialized into the home directory.
  - Root files/dirs prefixed with `dot_` become hidden entries (`dot_zshrc` → `~/.zshrc`, `dot_config/` → `~/.config`).
  - The `executable_*` prefix sets a file mode of `0755`. `bin/` holds small executables installed into home.
  - Files named `*.tmpl` (e.g. `.chezmoiscripts/*/*.sh.tmpl`) are chezmoi templates — variables like `{{ .chezmoi.hostname }}` get filled in on apply.

## Deployment gotcha: hostname guard

`.chezmoiscripts/1_before/run_before_check-hostname.sh.tmpl` refuses to apply when the machine's hostname is exactly **`fedora`** (it prints a hint and exits 1). If `chezmoi apply` fails with that message, change the hostname first.

## `.chezmoiignore` — what does NOT get applied

`.chezmoiignore` excludes:
- `*.md` → every markdown file is **docs only**; it is never copied into `~`. The root `README.md` and `mgr/README.md` are dev notes, not deployed dotfiles.
- `mgr` → the setup manager itself lives in the repo, not in `~`.
- `.lmstudio/` → local LM Studio config/model dir is git-only.

## Setup manager: `mgr` (the real provisioning source of truth)

Besides raw dotfiles, `mgr/` is a bash setup manager for packages/system features (run from repo root):

```sh
./mgr help            # list profiles and tasks
./mgr desktop         # run every task in profiles/desktop.txt, in order
./mgr laptop          # run every task in profiles/laptop.txt, in order
./mgr core            # just the shared base layer
./mgr <task> [args]   # run a single task (e.g. ./mgr hibernation off)
./mgr $(hostname)     # works because both host names match their profile name
```

- **Order matters**: profiles resolve with an `#`-comment-stripping loop and `%include core`, so the base layer (`core`) always installs first, then machine-specific tasks. Edit `profiles/<name>.txt` to change what runs per machine; one `<task> [args]` per line.
- Circular profile includes (`%include` that loops) are a hard error.
- Tasks in `mgr/tasks/` are mostly idempotent (installers use pacman's `--needed`); profiles stop at the first failing task. Prefer running them via `./mgr <task>` rather than executing scripts directly — but both work (`./tasks/podman.sh` is fine).
- Shared helpers live in `mgr/lib/helpers.sh`: `pkg_install` (pacman, `sudo`), `aur_install` (via yay), `go_install`, `cargo_install`, `am_install`.

### Profiles

| Profile | Contents | Machine |
|---|---|---|
| `core` | base: dms-shell, core-packages, groups, shell, caddy local proxies, podman, doom-emacs | shared by every machine |
| `desktop` | `core` + nvidia, virtualization, hibernation off, ai-packages, emulators, waydroid | main PC (NVIDIA GPU) |
| `laptop` | `core` + hibernation off, disable-power-button | low-end notebook (Intel GPU) |

## Notable package boundaries / stacks

- **docker/** — docker-compose projects: `comfyui/`, `windows/` (WoW-style MMO emulation stack: mangosd/realmd/ahbot), and `tortoise/`. Managed manually, not part of a profile.
- **bin/** — user scripts installed to home (e.g. `vpn` cycles WireGuard/Xray services; `vimdiff`, `btfix`).
- **scripts/** — standalone helper scripts (audio flip, joystick wake, etc.).
- **LM Studio local models**: `dot_opencode/opencode.json` loads the `opencode-lmstudio@latest` plugin and `dot_lmstudio/` configures LM Studio as the local model backend. That's the inference path for OpenCode in this environment.

## Conventions to follow when editing

- Keep tasks idempotent; use the existing helpers in `mgr/lib/helpers.sh` instead of hand-rolling package installs.
- A new machine only needs a file in `profiles/` starting with `%include core`.
- Anything that should be git-only (docs, local model dir, mgr tooling) belongs in `.chezmoiignore`, not in `~`.
