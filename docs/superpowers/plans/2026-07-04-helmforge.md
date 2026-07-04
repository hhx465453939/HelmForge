# HelmForge Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build HelmForge — an 18-skill enterprise management cockpit (Forge trilogy #3), deployed across 5 agent mirrors, with PolyForm-NC license and enterprise ETHICS.

**Architecture:** Skill-pack project (prompts + references + scripts), not traditional code. `executive-consultant` is the orchestrator with an extended routing table. Five mirror directories (`.claude` / `.codex` / `.gemini` / `.agents` / universal-agent prompt) stay in sync via `skill-deploy` post-smoothing. 13 skills reused, 3 newly designed (finance/budget/strategy-cfo), 2 governance borrowed from Forge series.

**Tech Stack:** Markdown (SKILL.md / commands.md), PowerShell + Bash deploy scripts, Python (office-docs toolchain), PptxGenJS, frontmatter YAML, MCP integrations (高德地图 / finance / deep-research).

## Global Constraints

- **License:** PolyForm Noncommercial 1.0.0 — verbatim license text in `LICENSE`, no Change Date, no open-source conversion.
- **ETHICS:** 8 enterprise red lines (anti-bribery / anti-fraud / anti-monopoly / anti-money-laundering / data-privacy / compliance-boundary / human-in-loop / ESG).
- **Five mirrors must stay in sync:** `.claude/skills/` `.codex/skills/` `.gemini/skills/` `.agents/skills/` — same SKILL.md content, platform-specific entry docs.
- **Naming:** English kebab-case for all skill/command/dir names. Chinese allowed in skill content (user-facing) but not in paths.
- **Orchestrator:** `executive-consultant` is the single main dispatcher; routing table extended with 4 new branches (finance-manager / budget-architect / strategy-cfo / geo-sentinel).
- **Skill format:** Each skill = directory with `SKILL.md` (YAML frontmatter: name/description/version) + optional `references/` + optional `scripts/`.
- **Source pool location:** Reuse skills come from `E:\Development\Claude_skill_pool\skills.claude\<skill>\.claude\` and `E:\Development\Claude_skill_pool\package\enterprise-use\.claude\`.
- **No git commit/push without owner authorization** (per CLAUDE.md). Commits in this plan are gated behind explicit owner approval checkpoints.
- **Encoding:** All deploy scripts and generated files UTF-8. Windows PowerShell deploy uses `chcp 65001` to avoid GBK issues.

---

## File Structure

```
HelmForge/
├── LICENSE                              # PolyForm Noncommercial 1.0.0 (P1-T1)
├── ETHICS.md                            # 8 enterprise red lines (P1-T1)
├── README.md                            # Forge-style marketing (P1-T1 skeleton, P5-T19 polish)
├── CONTRIBUTING.md                      # incl. Agent self-evolution PR flow (P5-T18)
├── .gitignore                           # (P1-T1)
├── CLAUDE.md                            # Claude Code entry (P1-T2)
├── AGENTS.md                            # Codex entry (P1-T2)
├── GEMINI.md                            # Antigravity/Gemini entry (P1-T2)
├── OPENCLAW.md                          # OpenClaw/WorkBuddy/龙虾 entry (P1-T2)
├── deploy/
│   ├── deploy.ps1                       # Windows one-click (P1-T3 skeleton, P4-T17 complete)
│   ├── deploy.sh                        # macOS/Linux one-click (P1-T3 skeleton, P4-T17 complete)
│   └── mcp-config.template.json         # (P1-T3)
├── docs/
│   ├── cn-api-providers.md              # 国产 API config (P1-T4)
│   └── superpowers/{specs,plans}/       # this doc + spec (exists)
├── assets/                              # logo/banner placeholders (P5-T19)
├── .claude/
│   ├── commands/                        # 18 slash commands (P2-T7/T8, P3-T11-T13)
│   ├── skills/                          # 18 skill dirs (P2-T7/T8, P3-T11-T13, P4-T15-T16)
│   └── scripts/                         # office-docs toolchain (P2-T7, copied)
├── .codex/skills/                       # 5-mirror sync (P2-T9)
├── .gemini/skills/                      # 5-mirror sync (P2-T9)
└── .agents/skills/                      # 5-mirror sync (P2-T9)
```

---

# Phase 1 — Skeleton & Brand (Tasks 1-6)

### Task 1: Core legal & brand docs

**Files:**
- Create: `LICENSE`
- Create: `ETHICS.md`
- Create: `.gitignore`
- Create: `README.md` (skeleton, full polish in T19)

**Produces:** Project legally identifiable + brand narrative scaffold.

- [ ] **Step 1: Write LICENSE (PolyForm Noncommercial 1.0.0)**

Create `LICENSE` with the verbatim PolyForm Noncommercial License 1.0.0 text. Source: https://polyformproject.org/licenses/noncommercial/1.0.0/ . Top of file:
```
HelmForge is licensed under the PolyForm Noncommercial License, Version 1.0.0
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at:

    https://polyformproject.org/licenses/noncommercial/1.0.0

