---
name: ecommerce-finance
description: 电商财务费用闭环处理专家。将支付宝/微信 CSV 账务明细自动分类、匹配订单、聚合输出多 Sheet Excel 报表，含 8 项闭环校验。支持自适应识别新增费用项，会计人员可通过自然语言扩展功能。触发词：电商财务、店铺账务、支付宝、微信、CSV 账单、订单核账、费用分类、多 Sheet Excel、财务对账。
version: 0.1.0
---

# Ecommerce Finance — 电商财务费用闭环处理专家

## 定位

面向电商店铺（淘宝/天猫/京东/拼多多/抖店等）的**财务费用闭环处理专家**。核心能力：将平台原始 CSV 账单（支付宝/微信为主）自动分类 → 匹配订单 → 聚合校验 → 输出多 Sheet Excel 报表。

## 适用场景

- 电商店铺月度/季度对账（GMV、退款、佣金、推广费、物流、平台服务费等费项归集）
- 支付宝/微信商户账单原始 CSV 自动分类
- 订单流水 × 平台账单 × 财务记账三方对账
- 新增费用项的自适应识别（模式匹配 + 会计科目映射）

## 不适用场景

- 非电商场景的通用财务分析 → 用 `/finance-manager`
- 未来预算/预测 → 用 `/budget-architect`
- 战略层的财务决策 → 用 `/strategy-cfo`
- 全公司集团报表合并 → 需专业审计工具

## 与 finance-manager 的边界

| 维度 | ecommerce-finance | finance-manager |
|---|---|---|
| 视角 | 交易层（CSV → Excel） | 报表层（三表分析） |
| 粒度 | 单笔账务 → 月度汇总 | 整体财务健康 |
| 输入 | 原始账单 CSV | 已编制财务报表 |
| 输出 | 多 Sheet 对账报表 | 比率诊断 + 改善建议 |

## 8 项闭环校验（核心质量门控）

1. **账单总金额 = 分类金额之和**（无遗漏、无重分类）
2. **订单退款金额 = 平台退款账目**（订单侧 vs 账单侧）
3. **佣金账目 = 订单成交额 × 平台费率**（预期费率误差 < 0.1%）
4. **推广费账目分平台归集**（阿里妈妈/巨量千川/京准通独立分类）
5. **物流费 = 快递单量 × 平均单价**（异常单价预警）
6. **税金归集完整**（增值税、附加税、企业所得税分类）
7. **收付款时间戳与账期一致**（延迟收付款流水单独标记）
8. **未识别费用项 < 1%**（超阈值触发自适应扩展流程）

## 核心工作流

参见 `references/` 与 `scripts/`：
- `references/mapping_schema.json`：费用项 → 会计科目映射表（可自适应扩展）
- `scripts/process_alipay.py`：支付宝 CSV 处理主入口
- `scripts/mapping_extractor.py`：新增费用项自适应识别
- `scripts/balance_checker.py`：8 项闭环校验引擎
- `templates/extend_template.md`：会计人员自然语言扩展模板

## 默认输出合同

```
输出文件：<店铺名>_<年月>_财务对账.xlsx

Sheet 1: 汇总（各费项分类汇总 + 校验状态）
Sheet 2: GMV & 退款
Sheet 3: 平台佣金
Sheet 4: 推广费（分平台）
Sheet 5: 物流 & 售后
Sheet 6: 税金
Sheet 7: 未识别流水（需人工确认）
Sheet 8: 8 项校验报告（PASS/WARN/FAIL）

同时输出:
- <文件>_summary.md：会计人员友好的一句话结论 + 关键异常提示
```

## 与 HelmForge 主调度的联动

由 `executive-consultant` 主调度检测到"电商财务、店铺账务、支付宝/微信 CSV、订单核账"关键词时路由过来。处理完成后可接：
- `/finance-manager`：跨月对账数据做财务比率分析
- `/budget-architect`：基于历史对账数据做预算滚动预测
- `/office-docs`：Excel 输出深度加工

## 边界与升级

- **不做真实会计凭证记账**：仅生成对账工作底稿，凭证录入需在正式财务系统操作
- **税务口径需专业审核**：涉及税务申报的科目建议注册会计师复核
- **平台费率变更需更新映射表**：新政策发布后 `references/mapping_schema.json` 需人工更新版本

## 相关 references / scripts / templates

- `references/mapping_schema.json`
- `scripts/process_alipay.py`
- `scripts/mapping_extractor.py`
- `scripts/balance_checker.py`
- `templates/extend_template.md`
