# Scenario: Audio Lab → EMC (crop sample integration)

Contract under test: Audio Lab's **Crop 10s Sample as WAV**
(`audio-lab.ncp.cropSampleItem`) prompts for a start time, builds an
`M:SS - M:SS` range, calls `emc.ncp.cropMedia` (Uri + range), then
`emc.ncp.convertWav` when the crop isn't WAV. Audio Lab gates the call on the
installed EMC version: `MIN_EMC_VERSION = 3.1.0`.

Fixtures: `fixtures/tone-15s.wav`, `fixtures/tone-15s.mp3` (15 s tone).

## A. Both from source (launch: "Audio Lab + EMC (both from source)")

- [ ] MP3 happy path: right-click `tone-15s.mp3` in Audio Lab's Media Files →
  Crop 10s Sample as WAV → start `0:02` → `tone-15s-cropped.wav` appears
  beside the fixture; **EMC's range prompt never appears**; the WAV is a real
  WAV (opens/plays, ~10 s).
- [ ] WAV happy path: same on `tone-15s.wav` → `tone-15s-cropped.wav`
  directly, no conversion step.
- [ ] Start given as bare seconds (`2`) works the same as `0:02`.
- [ ] Start near the end (`0:12` on a 15 s file): EMC's own range error
  surfaces; Audio Lab creates no phantom file and shows no second error.

## B. Against installed EMC (launch: "Audio Lab only (against installed EMC)")

- [ ] EMC 3.1.0 installed (VSIX or Marketplace once published): A-section
  happy paths behave identically.
- [ ] EMC 3.0.2 installed: crop command shows "Cropping needs Easy Media
  Converter 3.1.0 or newer (you have 3.0.2)" with an **Update** action, and
  does **not** fall through to EMC's interactive prompt.
- [ ] EMC disabled in the dev host: crop command offers to install EMC
  instead of erroring.
- [ ] Update action installs the latest EMC; after reload, the crop works.

## C. EMC standalone regression (either launch config)

- [ ] EMC's own crop (no range argument, from EMC's UI) still prompts for a
  range and crops as before — the argument is additive only.
