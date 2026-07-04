#!/usr/bin/env bash
# HelmForge deploy script (macOS / Linux / WSL / Git Bash)
# Usage:
#   bash ./deploy/deploy.sh --yes
#   bash ./deploy/deploy.sh --yes --target /path/to/dir
#   bash ./deploy/deploy.sh --yes --dry-run
#
# Implements the skill-deploy spec (.claude/skills/skill-deploy/SKILL.md).

set -euo pipefail
export LC_ALL="${LC_ALL:-C.UTF-8}" 2>/dev/null || true

# ---------------------------------------------------------------------------
# Defaults / arg parsing
# ---------------------------------------------------------------------------
YES=0
TARGET="${HOME}"
NO_BACKUP=0
INSTALL_ENTRY_DOCS=0
FORCE=0
DRY_RUN=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --yes|-y)               YES=1; shift ;;
        --target)               TARGET="$2"; shift 2 ;;
        --target=*)             TARGET="${1#*=}"; shift ;;
        --no-backup)            NO_BACKUP=1; shift ;;
        --install-entry-docs)   INSTALL_ENTRY_DOCS=1; shift ;;
        --force)                FORCE=1; shift ;;
        --dry-run)              DRY_RUN=1; shift ;;
        -h|--help)
            cat <<EOF
Usage: $0 [--yes] [--target <path>] [--no-backup] [--install-entry-docs] [--force] [--dry-run]

  --yes                 non-interactive
  --target <path>       deploy destination (default: \$HOME)
  --no-backup           skip pre-deploy backup
  --install-entry-docs  copy CLAUDE.md/AGENTS.md/GEMINI.md/OPENCLAW.md to target
  --force               overwrite existing entry docs
  --dry-run             print actions without touching files
EOF
            exit 0
            ;;
        *) echo "Unknown arg: $1" >&2; exit 2 ;;
    esac
done

# ---------------------------------------------------------------------------
# Resolve repo root
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

MIRRORS=(".claude" ".codex" ".gemini" ".agents")
ENTRY_DOCS=("CLAUDE.md" "AGENTS.md" "GEMINI.md" "OPENCLAW.md")

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
ISO_STAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
BACKUP_ROOT="${REPO_ROOT}/.deploy-backup/${TIMESTAMP}"

echo "=============================================="
echo " HelmForge Deploy (P4-T17)"
echo "=============================================="
echo ""
echo "Repo root  : ${REPO_ROOT}"
echo "Target dir : ${TARGET}"
echo "Auto-yes   : ${YES}"
echo "NoBackup   : ${NO_BACKUP}"
echo "EntryDocs  : ${INSTALL_ENTRY_DOCS} (force=${FORCE})"
echo "DryRun     : ${DRY_RUN}"
echo ""

# ---------------------------------------------------------------------------
# Validate target
# ---------------------------------------------------------------------------
if [[ ! -d "${TARGET}" ]]; then
    if [[ "${DRY_RUN}" -eq 1 ]]; then
        echo "[dry-run] would create target: ${TARGET}"
    else
        mkdir -p "${TARGET}" || { echo "ERROR: cannot create target ${TARGET}" >&2; exit 1; }
    fi
fi
if [[ "${DRY_RUN}" -ne 1 ]]; then
    probe="${TARGET}/.helmforge-writeprobe-${TIMESTAMP}"
    if ! ( : > "${probe}" ) 2>/dev/null; then
        echo "ERROR: target '${TARGET}' not writable" >&2; exit 1
    fi
    rm -f "${probe}"
fi

# ---------------------------------------------------------------------------
# Confirm
# ---------------------------------------------------------------------------
if [[ "${YES}" -ne 1 ]]; then
    read -r -p "Proceed with deployment? [y/N] " answer
    case "${answer}" in
        [Yy]*) ;;
        *) echo "Aborted by user."; exit 0 ;;
    esac
fi

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
FINDINGS=()
add_finding() { FINDINGS+=("$1"); }

