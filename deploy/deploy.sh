#!/usr/bin/env bash
# HelmForge deploy script (macOS / Linux)
# Usage: bash ./deploy/deploy.sh --yes [--target /path/to/dir]
# Full one-click logic added in P4-T17. This skeleton creates mirror dirs + copies skills.

set -euo pipefail

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------
YES=0
TARGET="${HOME}"

# ---------------------------------------------------------------------------
# Arg parsing
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        --yes|-y)
            YES=1
            shift
            ;;
        --target)
            TARGET="$2"
            shift 2
            ;;
        --target=*)
            TARGET="${1#*=}"
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--yes] [--target <path>]"
            exit 0
            ;;
        *)
            echo "Unknown arg: $1" >&2
            exit 2
            ;;
    esac
done

# ---------------------------------------------------------------------------
# Resolve repo root (parent of the script's directory)
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=============================================="
echo " HelmForge Deploy Skeleton (P1-T3)"
echo " Full one-click logic ships in P4-T17"
echo "=============================================="
echo ""
echo "Repo root  : ${REPO_ROOT}"
echo "Target dir : ${TARGET}"
echo "Auto-yes   : ${YES}"
echo ""

# ---------------------------------------------------------------------------
# Confirm (unless --yes)
# ---------------------------------------------------------------------------
if [[ "${YES}" -ne 1 ]]; then
    read -r -p "Proceed with deployment? [y/N] " answer
    case "${answer}" in
        [Yy]*) ;;
        *)
            echo "Aborted by user."
            exit 0
            ;;
    esac
fi

# ---------------------------------------------------------------------------
# TODO T17: add backup of existing mirror dirs before overwriting
# TODO T17: add pre-flight verification (disk space, existing configs)
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Create five mirror directories under the target
# ---------------------------------------------------------------------------
MIRRORS=(".claude" ".codex" ".gemini" ".agents")

echo "[1/3] Creating mirror directories..."
for mirror in "${MIRRORS[@]}"; do
    mirror_path="${TARGET}/${mirror}"
    if [[ ! -d "${mirror_path}" ]]; then
        mkdir -p "${mirror_path}"
        echo "  created: ${mirror_path}"
    else
        echo "  exists : ${mirror_path}"
    fi
done
echo ""

# ---------------------------------------------------------------------------
# Copy skills from each mirror source in the repo to the target
# Assumes repo layout: <REPO_ROOT>/<mirror>/skills/ -> <TARGET>/<mirror>/skills/
# ---------------------------------------------------------------------------
echo "[2/3] Copying skills into mirror directories..."
for mirror in "${MIRRORS[@]}"; do
    src_dir="${REPO_ROOT}/${mirror}"
    dst_dir="${TARGET}/${mirror}"

    if [[ -d "${src_dir}" ]]; then
        # TODO T17: replace naive copy with de-dup + merge + version diff
        cp -R "${src_dir}/." "${dst_dir}/" 2>/dev/null || true
        echo "  copied : ${src_dir} -> ${dst_dir}"
    else
        echo "  skip   : ${src_dir} (source not present yet)"
    fi
done
echo ""

# ---------------------------------------------------------------------------
# TODO T17: run post-smoothing (rewrite absolute paths, patch mcp-config.json,
#            inject user-specific env vars, normalize line endings, chmod +x)
# TODO T17: run verification (list installed skills, ping MCP servers, dry-run
#            each skill's smoke test, print health report)
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Print summary
# ---------------------------------------------------------------------------
echo "[3/3] Summary"
echo "  Mirror dirs prepared under: ${TARGET}"
for mirror in "${MIRRORS[@]}"; do
    echo "    - ${TARGET}/${mirror}"
done
echo ""
echo "NOTE: This is the P1-T3 skeleton. Backup, post-smoothing and"
echo "      verification will be wired up in P4-T17."
echo ""
echo "Done."
