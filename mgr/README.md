# mgr

Setup manager for my CachyOS installation. Each script in `tasks/` is one
self-contained "task" (install packages, enable a feature, ...). Machine
profiles in `profiles/` decide which tasks run on each of my two PCs:

| Machine   | What it gets                                                              | Why                                                        |
|-----------|---------------------------------------------------------------------------|------------------------------------------------------------|
| `core`    | shared base: dms-shell, core-packages, groups, shell, vpn                 | common to every machine; pulled in by all profiles via `%include core` |
| `desktop` | core + nvidia, podman, virtualization, voxtype, hibernation off, ai packages, emulators | main machine with an NVIDIA GPU; all heavy stuff lives here |
| `laptop`  | core + caddy local proxies                                                | low-end notebook with Intel GPU, mostly for watching movies |

## Layout

```
mgr/
├── mgr                  # entry point — run this, not the scripts directly
├── lib/helpers.sh       # shared functions used by tasks (logging, package installers)
├── tasks/               # one file per task; run via ./mgr or directly
│   ├── <task1>.sh
│   ├── <task2>.sh
│   ├── ...
├── profiles/            # which tasks run on which machine (one "<task> [args]" per line)
│   │                    # a "%include <profile>" line pulls in another profile first
│   ├── core.txt         # shared base layer, included by every other profile
│   ├── desktop.txt      # %include core + desktop-only tasks
│   └── laptop.txt       # %include core + laptop-only tasks
└── tools/                      # manual utilities, not part of any profile (desktop only)
    ├── savegames-link-ps4      # link shadPS4 saves to ~/.savegames/shadps4/savedata
    ├── savegames-link-switch   # link Eden saves to ~/.savegames/switch
    └── savegames-link-windows  # link a wine prefix's steamuser dir to ~/.savegames/windows
```

## Usage

Run the whole profile for this machine:

```sh
./mgr desktop     # on the desktop
./mgr laptop      # on the laptop
```

Since both hostnames match their profile names, `./mgr $(hostname)` works too.

Run a single task (with optional arguments):

```sh
./mgr hibernation off
./mgr podman
```

List available profiles and tasks:

```sh
./mgr help
```

Manual tools — run when needed on the desktop:

```sh
./tools/savegames-link-ps4
./tools/savegames-link-switch [--force]
./tools/savegames-link-windows <wine-prefix-dir>   # SAVEGAMES_DIR env var to override target
```

## Notes

- Tasks are mostly idempotent (installers use `--needed`), so re-running a
  profile is safe. A profile stops at the first failing task.
- To change what runs on a machine, edit its file in `profiles/` — one
  `<task> [args...]` per line, lines starting with `#` are comments.
- Profiles can include other profiles: a `%include <name>` line (e.g.
  `%include core`) runs that profile's tasks at that point. All machine
  profiles start from the shared `core` base layer; new machines just need a
  file in `profiles/` beginning with `%include core`. Includes are resolved
  against `profiles/`, so `core.txt` is accepted as well. A circular include
  (a profile including itself, directly or via another profile) is an error.
- `./mgr core` installs just the base layer on its own.
- Tasks can also be run directly (`./tasks/podman.sh`) if you prefer.