Software distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Copyright (c) 2026 HelmForge contributors. All rights reserved.
```
Followed by the full license body from the PolyForm site.

- [ ] **Step 2: Write ETHICS.md (8 enterprise red lines)**

Create `ETHICS.md`. Content sections:
1. Purpose & scope (applies to all uses of HelmForge)
2. The 8 red lines (table from spec §8.2):
   - 🚫 Anti-commercial-bribery (no designing/executing bribery, kickbacks, rent-seeking, gray gov-business ops)
   - 🚫 Anti-financial-fraud (no accounting fraud, false statements, report manipulation, earnings dressing)
   - 🚫 Anti-monopoly (no price manipulation, market carving, bid-rigging)
   - 🚫 Anti-money-laundering (no laundering, capital channel design, FX-control evasion)
   - 🔒 Data-privacy (sensitive enterprise/customer/employee data must be anonymized; cross-border compliance)
   - ⚖️ Compliance-boundary (does NOT replace lawyer/accountant/auditor/tax-advisor opinions; major decisions need human review)
   - 🤝 Human-in-loop (major decisions — investment/layoff/M&A/disclosure — require human final call; AI is advisor only)
   - 🌱 ESG-encouragement (responsible, sustainable decisions; reject short-sighted profit-chasing)
3. Commercial-use authorization process (point to LICENSE §2; email placeholder for commercial license requests: `helmforge-commercial@example.com` — owner to replace)
4. Reporting & feedback (§7 equivalent — how to report ethics violations)
5. Violation handling (immediate license termination per PolyForm-NC)

- [ ] **Step 3: Write .gitignore**

```
# OS
.DS_Store
Thumbs.db
# Editor
.vscode/
.idea/
*.swp
# Python
__pycache__/
*.pyc
.venv/
venv/
# Node
node_modules/
# Deploy local
.deploy-backup/
# Logs
*.log
```

- [ ] **Step 4: Write README.md skeleton (full polish deferred to T19)**

Structure (Forge-style, mirrors VitaForge/CodeForge README):
- Hero header with ⚓ HelmForge logo placeholder + slogan `Forge your enterprise. Take the helm.`
- Badges (License: PolyForm-NC | Ethics: Enterprise | Platforms: Claude/Codex/Antigravity/OpenClaw | Skills: 18)
- "📖 HelmForge 是什么" section (cockpit for enterprise commanders; Forge trilogy #3)
- "🚀 一键部署" section (placeholder, fill commands in T17)
- "📊 技能矩阵" section (18-skill table, fill from spec §3.1)
- "🔌 推荐 MCP" (placeholder)
- "📜 License & Ethics" (PolyForm-NC summary + ETHICS pointer)
- "💬 社区" (Issues / sibling projects CodeForge & VitaForge)
- Footer with slogan + star CTA

Leave deployment commands and full tables as `<!-- TODO: fill in T17/T19 -->` for now (these are legitimate deferrals to later tasks, NOT plan placeholders — the content is specified by those tasks).

- [ ] **Step 5: Verify P1-T1**

```bash
ls -la "E:/Development/HelmForge/LICENSE" "E:/Development/HelmForge/ETHICS.md" "E:/Development/HelmForge/.gitignore" "E:/Development/HelmForge/README.md"
head -5 "E:/Development/HelmForge/LICENSE"  # expect PolyForm Noncommercial
grep -c "反商业贿赂\|反财务欺诈\|人在回路" "E:/Development/HelmForge/ETHICS.md"  # expect >= 3
```
Expected: 4 files exist; LICENSE header mentions PolyForm Noncommercial; ETHICS contains the 8 red lines.

- [ ] **Step 6: Commit (gated — ask owner first)**

```bash
git -C "E:/Development/HelmForge" add LICENSE ETHICS.md .gitignore README.md
git -C "E:/Development/HelmForge" commit -m "feat: add LICENSE (PolyForm-NC), ETHICS, README skeleton"
# Do NOT push without owner authorization.
```

---

### Task 2: Four platform entry docs

**Files:**
- Create: `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `OPENCLAW.md`

**Interfaces:**
- Produces: Each entry doc declares `executive-consultant` as main dispatcher + lists all 18 skills. All four must list identical skill set (consistency check in Step 5).

- [ ] **Step 1: Write CLAUDE.md (Claude Code entry)**

Content (based on `package/enterprise-use/CLAUDE.md` pattern, extended to 18 skills + 5 routing branches):
```markdown
# CLAUDE.md - HelmForge

## 主调度入口

- `/executive-consultant` — **企业经营主调度**（推荐首选入口）。描述你的经营场景，自动分诊路由到对应子 skill。

## 技能命令一览（18 skill）

| 板块 | 命令 | 定位 |
|------|------|------|
| 🧭 战略决策 | `/executive-consultant` | 主调度 — 高管咨询 / 参谋长增强 |
| | `/strategy-cfo` | 商业战略 + 财商融合 |
| | `/geo-sentinel` | 地缘宏观预测 |
| | `/deep-research` | 多 Agent 深度调研 |
| 💰 财务预算 | `/finance-manager` | 三大报表 / 比率 / DCF / 现金流预警 |
| | `/budget-architect` | 年度预算 / 零基 / 滚动 / 差异分析 |
| | `/ecommerce-finance` | 电商财务补充 |
| 🏛️ 组织治理 | `/executive-secretary` | 高级行政秘书（高德地图 MCP） |
| | `/external-negotiation-master` | 对外谈判大师 |
| | `/global-legal-counsel` | 全球法律顾问 |
| 📦 交付展示 | `/office-docs` | PPTX/DOCX/XLSX |
| | `/editing` | PPT 模板编辑 |
| | `/pptxgenjs` | 代码生成 PPT |
| | `/frontend-slides` | 零依赖炫酷 HTML 演示 |
| | `/pdf-reader` | PDF → Markdown |
| 🔧 治理引擎 | `/loop-engineer` | 多 skill package 编排 |
| | `/skill-deploy` | 五镜像融合部署 |
| | `/skill-governor` | skill 开发质量门控 |

## 典型联动链路

```
/executive-consultant 经营诊断
  → /strategy-cfo 商业战略 + 财务可行性
  → /finance-manager 财务建模
  → /budget-architect 预算编制
  → /geo-sentinel 宏观风险
  → /frontend-slides 投资人路演 PPT
```

## 使用方式

1. 将本仓库 `.claude/` 合并到目标项目根目录（或用 `deploy/deploy.ps1`）
2. 重启 Claude Code 会话
3. 不确定用哪个命令时，先用 `/executive-consultant`

License: PolyForm Noncommercial 1.0.0 — 详见 LICENSE 与 ETHICS.md。
```

- [ ] **Step 2: Write AGENTS.md (Codex entry)**

Same skill list as CLAUDE.md but Codex syntax (`$skill-name` triggers). Use `<!-- SKILL-LIST-START -->` / `<!-- SKILL-LIST-END -->` markers (matches enterprise-use pattern, enables skill-deploy post-smoothing). Header declares `$executive-consultant` as main dispatcher.

- [ ] **Step 3: Write GEMINI.md (Antigravity/Gemini entry)**

Same skill list, Gemini auto-match style. Note at top: "Antigravity: 本镜像先按 Gemini 格式，待 Antigravity 格式确认后优化。"

- [ ] **Step 4: Write OPENCLAW.md (OpenClaw/WorkBuddy/龙虾 entry)**

Same skill list. Document OpenClaw skill discovery paths:
```markdown
# OPENCLAW.md - HelmForge (OpenClaw / WorkBuddy / 龙虾)

## 技能发现路径（OpenClaw 优先级）

| 优先级 | 路径 | 说明 |
|---|---|---|
| 1 | `.agents/skills/` | 项目级技能（跟随仓库） |
| 2 | `skills/` | 工作区级 |
| 3 | `~/.openclaw/skills/` 或 `~/.workbuddy/skills/` | 用户全局 |

本仓库 `.agents/skills/` 含全部 18 skill，与 Claude 镜像内容一致（SKILL.md 兼容）。

## 主调度

`executive-consultant` — 描述经营场景后自动路由。

## 18 skill 列表
[same list as CLAUDE.md]

## 安装

1. 拖拽 `.agents/skills/` 到 WorkBuddy 聊天框，或
2. `workbuddy skill install .agents/skills/<skill>` 逐个安装，或
3. 复制到 `~/.workbuddy/skills/` 全局生效。
```

- [ ] **Step 5: Verify four entry docs are consistent**

