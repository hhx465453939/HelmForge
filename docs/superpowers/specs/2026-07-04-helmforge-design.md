# HelmForge — 企业掌舵者的 AI 经营驾驶舱

**Design Spec** · `2026-07-04` · Status: Approved by owner (pending spec self-review + user review)

> 本文档是 HelmForge 项目的权威设计规范。后续 `writing-plans` 将据此拆分实现任务。

---

## 0. 元信息

| 项 | 值 |
|---|---|
| 项目名 | **HelmForge**（Helm 舵轮 + Forge 锻造炉） |
| 仓库 | https://github.com/hhx465453939/HelmForge |
| Slogan | `Forge your enterprise. Take the helm.` |
| 定位 | 企业掌舵者的 AI 经营驾驶舱 |
| License | PolyForm Noncommercial 1.0.0（永久非商业，无开源转换） |
| 姊妹项目 | CodeForge 🛠️（开发者）· VitaForge 🧬（研究者）· **HelmForge ⚓（掌舵者）** |
| 目标用户 | CEO / CFO / COO / 部门负责人 / 创业者 / 企业战略与经营团队 |
| 部署形态 | Skill 包，部署到用户自己的 Agent 环境（非 SaaS） |

---

## 1. 项目概述

### 1.1 核心叙事

HelmForge 是 **Forge 三部曲** 的第三部：

```
CodeForge  🛠️  开发者 → 开源贡献引擎
VitaForge  🧬  研究者 → 生命科学引擎
HelmForge  ⚓  掌舵者 → 企业经营引擎   ← 本项目
```

它把企业掌舵者日常需要的**战略、预算、财务、组织、谈判、法律、宏观地缘、交付展示**八大能力，融合去重为一套 18 skill 的驾驶舱，一个入口（`executive-consultant` 主调度）智能路由。

### 1.2 差异化价值（vs 普通管理咨询工具 / 知识库）

1. **驾驶舱式统管**：一个主调度路由 18 个专业 skill，而非散装 prompt
2. **财商融合**：全新设计 `finance-manager` + `budget-architect` + `strategy-cfo`，补齐企业管理中常缺的财务/预算视角
3. **宏观地缘**：内置 `geo-sentinel`（地缘政治 + 宏观新闻预测），服务出海与宏观风险决策
4. **5 镜像实质部署**：Claude / Codex / Antigravity / **OpenClaw 系（WorkBuddy/龙虾）** / 通用 Agent
5. **永久非商业**：PolyForm-NC 保护项目特殊性，配套企业经营 ETHICS 红线

---

## 2. 目标与非目标

### 2.1 目标 (Goals)

- ✅ 面向企业管理人员的 AI 经营副驾驶，覆盖战略 / 预算 / 财务 / 组织 / 谈判 / 法律 / 宏观 / 交付
- ✅ 18 skill 旗舰矩阵（13 复用 + 3 全新财务/战略 + 2 治理借用）
- ✅ `executive-consultant` 作为主调度，路由表补财务/预算/地缘/战略 CFO 四条新分支
- ✅ 5 镜像部署，OpenClaw 系（WorkBuddy/龙虾）实质支持
- ✅ 治理三件套（loop-engineer / skill-deploy / skill-governor）支持自进化
- ✅ 一键部署脚本 + 通用 Agent 一句话部署 prompt
- ✅ PolyForm-NC license + 企业经营 ETHICS
- ✅ Forge 风格的营销向 README + 国产 API 配置文档

### 2.2 非目标 (Non-Goals)

- ❌ 不替代律师 / 会计师 / 审计师 / 税务师的专业意见（ETHICS 明确）
- ❌ 不做实时交易 / 量化交易系统（那是 ai4s-quant / market-alpha-orchestrator 的领域）
- ❌ 不做通用 ERP / 财务软件（是 skill 包，不是产品）
- ❌ 不做 SaaS 平台（部署到用户自己的 Agent 环境）
- ❌ 第一版不做 `skill-reviewer`（留作 v1.1）
- ❌ 不设立开源转换机制（PolyForm-NC 永久非商业）

---

## 3. 完整 Skill 矩阵（18 skill）

### 3.1 板块与清单

