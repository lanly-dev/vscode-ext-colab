#!/usr/bin/env bash
# Clone (or update) Audio Lab + EMC into this folder and install their deps.
# The clones are gitignored — this folder is only the dev-host wiring.
set -euo pipefail
cd "$(dirname "$0")"

clone_or_update() {
  local dir="$1" url="$2" branch="$3"
  if [ -d "$dir/.git" ]; then
    echo "== $dir already cloned — pulling =="
    git -C "$dir" pull --ff-only
  else
    echo "== cloning $url -> $dir (branch: $branch) =="
    git clone --branch "$branch" "$url" "$dir"
  fi
  echo "== npm install in $dir =="
  (cd "$dir" && npm install)
}

# The Crop command lives on Audio Lab's PR #5 branch, not main yet.
clone_or_update "audio-lab"  "https://github.com/lanly-dev/vscode-audio-lab.git" "feat/crop-sample-via-emc"
# EMC's crop range-arg (3.1.0) is merged on main.
clone_or_update "vscode-emc" "https://github.com/lanly-dev/vscode-emc.git"        "main"

echo
echo "Done. Open THIS folder (emc-audio-lab) in VS Code, then F5:"
echo "  Run and Debug -> 'EMC + Audio Lab (both from source)'"