```bash
for f in CLAUDE AGENTS GEMINI OPENCLAW; do
  echo "=== $f.md skill count ==="
  grep -cE "executive-consultant|strategy-cfo|geo-sentinel|deep-research|finance-manager|budget-architect|ecommerce-finance|executive-secretary|external-negotiation-master|global-legal-counsel|office-docs|editing|pptxgenjs|frontend-slides|pdf-reader|loop-engineer|skill-deploy|skill-governor" "E:/Development/HelmForge/$f.md"
done
```
Expected: each file's count >= 18 (all skills referenced).

- [ ] **Step 6: Commit (gated)**

```bash
git -C "E:/Development/HelmForge" add CLAUDE.md AGENTS.md GEMINI.md OPENCLAW.md
git -C "E:/Development/HelmForge" commit -m "feat: add 4 platform entry docs (Claude/Codex/Gemini/OpenClaw)"
```

---

### Task 3: Deploy script skeletons + MCP template

**Files:**
- Create: `deploy/deploy.ps1` (skeleton, full logic in T17)
- Create: `deploy/deploy.sh` (skeleton, full logic in T17)
- Create: `deploy/mcp-config.template.json`

**Interfaces:**
- Produces: Skeleton deploy scripts that create 5 mirror dirs + copy skills. Full one-click logic (backup, post-smoothing) added in T17.

- [ ] **Step 1: Write deploy/deploy.ps1 skeleton**

PowerShell script. Header:
```powershell
# HelmForge deploy script (Windows PowerShell)
# Usage: powershell -ExecutionPolicy Bypass -File .\deploy\deploy.ps1 -Yes
# Full one-click logic added in P4-T17. This skeleton creates mirror dirs + copies skills.
```
Body: param block (`-Yes`), `chcp 65001` for UTF-8, create `.claude`/`.codex`/`.gemini`/`.agents` under user home if missing, copy each mirror's skills, print summary. Mark `# TODO T17: add backup + post-smoothing + verification` at insertion points (legitimate deferral — T17 specifies the content).

- [ ] **Step 2: Write deploy/deploy.sh skeleton**

Bash equivalent for macOS/Linux. Same structure: `--yes` flag, mkdir mirrors under `$HOME`, cp skills, summary. Same `# TODO T17` markers.

- [ ] **Step 3: Write deploy/mcp-config.template.json**

```json
{
  "mcpServers": {
    "amap-maps": {
      "comment": "高德地图 MCP — executive-secretary 通勤/路线规划",
      "command": "npx",
      "args": ["-y", "@amap/amap-maps-mcp-server"],
      "env": { "AMAP_API_KEY": "<your-key>" }
    },
    "finance": {
      "comment": "财经数据 MCP — finance-manager 财务数据",
      "command": "npx",
      "args": ["-y", "finance-mcp-server"],
      "env": { "TUSHARE_TOKEN": "<your-token>" }
    }
  }
}
```
Note: actual MCP server names/args validated in P2 when skills are wired.

- [ ] **Step 4: Verify scripts are syntactically OK**

```bash
powershell -Command "[System.Management.Automation.PSParser]::Tokenize((Get-Content 'E:/Development/HelmForge/deploy/deploy.ps1' -Raw), [ref]$null) | Out-Null; 'PS1 OK'"
bash -n "E:/Development/HelmForge/deploy/deploy.sh" && echo "SH OK"
python -c "import json; json.load(open('E:/Development/HelmForge/deploy/mcp-config.template.json')); print('JSON OK')"
```
Expected: all three print OK.

- [ ] **Step 5: Commit (gated)**

```bash
git -C "E:/Development/HelmForge" add deploy/
git -C "E:/Development/HelmForge" commit -m "feat: add deploy script skeletons + MCP template"
```

---

### Task 4: docs/cn-api-providers.md

**Files:**
- Create: `docs/cn-api-providers.md`

**Interfaces:**
- Produces: National-model API config guide (GLM-5.2 / DeepSeek / Kimi / MiMo / 硅基流动), bash + PowerShell + CMD templates, settings.json recommendation.

- [ ] **Step 1: Write docs/cn-api-providers.md**

Adapt from CodeForge's `docs/cn-api-providers.md` pattern (it's a published reference doc). Sections:
1. Why national models (国内访问 Anthropic API 受限)
2. 🏆 Recommended: 智谱 GLM-5.2[1m] — endpoint `https://api.z.ai/api/anthropic`, model `glm-5.2[1m]`, small-fast `glm-4.7`
3. DeepSeek — `https://api.deepseek.com/anthropic`, `deepseek-v4-pro[1m]`
4. Kimi K2.7-Code (256K, needs `CLAUDE_CODE_AUTO_COMPACT_WINDOW=262144`)
5. 小米 MiMo v2.5-pro[1m]
6. 硅基流动 (multi-model gateway)
7. Cross-platform config templates: bash / PowerShell / CMD (copy verbatim from CodeForge pattern)
8. settings.json recommendation
9. Cost comparison table

- [ ] **Step 2: Verify**

```bash
grep -cE "glm-5.2|deepseek|kimi|mimo|siliconflow|硅基流动" "E:/Development/HelmForge/docs/cn-api-providers.md"  # expect >= 5
grep -c "ANTHROPIC_BASE_URL" "E:/Development/HelmForge/docs/cn-api-providers.md"  # expect >= 3 (bash/ps/cmd templates)
```

- [ ] **Step 3: Commit (gated)**

```bash
git -C "E:/Development/HelmForge" add docs/cn-api-providers.md
git -C "E:/Development/HelmForge" commit -m "docs: add national API providers guide"
```

---

### Task 5: Create 5 mirror directory skeletons

**Files:**
- Create dirs: `.claude/commands/`, `.claude/skills/`, `.claude/scripts/`, `.codex/skills/`, `.gemini/skills/`, `.agents/skills/`, `assets/`

**Produces:** Empty mirror skeletons ready for P2 skill migration.

- [ ] **Step 1: Create all directories**

```bash
cd "E:/Development/HelmForge"
mkdir -p .claude/commands .claude/skills .claude/scripts
mkdir -p .codex/skills .gemini/skills .agents/skills
mkdir -p assets docs/superpowers/specs docs/superpowers/plans
touch .claude/commands/.gitkeep .claude/skills/.gitkeep .claude/scripts/.gitkeep
touch .codex/skills/.gitkeep .gemini/skills/.gitkeep .agents/skills/.gitkeep
touch assets/.gitkeep
```

- [ ] **Step 2: Verify**

```bash
for d in .claude/commands .claude/skills .claude/scripts .codex/skills .gemini/skills .agents/skills assets; do
  test -d "E:/Development/HelmForge/$d" && echo "OK $d" || echo "MISSING $d"
done
```
Expected: all 7 print OK.

- [ ] **Step 3: Commit (gated)**

