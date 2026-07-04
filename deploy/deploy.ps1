# HelmForge deploy script (Windows PowerShell)
# Usage: powershell -ExecutionPolicy Bypass -File .\deploy\deploy.ps1 -Yes
# Full one-click logic added in P4-T17. This skeleton creates mirror dirs + copies skills.

param(
    [switch]$Yes,
    [string]$Target = "$env:USERPROFILE"
)

# Force UTF-8 output to avoid GBK encoding issues on Windows
chcp 65001 > $null
$env:PYTHONUTF8 = 1
$env:PYTHONIOENCODING = 'utf-8'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Resolve repo root (parent of the script's directory)
# ---------------------------------------------------------------------------
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot  = Split-Path -Parent $ScriptDir

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host " HelmForge Deploy Skeleton (P1-T3)" -ForegroundColor Cyan
Write-Host " Full one-click logic ships in P4-T17" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Repo root  : $RepoRoot"
Write-Host "Target dir : $Target"
Write-Host "Auto-yes   : $Yes"
Write-Host ""

# ---------------------------------------------------------------------------
# Confirm (unless -Yes)
# ---------------------------------------------------------------------------
if (-not $Yes) {
    $answer = Read-Host "Proceed with deployment? [y/N]"
    if ($answer -notmatch '^[Yy]') {
        Write-Host "Aborted by user." -ForegroundColor Yellow
        exit 0
    }
}

# ---------------------------------------------------------------------------
# TODO T17: add backup of existing mirror dirs before overwriting
# TODO T17: add pre-flight verification (disk space, existing configs)
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Create five mirror directories under the target
# ---------------------------------------------------------------------------
$Mirrors = @('.claude', '.codex', '.gemini', '.agents')

Write-Host "[1/3] Creating mirror directories..." -ForegroundColor Green
foreach ($mirror in $Mirrors) {
    $mirrorPath = Join-Path $Target $mirror
    if (-not (Test-Path $mirrorPath)) {
        New-Item -ItemType Directory -Force -Path $mirrorPath | Out-Null
        Write-Host "  created: $mirrorPath"
    } else {
        Write-Host "  exists : $mirrorPath"
    }
}
Write-Host ""

# ---------------------------------------------------------------------------
# Copy skills from each mirror source in the repo to the target
# Assumes repo layout: <RepoRoot>/<mirror>/skills/ -> <Target>/<mirror>/skills/
# ---------------------------------------------------------------------------
Write-Host "[2/3] Copying skills into mirror directories..." -ForegroundColor Green
foreach ($mirror in $Mirrors) {
    $srcDir = Join-Path $RepoRoot  $mirror
    $dstDir = Join-Path $Target    $mirror

    if (Test-Path $srcDir) {
        # TODO T17: replace naive copy with de-dup + merge + version diff
        Copy-Item -Path (Join-Path $srcDir '*') -Destination $dstDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "  copied : $srcDir -> $dstDir"
    } else {
        Write-Host "  skip   : $srcDir (source not present yet)"
    }
}
Write-Host ""

# ---------------------------------------------------------------------------
# TODO T17: run post-smoothing (rewrite absolute paths, patch mcp-config.json,
#            inject user-specific env vars, normalize line endings, chmod on WSL)
# TODO T17: run verification (list installed skills, ping MCP servers, dry-run
#            each skill's smoke test, print health report)
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Print summary
# ---------------------------------------------------------------------------
Write-Host "[3/3] Summary" -ForegroundColor Green
Write-Host "  Mirror dirs prepared under: $Target"
foreach ($mirror in $Mirrors) {
    $mirrorPath = Join-Path $Target $mirror
    Write-Host "    - $mirrorPath"
}
Write-Host ""
Write-Host "NOTE: This is the P1-T3 skeleton. Backup, post-smoothing and" -ForegroundColor Yellow
Write-Host "      verification will be wired up in P4-T17." -ForegroundColor Yellow
Write-Host ""
Write-Host "Done." -ForegroundColor Cyan
