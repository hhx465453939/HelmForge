---
description: HelmForge skill 开发规范执行官 — 新增/修改/废弃 skill 的规范流程 + 4 镜像同步 + 入口文档 delta + ETHICS check
---

# /skill-governor

启动 HelmForge 的 **skill-governor** skill，作为 skill 开发规范执行官指导本次改动。

## 使用场景

- 新增一个 skill（从 0 到 1）
- 修改现有 skill（正文 / references / 路由 / version）
- 废弃某个过时 skill
- `skill-deploy` 后平滑报告出现 `[ROUTE-MISMATCH]` / `[MISSING-SKILL]` / `[MIRROR-GAP]` / `[VERSION-DRIFT]`，需要回来修
- 从 CodeForge / VitaForge 借用一个 skill，做 PolyForm-NC 合规改写

## 入口

读取并执行 `.claude/skills/skill-governor/SKILL.md`。

## 参数

`$ARGUMENTS` — 可选，控制运行意图：

- 空 — 进入交互模式，先问用户"你要新增 / 修改 / 废弃 哪个 skill"
- `new <skill-name>` — 走 8 步新增流程
- `edit <skill-name>` — 走 Diff-First 修改流程
- `deprecate <skill-name>` — 走废弃流程
- `sync-mirror <skill-name>` — 修 `[MIRROR-GAP]` / `[ROUTE-MISMATCH]`，把 `.claude` 扇出到其他 3 镜像
- `sync-entry-docs` — 修 `[MISSING-SKILL]` / `[UNLISTED-SKILL]`，用实际 skill 集合重写 4 份入口文档的 SKILL-LIST
- `adapt <upstream>/<skill-name>` — 从外部项目借用并 PolyForm-NC 合规改写
- `checklist` — 只输出 Quality Gate Checklist，不做改动

## 示例

```
/skill-governor
/skill-governor new tax-optimizer
/skill-governor edit executive-consultant
/skill-governor deprecate legacy-forecaster
/skill-governor sync-mirror executive-consultant
/skill-governor sync-entry-docs
/skill-governor adapt CodeForge/git-refactor-planner
/skill-governor checklist
```

## 边界

- **不做部署**。把 skill 从仓库搬到用户宿主环境 → 走 `/skill-deploy`
- **不改用户已部署环境**。改完仓库让用户重新跑 `/skill-deploy` 才生效
- **不代 owner commit**。除非 owner 明确授权，只输出 diff + checklist，让 owner 自己 `git commit`
- **不做多 skill 联动 package 顶层设计**。那是 `/loop-engineer` 的作业面；本命令只负责其中每一个 skill 的规范落地