```bash
git -C "E:/Development/HelmForge" add .claude .codex .gemini .agents assets
git -C "E:/Development/HelmForge" commit -m "chore: create 5 mirror directory skeletons"
```

---

### Task 6: P1 verification gate

**Files:** No new files — verification only.

- [ ] **Step 1: Run full P1 structure check**

```bash
cd "E:/Development/HelmForge"
echo "=== Root files ===" && ls LICENSE ETHICS.md README.md CONTRIBUTING.md .gitignore CLAUDE.md AGENTS.md GEMINI.md OPENCLAW.md 2>&1
echo "=== Deploy ===" && ls deploy/deploy.ps1 deploy/deploy.sh deploy/mcp-config.template.json
echo "=== Docs ===" && ls docs/cn-api-providers.md docs/superpowers/specs docs/superpowers/plans
echo "=== Mirrors ===" && ls -d .claude .codex .gemini .agents
echo "=== LICENSE check ===" && head -3 LICENSE
```
Expected: all listed files/dirs present; LICENSE shows PolyForm Noncommercial.

- [ ] **Step 2: P1 done — notify owner, request commit/push authorization**

P1 produces a visible empty-project skeleton. Present to owner before P2.

---

# Phase 2 — Migrate Reused Skills (Tasks 7-10)

### Task 7: Migrate 9 enterprise-use skills to .claude mirror

**Files:**
- Copy into `.claude/`: `commands/{executive-consultant,executive-secretary,external-negotiation-master,global-legal-counsel,office-docs,pdf-reader,deep-research,loop-engineer}.md` + `skills/{executive-consultant,executive-secretary,external-negotiation-master,global-legal-counsel,office-docs,pdf-reader,deep-research,editing,pptxgenjs}/` + `scripts/` (office-docs toolchain)

**Source:** `E:\Development\Claude_skill_pool\package\enterprise-use\.claude\`

- [ ] **Step 1: Copy commands**

```bash
SRC="E:/Development/Claude_skill_pool/package/enterprise-use/.claude"
DST="E:/Development/HelmForge/.claude"
cp "$SRC/commands/executive-consultant.md" "$DST/commands/"
cp "$SRC/commands/executive-secretary.md" "$DST/commands/"
cp "$SRC/commands/external-negotiation-master.md" "$DST/commands/"
cp "$SRC/commands/global-legal-counsel.md" "$DST/commands/"
cp "$SRC/commands/office-docs.md" "$DST/commands/"
cp "$SRC/commands/pdf-reader.md" "$DST/commands/"
cp "$SRC/commands/deep-research.md" "$DST/commands/"
cp "$SRC/commands/loop-engineer.md" "$DST/commands/"
```

- [ ] **Step 2: Copy skill directories**

```bash
for s in executive-consultant executive-secretary external-negotiation-master global-legal-counsel office-docs pdf-reader deep-research editing pptxgenjs; do
  cp -r "$SRC/skills/$s" "$DST/skills/"
done
```

- [ ] **Step 3: Copy office-docs scripts toolchain**

```bash
cp -r "$SRC/scripts/"* "$DST/scripts/" 2>/dev/null || echo "scripts dir contents copied"
```

- [ ] **Step 4: Verify**

```bash
DST="E:/Development/HelmForge/.claude"
echo "commands:" && ls "$DST/commands/" | wc -l  # expect >= 8
echo "skills:" && ls "$DST/skills/" | wc -l  # expect >= 9
echo "executive-consultant SKILL.md:" && test -f "$DST/skills/executive-consultant/SKILL.md" && echo OK
echo "office-docs scripts:" && ls "$DST/scripts/" | head -3
```

- [ ] **Step 5: Commit (gated)**

```bash
git -C "E:/Development/HelmForge" add .claude
git -C "E:/Development/HelmForge" commit -m "feat: migrate 9 enterprise-use skills to .claude mirror"
```

---

### Task 8: Migrate 4 pool skills (geo-sentinel, frontend-slides, ecommerce-finance, loop-engineer) to .claude

**Files:**
- Copy into `.claude/skills/`: `geo-sentinel/`, `frontend-slides/`, `ecommerce-finance/`, `loop-engineer/`
- Copy into `.claude/commands/`: corresponding command md if exists

**Source:** `E:\Development\Claude_skill_pool\skills.claude\<skill>\.claude\`

- [ ] **Step 1: Locate each skill's .claude content**

```bash
for s in geo-sentinel frontend-slides ecommerce-finance loop-engineer; do
  echo "=== $s ==="
  find "E:/Development/Claude_skill_pool/skills.claude/$s/.claude" -maxdepth 2 -type d 2>&1 | head
done
```
Inspect output: each pool skill has `.claude/commands/<skill>.md` + `.claude/skills/<skill>/SKILL.md` structure.

- [ ] **Step 2: Copy each skill's commands + skill dir**

```bash
DST="E:/Development/HelmForge/.claude"
for s in geo-sentinel frontend-slides ecommerce-finance loop-engineer; do
  SRC="E:/Development/Claude_skill_pool/skills.claude/$s/.claude"
  # command
  if [ -f "$SRC/commands/$s.md" ]; then cp "$SRC/commands/$s.md" "$DST/commands/"; fi
  # skill dir
  if [ -d "$SRC/skills/$s" ]; then cp -r "$SRC/skills/$s" "$DST/skills/"; fi
done
```

- [ ] **Step 3: Verify**

```bash
DST="E:/Development/HelmForge/.claude"
for s in geo-sentinel frontend-slides ecommerce-finance loop-engineer; do
  test -f "$DST/skills/$s/SKILL.md" && echo "OK skill $s" || echo "MISSING skill $s"