| 板块 | # | Skill | 来源 | 用途 |
|---|---|---|---|---|
| 🧭 **战略决策** | 1 | `executive-consultant` | ✅ enterprise-use | **主调度** · 6 大模块（战略/组织/跨文化/变革/人际/绩效）+ 参谋长增强 + 快反模式 |
| | 2 | `strategy-cfo` | 🆕 新建 | 商业战略 + 财商融合决策（资本结构 / 资源配置 / 估值视角 / 投资决策） |
| | 3 | `geo-sentinel` | 🔄 池子 | 地缘政治 + 宏观新闻预测（F-G+ 约束，预测战争/选举/政策/制裁/出海风险） |
| | 4 | `deep-research` | ✅ enterprise-use | 多 Agent 并行深度调研（引用管理 / 量化验证 / 稳定交付） |
| 💰 **财务预算** | 5 | `finance-manager` | 🆕 新建 | 三大报表分析 / 财务比率（偿债·盈利·营运·成长）/ 杜邦分解 / DCF 估值 / 现金流预警 |
| | 6 | `budget-architect` | 🆕 新建 | 年度预算编制（自上而下·自下而上）/ 零基预算 / 滚动预测 / 差异分析与预警 |
| | 7 | `ecommerce-finance` | 🔄 池子 | 财务补充（电商背景，去电商化复用通用财务模块） |
| 🏛️ **组织治理** | 8 | `executive-secretary` | ✅ enterprise-use | 高级行政秘书 + 高德地图 MCP（日程 / 多地行程 / 通勤估算） |
| | 9 | `external-negotiation-master` | ✅ enterprise-use | 对外谈判大师 / 超级说客（话术 / 砍价 / 催款 / BATNA） |
| | 10 | `global-legal-counsel` | ✅ enterprise-use | 全球法律顾问 / 总法律顾问（合规 / 合同 / 诉讼 / 调查 / 追偿） |
| 📦 **交付展示** | 11 | `office-docs` | ✅ enterprise-use | PPTX / DOCX / XLSX 读写编辑与校验（含 ISO-IEC29500 schema 工具链） |
| | 12 | `editing` | ✅ enterprise-use | PPT 模板编辑（以现有 PPTX 为模板替换内容） |
| | 13 | `pptxgenjs` | ✅ enterprise-use | 代码生成全新 PPTX（PptxGenJS） |
| | 14 | `frontend-slides` | 🔄 池子 | 零依赖炫酷 HTML 演示文稿（投资人路演 / 董事会汇报利器） |
| | 15 | `pdf-reader` | ✅ enterprise-use | 本地 PDF → Markdown 提取前处理 |
| 🔧 **治理引擎** | 16 | `loop-engineer` | 🔄 池子 | 多 skill package 联动设计与编排审计 |
| | 17 | `skill-deploy` | 📥 借用 Forge | 三镜像（扩展为五镜像）融合部署 + 后平滑路由一致性 |
| | 18 | `skill-governor` | 📥 借用 Forge | 单 skill 开发流程 + 质量门控（三镜像同步规范） |

### 3.2 来源汇总

| 来源 | 数量 | 说明 |
|---|---|---|
| ✅ enterprise-use 已有 | 9 | 直接迁移复用 |
| 🔄 池子复用 | 4 | geo-sentinel / frontend-slides / ecommerce-finance / loop-engineer |
| 🆕 全新设计 | 3 | finance-manager / budget-architect / strategy-cfo（**核心增量**） |
| 📥 借用 Forge 系列 | 2 | skill-deploy / skill-governor（适配五镜像） |
| **合计** | **18** | |

---

## 4. 主调度路由架构

### 4.1 主调度选型

**复用 `executive-consultant` 作为主调度**。理由：
- 它已是 enterprise-use 的成熟主调度（6 大模块 + 参谋长增强 + 快反 + 20 个 references）
- 自带「Package 主调度协议」路由表，为扩展而设计
- 避免重复造轮子，最快成型

### 4.2 路由表（扩展版）

在 executive-consultant 现有路由表基础上**新增 4 条分支**：

