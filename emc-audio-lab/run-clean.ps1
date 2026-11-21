# Launch a clean-profile VS Code window with ONLY Audio Lab + EMC loaded
# from source. This goes through the `code` CLI directly instead of the F5
# debugger, because the extensionHost debugger does not reliably honor
# --user-data-dir / --extensions-dir (the dev host can fall back to your
# normal profile, so your installed extensions show up anyway).
# Built-in extensions (Git, Emmet, JSON, ...) always show - they ship with
# VS Code itself and no profile can remove them.
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

foreach ($dir in 'audio-lab', 'vscode-emc') {
  if (-not (Test-Path "$dir/package.json")) {
    throw "$dir is not cloned yet - run ./setup.ps1 first."
  }
  Write-Host "== building $dir =="
  Push-Location $dir
  npx webpack --mode development
  Pop-Location
  if ($LASTEXITCODE -ne 0) { throw "build failed for $dir" }
}

$profile = Join-Path $PSScriptRoot '.test-profile'
Write-Host '== launching clean VS Code (profile: .test-profile) =='
code --new-window `
  --user-data-dir "$profile" `
  --extensions-dir "$profile/extensions" `
  --disable-workspace-trust `
  --extensionDevelopmentPath "$PSScriptRoot/audio-lab" `
  --extensionDevelopmentPath "$PSScriptRoot/vscode-emc" `
  "$PSScriptRoot/test-workspace"
