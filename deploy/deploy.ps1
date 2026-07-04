# HelmForge deploy script (Windows PowerShell)
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\deploy\deploy.ps1 -Yes
#   powershell -ExecutionPolicy Bypass -File .\deploy\deploy.ps1 -Yes -Target D:\sandbox
#   powershell -ExecutionPolicy Bypass -File .\deploy\deploy.ps1 -Yes -DryRun
#   powershell -ExecutionPolicy Bypass -File .\deploy\deploy.ps1 -Yes -Only claude
#   powershell -ExecutionPolicy Bypass -File .\deploy\deploy.ps1 -Yes -Only agents
#   powershell -ExecutionPolicy Bypass -File .\deploy\deploy.ps1 -Yes -Only claude,codex
#
# See docs/deployment-guide.md for choosing the right mirror(s) for your agent host.
# Implements the skill-deploy spec (.claude/skills/skill-deploy/SKILL.md):
#   1. Pre-deploy backup of existing mirror dirs
#   2. Copy selected mirror skills into $Target
#   3. Optional entry-doc install (only for selected mirrors)
#   4. Post-smoothing (4a route consistency, 4b AGENTS.md alignment,
#                       4c mirror gap, 4d universal-agent reference)
#   5. Summary: deploy-manifest.json + deploy-report.md + colored stdout

