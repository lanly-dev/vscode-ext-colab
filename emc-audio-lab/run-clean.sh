#!/usr/bin/env bash
# Clean dev environment with ONLY Audio Lab + EMC in it.
#
# How each extension gets in:
# - EMC is packaged as a .vsix and INSTALLED into the isolated
#   .test-profile, so it shows under "Installed" in the Extensions view
#   and Audio Lab's version gate sees a real installed EMC 3.1.0.
# - Audio Lab loads from source via --extensionDevelopmentPath (its vsix
#   packaging is currently blocked by its own manifest: @types/vscode
#   ^1.145.0 vs engines.vscode ^1.144.0 - vsce refuses to package).
#
# Why not F5 for this: the extensionHost debugger does not reliably honor
# --user-data-dir / --extensions-dir, so the dev host can fall back to
# your normal profile. The `code` CLI honors them.
# Built-in extensions (Git, Emmet, JSON, ...) always show - they ship
# with VS Code itself and no profile can remove them.
set -euo pipefail
cd "$(dirname "$0")"
root="$PWD"

for dir in audio-lab vscode-emc; do
  if [ ! -f "$dir/package.json" ]; then
    echo "$dir is not cloned yet - run ./setup.sh first." >&2
    exit 1
  fi
done

echo "== building audio-lab (dev) =="
(cd audio-lab && npx webpack --mode development)

echo "== packaging + installing EMC into .test-profile =="
(cd vscode-emc && npx -y @vscode/vsce package --out "$root/emc.vsix")
profile="$root/.test-profile"
code --user-data-dir "$profile" --extensions-dir "$profile/extensions" --install-extension "$root/emc.vsix" --force
rm -f "$root/emc.vsix"

echo "== launching clean VS Code =="
echo 'Check: Extensions view should list Easy Media Converter under Installed;'
echo 'Command Palette -> "Developer: Show Running Extensions" should list both.'
code --new-window \
  --user-data-dir "$profile" \
  --extensions-dir "$profile/extensions" \
  --disable-workspace-trust \
  --extensionDevelopmentPath "$root/audio-lab" \
  "$root/test-workspace"
