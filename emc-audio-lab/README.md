# emc-audio-lab

Self-contained dev folder for the **Audio Lab → EMC** pair. Instead of three
sibling clones wired by a multi-root workspace (the parent repo's original
layout), this folder clones both extensions *inside itself* and is opened
directly in VS Code as a plain folder — its `.vscode/launch.json` spins up
one Extension Development Host with both extensions loaded from source.

Why one host matters: cross-extension calls
(`commands.executeCommand('emc.ncp.cropMedia', …)`) only resolve when both
extensions load in the **same** extension host. Two separate F5 windows can't
see each other.

## Setup

Windows:

```powershell
./setup.ps1
```

macOS / Linux:

```bash
./setup.sh
```

The script clones (or pulls, if already cloned) into this folder and runs
`npm install` in each:

| Folder       | Repo                            | Branch                   |
|--------------|---------------------------------|--------------------------|
| `audio-lab/` | `lanly-dev/vscode-audio-lab`    | `feat/crop-sample-via-emc` (the Crop command, PR #5 — not on main yet) |
| `vscode-emc/`| `lanly-dev/vscode-emc`          | `main` (3.1.0 crop range-arg, merged) |

Both clones are listed in this folder's `.gitignore` — they keep their own
repos and are never committed here.

## Run

1. Open **this folder** (`emc-audio-lab`) in VS Code — not a `.code-workspace`.
2. Run and Debug → pick a configuration → F5:
   - **EMC + Audio Lab (clean profile, only these 2)** — the recommended
     test config. Same as below, plus `--user-data-dir` /
     `--extensions-dir` pointing at this folder's `.test-profile/`, so the
     dev host starts with a clean, isolated VS Code profile: no installed
     extensions, no settings or sign-ins from your normal profile — only
     VS Code's built-ins and the two dev extensions. The profile persists
     between runs (so settings you set while testing stick); delete
     `.test-profile/` to reset it to factory. It's gitignored.
   - **EMC + Audio Lab (both from source)** — builds both with webpack
     (`build: both` task), then opens a dev host with both extensions loaded
     and `test-workspace/` open as the workspace folder, using your normal
     profile (your installed extensions are present too).
   - **Audio Lab only (against installed EMC)** — only Audio Lab is a dev
     extension; EMC is whatever you have installed. Use this to test Audio
     Lab's EMC version gate (≥ 3.1.0) and the not-installed flow. This one
     deliberately uses your normal profile — a clean profile has no
     installed EMC to test against.
3. Work through the pair's checklist in `../scenarios/audio-lab-emc.md`.

Notes:

- "Loaded from source" is not "installed": a dev extension shadows an
  installed copy with the same ID inside the dev host only.
- `test-workspace/` holds the 15 s tone fixtures (WAV + MP3) for the crop
  tests. Cropped outputs land there too and are gitignored.
- To test the *missing-extension* state in the second configuration,
  disable/uninstall EMC in the dev host's Extensions panel.