hash_file() {
    # portable md5 (Linux md5sum, macOS md5, Windows Git Bash usually has md5sum)
    if command -v md5sum >/dev/null 2>&1; then
        md5sum "$1" 2>/dev/null | awk '{print $1}'
    elif command -v md5 >/dev/null 2>&1; then
        md5 -q "$1" 2>/dev/null
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$1" 2>/dev/null | awk '{print $1}'
    else
        # fallback: wc-based signature (weakest)
        wc -c < "$1" 2>/dev/null
    fi
}

# ---------------------------------------------------------------------------
# Step 1: Backup
# ---------------------------------------------------------------------------
echo "[1/5] Pre-deploy backup"
BACKUP_DIR_LOG=""
if [[ "${NO_BACKUP}" -eq 1 ]]; then
    echo "  --no-backup set, skipping"
else
    for m in "${MIRRORS[@]}"; do
        src="${TARGET}/${m}"
        if [[ -d "${src}" ]]; then
            dst="${BACKUP_ROOT}/${m}"
            if [[ "${DRY_RUN}" -eq 1 ]]; then
                echo "  [dry-run] would back up ${src} -> ${dst}"
            else
                mkdir -p "${dst}"
                cp -R "${src}/." "${dst}/" 2>/dev/null || true
                echo "  backed up ${m} -> ${dst}"
            fi
        else
            echo "  skip ${m} (target absent)"
        fi
    done
    for d in "${ENTRY_DOCS[@]}"; do
        src="${TARGET}/${d}"
        if [[ -f "${src}" ]]; then
            if [[ "${DRY_RUN}" -eq 1 ]]; then
                echo "  [dry-run] would back up ${d}"
            else
                mkdir -p "${BACKUP_ROOT}"
                cp -f "${src}" "${BACKUP_ROOT}/${d}"
                echo "  backed up ${d}"
            fi
        fi
    done
    if [[ -d "${BACKUP_ROOT}" ]]; then
        BACKUP_DIR_LOG=".deploy-backup/${TIMESTAMP}"
    fi
fi
echo ""

# ---------------------------------------------------------------------------
# Step 2: Copy mirrors
# ---------------------------------------------------------------------------
echo "[2/5] Copy 4 mirrors"
declare -A MIRROR_STATS
MIRRORS_COPIED=()
for m in "${MIRRORS[@]}"; do
    src_dir="${REPO_ROOT}/${m}"
    dst_dir="${TARGET}/${m}"
    if [[ ! -d "${src_dir}" ]]; then
        echo "  ERROR: source mirror missing: ${src_dir}" >&2
        add_finding "[SOURCE-MISSING] ${m} missing in repo"
        continue
    fi
    skill_count=0
    if [[ -d "${src_dir}/skills" ]]; then
        skill_count=$(find "${src_dir}/skills" -maxdepth 1 -mindepth 1 -type d \! -name '.gitkeep' 2>/dev/null | wc -l | tr -d ' ')
    fi
    if [[ "${DRY_RUN}" -eq 1 ]]; then
        echo "  [dry-run] ${m} : ${skill_count} skills would be copied to ${dst_dir}"
    else
        mkdir -p "${dst_dir}"
        cp -R "${src_dir}/." "${dst_dir}/" 2>/dev/null || true
        echo "  ${m} : ${skill_count} skills copied -> ${dst_dir}"
    fi
    MIRRORS_COPIED+=("${m}")
    MIRROR_STATS["${m}"]="${skill_count}"
done
echo ""