done
echo "total skills in .claude:" && ls "$DST/skills/" | wc -l  # expect 13 (9+4)
```

- [ ] **Step 4: Commit (gated)**

```bash
git -C "E:/Development/HelmForge" add .claude
git -C "E:/Development/HelmForge" commit -m "feat: migrate 4 pool skills (geo-sentinel/frontend-slides/ecommerce-finance/loop-engineer)"
```

---

### Task 9: Sync 13 skills to .codex / .gemini / .agents mirrors

**Files:**
- Copy `.claude/skills/*` → `.codex/skills/`, `.gemini/skills/`, `.agents/skills/`
- Adapt: `.codex` skills need `agents/openai.yaml` if enterprise-use pattern used; `.agents` uses identical SKILL.md (OpenClaw-compatible)

- [ ] **Step 1: Sync to .codex**

```bash
SRC="E:/Development/HelmForge/.claude/skills"
for s in $(ls "$SRC"); do
  cp -r "$SRC/$s" "E:/Development/HelmForge/.codex/skills/"
done
# If enterprise-use .codex had openai.yaml per skill, copy that pattern too:
# Reference: E:/Development/Claude_skill_pool/package/enterprise-use/.codex/skills/
```

- [ ] **Step 2: Sync to .gemini**

```bash
for s in $(ls "$SRC"); do
  cp -r "$SRC/$s" "E:/Development/HelmForge/.gemini/skills/"
done
```

- [ ] **Step 3: Sync to .agents (OpenClaw/WorkBuddy/龙虾)**

```bash
for s in $(ls "$SRC"); do
  cp -r "$SRC/$s" "E:/Development/HelmForge/.agents/skills/"
done
```

- [ ] **Step 4: Verify 4-mirror skill count parity**

```bash
for m in .claude .codex .gemini .agents; do
  n=$(ls "E:/Development/HelmForge/$m/skills/" | grep -v gitkeep | wc -l)
  echo "$m: $n skills"
done
```
Expected: all four show 13.

- [ ] **Step 5: Commit (gated)**

```bash
git -C "E:/Development/HelmForge" add .codex .gemini .agents
git -C "E:/Development/HelmForge" commit -m "feat: sync 13 skills to .codex/.gemini/.agents mirrors"
```

---

### Task 10: Extend executive-consultant routing table (4 new branches)

**Files:**
- Modify: `.claude/skills/executive-consultant/SKILL.md` (routing table section, ~line 365-378 in source)
- Modify: same file in `.codex/`, `.gemini/`, `.agents/` mirrors (keep in sync)

**Interfaces:**
- Consumes: routing table pattern from executive-consultant's existing "Package 主调度协议" section.
- Produces: 4 new routing rows pointing to finance-manager / budget-architect / strategy-cfo / geo-sentinel (these skills created in P3; routing wired now, skills land in T11-T13).

- [ ] **Step 1: Edit .claude executive-consultant routing table**

Open `.claude/skills/executive-consultant/SKILL.md`, find the "Package 主调度协议" routing table (the table with columns 用户意图关键词 | 路由目标 | 说明). Insert 4 new rows at the top:
```markdown
| 财务、报表、比率、现金流、DCF、估值、财务健康 | → `finance-manager` | 财务分析/建模/预警 |
| 预算、预测、零基、滚动、差异分析、预算编制 | → `budget-architect` | 预算编制/滚动预测 |
| 商业模式、战略方向、资本结构、投资决策、资源配置 | → `strategy-cfo` | 商业战略+财商融合 |
| 地缘、宏观、政策、战争、选举、制裁、出海风险、汇率 | → `geo-sentinel` | 地缘宏观预测 |
```

- [ ] **Step 2: Propagate the same edit to .codex/.gemini/.agents**

```bash
SRC_SKILL="E:/Development/HelmForge/.claude/skills/executive-consultant/SKILL.md"
for m in .codex .gemini .agents; do
  cp "$SRC_SKILL" "E:/Development/HelmForge/$m/skills/executive-consultant/SKILL.md"
done
```

- [ ] **Step 3: Verify routing table consistency across 4 mirrors**

```bash
for m in .claude .codex .gemini .agents; do
  f="E:/Development/HelmForge/$m/skills/executive-consultant/SKILL.md"
  n=$(grep -cE "finance-manager|budget-architect|strategy-cfo|geo-sentinel" "$f")
  echo "$m: $n new-branch refs (expect >= 4)"
done
```
Expected: each mirror >= 4.

- [ ] **Step 4: Commit (gated)**

```bash
git -C "E:/Development/HelmForge" add .claude/skills/executive-consultant .codex .gemini .agents
git -C "E:/Development/HelmForge" commit -m "feat: extend executive-consultant routing with 4 new branches"
```

---

# Phase 3 — New Core Skills (Tasks 11-14)

### Task 11: Build finance-manager skill (5 mirrors)

**Files:**
- Create: `.claude/skills/finance-manager/SKILL.md` + `references/`
- Create: `.claude/commands/finance-manager.md`
- Sync to `.codex/`, `.gemini/`, `.agents/`

**Interfaces:**
- Produces: `finance-manager` skill callable from executive-consultant routing. Output contract = financial-health one-liner + key-ratio table + risk points + improvement suggestions.

- [ ] **Step 1: Write SKILL.md frontmatter + overview**

Create `.claude/skills/finance-manager/SKILL.md`:
```markdown
---
name: finance-manager
description: 企业财务管理与财务分析专家。用于三大报表分析、财务比率（偿债/盈利/营运/成长）、杜邦分解、DCF 估值、现金流预警、财务健康诊断。触发词：财务、报表、资产负债表、利润表、现金流量表、财务比率、杜邦、ROE、ROA、现金流、估值、DCF、财务健康、偿债能力、营运能力。默认输出财务健康一句话判断 + 关键比率表 + 风险点 + 改善建议；不替代审计，重大结论标注"需会计师复核"。
version: 0.1.0
---

# Finance Manager — 企业财务管理与财务分析专家

[overview: 定位、适用场景、不适用场景、工作原则、与 executive-consultant 战略模块的边界]
```

- [ ] **Step 2: Write the 6 core capability sections**

Sections (each points to a reference file):
1. 三大报表分析（资产负债表/利润表/现金流量表）→ `references/three-statements.md`
2. 财务比率体系（偿债/盈利/营运/成长四大类）→ `references/financial-ratios.md`
3. 杜邦分解（ROE = 净利率 × 总资产周转率 × 权益乘数）→ `references/dupont.md`
4. DCF 估值（自由现金流预测 + WACC + 终值）→ `references/dcf-valuation.md`
5. 现金流预警（经营性现金流/净利润背离、现金短债比、现金循环周期）→ `references/cashflow-warning.md`
6. 行业基准对比 → `references/industry-benchmarks.md`

- [ ] **Step 3: Write the output contract section**

```markdown
## 默认输出合同

除非用户明确要求其他格式，否则按以下结构输出：

\`\`\`markdown
## 财务健康一句话判断
[例：盈利能力稳健但短期偿债承压，现金流质量待改善]

## 关键财务比率表
| 维度 | 指标 | 数值 | 行业基准 | 评价 |
|---|---|---|---|---|
| 偿债 | 流动比率 | x.xx | ~2.0 | ⚠️ |
| ... | ... | ... | ... | ... |

## 杜邦分解
ROE = 净利率 × 总资产周转率 × 权益乘数 = xx% × x.xx × x.xx = xx%

## 风险点
1. ...
2. ...

## 改善建议
1. 短期（0-3 月）：...
2. 中期（3-12 月）：...

## 数据假设与复核提示
- [标注哪些数据是用户提供 vs 假设]
- ⚠️ 本分析不替代审计，重大结论需会计师复核
\`\`\`
```

- [ ] **Step 4: Write 6 reference files**

Each reference file is 100-200 lines of domain knowledge:
- `three-statements.md`: 三大报表的结构、勾稽关系、常见粉饰手法识别
- `financial-ratios.md`: 四类比率的公式、健康区间、行业差异、计算示例
- `dupont.md`: 杜邦分解的推导、五因子扩展、与同行对比
- `dcf-valuation.md`: FCF 计算、WACC 估算、终值（永续增长/退出乘数）、敏感性分析
- `cashflow-warning.md`: 预警信号清单、阈值、触发动作
- `industry-benchmarks.md`: 主要行业的基准比率范围（制造/零售/SaaS/金融等）

- [ ] **Step 5: Write .claude/commands/finance-manager.md**

```markdown
---
description: 财务管理与财务分析专家 — 三大报表/比率/杜邦/DCF/现金流预警
---

# /finance-manager

[简短描述 + 引导用户描述财务场景，调用 finance-manager skill]
```

- [ ] **Step 6: Sync to .codex/.gemini/.agents**

```bash
SRC="E:/Development/HelmForge/.claude/skills/finance-manager"
for m in .codex .gemini .agents; do
  cp -r "$SRC" "E:/Development/HelmForge/$m/skills/"
done
cp "E:/Development/HelmForge/.claude/commands/finance-manager.md" "E:/Development/HelmForge/.codex/skills/finance-manager/" 2>/dev/null  # codex may bundle command in skill
```

- [ ] **Step 7: Verify finance-manager in all 4 mirrors**

```bash
for m in .claude .codex .gemini .agents; do
  f="E:/Development/HelmForge/$m/skills/finance-manager/SKILL.md"
  test -f "$f" && grep -q "name: finance-manager" "$f" && echo "OK $m" || echo "FAIL $m"
  ls "E:/Development/HelmForge/$m/skills/finance-manager/references/" | wc -l  # expect 6
done
```

- [ ] **Step 8: Commit (gated)**

```bash
git -C "E:/Development/HelmForge" add .claude .codex .gemini .agents
git -C "E:/Development/HelmForge" commit -m "feat: add finance-manager skill (财务报表/比率/杜邦/DCF/现金流预警)"
```

---

### Task 12: Build budget-architect skill (5 mirrors)

**Files:**
- Create: `.claude/skills/budget-architect/SKILL.md` + `references/`
- Create: `.claude/commands/budget-architect.md`
- Sync to `.codex/`, `.gemini/`, `.agents/`

**Produces:** `budget-architect` skill. Output contract = budget plan + top-down/bottom-up reconciliation + rolling forecast table + variance warning mechanism.

- [ ] **Step 1: Write SKILL.md frontmatter + overview**

```markdown
---
name: budget-architect
description: 企业预算制定与预算管理专家。用于年度预算编制（自上而下/自下而上）、零基预算、滚动预测、差异分析与预警、部门预算协同。触发词：预算、预算编制、年度预算、零基预算、滚动预测、预算差异、预算执行、部门预算、财务规划、FP&A。默认输出预算编制方案 + 自上而下/自下而上对账 + 滚动预测表 + 差异预警机制；依赖输入数据质量，缺数据时明确标注假设。
version: 0.1.0
---

# Budget Architect — 企业预算制定与管理专家

[overview: 定位、适用场景、不适用、工作原则、与 finance-manager 的边界（finance 看历史报表，budget 看未来预测）]
```

- [ ] **Step 5 reference files** (analogous structure to T11):
- `budgeting-methods.md`: 增量预算 / 零基预算 / 滚动预算 / 作业基础预算的适用场景与步骤
- `top-down-bottom-up.md`: 自上而下与自下而上对账方法、分歧处理
- `rolling-forecast.md`: 滚动预测的窗口设计、驱动因子、更新节奏
- `variance-analysis.md`: 差异分析的价差/量差分解、根因定位、预警阈值
- `department-collaboration.md`: 部门预算协同流程、模板、口径统一

- [ ] **Step 2-7**: Mirror T11 Steps 2-7 structure (6 sections → output contract → references → command → sync → verify). Output contract:
```markdown
## 预算编制方案
[方法选择 + 假设 + 编制逻辑]

## 自上而下 / 自下而上对账
[目标 vs 各部门汇总，差异与调整]

## 滚动预测表（12 个月）
| 月份 | 收入 | 成本 | 毛利 | ... |

## 差异预警机制
[预警阈值 + 触发动作 + 复盘节奏]

## 数据假设与依赖
[标注假设项 + 缺数据提示]
```

- [ ] **Step 8: Commit (gated)**

```bash
git -C "E:/Development/HelmForge" add .claude .codex .gemini .agents
git -C "E:/Development/HelmForge" commit -m "feat: add budget-architect skill (预算编制/零基/滚动/差异分析)"
```

---

### Task 13: Build strategy-cfo skill (5 mirrors)

**Files:**
- Create: `.claude/skills/strategy-cfo/SKILL.md` + `references/`
- Create: `.claude/commands/strategy-cfo.md`
- Sync to `.codex/`, `.gemini/`, `.agents/`

**Produces:** `strategy-cfo` skill. Differentiator from executive-consultant's strategic-diagnosis module: executive-consultant = management/organization lens; strategy-cfo = commercial/financial lens (capital structure / valuation / investment return).

- [ ] **Step 1: Write SKILL.md frontmatter + overview**

```markdown
---
name: strategy-cfo
description: 商业战略与财商融合决策专家。用于商业模式设计、资本结构决策、投资决策（NPV/IRR/回收期）、资源配置矩阵、估值视角的战略选项评估。触发词：商业模式、战略、资本结构、投资决策、资源配置、估值、NPV、IRR、融资、并购、M&A、业务组合。与 executive-consultant 战略诊断模块的区别：executive-consultant 偏管理与组织视角，strategy-cfo 偏商业与财务视角（资本/估值/投资回报）。
version: 0.1.0
---

# Strategy CFO — 商业战略 + 财商融合决策专家

[overview: 定位、与 executive-consultant 的边界、适用场景]
```

- [ ] **5 reference files**:
- `business-model-canvas.md`: 商业模式画布 9 模块 + 变现路径
- `capital-structure.md`: 资本结构决策（债务/股权比例、WACC、财务杠杆）
- `investment-decision.md`: NPV/IRR/回收期/获利指数、互斥项目选择
- `resource-allocation.md`: 资源配置矩阵（BCG/GE）、投资优先级
- `valuation-lens.md`: 估值视角（DCF/可比公司/可比交易）、战略对估值的影响

- [ ] **Step 2-7**: Mirror T11 structure. Output contract:
```markdown
## 战略选项
[2-3 个候选战略方向]

## 财务可行性
[各选项的资本需求、回报测算、风险]

## 资本结构建议
[融资组合、杠杆水平、WACC 影响]

## 投资回报测算
| 选项 | NPV | IRR | 回收期 | 风险 |

## 推荐路径与退出条件
```

- [ ] **Step 8: Commit (gated)**

```bash
git -C "E:/Development/HelmForge" add .claude .codex .gemini .agents
git -C "E:/Development/HelmForge" commit -m "feat: add strategy-cfo skill (商业战略+财商融合)"
```

---

### Task 14: P3 verification — all 3 new skills wired into routing

**Files:** Verification only.

- [ ] **Step 1: Verify 18 skills present in .claude**

```bash
ls "E:/Development/HelmForge/.claude/skills/" | grep -v gitkeep | wc -l  # expect 16 (13+3)
ls "E:/Development/HelmForge/.claude/commands/" | wc -l  # expect >= 11 (8 migrated + 3 new)
```

- [ ] **Step 2: Verify routing table references all 3 new skills**

```bash
grep -E "finance-manager|budget-architect|strategy-cfo" "E:/Development/HelmForge/.claude/skills/executive-consultant/SKILL.md" | wc -l  # expect >= 3
```

- [ ] **Step 3: Verify 5-mirror parity for 3 new skills**

```bash
for s in finance-manager budget-architect strategy-cfo; do
  for m in .claude .codex .gemini .agents; do
    test -f "E:/Development/HelmForge/$m/skills/$s/SKILL.md" && echo "OK $m/$s" || echo "MISSING $m/$s"
  done
done
```
Expected: 12 OK.

- [ ] **Step 4: P3 done — notify owner, request commit/push authorization**

---

# Phase 4 — Governance & Deployment (Tasks 15-17)

### Task 15: Adapt skill-deploy for 5 mirrors

**Files:**
- Create: `.claude/skills/skill-deploy/SKILL.md` (adapted from CodeForge/VitaForge, rewritten for PolyForm-NC + 5 mirrors)
- Create: `.claude/commands/skill-deploy.md`
- Sync to `.codex/`, `.gemini/`, `.agents/`

**Interfaces:**
- Produces: `skill-deploy` skill that deploys HelmForge's 5 mirrors to user environment + runs post-smoothing (routing consistency check).

- [ ] **Step 1: Source the Forge skill-deploy prompt as reference**

```bash
# Inspect (not copy verbatim — rewrite for 5 mirrors + PolyForm-NC):
gh api repos/PancrePal-xiaoyibao/CodeForge/contents/.claude/skills/skill-deploy/SKILL.md --jq '.content' | base64 -d | head -100
```

- [ ] **Step 2: Write HelmForge's skill-deploy SKILL.md**

Rewrite (do NOT copy verbatim — PolyForm-NC prohibits redistribution of borrowed code as-is; rewrite the prompt logic):
- Frontmatter: `name: skill-deploy`, description mentions 5 mirrors + post-smoothing
- Body: deploy flow (backup existing → copy 5 mirrors → verify entry docs → post-smoothing routing check)
- Post-smoothing algorithm: compare executive-consultant routing tables across 4 skill mirrors, flag any mismatch

- [ ] **Step 3: Write command + sync 4 mirrors** (same pattern as T11 Step 5-6)

- [ ] **Step 4: Verify**

```bash
for m in .claude .codex .gemini .agents; do
  test -f "E:/Development/HelmForge/$m/skills/skill-deploy/SKILL.md" && echo "OK $m" || echo "MISSING $m"
done
```

- [ ] **Step 5: Commit (gated)**

```bash
git -C "E:/Development/HelmForge" add .claude .codex .gemini .agents
git -C "E:/Development/HelmForge" commit -m "feat: add skill-deploy (5-mirror fusion deploy + post-smoothing)"
```

---

### Task 16: Adapt skill-governor for 5 mirrors

**Files:**
- Create: `.claude/skills/skill-governor/SKILL.md` + `.claude/commands/skill-governor.md`
- Sync to 4 mirrors

**Produces:** `skill-governor` skill — single-skill dev/upgrade flow + quality gate (5-mirror sync checklist).

- [ ] **Step 1: Source Forge skill-governor as reference**

```bash
gh api repos/PancrePal-xiaoyibao/VitaForge/contents/.claude/skills/skill-governor/SKILL.md --jq '.content' | base64 -d | head -100
```

- [ ] **Step 2: Rewrite skill-governor SKILL.md** (PolyForm-NC safe rewrite):
- Checklist: frontmatter valid (name/description/version) · references listed · 5 mirrors synced · entry docs updated · routing table consistent · ETHICS respected
- Dev workflow: spec → draft SKILL.md → references → 5-mirror sync → entry doc update → commit

- [ ] **Step 3: Command + sync + verify** (T11 pattern)

- [ ] **Step 4: Commit (gated)**

```bash
git -C "E:/Development/HelmForge" add .claude .codex .gemini .agents
git -C "E:/Development/HelmForge" commit -m "feat: add skill-governor (5-mirror quality gate)"
```

---

### Task 17: Complete deploy scripts + one-click deploy test

**Files:**
- Modify: `deploy/deploy.ps1` (fill T3 TODOs: backup + post-smoothing + verification)
- Modify: `deploy/deploy.sh` (same)

- [ ] **Step 1: Complete deploy.ps1**

Add to the skeleton:
- Pre-deploy backup: copy existing `~/.claude` `~/.codex` `~/.gemini` `~/.agents` to `.deploy-backup/<timestamp>/` if exist
- Deploy: copy each mirror's skills to corresponding user home dir
- Post-smoothing: invoke skill-deploy logic (or inline check) verifying routing consistency
- Summary report: paths deployed, backups made, post-smoothing result, next-step CLI hint

- [ ] **Step 2: Complete deploy.sh** (mirror Step 1 for bash)

- [ ] **Step 3: Dry-run test on Windows**

```bash
cd "E:/Development/HelmForge"
# Test to a temp target, not real user home:
TMPDIR=$(mktemp -d)
powershell -ExecutionPolicy Bypass -File ./deploy/deploy.ps1 -Yes -Target "$TMPDIR" 2>&1 | tail -20
# Verify mirrors landed:
ls "$TMPDIR/.claude/skills/" | wc -l  # expect 18
ls "$TMPDIR/.agents/skills/" | wc -l  # expect 18
rm -rf "$TMPDIR"
```
Note: if deploy.ps1 doesn't yet support `-Target`, add it as a param for testing (don't pollute real user home).

- [ ] **Step 4: Verify both scripts pass syntax**

```bash
powershell -Command "[System.Management.Automation.PSParser]::Tokenize((Get-Content 'E:/Development/HelmForge/deploy/deploy.ps1' -Raw), [ref]$null) | Out-Null; 'PS1 OK'"
bash -n "E:/Development/HelmForge/deploy/deploy.sh" && echo "SH OK"
```

- [ ] **Step 5: Commit (gated)**

```bash
git -C "E:/Development/HelmForge" add deploy/
git -C "E:/Development/HelmForge" commit -m "feat: complete deploy scripts (backup + post-smoothing + verification)"
```

---

# Phase 5 — Open-Source Front (Tasks 18-20)

### Task 18: CONTRIBUTING.md with Agent self-evolution flow

**Files:**
- Create: `CONTRIBUTING.md`

- [ ] **Step 1: Write CONTRIBUTING.md**

Sections (Forge-style):
1. How to contribute (3 paths):
   - Path A: Report issue / suggest skill
   - Path B: Improve existing skill (manual PR)
   - **Path C: Agent self-evolution** — let the agent optimize a skill via skill-governor → 5-mirror sync → fork → PR (copy the workflow template from CodeForge CONTRIBUTING, adapt for HelmForge's 5 mirrors)
2. Skill dev standards (point to skill-governor)
3. Commit format (conventional commits + `🤖 Generated with HelmForge` trailer)
4. PR template (AI-disclosure section mandatory)
5. License reminder (PolyForm-NC — commercial use needs authorization)

- [ ] **Step 2: Verify**

```bash
grep -c "skill-governor\|skill-deploy\|self-evolution\|自进化\|AI 辅助披露\|PolyForm" "E:/Development/HelmForge/CONTRIBUTING.md"  # expect >= 5
```

- [ ] **Step 3: Commit (gated)**

```bash
git -C "E:/Development/HelmForge" add CONTRIBUTING.md
git -C "E:/Development/HelmForge" commit -m "docs: add CONTRIBUTING with Agent self-evolution flow"
```

---

### Task 19: README polish + assets

**Files:**
- Modify: `README.md` (fill T1 skeleton placeholders)
- Create: `assets/logo.png`, `assets/banner.png` (placeholders if no designer), `assets/header.png`

- [ ] **Step 1: Polish README.md**

Fill the T1 skeleton with:
- Full 18-skill matrix table (from spec §3.1)
- One-click deploy section (commands from T17)
- Recommended MCP section (from deploy/mcp-config.template.json)
- Typical scenarios (3-4 example chains, like VitaForge)
- Fork-your-own section
- Agent self-evolution teaser (point to CONTRIBUTING Path C)

- [ ] **Step 2: Create asset placeholders**

If no designer assets available, create SVG placeholders:
- `assets/logo.svg`: ⚓ helm-wheel + forge-fire motif, HelmForge wordmark
- `assets/banner.svg`: hero banner with slogan
Reference: convert to PNG later or keep SVG (GitHub renders SVG).

- [ ] **Step 3: Verify README completeness**

```bash
grep -cE "executive-consultant|finance-manager|budget-architect|strategy-cfo|geo-sentinel" "E:/Development/HelmForge/README.md"  # expect >= 5
grep -c "deploy.ps1\|deploy.sh\|一键部署" "E:/Development/HelmForge/README.md"  # expect >= 2
test -f "E:/Development/HelmForge/assets/logo.svg" && echo "logo OK"
```

- [ ] **Step 4: Commit (gated)**

```bash
git -C "E:/Development/HelmForge" add README.md assets/
git -C "E:/Development/HelmForge" commit -m "docs: polish README + add logo/banner assets"
```

---

### Task 20: Final integration verification + first full push

**Files:** Verification + push.

- [ ] **Step 1: Full structure verification**

```bash
cd "E:/Development/HelmForge"
echo "=== 18 skills in .claude ===" && ls .claude/skills/ | grep -v gitkeep | wc -l  # expect 18
echo "=== 5-mirror parity ===" 
for m in .claude .codex .gemini .agents; do
  echo "$m: $(ls $m/skills/ | grep -v gitkeep | wc -l) skills"
done  # all expect 18
echo "=== Entry docs ===" && ls CLAUDE.md AGENTS.md GEMINI.md OPENCLAW.md
echo "=== Legal ===" && head -2 LICENSE && grep -c "反商业贿赂" ETHICS.md
echo "=== Deploy ===" && ls deploy/
echo "=== Routing parity ===" 
for m in .claude .codex .gemini .agents; do
  grep -c "finance-manager\|budget-architect\|strategy-cfo\|geo-sentinel" "$m/skills/executive-consultant/SKILL.md"
done  # all expect >= 4
```

- [ ] **Step 2: Dry-run deploy to temp dir (full test)**

```bash
TMPDIR=$(mktemp -d)
powershell -ExecutionPolicy Bypass -File ./deploy/deploy.ps1 -Yes -Target "$TMPDIR" 2>&1 | tail -30
# Post-smoothing should report routing consistency OK
rm -rf "$TMPDIR"
```

- [ ] **Step 3: Owner authorization checkpoint**

Present full HelmForge structure to owner. Request authorization for final `git push`.

- [ ] **Step 4: Push (gated — owner authorized only)**

```bash
git -C "E:/Development/HelmForge" push origin main
```

- [ ] **Step 5: Post-push verification**

```bash
gh repo view hhx465453939/HelmForge --json description,url,defaultBranchRef
gh api repos/hhx465453939/HelmForge/git/trees/main?recursive=1 --jq '.tree | length'  # file count
```

---

## Self-Review

**1. Spec coverage:**
- §1 定位 → README (T1/T19), entry docs (T2) ✅
- §2 目标/非目标 → constraints + ETHICS (T1) + scope of all tasks ✅
- §3 18-skill matrix → T7 (9) + T8 (4) + T11/T12/T13 (3) + T15/T16 (2 governance) = 18 ✅
- §4 routing → T10 (4 new branches) ✅
- §5 governance trio → T16 (loop-engineer migrated T8) + T15 (skill-deploy) + T16 (skill-governor) ✅
- §6 5 mirrors → T5 (skeletons) + T9/T11/T12/T13/T15/T16 (sync) ✅
- §7 repo structure → T1-T20 collectively ✅
- §8 license + ethics → T1 ✅
- §9 5-phase roadmap → P1-P5 = T1-T20 ✅
- §10 acceptance → T6/T14/T20 verification gates ✅
- §11 risks → mitigated inline (PolyForm-NC rewrite for borrowed governance in T15/T16; OpenClaw format note in T2/T9; Antigravity note in T2) ✅

**2. Placeholder scan:** Legitimate deferrals are marked with explicit "filled in T17/T19" cross-references (deploy script logic, README polish) — these are task boundaries, not plan placeholders. No TBD/TODO-without-target. ✅

**3. Type/naming consistency:** `finance-manager` / `budget-architect` / `strategy-cfo` used consistently across T10/T11/T12/T13/T14/T19. Mirror names `.claude/.codex/.gemini/.agents` consistent throughout. ✅

No gaps found. Plan is complete.

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-07-04-helmforge.md`. Two execution options:

**1. Subagent-Driven (recommended)** — I dispatch a fresh subagent per task, review between tasks, fast iteration. Best for this plan because tasks are largely independent (skill migration vs new skill design) and benefit from fresh context per task.

**2. Inline Execution** — Execute tasks in this session using executing-plans, batch execution with checkpoints.

Which approach?
