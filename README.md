<div align="center">

# ⚓ HelmForge

### Forge your enterprise. Take the helm.

**企业掌舵者的 AI 经营驾驶舱 · Forge 三部曲 · 第三部**

<!-- TODO T19: replace placeholder logo with assets/helmforge-logo.png -->

[![License: PolyForm-NC](https://img.shields.io/badge/License-PolyForm--NC%201.0.0-blue.svg)](./LICENSE)
[![Ethics: Enterprise](https://img.shields.io/badge/Ethics-Enterprise%208%20Red%20Lines-critical.svg)](./ETHICS.md)
[![Platforms](https://img.shields.io/badge/Platforms-Claude%20%7C%20Codex%20%7C%20Antigravity%20%7C%20OpenClaw-green.svg)](#-多镜像部署)
[![Skills](https://img.shields.io/badge/Skills-18-orange.svg)](#-技能矩阵)
[![Status](https://img.shields.io/badge/Status-P1%20Foundation-lightgrey.svg)](./docs/superpowers/specs/2026-07-04-helmforge-design.md)

</div>

---

## 📖 HelmForge 是什么

HelmForge 是 **Forge 三部曲** 的收官之作：

```
CodeForge  🛠️  开发者 → 开源贡献引擎
VitaForge  🧬  研究者 → 生命科学引擎
HelmForge  ⚓  掌舵者 → 企业经营引擎   ← 本项目
```

它是面向 **CEO / CFO / COO / 部门负责人 / 创业者 / 企业战略与经营团队** 的 AI 经营副驾驶。一个入口（`executive-consultant` 主调度）智能路由 **18 个专业 skill**，覆盖：

- 🧭 **战略决策** — 战略 / 商业模式 / 地缘宏观 / 深度调研
- 💰 **财务预算** — 三大报表 / 预算编制 / 财务补充
- 🏛️ **组织治理** — 高级行政秘书 / 对外谈判 / 全球法律顾问
- 📦 **交付展示** — PPTX/DOCX/XLSX 读写 / PPT 模板编辑 / 代码生成 PPT / HTML 演示 / PDF 提取
- 🔧 **治理引擎** — 多 skill 联动设计 / 五镜像部署 / 单 skill 质量门控

### 💡 核心差异化

| # | 特性 | 说明 |
|---|---|---|
| 1 | 驾驶舱式统管 | 一个主调度路由 18 个专业 skill，而非散装 prompt |
| 2 | 财商融合 | 全新设计 `finance-manager` + `budget-architect` + `strategy-cfo`，补齐财务管理视角 |
| 3 | 宏观地缘 | 内置 `geo-sentinel`（地缘政治 + 宏观新闻预测），服务出海与宏观风险决策 |
| 4 | 5 镜像实质部署 | Claude / Codex / Antigravity / OpenClaw 系（WorkBuddy/龙虾） / 通用 Agent |
| 5 | 永久非商业 | PolyForm-NC 保护项目特殊性，配套企业经营 ETHICS 红线 |

---

## 🚀 一键部署

<!-- TODO T17 (deploy scripts): fill in one-line deploy commands for Windows / macOS / Linux -->
<!-- TODO T17: replace this block with actual deploy.ps1 / deploy.sh invocation examples -->

部署脚本与 MCP 配置模板将在 **Task 17** 完成。当前 P1 阶段仅完成项目骨架。

预计形态：

```powershell
# Windows (PowerShell)
# TODO T17: ./deploy/deploy.ps1 -Target Claude
```

```bash
# macOS / Linux (Bash)
# TODO T17: ./deploy/deploy.sh --target claude
```

通用 Agent 一句话部署 prompt 也将由 Task 17 提供。

---

## 📊 技能矩阵（18 skill）

<!-- TODO T19 (full skill matrix): replace with full 18-skill table from design spec §3.1 -->

完整 18 skill 表格将在 **Task 19**（README 营销润色阶段）补全。

板块概览（详细表格见 [design spec §3.1](./docs/superpowers/specs/2026-07-04-helmforge-design.md)）：

| 板块 | 数量 | 代表 skill |
|---|---|---|
| 🧭 战略决策 | 4 | `executive-consultant` (主调度) · `strategy-cfo` 🆕 · `geo-sentinel` · `deep-research` |
| 💰 财务预算 | 3 | `finance-manager` 🆕 · `budget-architect` 🆕 · `ecommerce-finance` |
| 🏛️ 组织治理 | 3 | `executive-secretary` · `external-negotiation-master` · `global-legal-counsel` |
| 📦 交付展示 | 5 | `office-docs` · `editing` · `pptxgenjs` · `frontend-slides` · `pdf-reader` |
| 🔧 治理引擎 | 3 | `loop-engineer` · `skill-deploy` · `skill-governor` |
| **合计** | **18** | **9 已有 + 4 池子复用 + 3 全新 + 2 借用 Forge** |

🆕 = HelmForge 全新设计的核心增量

---

## 🔌 推荐 MCP

<!-- TODO T17 (deploy scripts): list recommended MCP servers with config template link -->

HelmForge 部分 skill 通过 MCP（Model Context Protocol）增强能力。完整 MCP 配置模板将在 Task 17 与 `deploy/mcp-config.template.json` 一同发布。

---

## 🪞 多镜像部署

| 镜像平台 | 目录结构 | 入口文档 | 第一版状态 |
|---|---|---|---|
| **Claude Code** | `.claude/commands/*.md` + `.claude/skills/*/` | `CLAUDE.md` | ✅ 完整 |
| **Codex CLI** | `.codex/skills/*/` | `AGENTS.md` | ✅ 完整 |
| **Antigravity** (原 Gemini) | `.gemini/skills/*/` | `GEMINI.md` | ⚠️ 先按 Gemini 格式占位 |
| **OpenClaw / WorkBuddy / 龙虾** | `.agents/skills/*/` | `OPENCLAW.md` | ✅ 实质支持 |
| **通用 Agent 一句话部署** | — | README | ✅ |

每个镜像的 `executive-consultant` 都内置**相同的 Package 主调度路由表**，由 `skill-deploy` 后平滑校验。

---

## 📜 License & Ethics

### License: PolyForm Noncommercial 1.0.0

详见 [LICENSE](./LICENSE)。

- ✅ **非商业使用 / 修改 / 分发**：永久免费（个人 / 教育 / 科研 / 非营利 / 内部测试）
- ✅ **源码可见**（source available）
- ❌ **未授权商业使用禁止**（含 SaaS / 付费服务 / 企业生产部署 / 嵌入商业产品）
- 🚫 **无 Change Date**（永久非商业，不转开源 — 项目特殊性）
- 📝 **商业授权**：另行书面协议（联系方式见 ETHICS.md §3.2）

### Ethics: 企业经营八条红线

详见 [ETHICS.md](./ETHICS.md)。摘要：

| # | 红线 | 一句话 |
|---|---|---|
| 1 | 🚫 反商业贿赂 | 不设计、不执行任何贿赂、回扣、利益输送 |
| 2 | 🚫 反财务欺诈 | 不参与财务造假、报表操纵、业绩粉饰 |
| 3 | 🚫 反垄断 | 不策划价格操纵、市场瓜分、串通投标 |
| 4 | 🚫 反洗钱 | 不设计资金通道、不规避外汇管制 |
| 5 | 🔒 数据隐私 | 敏感数据须脱敏，遵守跨境合规 |
| 6 | ⚖️ 合规边界 | 不替代律师/会计师/审计师专业意见 |
| 7 | 🤝 人在回路 | 重大决策必须人类最终拍板，AI 仅参谋 |
| 8 | 🌱 ESG 鼓励 | 鼓励负责任、可持续的经营决策 |

---

## 💬 社区

- **Issues**: <https://github.com/hhx465453939/HelmForge/issues>
- **Design spec**: [`docs/superpowers/specs/2026-07-04-helmforge-design.md`](./docs/superpowers/specs/2026-07-04-helmforge-design.md)
- **伦理举报**: ETHICS.md §4

### 姊妹项目（Forge 三部曲）

<!-- TODO T19: replace with actual repo links once sibling projects published -->

| 项目 | 定位 | 状态 |
|---|---|---|
| 🛠️ **CodeForge** | 开发者 → 开源贡献引擎 | 待发布 |
| 🧬 **VitaForge** | 研究者 → 生命科学引擎 | 待发布 |
| ⚓ **HelmForge** | 掌舵者 → 企业经营引擎 | **本项目** |

---

## 🗺️ 开发路线（5 Phase）

<!-- TODO T19: link each phase to its completion report -->

| Phase | 内容 | 当前 |
|---|---|---|
| **P1 骨架品牌** | LICENSE + ETHICS + README + 4 入口文档 + deploy 骨架 | 🟡 进行中（Task 1/4 完成） |
| **P2 迁移复用** | 13 个已有 skill → 五镜像 | ⬜ |
| **P3 新建核心** | 🆕 finance-manager + budget-architect + strategy-cfo | ⬜ |
| **P4 治理部署** | loop-engineer / skill-deploy / skill-governor + 一键部署 | ⬜ |
| **P5 开源门面** | CONTRIBUTING + cn-api 文档 + logo/banner + 首次 push | ⬜ |

---

<div align="center">

---

⚓ **HelmForge** · *Forge your enterprise. Take the helm.*

如果这个项目对你有帮助，欢迎 ⭐ Star 支持。

</div>
