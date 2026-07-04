# OPENCLAW.md - HelmForge (OpenClaw / WorkBuddy / 龙虾)

> **⚓ Forge your enterprise. Take the helm.**
>
> 企业掌舵者的 AI 经营驾驶舱。一个入口路由 18 个专业 skill。
>
> _本入口适用于 OpenClaw 生态智能体：腾讯 WorkBuddy、社区龙虾（OpenClaw）、以及一切兼容 OpenClaw 技能标准的宿主。_

## 主调度入口

`executive-consultant` — **企业经营主调度**。描述你的经营场景后自动分诊路由到对应子 skill（战略 / 财务 / 组织 / 文档 / 治理）。

## 技能发现路径（OpenClaw 优先级）

| 优先级 | 路径 | 说明 |
|---|---|---|
| 1 | `.agents/skills/` | 项目级技能（跟随仓库） |
| 2 | `skills/` | 工作区级 |
| 3 | `~/.openclaw/skills/` 或 `~/.workbuddy/skills/` | 用户全局 |

本仓库 `.agents/skills/` 含全部 **18 个 skill**，与 Claude 镜像内容一致（SKILL.md 兼容 OpenClaw 技能规范）。

## 技能命令一览（18 skill）

| 板块 | Skill | 定位 |
|------|------|------|
| 🧭 战略决策 | `executive-consultant` | 主调度 — 高管咨询 / 参谋长增强 |
| | `strategy-cfo` | 商业战略 + 财商融合 |
| | `geo-sentinel` | 地缘宏观预测 |
| | `deep-research` | 多 Agent 深度调研 |
| 💰 财务预算 | `finance-manager` | 三大报表 / 比率 / DCF / 现金流预警 |
| | `budget-architect` | 年度预算 / 零基 / 滚动 / 差异分析 |
| | `ecommerce-finance` | 电商财务补充 |
| 🏛️ 组织治理 | `executive-secretary` | 高级行政秘书（高德地图 MCP） |
| | `external-negotiation-master` | 对外谈判大师 |
| | `global-legal-counsel` | 全球法律顾问 |
| 📦 交付展示 | `office-docs` | PPTX / DOCX / XLSX 读写 |
| | `editing` | PPT 模板编辑 |
| | `pptxgenjs` | 代码生成 PPT |
| | `frontend-slides` | 零依赖炫酷 HTML 演示 |
| | `pdf-reader` | PDF → Markdown |
| 🔧 治理引擎 | `loop-engineer` | 多 skill package 编排 |
| | `skill-deploy` | 五镜像融合部署 |
| | `skill-governor` | skill 开发质量门控 |

## 主调度分诊路由

`executive-consultant` 收到自然语言描述后，按以下分支自动路由：

| 触发关键词 | 路由分支 | 典型 skill 链 |
|---|---|---|
| 战略 / 商业模式 / 转型 / 增长路径 | 战略决策 | `strategy-cfo` → `geo-sentinel` → `deep-research` |
| 财务 / 报表 / 预算 / 现金流 / DCF | 财务预算 | `finance-manager` → `budget-architect` → `ecommerce-finance` |
| 日程 / 谈判 / 法务 / 合规 | 组织治理 | `executive-secretary` / `external-negotiation-master` / `global-legal-counsel` |
| 路演 / 报告 / PPT / 文档 / 提案 | 交付展示 | `office-docs` / `editing` / `pptxgenjs` / `frontend-slides` / `pdf-reader` |
| 包治理 / 部署 / 质量门控 | 治理引擎 | `loop-engineer` / `skill-deploy` / `skill-governor` |

## 典型联动链路

```
executive-consultant 经营诊断
  → strategy-cfo 商业战略 + 财务可行性
  → finance-manager 财务建模
  → budget-architect 预算编制
  → geo-sentinel 宏观风险
  → frontend-slides 投资人路演 PPT
```

## 安装

三种方式任选：

1. **拖拽安装（WorkBuddy 最简）**：把 `.agents/skills/<skill>/` 目录拖拽到 WorkBuddy 聊天框，自动导入。
2. **命令行安装**：逐个安装到用户全局。
   ```bash
   # WorkBuddy
   workbuddy skill install .agents/skills/executive-consultant
   # OpenClaw
   openclaw skill install .agents/skills/executive-consultant
   ```
3. **复制到全局目录**（跨项目共享）：
   ```bash
   # WorkBuddy
   cp -r .agents/skills/* ~/.workbuddy/skills/
   # OpenClaw
   cp -r .agents/skills/* ~/.openclaw/skills/
   ```

安装完成后重启 WorkBuddy / OpenClaw 即可生效。不确定用哪个 skill 时，先描述场景给 `executive-consultant`。

> Task 17 会提供 `deploy/deploy.sh` 一键部署脚本，自动完成上述步骤。

## 使用方式

1. 部署 `.agents/skills/` 到目标智能体的技能路径（见上）
2. 重启智能体宿主（WorkBuddy / OpenClaw / 龙虾）
3. 描述经营场景后调用主调度：`executive-consultant`

## License & Ethics

License: **PolyForm Noncommercial 1.0.0** — 详见 [LICENSE](./LICENSE) 与 [ETHICS.md](./ETHICS.md)。

- ✅ 非商业使用 / 修改 / 分发（个人 / 教育 / 科研 / 非营利 / 内部测试）永久免费
- ❌ 未授权商业使用禁止（含 SaaS / 付费服务 / 企业生产部署 / 嵌入商业产品）
- 🤝 重大经营决策须人类最终拍板（详见 ETHICS.md §2 红线 7 人在回路）
