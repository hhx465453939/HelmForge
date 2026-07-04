---
description: 启动 Loop Engineer — 从需求出发设计并开发完整的多 skill 联动 package（扫描资产 → Gap分析 → 逐一开发 → 组包 → 平滑层）
---

# /loop-engineer

启动 Loop 系统工程师，执行需求驱动的 skill package 开发全流程。

## 使用场景

- 需要设计一个完整的多 skill 联动系统时
- 需要从零到一开发一个功能性 loop 包时
- 需要将现有 skill 重组为一个可部署的 package 时

## 入口

读取并执行 `.claude/skills/loop-engineer/SKILL.md`

## 参数

`$ARGUMENTS` — 用户的需求描述（自然语言）

## 示例

```
/loop-engineer 我需要一个全自动量化交易系统，包括实时市场监控、策略回测、机器学习建模、自动下单、复盘优化
```

```
/loop-engineer 设计一个学术论文全流程 loop，从选题到投稿
```

## 不可妥协的规则

1. 必须先盘点现有资产，不做重复开发
2. 每个新 skill 必须三镜像同步（Claude/Codex/Gemini）
3. 必须有用户确认的 Gate 点
4. 最终交付必须包含主调度 skill + 平滑层