# ---------------------------------------------------------------------------
# Step 3: Entry docs
# ---------------------------------------------------------------------------
echo "[3/5] Entry docs"
ENTRY_INSTALLED=()
UNIVERSAL_DEPLOYED=0
if [[ "${INSTALL_ENTRY_DOCS}" -eq 1 ]]; then
    for d in "${ENTRY_DOCS[@]}"; do
        src="${REPO_ROOT}/${d}"
        dst="${TARGET}/${d}"
        [[ -f "${src}" ]] || continue
        if [[ -f "${dst}" && "${FORCE}" -ne 1 ]]; then
            echo "  skip ${d} (already at target, use --force to overwrite)"
            continue
        fi
        if [[ "${DRY_RUN}" -eq 1 ]]; then
            echo "  [dry-run] would install ${d}"
        else
            cp -f "${src}" "${dst}"
            echo "  installed ${d}"
        fi
        ENTRY_INSTALLED+=("${d}")
    done
    uni_src="${REPO_ROOT}/deploy/universal-agent-prompt.md"
    if [[ -f "${uni_src}" ]]; then
        if [[ "${DRY_RUN}" -eq 1 ]]; then
            echo "  [dry-run] would install universal-agent-prompt.md"
        else
            cp -f "${uni_src}" "${TARGET}/universal-agent-prompt.md"
            echo "  installed universal-agent-prompt.md"
        fi
        UNIVERSAL_DEPLOYED=1
    else
        echo "  universal-agent-prompt.md not present in repo (skipped)"
    fi
else
    echo "  --install-entry-docs not set, skipping"
fi
echo ""

# ---------------------------------------------------------------------------
# Step 4: Post-smoothing
# ---------------------------------------------------------------------------
echo "[4/5] Post-smoothing"

# 4a route consistency
route_rel="skills/executive-consultant/SKILL.md"
base_file="${REPO_ROOT}/.claude/${route_rel}"
route_state="PASS"
if [[ -f "${base_file}" ]]; then
    base_hash="$(hash_file "${base_file}")"
    for m in .codex .gemini .agents; do
        other="${REPO_ROOT}/${m}/${route_rel}"
        if [[ ! -f "${other}" ]]; then
            add_finding "[MIRROR-GAP] executive-consultant missing in ${m}"
            route_state="FAIL"
            continue
        fi
        other_hash="$(hash_file "${other}")"
        if [[ "${base_hash}" != "${other_hash}" ]]; then
            add_finding "[ROUTE-MISMATCH] ${m}/skills/executive-consultant/SKILL.md differs from .claude baseline"
            [[ "${route_state}" != "FAIL" ]] && route_state="WARN"
        fi
    done
else
    add_finding "[ROUTE-BASELINE-MISSING] .claude/skills/executive-consultant/SKILL.md not found"
    route_state="FAIL"
fi
echo "  4a route consistency  : ${route_state}"

# 4b AGENTS.md alignment
agents_md="${REPO_ROOT}/AGENTS.md"
codex_skills="${REPO_ROOT}/.codex/skills"
list_state="PASS"
if [[ -f "${agents_md}" && -d "${codex_skills}" ]]; then
    # extract skill names between markers
    declared="$(awk '/<!-- SKILL-LIST-START -->/{flag=1;next}/<!-- SKILL-LIST-END -->/{flag=0}flag' "${agents_md}" \
        | grep -oE '\$[a-zA-Z0-9_-]+' | sed 's/^\$//' | sort -u)"
    actual="$(find "${codex_skills}" -maxdepth 1 -mindepth 1 -type d \! -name '.gitkeep' -exec basename {} \; | sort -u)"
    # declared - actual
    missing="$(comm -23 <(echo "${declared}") <(echo "${actual}") || true)"
    while IFS= read -r s; do
        [[ -n "${s}" ]] && { add_finding "[MISSING-SKILL] ${s} declared in AGENTS.md but not in .codex/skills/"; list_state="WARN"; }
    done <<< "${missing}"
    # actual - declared
    unlisted="$(comm -13 <(echo "${declared}") <(echo "${actual}") || true)"
    while IFS= read -r s; do
        [[ -n "${s}" ]] && { add_finding "[UNLISTED-SKILL] ${s} in .codex/skills/ but not in AGENTS.md"; list_state="WARN"; }
    done <<< "${unlisted}"
else
    list_state="FAIL"
    [[ ! -f "${agents_md}" ]] && add_finding "[AGENTS-MD-MISSING] AGENTS.md not found"
    [[ ! -d "${codex_skills}" ]] && add_finding "[CODEX-SKILLS-MISSING] .codex/skills/ not found"
