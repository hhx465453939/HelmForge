# AGENTS.md - HelmForge (Codex CLI)

> **⚓ Forge your enterprise. Take the helm.**
>
> Codex CLI 镜像入口。18 skill 与 Claude 镜像内容一致，仅触发语法不同。

## 主调度

`$executive-consultant` — 企业经营主调度。描述经营场景后自动路由到对应子 skill。

## Available Skills

<!-- SKILL-LIST-START -->
- `$executive-consultant` — 主调度 · 高管咨询 / 参谋长增强（战略决策板块）
- `$strategy-cfo` — 商业战略 + 财商融合（战略决策板块）
- `$geo-sentinel` — 地缘宏观预测（战略决策板块）
- `$deep-research` — 多 Agent 深度调研（战略决策板块）
- `$finance-manager` — 三大报表 / 比率 / DCF / 现金流预警（财务预算板块）
- `$budget-architect` — 年度预算 / 零基 / 滚动 / 差异分析（财务预算板块）
- `$ecommerce-finance` — 电商财务补充（财务预算板块）
- `$executive-secretary` — 高级行政秘书 / 高德地图 MCP（组织治理板块）
- `$external-negotiation-master` — 对外谈判大师 / 超级说客（组织治理板块）
- `$global-legal-counsel` — 全球法律顾问 / 总法律顾问（组织治理板块）
- `$office-docs` — PPTX / DOCX / XLSX 读写（交付展示板块）
- `$editing` — PPT 模板编辑（交付展示板块）
- `$pptxgenjs` — 代码生成 PPT（交付展示板块）
- `$frontend-slides` — 零依赖炫酷 HTML 演示（交付展示板块）
- `$pdf-reader` — PDF → Markdown（交付展示板块）
- `$loop-engineer` — 多 skill package 编排（治理引擎板块）
- `$skill-deploy` — 五镜像融合部署（治理引擎板块）
- `$skill-governor` — skill 开发质量门控（治理引擎板块）
<!-- SKILL-LIST-END -->

## 主调度分诊路由

`$executive-consultant` 收到自然语言描述后，按以下分支自动路由：

| 触发关键词 | 路由分支 | 典型 skill 链 |
|---|---|---|
| 战略 / 商业模式 / 转型 / 增长路径 | 战略决策 | `strategy-cfo` → `geo-sentinel` → `deep-research` |
| 财务 / 报表 / 预算 / 现金流 / DCF | 财务预算 | `finance-manager` → `budget-architect` → `ecommerce-finance` |
| 日程 / 谈判 / 法务 / 合规 | 组织治理 | `executive-secretary` / `external-negotiation-master` / `global-legal-counsel` |
| 路演 / 报告 / PPT / 文档 / 提案 | 交付展示 | `office-docs` / `editing` / `pptxgenjs` / `frontend-slides` / `pdf-reader` |
| 包治理 / 部署 / 质量门控 | 治理引擎 | `loop-engineer` / `skill-deploy` / `skill-governor` |

## 典型联动链路

```
$executive-consultant 经营诊断
  → $strategy-cfo 商业战略 + 财务可行性
  → $finance-manager 财务建模
  → $budget-architect 预算编制
  → $geo-sentinel 宏观风险
  → $frontend-slides 投资人路演 PPT
```

## 安装

1. 将本仓库 `.codex/` 合并到目标项目根目录（或用 `deploy/deploy.ps1`，Task 17 提供）
2. 在 Codex CLI 中以 `$skill-name` 形式触发（例如 `$executive-consultant`）
3. 不确定用哪个 skill 时，先用 `$executive-consultant`

## License & Ethics

License: **PolyForm Noncommercial 1.0.0** — 详见 [LICENSE](./LICENSE) 与 [ETHICS.md](./ETHICS.md)。

- ✅ 非商业使用 / 修改 / 分发（个人 / 教育 / 科研 / 非营利 / 内部测试）永久免费
- ❌ 未授权商业使用禁止（含 SaaS / 付费服务 / 企业生产部署 / 嵌入商业产品）
- 🤝 重大经营决策须人类最终拍板（详见 ETHICS.md §2 红线 7 人在回路）