| 用户意图关键词 | 路由目标 | 状态 |
|---|---|---|
| 财务、报表、比率、现金流、DCF、估值、财务健康 | → `finance-manager` | 🆕 新增 |
| 预算、预测、零基、滚动、差异分析、预算编制 | → `budget-architect` | 🆕 新增 |
| 商业模式、战略方向、资本结构、投资决策、资源配置 | → `strategy-cfo` | 🆕 新增 |
| 地缘、宏观、政策、战争、选举、制裁、出海风险、汇率 | → `geo-sentinel` | 🆕 新增 |
| 谈判 / 话术 / 砍价 / 报价 / 催款 / 推进合作 | → `external-negotiation-master` | 已有 |
| 合同 / 起诉 / 合规 / 仲裁 / 法务 / 调查 | → `global-legal-counsel` | 已有 |
| 日程 / 会议安排 / 行程 / 路线 | → `executive-secretary` | 已有 |
| PPT / Word / Excel / 文档 / 排版 | → `office-docs` | 已有 |
| 编辑 PPT / 模板替换 | → `editing` | 已有 |
| 生成 PPT / 代码创建演示 | → `pptxgenjs` | 已有 |
| 路演 / 炫酷演示 / HTML 演示 / 投资人汇报 | → `frontend-slides` | 已有 |
| PDF / 阅读 / 提取 | → `pdf-reader` | 已有 |
| 调研 / 行业报告 / 深度分析 / 信息搜索 | → `deep-research` | 已有 |
| 管理 / 组织 / 人事 / 绩效 / 战略 / 领导力 / 变革 | **（自身处理）** | 默认主场景 |

### 4.3 调度四原则

1. **先诊断再路由**：1-2 句确认用户真实意图后再建议切换
2. **可组合调用**：复杂场景多 skill 协作（如"先战略诊断 → 再财务建模 → 最后路演 PPT"）
3. **回流机制**：子 skill 完成后回到 executive-consultant 全局复盘
4. **不阻断**：用户坚持在本 skill 处理非核心场景，仍尽力回答 + 标注"建议用 /xxx"

---

## 5. 治理三件套

| Skill | 来源 | 职责 |
|---|---|---|
| `loop-engineer` | 🔄 池子 | 多 skill 联动 package 设计 / 联动完整性审计（格式合规 + 主调度逻辑 + 入口文档同步 + 命名一致性） |
| `skill-deploy` | 📥 借用 Forge | 五镜像融合部署 + **后平滑**（路由双向一致性检查） |
| `skill-governor` | 📥 借用 Forge | 单 skill 新增/升级流程 + 质量门控（五镜像接入点更新） |

**自进化闭环**：Agent 可通过 skill-governor 优化某 skill → 五镜像同步 → fork → 提 PR（参考 Forge 系列 CONTRIBUTING Path C）。

---

## 6. 多镜像部署架构（5 镜像，全部实质支持）

| 镜像平台 | 目录结构 | Skill 格式 | 入口文档 | 第一版状态 |
|---|---|---|---|---|
| **Claude Code** | `.claude/commands/*.md` + `.claude/skills/*/` | commands.md + SKILL.md | `CLAUDE.md` | ✅ 完整 |
| **Codex CLI** | `.codex/skills/*/` | SKILL.md + agents/openai.yaml | `AGENTS.md` | ✅ 完整 |
| **Antigravity**（原 Gemini） | `.gemini/skills/*/` | SKILL.md | `GEMINI.md` | ⚠️ 先按 Gemini 格式，后续按 Antigravity 差异优化 |
| **OpenClaw / WorkBuddy / 龙虾** | `.agents/skills/*/` | SKILL.md（与 Claude 兼容） | `OPENCLAW.md` | ✅ 实质支持 |
| **通用 Agent 一句话部署** | — | 贴部署 prompt | README | ✅ |

### 6.1 OpenClaw 系兼容性说明

调研确认：WorkBuddy（腾讯版小龙虾）与龙虾（OpenClaw 社区昵称）**完全兼容 OpenClaw 技能生态**：
- Skill 格式 = 含 `SKILL.md` 的文件夹（与 Claude Code 一致）
- 发现路径：`.agents/skills/`（项目级）→ `skills/`（工作区）→ `~/.openclaw/skills/`（全局）
- 因此实质支持仅需新增 `.agents/skills/` 镜像目录，SKILL.md 可直接复用 Claude 版

### 6.2 跨平台一致性保证

每个镜像的 `executive-consultant` 都内置**相同的 Package 主调度路由表**，由 `skill-deploy` 后平滑校验。

---

## 7. 仓库结构