param(
    [switch]$Yes,
    [string]$Target = "$env:USERPROFILE",
    [switch]$NoBackup,
    [switch]$InstallEntryDocs,
    [switch]$Force,
    [switch]$DryRun,
    [string[]]$Only = @()
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
$ScriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot   = Split-Path -Parent $ScriptDir
$AllMirrors   = @('.claude', '.codex', '.gemini', '.agents')
$AllEntryDocs = @('CLAUDE.md', 'AGENTS.md', 'GEMINI.md', 'OPENCLAW.md')

# --- Apply -Only filter (with aliases) ---
$mirrorMap = @{
    'claude'      = @{ dir='.claude';  doc='CLAUDE.md'   }
    'codex'       = @{ dir='.codex';   doc='AGENTS.md'   }
    'gemini'      = @{ dir='.gemini';  doc='GEMINI.md'   }
    'agents'      = @{ dir='.agents';  doc='OPENCLAW.md' }
    # aliases
    'workbuddy'   = @{ dir='.agents';  doc='OPENCLAW.md' }
    'openclaw'    = @{ dir='.agents';  doc='OPENCLAW.md' }
    'lobster'     = @{ dir='.agents';  doc='OPENCLAW.md' }
    'antigravity' = @{ dir='.gemini';  doc='GEMINI.md'   }
}

# accept comma-separated single string as well: -Only "claude,codex"
if ($Only.Count -eq 1 -and $Only[0] -match ',') {
    $Only = $Only[0].Split(',')
}

if ($Only.Count -gt 0) {
    $Mirrors   = @()
    $EntryDocs = @()
    foreach ($tokRaw in $Only) {
        $tok = $tokRaw.Trim().TrimStart('.').ToLower()
        if (-not $mirrorMap.ContainsKey($tok)) {
            Write-Host "ERROR: unknown -Only token: $tokRaw" -ForegroundColor Red
            Write-Host "Valid tokens: claude, codex, gemini, agents (aliases: workbuddy/openclaw -> agents, antigravity -> gemini)" -ForegroundColor Red
            exit 2
        }
        $entry = $mirrorMap[$tok]
        if ($Mirrors -notcontains $entry.dir) {
            $Mirrors   += $entry.dir
            $EntryDocs += $entry.doc
        }
    }
    if ($Mirrors.Count -eq 0) {
        Write-Host "ERROR: -Only produced empty mirror list" -ForegroundColor Red
        exit 2
    }
} else {
    $Mirrors   = $AllMirrors
    $EntryDocs = $AllEntryDocs
}

$Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$IsoStamp  = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host " HelmForge Deploy (P4-T17)" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Repo root  : $RepoRoot"
Write-Host "Target dir : $Target"
Write-Host "Mirrors    : $($Mirrors -join ' ')"
Write-Host "Auto-yes   : $Yes"
Write-Host "NoBackup   : $NoBackup"
Write-Host "EntryDocs  : $InstallEntryDocs (force=$Force)"
Write-Host "DryRun     : $DryRun"
Write-Host ""

# ---------------------------------------------------------------------------
# Validate target dir (create if missing)
# ---------------------------------------------------------------------------
if (-not (Test-Path $Target)) {
    if ($DryRun) {
        Write-Host "[dry-run] would create target: $Target"
    } else {
        try {
            New-Item -ItemType Directory -Force -Path $Target | Out-Null
        } catch {
            Write-Host "ERROR: cannot create target dir '$Target': $_" -ForegroundColor Red
            exit 1
        }
    }
}

# quick writability probe
if (-not $DryRun) {
    $probe = Join-Path $Target ".helmforge-writeprobe-$Timestamp"
    try {
        New-Item -ItemType File -Path $probe -Force | Out-Null
        Remove-Item -Path $probe -Force
    } catch {
        Write-Host "ERROR: target '$Target' not writable: $_" -ForegroundColor Red
        exit 1
    }
}

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

# Manifest state
$Manifest = [ordered]@{
    timestamp                = $IsoStamp
    target                   = $Target
    repo_root                = $RepoRoot
    dry_run                  = [bool]$DryRun
    backup_dir               = $null
    mirrors_copied           = @()
    mirror_stats             = @{}
    entry_docs_installed     = @()
    universal_agent_deployed = $false
    post_smoothing           = [ordered]@{
        route_consistency    = 'SKIPPED'
        agents_md_alignment  = 'SKIPPED'
        mirror_gap           = 'SKIPPED'
        universal_alignment  = 'SKIPPED'
    }
    findings                 = @()
}

# ---------------------------------------------------------------------------
# Step 1: Pre-deploy backup
# ---------------------------------------------------------------------------
$BackupRoot = Join-Path $RepoRoot ".deploy-backup\$Timestamp"

Write-Host "[1/5] Pre-deploy backup" -ForegroundColor Green
if ($NoBackup) {
    Write-Host "  --no-backup set, skipping"
} else {
    foreach ($mirror in $Mirrors) {
        $src = Join-Path $Target $mirror
        if (Test-Path $src) {
            $dst = Join-Path $BackupRoot $mirror
            if ($DryRun) {
                Write-Host "  [dry-run] would back up $src -> $dst"
            } else {
                New-Item -ItemType Directory -Force -Path $dst | Out-Null
                Copy-Item -Path (Join-Path $src '*') -Destination $dst -Recurse -Force -ErrorAction SilentlyContinue
                Write-Host "  backed up $mirror -> $dst"
            }
        } else {
            Write-Host "  skip $mirror (target absent)"
        }
    }
    foreach ($doc in $EntryDocs) {
        $src = Join-Path $Target $doc
        if (Test-Path $src) {
            if ($DryRun) {
                Write-Host "  [dry-run] would back up $doc"
            } else {
                New-Item -ItemType Directory -Force -Path $BackupRoot | Out-Null
                Copy-Item -Path $src -Destination (Join-Path $BackupRoot $doc) -Force
                Write-Host "  backed up $doc"
            }
        }
    }
    if (Test-Path $BackupRoot) {
        $Manifest.backup_dir = ".deploy-backup/$Timestamp"
    }
}
Write-Host ""

# ---------------------------------------------------------------------------
# Step 2: Copy 4 mirror skills (+commands for .claude, +scripts if present)
# ---------------------------------------------------------------------------
Write-Host "[2/5] Copy $($Mirrors.Count) mirror(s): $($Mirrors -join ' ')" -ForegroundColor Green
foreach ($mirror in $Mirrors) {
    $srcDir = Join-Path $RepoRoot $mirror
    $dstDir = Join-Path $Target   $mirror

    if (-not (Test-Path $srcDir)) {
        Write-Host "  ERROR: source mirror missing: $srcDir" -ForegroundColor Red
        $Manifest.findings += "[SOURCE-MISSING] $mirror missing in repo"
        continue
    }

    # count skills for stats
    $skillsSrc = Join-Path $srcDir 'skills'
    $skillCount = 0
    if (Test-Path $skillsSrc) {
        $skillCount = (Get-ChildItem -Path $skillsSrc -Directory -ErrorAction SilentlyContinue |
                       Where-Object { $_.Name -ne '.gitkeep' }).Count
    }

    if ($DryRun) {
        Write-Host "  [dry-run] $mirror : $skillCount skills would be copied to $dstDir"
    } else {
        New-Item -ItemType Directory -Force -Path $dstDir | Out-Null
        # copy all subdirs (skills, commands for .claude, scripts if present)
        Copy-Item -Path (Join-Path $srcDir '*') -Destination $dstDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "  $mirror : $skillCount skills copied -> $dstDir"
    }
    $Manifest.mirrors_copied  += $mirror
    $Manifest.mirror_stats[$mirror] = $skillCount
}
Write-Host ""

# ---------------------------------------------------------------------------
# Step 3: Entry docs (opt-in)
# ---------------------------------------------------------------------------
Write-Host "[3/5] Entry docs" -ForegroundColor Green
if ($InstallEntryDocs) {
    foreach ($doc in $EntryDocs) {
        $src = Join-Path $RepoRoot $doc
        $dst = Join-Path $Target   $doc
        if (-not (Test-Path $src)) { continue }
        if ((Test-Path $dst) -and (-not $Force)) {
            Write-Host "  skip $doc (already at target, use -Force to overwrite)"
            continue
        }
        if ($DryRun) {
            Write-Host "  [dry-run] would install $doc -> $dst"
        } else {
            Copy-Item -Path $src -Destination $dst -Force
            Write-Host "  installed $doc"
        }
        $Manifest.entry_docs_installed += $doc
    }
    # universal-agent one-shot
    $uniSrc = Join-Path $RepoRoot 'deploy\universal-agent-prompt.md'
    if (Test-Path $uniSrc) {
        $uniDst = Join-Path $Target 'universal-agent-prompt.md'
        if ($DryRun) {
            Write-Host "  [dry-run] would install universal-agent-prompt.md"
        } else {
            Copy-Item -Path $uniSrc -Destination $uniDst -Force
            Write-Host "  installed universal-agent-prompt.md"
        }
        $Manifest.universal_agent_deployed = $true
    } else {
        Write-Host "  universal-agent-prompt.md not present in repo (skipped)"
    }
} else {
    Write-Host "  --install-entry-docs not set, skipping (add -InstallEntryDocs to enable)"
}
Write-Host ""

# ---------------------------------------------------------------------------
# Step 4: Post-smoothing
# ---------------------------------------------------------------------------
Write-Host "[4/5] Post-smoothing" -ForegroundColor Green

# 4a - route consistency across 4 mirrors
$routePath = 'skills\executive-consultant\SKILL.md'
$baseFile  = Join-Path $RepoRoot (Join-Path '.claude' $routePath)
$routeState = 'PASS'
if (Test-Path $baseFile) {
    $baseHash = (Get-FileHash -Path $baseFile -Algorithm SHA256).Hash
    foreach ($m in @('.codex', '.gemini', '.agents')) {
        $other = Join-Path $RepoRoot (Join-Path $m $routePath)
        if (-not (Test-Path $other)) {
            $Manifest.findings += "[MIRROR-GAP] executive-consultant missing in $m"
            $routeState = 'FAIL'
            continue
        }
        $otherHash = (Get-FileHash -Path $other -Algorithm SHA256).Hash
        if ($baseHash -ne $otherHash) {
            $Manifest.findings += "[ROUTE-MISMATCH] $m/skills/executive-consultant/SKILL.md differs from .claude baseline"
            $routeState = 'WARN'
        }
    }
} else {
    $Manifest.findings += "[ROUTE-BASELINE-MISSING] .claude/skills/executive-consultant/SKILL.md not found in repo"
    $routeState = 'FAIL'
}
$Manifest.post_smoothing.route_consistency = $routeState
Write-Host "  4a route consistency  : $routeState"

# 4b - AGENTS.md SKILL-LIST vs .codex/skills/
$agentsMdPath = Join-Path $RepoRoot 'AGENTS.md'
$codexSkillsPath = Join-Path $RepoRoot '.codex\skills'
$listState = 'PASS'
if ((Test-Path $agentsMdPath) -and (Test-Path $codexSkillsPath)) {
    $agentsMd = Get-Content -Path $agentsMdPath -Raw -Encoding UTF8
    $declared = @()
    if ($agentsMd -match '(?s)<!--\s*SKILL-LIST-START\s*-->(.*?)<!--\s*SKILL-LIST-END\s*-->') {
        $block = $matches[1]
        $matchInfos = [regex]::Matches($block, '\$([a-zA-Z0-9_\-]+)')
        foreach ($mi in $matchInfos) { $declared += $mi.Groups[1].Value }
    }
    $declaredSet = $declared | Sort-Object -Unique
    $actualSet = (Get-ChildItem -Path $codexSkillsPath -Directory -ErrorAction SilentlyContinue |
                  Where-Object { $_.Name -ne '.gitkeep' } | Select-Object -ExpandProperty Name) | Sort-Object -Unique
    foreach ($s in $declaredSet) {
        if ($actualSet -notcontains $s) {
            $Manifest.findings += "[MISSING-SKILL] $s declared in AGENTS.md but not in .codex/skills/"
            $listState = 'WARN'
        }
    }
    foreach ($s in $actualSet) {
        if ($declaredSet -notcontains $s) {
            $Manifest.findings += "[UNLISTED-SKILL] $s in .codex/skills/ but not declared in AGENTS.md"
            $listState = 'WARN'
        }
    }
} else {
    $listState = 'FAIL'
    if (-not (Test-Path $agentsMdPath)) { $Manifest.findings += "[AGENTS-MD-MISSING] AGENTS.md not found" }
    if (-not (Test-Path $codexSkillsPath)) { $Manifest.findings += "[CODEX-SKILLS-MISSING] .codex/skills/ not found" }
}
$Manifest.post_smoothing.agents_md_alignment = $listState
Write-Host "  4b AGENTS.md align    : $listState"

# 4c - each skill exists in all 4 mirrors
$gapState = 'PASS'
if (Test-Path $codexSkillsPath) {
    $actualSet = Get-ChildItem -Path $codexSkillsPath -Directory -ErrorAction SilentlyContinue |
                 Where-Object { $_.Name -ne '.gitkeep' } | Select-Object -ExpandProperty Name
    foreach ($s in $actualSet) {
        foreach ($m in $Mirrors) {
            $mDir = Join-Path $RepoRoot (Join-Path $m "skills\$s")
            if (-not (Test-Path $mDir)) {
                $Manifest.findings += "[MIRROR-GAP] $s missing in $m"
                $gapState = 'WARN'
            }
        }
    }
} else {
    $gapState = 'FAIL'
}
$Manifest.post_smoothing.mirror_gap = $gapState
Write-Host "  4c mirror gap         : $gapState"

# 4d - universal-agent references
$uniFile = Join-Path $RepoRoot 'deploy\universal-agent-prompt.md'
if (Test-Path $uniFile) {
    $uniText = Get-Content -Path $uniFile -Raw -Encoding UTF8
    $refs = @()
    foreach ($mi in [regex]::Matches($uniText, '\$([a-zA-Z0-9_\-]+)')) {
        $refs += $mi.Groups[1].Value
    }
    $refs = $refs | Sort-Object -Unique
    $actualSet = @()
    if (Test-Path $codexSkillsPath) {
        $actualSet = Get-ChildItem -Path $codexSkillsPath -Directory | Where-Object { $_.Name -ne '.gitkeep' } | Select-Object -ExpandProperty Name
    }
    $uniState = 'PASS'
    foreach ($s in $refs) {
        if ($actualSet -notcontains $s) {
            $Manifest.findings += "[UNIVERSAL-DANGLING] universal one-shot references $s but not in repo"
            $uniState = 'WARN'
        }
    }
    foreach ($s in $actualSet) {
        if ($refs -notcontains $s) {
            $Manifest.findings += "[UNIVERSAL-MISSING] $s exists in repo but not in universal one-shot"
            $uniState = 'WARN'
        }
    }
    $Manifest.post_smoothing.universal_alignment = $uniState
    Write-Host "  4d universal one-shot : $uniState"
} else {
    $Manifest.post_smoothing.universal_alignment = 'INFO-SKIP'
    $Manifest.findings += "[INFO] deploy/universal-agent-prompt.md not present, 4d skipped"
    Write-Host "  4d universal one-shot : INFO-SKIP (file not present)"
}
Write-Host ""

# ---------------------------------------------------------------------------
# Step 5: Summary report + manifest
# ---------------------------------------------------------------------------
Write-Host "[5/5] Summary" -ForegroundColor Green

# Choose output dir: prefer backup dir (if it exists), else create manifest dir under $Target
$outDir = $BackupRoot
if (-not (Test-Path $outDir)) {
    $outDir = Join-Path $Target ".deploy-backup\$Timestamp"
    if (-not $DryRun) {
        New-Item -ItemType Directory -Force -Path $outDir | Out-Null
    }
}

# Build human report
$mirrorLines = @()
foreach ($m in $Mirrors) {
    $n = 0
    if ($Manifest.mirror_stats.ContainsKey($m)) { $n = $Manifest.mirror_stats[$m] }
    $mirrorLines += ("  {0,-10} : {1} skills copied" -f $m, $n)
}

$backupNote = if ($Manifest.backup_dir) { $Manifest.backup_dir } else { '(no backup)' }
$uniNote = if ($Manifest.universal_agent_deployed) { 'yes' } else { 'no' }

$overallState = 'PASS'
foreach ($k in @('route_consistency','agents_md_alignment','mirror_gap','universal_alignment')) {
    $v = $Manifest.post_smoothing[$k]
    if ($v -eq 'FAIL') { $overallState = 'FAIL' }
    elseif ($v -eq 'WARN' -and $overallState -ne 'FAIL') { $overallState = 'WARN' }
}

$reportLines = @(
    "# HelmForge Deploy Report"
    ""
    "- Timestamp    : $IsoStamp"
    "- Target       : $Target"
    "- Repo root    : $RepoRoot"
    "- Dry run      : $DryRun"
    "- Overall      : $overallState"
    ""
    "## Backup"
    "  backup dir  : $backupNote"
    ""
    "## Deploy"
) + $mirrorLines + @(
    "  universal   : $uniNote"
    "  entry docs  : " + ($(if ($Manifest.entry_docs_installed.Count) { $Manifest.entry_docs_installed -join ', ' } else { '(not installed)' }))
    ""
    "## Post-Smoothing"
    ("  4a route consistency : {0}" -f $Manifest.post_smoothing.route_consistency)
    ("  4b AGENTS.md align   : {0}" -f $Manifest.post_smoothing.agents_md_alignment)
    ("  4c mirror gap        : {0}" -f $Manifest.post_smoothing.mirror_gap)
    ("  4d universal one-shot: {0}" -f $Manifest.post_smoothing.universal_alignment)
    ""
    "## Findings"
)
if ($Manifest.findings.Count -eq 0) {
    $reportLines += "  (none)"
} else {
    foreach ($f in $Manifest.findings) { $reportLines += "  - $f" }
}
$reportLines += @(
    ""
    "## Next Steps"
    "  - Try /executive-consultant in Claude Code"
    "  - Try \$executive-consultant in Codex CLI"
    "  - Backup lives at: $backupNote"
)
$reportText = ($reportLines -join "`r`n")

$reportPath   = Join-Path $outDir 'deploy-report.md'
$manifestPath = Join-Path $outDir 'deploy-manifest.json'

if ($DryRun) {
    Write-Host "  [dry-run] would write $reportPath"
    Write-Host "  [dry-run] would write $manifestPath"
} else {
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null
    [System.IO.File]::WriteAllText($reportPath, $reportText, (New-Object System.Text.UTF8Encoding($false)))
    $manifestJson = $Manifest | ConvertTo-Json -Depth 6
    [System.IO.File]::WriteAllText($manifestPath, $manifestJson, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host "  report   : $reportPath"
    Write-Host "  manifest : $manifestPath"
}

Write-Host ""
$overallColor = 'Green'
if ($overallState -eq 'WARN') { $overallColor = 'Yellow' }
if ($overallState -eq 'FAIL') { $overallColor = 'Red' }
Write-Host "Overall: $overallState" -ForegroundColor $overallColor
Write-Host "Done." -ForegroundColor Cyan

if ($overallState -eq 'FAIL') { exit 1 } else { exit 0 }
