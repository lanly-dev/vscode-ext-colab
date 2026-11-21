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
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

foreach ($dir in 'audio-lab', 'vscode-emc') {
  if (-not (Test-Path "$dir/package.json")) {
    throw "$dir is not cloned yet - run ./setup.ps1 first."
  }
}

Write-Host '== building audio-lab (dev) =='
Push-Location audio-lab
npx webpack --mode development
Pop-Location
if ($LASTEXITCODE -ne 0) { throw 'audio-lab build failed' }

Write-Host '== packaging + installing EMC into .test-profile =='
Push-Location vscode-emc
npx -y @vscode/vsce package --out "$PSScriptRoot/emc.vsix"
Pop-Location
if ($LASTEXITCODE -ne 0) { throw 'EMC packaging failed' }

$profile = Join-Path $PSScriptRoot '.test-profile'
code --user-data-dir "$profile" --extensions-dir "$profile/extensions" --install-extension "$PSScriptRoot/emc.vsix" --force
Remove-Item "$PSScriptRoot/emc.vsix"

Write-Host '== launching clean VS Code =='
Write-Host 'Check: Extensions view should list Easy Media Converter under Installed;'
Write-Host 'Command Palette -> "Developer: Show Running Extensions" should list both.'
$launchArgs = @(
  '--new-window'
  "--user-data-dir=$profile"
  "--extensions-dir=$profile/extensions"
  '--disable-workspace-trust'
  "--extensionDevelopmentPath=$PSScriptRoot/audio-lab"
  "$PSScriptRoot/test-workspace"
)
code @launchArgs
