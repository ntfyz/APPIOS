[CmdletBinding()]
param(
    [string]$Message = "Update Check Gio Meme",
    [int]$TimeoutMinutes = 70
)

$ErrorActionPreference = "Stop"
# GitHub CLI reports an unauthenticated status with a non-zero exit code.
# Keep that result available in $LASTEXITCODE so the script can start login.
if ($PSVersionTable.PSVersion.Major -ge 7) {
    $PSNativeCommandUseErrorActionPreference = $false
}
$projectRoot = $PSScriptRoot
$artifactName = "JoyCards-Unsigned-IPA"
$workflowFile = "build-unsigned-ipa.yml"
$downloadRoot = Join-Path $projectRoot "build-download"

function Invoke-Git([string[]]$Arguments) {
    & git -C $projectRoot @Arguments
    if ($LASTEXITCODE -ne 0) { throw "Git command failed: git $($Arguments -join ' ')" }
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "GitHub CLI not found. Installing it now..." -ForegroundColor Yellow
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw "winget is not available. Install GitHub CLI from https://cli.github.com/, then run this file again."
    }

    & winget install --id GitHub.cli --exact --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) { throw "GitHub CLI installation failed." }

    # A newly installed app is not always added to the current PowerShell PATH.
    $ghFolder = Join-Path $env:ProgramFiles "GitHub CLI"
    $ghExe = Join-Path $ghFolder "gh.exe"
    if ((Test-Path $ghExe) -and ($env:Path -notlike "*$ghFolder*")) {
        $env:Path += ";$ghFolder"
    }
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        throw "GitHub CLI was installed, but Windows needs a new terminal session. Close this window and run build-ipa.cmd again."
    }
}

# Run through cmd to suppress gh's expected unauthenticated diagnostic on
# PowerShell versions that convert native stderr into a terminating error.
& cmd.exe /d /c "gh auth status >nul 2>nul"
if ($LASTEXITCODE -ne 0) {
    Write-Host "Sign in to GitHub in the next prompt, then the build will continue." -ForegroundColor Yellow
    & gh auth login
    if ($LASTEXITCODE -ne 0) { throw "GitHub sign-in was not completed." }
}

Push-Location $projectRoot
try {
    $branch = (& git branch --show-current).Trim()
    if ([string]::IsNullOrWhiteSpace($branch)) { throw "No active Git branch found." }

    Invoke-Git @("add", "-A")
    & git diff --cached --quiet
    $hasChanges = $LASTEXITCODE -ne 0
    if ($hasChanges) {
        Invoke-Git @("commit", "-m", $Message)
    }

    Invoke-Git @("push", "-u", "origin", $branch)
    $commit = (& git rev-parse HEAD).Trim()
    Write-Host "Pushed commit $commit on $branch." -ForegroundColor Cyan

    # The workflow starts automatically from a push to main. For any other branch,
    # trigger its workflow_dispatch event explicitly.
    if ($branch -ne "main") {
        & gh workflow run $workflowFile --ref $branch
        if ($LASTEXITCODE -ne 0) { throw "Could not start GitHub Actions workflow." }
    }

    $deadline = (Get-Date).AddMinutes($TimeoutMinutes)
    $runId = $null
    do {
        $runId = (& gh run list --workflow $workflowFile --commit $commit --limit 1 --json databaseId --jq ".[0].databaseId").Trim()
        if (-not $runId) { Start-Sleep -Seconds 5 }
    } while (-not $runId -and (Get-Date) -lt $deadline)
    if (-not $runId) { throw "No matching Actions run was created before timeout." }

    Write-Host "GitHub Actions run: $runId" -ForegroundColor Cyan
    & gh run watch $runId --exit-status
    if ($LASTEXITCODE -ne 0) { throw "Build failed. Open: gh run view $runId --log-failed" }

    $runFolder = Join-Path $downloadRoot "run-$runId"
    New-Item -ItemType Directory -Path $runFolder -Force | Out-Null
    & gh run download $runId --name $artifactName --dir $runFolder
    if ($LASTEXITCODE -ne 0) { throw "Artifact download failed." }

    $ipa = Get-ChildItem -Path $runFolder -Filter "*.ipa" -Recurse | Select-Object -First 1
    if (-not $ipa) { throw "Build succeeded but no IPA was found in the downloaded artifact." }

    Write-Host "`nDONE: $($ipa.FullName)" -ForegroundColor Green
    Invoke-Item $ipa.FullName
}
finally {
    Pop-Location
}
