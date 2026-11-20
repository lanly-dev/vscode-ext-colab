# Clone (or update) Audio Lab + EMC into this folder and install their deps.
# The clones are gitignored — this folder is only the dev-host wiring.
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

function Clone-Or-Update($Dir, $Url, $Branch) {
  if (Test-Path "$Dir/.git") {
    Write-Host "== $Dir already cloned — pulling =="
    git -C $Dir pull --ff-only
  } else {
    Write-Host "== cloning $Url -> $Dir (branch: $Branch) =="
    git clone --branch $Branch $Url $Dir
  }
  if ($LASTEXITCODE -ne 0) { throw "git failed for $Dir" }
  Write-Host "== npm install in $Dir =="
  Push-Location $Dir
  npm install
  Pop-Location
  if ($LASTEXITCODE -ne 0) { throw "npm install failed for $Dir" }
}

# The Crop command lives on Audio Lab's PR #5 branch, not main yet.
Clone-Or-Update 'audio-lab'  'https://github.com/lanly-dev/vscode-audio-lab.git' 'feat/crop-sample-via-emc'
# EMC's crop range-arg (3.1.0) is merged on main.
Clone-Or-Update 'vscode-emc' 'https://github.com/lanly-dev/vscode-emc.git'        'main'

Write-Host ''
Write-Host 'Done. Open THIS folder (emc-audio-lab) in VS Code, then F5:'
Write-Host "  Run and Debug -> 'EMC + Audio Lab (both from source)'"
