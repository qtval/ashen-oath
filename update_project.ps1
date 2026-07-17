param(
    [switch]$NoPause
)

$ErrorActionPreference = "Stop"
$repoRoot = if (Test-Path (Join-Path $PSScriptRoot ".git")) {
    (Resolve-Path $PSScriptRoot)
} else {
    (Resolve-Path (Join-Path $PSScriptRoot ".."))
}
Set-Location $repoRoot

function Finish([string]$message, [int]$exitCode = 0) {
    Write-Host $message
    if (-not $NoPause) { Read-Host "Press Enter to close" | Out-Null }
    exit $exitCode
}

if (-not (Test-Path (Join-Path $repoRoot ".git"))) {
    Finish "This folder is not a Git repository. Download or clone the project first." 1
}

$changes = git status --porcelain
if ($LASTEXITCODE -ne 0) { Finish "Git could not inspect this project." 1 }
if ($changes) {
    Write-Host "Update stopped because this project has unsaved Git changes:" -ForegroundColor Yellow
    Write-Host $changes
    Finish "Save or commit your work, then run the updater again." 1
}

$branch = (git branch --show-current).Trim()
Write-Host "Updating The Ashen Oath ($branch)..."
git fetch origin
if ($LASTEXITCODE -ne 0) { Finish "Could not contact GitHub. Check your internet connection." 1 }

$upstream = (git rev-parse --abbrev-ref "@{u}" 2>$null).Trim()
if ($LASTEXITCODE -eq 0 -and $upstream) { git pull --ff-only } else { git pull --ff-only origin main }
if ($LASTEXITCODE -ne 0) { Finish "The update could not be applied automatically. No files were changed." 1 }

Finish "Project updated successfully. You can reopen or press Play in Godot."
