#!/usr/bin/env bash
# Launch a clean-profile VS Code window with ONLY Audio Lab + EMC loaded
# from source. This goes through the `code` CLI directly instead of the F5
# debugger, because the extensionHost debugger does not reliably honor
# --user-data-dir / --extensions-dir (the dev host can fall back to your
# normal profile, so your installed extensions show up anyway).
# Built-in extensions (Git, Emmet, JSON, ...) always show - they ship with
# VS Code itself and no profile can remove them.
set -euo pipefail
cd "$(dirname "$0")"

for dir in audio-lab vscode-emc; do
  if [ ! -f "$dir/package.json" ]; then
    echo "$dir is not cloned yet - run ./setup.sh first." >&2
    exit 1
  fi
  echo "== building $dir =="
  (cd "$dir" && npx webpack --mode development)
done

profile="$PWD/.test-profile"
echo "== launching clean VS Code (profile: .test-profile) =="
code --new-window \
  --user-data-dir "$profile" \
  --extensions-dir "$profile/extensions" \
  --disable-workspace-trust \
  --extensionDevelopmentPath "$PWD/audio-lab" \
  --extensionDevelopmentPath "$PWD/vscode-emc" \
  "$PWD/test-workspace"