```
HelmForge/
├── .claude/                    # Claude Code 镜像
│   ├── commands/               # 18 个 slash command（含主调度 executive-consultant）
│   ├── skills/                 # 18 个 skill 目录（SKILL.md + references + scripts）
│   └── scripts/                # office-docs 等的 Python 脚本工具链
├── .codex/                     # Codex CLI 镜像
│   └── skills/
├── .gemini/                    # Antigravity 镜像（先按 Gemini 格式）
│   └── skills/
├── .agents/                    # OpenClaw/WorkBuddy/龙虾 镜像
│   └── skills/
├── CLAUDE.md                   # Claude Code 入口
├── AGENTS.md                   # Codex 入口
├── GEMINI.md                   # Antigravity/Gemini 入口
├── OPENCLAW.md                 # OpenClaw 系入口
├── LICENSE                     # PolyForm Noncommercial 1.0.0
├── ETHICS.md                   # 企业经营伦理附加
├── README.md                   # 主文档（Forge 风格营销向）
├── CONTRIBUTING.md             # 贡献指南（含 Agent 自进化提 PR 流程）
├── deploy/
│   ├── deploy.ps1              # Windows 一键部署
│   ├── deploy.sh               # macOS/Linux 一键部署
│   └── mcp-config.template.json
├── docs/
│   ├── cn-api-providers.md     # 国产 API 配置（GLM/DeepSeek/Kimi/MiMo/硅基流动）
│   └── superpowers/specs/      # design doc 存放（本文件在此）
├── assets/                     # logo / banner / 截图
└── scripts/                    # 仓库级脚本（如迁移/同步工具）
```

---

## 8. License & ETHICS

### 8.1 License: PolyForm Noncommercial 1.0.0

- ✅ 非商业使用 / 修改 / 分发：**永久免费**（个人 / 教育 / 科研 / 非营利 / 内部测试）
- ✅ 源码可见（source available）
- ❌ 未授权商业使用：**禁止**（含 SaaS / 付费服务 / 企业生产部署 / 嵌入商业产品）
- 🚫 **无 Change Date**（永久非商业，不转开源 —— 项目特殊性）
- 📝 商业授权：另行书面协议

### 8.2 ETHICS.md（企业经营版红线）

Forge 系列 ETHICS 均为行业特化（CodeForge 禁恶意代码，VitaForge 禁基因歧视）。HelmForge 企业经营版：

| 红线 | 说明 |
|---|---|
| 🚫 反商业贿赂 | 禁止用于设计/执行贿赂、回扣、利益输送、政商灰色操作 |
| 🚫 反财务欺诈 | 禁止财务造假、虚假陈述、报表操纵、粉饰业绩 |
| 🚫 反垄断 | 禁止用于价格操纵、市场瓜分、串通投标等反竞争行为 |
| 🚫 反洗钱 | 禁止用于洗钱、资金通道设计、规避外汇管制 |
| 🔒 数据隐私 | 处理企业/客户/员工敏感数据须脱敏，遵守数据跨境合规 |
| ⚖️ 合规边界 | 不替代律师/会计师/审计师/税务师专业意见，重大决策须人类复核 |
| 🤝 人在回路 | 重大经营决策（投资/裁员/并购/披露）必须人类最终拍板，AI 仅参谋 |
| 🌱 ESG 鼓励 | 鼓励负责任、可持续的经营决策，反对短视逐利 |

---

## 9. 开发路线（5 Phase）

| Phase | 内容 | 关键产出 | 工作量 |
|---|---|---|---|
| **P1 骨架品牌** | 仓库结构 + README + LICENSE + ETHICS + 4 入口文档 + deploy 脚本骨架 + 本 design doc | 可见的空项目骨架 | ⭐⭐ |
| **P2 迁移复用** | 13 个已有 skill（9 enterprise-use + 4 池子）→ 五镜像 + executive-consultant 路由表更新 | 13 skill × 5 镜像就位 | ⭐⭐⭐ |
| **P3 新建核心** | 🆕 finance-manager + budget-architect + strategy-cfo（含 references）→ 五镜像 | 3 个全新财务/战略 skill | ⭐⭐⭐⭐⭐ |
| **P4 治理部署** | loop-engineer / skill-deploy / skill-governor 借用适配 + deploy.ps1/sh 完成 + 一键部署测试 + 后平滑验证 | 自进化能力 + 可部署 | ⭐⭐⭐ |
| **P5 开源门面** | CONTRIBUTING + cn-api-providers 文档 + logo/banner + README 营销润色 + 首次 push | 可发布开源项目 | ⭐⭐ |