fi
echo "  4b AGENTS.md align    : ${list_state}"

# 4c mirror gap
gap_state="PASS"
if [[ -d "${codex_skills}" ]]; then
    actual="$(find "${codex_skills}" -maxdepth 1 -mindepth 1 -type d \! -name '.gitkeep' -exec basename {} \;)"
    while IFS= read -r s; do
        [[ -z "${s}" ]] && continue
        for m in "${MIRRORS[@]}"; do
            mp="${REPO_ROOT}/${m}/skills/${s}"
            if [[ ! -d "${mp}" ]]; then
                add_finding "[MIRROR-GAP] ${s} missing in ${m}"
                gap_state="WARN"
            fi
        done
    done <<< "${actual}"
else
    gap_state="FAIL"
fi
echo "  4c mirror gap         : ${gap_state}"

# 4d universal alignment
uni_file="${REPO_ROOT}/deploy/universal-agent-prompt.md"
if [[ -f "${uni_file}" ]]; then
    refs="$(grep -oE '\$[a-zA-Z0-9_-]+' "${uni_file}" | sed 's/^\$//' | sort -u)"
    actual="$(find "${codex_skills}" -maxdepth 1 -mindepth 1 -type d \! -name '.gitkeep' -exec basename {} \; 2>/dev/null | sort -u)"
    uni_state="PASS"
    dangling="$(comm -23 <(echo "${refs}") <(echo "${actual}") || true)"
    while IFS= read -r s; do
        [[ -n "${s}" ]] && { add_finding "[UNIVERSAL-DANGLING] universal one-shot references ${s} but not in repo"; uni_state="WARN"; }
    done <<< "${dangling}"
    unimissing="$(comm -13 <(echo "${refs}") <(echo "${actual}") || true)"
    while IFS= read -r s; do
        [[ -n "${s}" ]] && { add_finding "[UNIVERSAL-MISSING] ${s} exists in repo but not in universal one-shot"; uni_state="WARN"; }
    done <<< "${unimissing}"
    echo "  4d universal one-shot : ${uni_state}"
else
    uni_state="INFO-SKIP"
    add_finding "[INFO] deploy/universal-agent-prompt.md not present, 4d skipped"
    echo "  4d universal one-shot : INFO-SKIP (file not present)"
fi
echo ""

# ---------------------------------------------------------------------------
# Step 5: Summary
# ---------------------------------------------------------------------------
echo "[5/5] Summary"

# choose output dir
OUT_DIR="${BACKUP_ROOT}"
if [[ ! -d "${OUT_DIR}" ]]; then
    OUT_DIR="${TARGET}/.deploy-backup/${TIMESTAMP}"
    if [[ "${DRY_RUN}" -ne 1 ]]; then
        mkdir -p "${OUT_DIR}"
    fi
fi

# overall
overall="PASS"
for st in "${route_state}" "${list_state}" "${gap_state}" "${uni_state}"; do
    case "${st}" in
        FAIL) overall="FAIL" ;;
        WARN) [[ "${overall}" != "FAIL" ]] && overall="WARN" ;;
    esac
done

report_path="${OUT_DIR}/deploy-report.md"
manifest_path="${OUT_DIR}/deploy-manifest.json"

