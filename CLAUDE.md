# CLAUDE.md - HelmForge

> **⚓ Forge your enterprise. Take the helm.**
>
> 企业掌舵者的 AI 经营驾驶舱。一个入口路由 18 个专业 skill。

## 主调度入口

- `/executive-consultant` — **企业经营主调度**（推荐首选入口）。描述你的经营场景，自动分诊路由到对应子 skill（战略 / 财务 / 组织 / 文档 / 治理）。

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
| 📦 交付展示 | `/office-docs` | PPTX / DOCX / XLSX 读写 |
| | `/editing` | PPT 模板编辑 |
| | `/pptxgenjs` | 代码生成 PPT |
| | `/frontend-slides` | 零依赖炫酷 HTML 演示 |
| | `/pdf-reader` | PDF → Markdown |
| 🔧 治理引擎 | `/loop-engineer` | 多 skill package 编排 |
| | `/skill-deploy` | 五镜像融合部署 |
| | `/skill-governor` | skill 开发质量门控 |

## 主调度分诊路由

`/executive-consultant` 收到自然语言描述后，按以下分支自动路由：

| 触发关键词 | 路由分支 | 典型 skill 链 |
|---|---|---|
| 战略 / 商业模式 / 转型 / 增长路径 | 战略决策 | `strategy-cfo` → `geo-sentinel` → `deep-research` |
| 财务 / 报表 / 预算 / 现金流 / DCF | 财务预算 | `finance-manager` → `budget-architect` → `ecommerce-finance` |
| 日程 / 谈判 / 法务 / 合规 | 组织治理 | `executive-secretary` / `external-negotiation-master` / `global-legal-counsel` |
| 路演 / 报告 / PPT / 文档 / 提案 | 交付展示 | `office-docs` / `editing` / `pptxgenjs` / `frontend-slides` / `pdf-reader` |
| 包治理 / 部署 / 质量门控 | 治理引擎 | `loop-engineer` / `skill-deploy` / `skill-governor` |

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

1. 将本仓库 `.claude/` 合并到目标项目根目录（或用 `deploy/deploy.ps1`，Task 17 提供）
2. 重启 Claude Code 会话
3. 不确定用哪个命令时，先用 `/executive-consultant`

## License & Ethics

License: **PolyForm Noncommercial 1.0.0** — 详见 [LICENSE](./LICENSE) 与 [ETHICS.md](./ETHICS.md)。

- ✅ 非商业使用 / 修改 / 分发（个人 / 教育 / 科研 / 非营利 / 内部测试）永久免费
- ❌ 未授权商业使用禁止（含 SaaS / 付费服务 / 企业生产部署 / 嵌入商业产品）
- 🤝 重大经营决策须人类最终拍板（详见 ETHICS.md §2 红线 7 人在回路）