### 9.1 Phase 依赖

```
P1 (骨架) → P2 (迁移) → P3 (新建) → P4 (治理部署) → P5 (门面)
```
P2 与 P3 可部分并行（不同 skill 互不阻塞），但 P3 依赖 P1 的目录约定。

### 9.2 P3 新建 skill 的设计要点

**finance-manager**（财务管理）：
- references：财务比率体系、杜邦分解模板、DCF 估值模型、现金流预警阈值、三大报表联动、行业基准
- 输出合同：财务健康一句话判断 + 关键比率表 + 风险点 + 改善建议
- 边界：不替代审计，重大结论标注"需会计师复核"

**budget-architect**（预算制定）：
- references：预算编制方法（增量/零基/滚动/作业）、差异分析模板、预测模型、部门预算协同
- 输出合同：预算编制方案 + 自上而下/自下而上对账 + 滚动预测表 + 差异预警机制
- 边界：依赖输入数据质量，缺数据时明确标注假设

**strategy-cfo**（商业战略 + 财商）：
- references：商业模式画布、资本结构决策、投资决策框架（NPV/IRR/回收期）、资源配置矩阵、估值视角
- 与 executive-consultant 战略模块的区别：executive-consultant 偏**管理与组织**视角，strategy-cfo 偏**商业与财务**视角（资本/估值/投资回报）
- 输出合同：战略选项 + 财务可行性 + 资本结构建议 + 投资回报测算

---

## 10. 成功标准 / 验收

### 10.1 功能验收

- [ ] 18 skill 全部存在且五镜像同步（格式合规）
- [ ] executive-consultant 主调度路由表含 4 条新分支，跨五镜像一致
- [ ] 3 个新建 skill（finance/budget/strategy-cfo）有完整 SKILL.md + references
- [ ] deploy.ps1 / deploy.sh 在 Windows + macOS/Linux 各跑通一次
- [ ] 通用 Agent 一句话部署 prompt 可被任意 agent 执行成功
- [ ] skill-deploy 后平滑校验通过（路由双向一致）

### 10.2 工程验收

- [ ] LICENSE = PolyForm Noncommercial 1.0.0 全文
- [ ] ETHICS.md 含 8 条企业经营红线
- [ ] README 含 Forge 三部曲叙事 + 技能矩阵表 + 一键部署 + 国产 API 说明
- [ ] 4 个入口文档（CLAUDE/AGENTS/GEMINI/OPENCLAW.md）同步
- [ ] CONTRIBUTING 含 Agent 自进化提 PR 流程

### 10.3 质量验收

- [ ] 首次 commit + push 到 main 成功
- [ ] GitHub 仓库 description / topics 已设置
- [ ] 仓库可在 Codespace 中 clone + deploy 跑通

---

## 11. 风险与缓解

| 风险 | 影响 | 缓解 |
|---|---|---|
| OpenClaw 系镜像格式细节与 Claude 不完全一致 | 部署到 WorkBuddy/龙虾时路由失效 | P4 部署测试时实际跑通；保留 `.agents/skills/` 与 `.claude/skills/` 内容一致，差异点在 OPENCLAW.md 注明 |
| Antigravity 与 Gemini 格式差异未知 | Antigravity 镜像可能失效 | 第一版按 Gemini 格式占位，文档标注"待 Antigravity 确认后优化"；README 说明 |
| 3 个新建财务 skill 质量参差 | 核心增量价值不足 | P3 每个 skill 写完整 references + 输出合同 + 边界声明；参考 ai4s-quant 方法论的严谨度 |
| PolyForm-NC 边界模糊（何为"商业"） | 用户误用 / 维护者争议 | ETHICS.md 明确商业定义 + 授权流程；README FAQ 说明 |
| 治理三件套从 Forge 借用的版权/依赖 | 借用合规问题 | skill-deploy / skill-governor 是技能 prompt（非代码），按 PolyForm-NC 在 HelmForge 内重写适配，不直接复制 Forge 代码 |

---

## 12. 后续步骤

本 spec 获主人审核通过后：
1. 浮浮酱 invoke `writing-plans` skill，据此 spec 拆分为可执行的实现计划
2. 实现计划获批后，按 P1→P5 顺序执行
3. 每个 Phase 完成后验证，再进入下一 Phase

---

_Design by 浮浮酱（HelmForge brainstorming session, 2026-07-04）_
