# vscode-ext-colab

A shared test bench for VS Code extensions that **invoke each other's commands**
(`commands.executeCommand` across extension boundaries). It holds no extension
code of its own — just the workspace wiring, test fixtures, and scenario
checklists needed to run two extensions in **one** Extension Development Host.

## Why this exists

Cross-extension calls only resolve when both extensions are loaded in the
**same** VS Code window (one extension host process). Two separate F5 windows
can't see each other's commands. This repo makes the one-window setup one
click, instead of re-deriving launch flags for every pair.

First pair: **Audio Lab** (`vscode-audio-lab`) calls **Easy Media Converter**
(`vscode-emc`) — Audio Lab's "Crop 10s Sample as WAV" delegates cropping to
`emc.ncp.cropMedia` and conversion to `emc.ncp.convertWav`, gated on the
installed EMC version (`>= 3.1.0`).

**Simpler path for this pair:** the [`emc-audio-lab/`](emc-audio-lab/) folder
is self-contained — run its `setup.ps1` / `setup.sh` to clone both extensions
inside it (gitignored), then open that folder in VS Code and F5. No sibling
clones or multi-root workspace needed. The sibling layout below is the
general pattern for other pairs.

## Layout expected

The member extensions are **sibling clones** of this repo (paths in the
workspace file are relative — no absolute paths):

```
<parent>/
  vscode-ext-colab/     <- this repo
  audio-lab/            <- lanly-dev/vscode-audio-lab
  vscode-emc/           <- lanly-dev/vscode-emc
```

## Usage

1. Open `ext-colab.code-workspace` in VS Code.
2. Run and Debug → pick a configuration → F5:
   - **Audio Lab + EMC (both from source)** — both extensions load from their
     working trees (webpack build runs first via the `build: both` task).
     Use this when iterating on either side of the contract.
   - **Audio Lab only (against installed EMC)** — only Audio Lab is a dev
     extension; EMC is whatever you have installed (Marketplace or VSIX).
     Use this to test the version gate and the not-installed flow against
     real installs.
3. Work through the pair's checklist in `scenarios/`.

Notes:

- In a dev host, a dev copy of an extension overrides the installed copy with
  the same ID — in the "both from source" config, your installed EMC is
  shadowed by the source EMC. That's expected.
- To test the *missing-extension* state, disable the partner extension in the
  dev host's Extensions panel (or uninstall it, for the "Audio Lab only"
  config).
- Fixtures live in `fixtures/` — small generated media (15 s tone as WAV and
  MP3) so crop/convert scenarios have something to chew on. Don't commit real
  recordings here.

## Adding another pair

1. Clone the extensions as siblings of this repo.
2. Add their folders to `ext-colab.code-workspace`.
3. Add a launch configuration with one `--extensionDevelopmentPath` per
   extension, plus matching `build:` tasks.
4. Add a checklist under `scenarios/<pair>.md`: happy path, partner missing,
   partner outdated (if version-gated), and malformed-input cases.