# build report
build_report() {
    echo "# HelmForge Deploy Report"
    echo ""
    echo "- Timestamp    : ${ISO_STAMP}"
    echo "- Target       : ${TARGET}"
    echo "- Repo root    : ${REPO_ROOT}"
    echo "- Dry run      : ${DRY_RUN}"
    echo "- Overall      : ${overall}"
    echo ""
    echo "## Backup"
    echo "  backup dir  : ${BACKUP_DIR_LOG:-(no backup)}"
    echo ""
    echo "## Deploy"
    for m in "${MIRRORS[@]}"; do
        printf "  %-10s : %s skills copied\n" "${m}" "${MIRROR_STATS[${m}]:-0}"
    done
    if [[ ${UNIVERSAL_DEPLOYED} -eq 1 ]]; then echo "  universal   : yes"; else echo "  universal   : no"; fi
    if [[ ${#ENTRY_INSTALLED[@]} -gt 0 ]]; then
        echo "  entry docs  : ${ENTRY_INSTALLED[*]}"
    else
        echo "  entry docs  : (not installed)"
    fi
    echo ""
    echo "## Post-Smoothing"
    echo "  4a route consistency : ${route_state}"
    echo "  4b AGENTS.md align   : ${list_state}"
    echo "  4c mirror gap        : ${gap_state}"
    echo "  4d universal one-shot: ${uni_state}"
    echo ""
    echo "## Findings"
    if [[ ${#FINDINGS[@]} -eq 0 ]]; then
        echo "  (none)"
    else
        for f in "${FINDINGS[@]}"; do echo "  - ${f}"; done
    fi
    echo ""
    echo "## Next Steps"
    echo "  - Try /executive-consultant in Claude Code"
    echo "  - Try \$executive-consultant in Codex CLI"
    echo "  - Backup lives at: ${BACKUP_DIR_LOG:-(no backup)}"
}

# build manifest json
build_manifest() {
    # findings json array
    local findings_json="["
    local i
    for i in "${!FINDINGS[@]}"; do
        local esc="${FINDINGS[$i]//\\/\\\\}"
        esc="${esc//\"/\\\"}"
        [[ $i -gt 0 ]] && findings_json+=","
        findings_json+="\"${esc}\""
    done
    findings_json+="]"

    local mirrors_json="["
    for i in "${!MIRRORS_COPIED[@]}"; do
        [[ $i -gt 0 ]] && mirrors_json+=","
        mirrors_json+="\"${MIRRORS_COPIED[$i]}\""
    done
    mirrors_json+="]"

    local mstats_json="{"
    local first=1
    for m in "${MIRRORS[@]}"; do
        if [[ -n "${MIRROR_STATS[${m}]:-}" ]]; then
            [[ ${first} -eq 0 ]] && mstats_json+=","
            mstats_json+="\"${m}\":${MIRROR_STATS[${m}]}"
            first=0
        fi
    done
    mstats_json+="}"

    local entry_json="["
    for i in "${!ENTRY_INSTALLED[@]}"; do
        [[ $i -gt 0 ]] && entry_json+=","
        entry_json+="\"${ENTRY_INSTALLED[$i]}\""
    done
    entry_json+="]"

    local uni_bool="false"
    [[ ${UNIVERSAL_DEPLOYED} -eq 1 ]] && uni_bool="true"
    local dry_bool="false"
    [[ ${DRY_RUN} -eq 1 ]] && dry_bool="true"

    local backup_val="null"
    [[ -n "${BACKUP_DIR_LOG}" ]] && backup_val="\"${BACKUP_DIR_LOG}\""

    cat <<EOF
{
  "timestamp": "${ISO_STAMP}",
  "target": "${TARGET}",
  "repo_root": "${REPO_ROOT}",
  "dry_run": ${dry_bool},
  "backup_dir": ${backup_val},
  "mirrors_copied": ${mirrors_json},
  "mirror_stats": ${mstats_json},
  "entry_docs_installed": ${entry_json},
  "universal_agent_deployed": ${uni_bool},
  "post_smoothing": {
    "route_consistency": "${route_state}",
    "agents_md_alignment": "${list_state}",
    "mirror_gap": "${gap_state}",
    "universal_alignment": "${uni_state}"
  },
  "findings": ${findings_json}
}
EOF
}

if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "  [dry-run] would write ${report_path}"
    echo "  [dry-run] would write ${manifest_path}"
else
    mkdir -p "${OUT_DIR}"
    build_report > "${report_path}"
    build_manifest > "${manifest_path}"
    echo "  report   : ${report_path}"
    echo "  manifest : ${manifest_path}"
fi

echo ""
echo "Overall: ${overall}"
echo "Done."

if [[ "${overall}" == "FAIL" ]]; then exit 1; else exit 0; fi
