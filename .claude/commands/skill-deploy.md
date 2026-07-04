---
description: HelmForge 五镜像融合部署 + 后平滑一致性检查（不改内容，只搬运和对表）
---

# /skill-deploy

启动 HelmForge 的 **skill-deploy** skill，把仓库里的 4 个 skill 镜像 + universal-agent one-shot 一次性部署到用户 Agent 环境，并跑后平滑检查。

## 使用场景

- 第一次把 HelmForge 装到本机（`~/.claude` / `~/.codex` / `~/.gemini` / `~/.agents`）
- 拉了新版 HelmForge 想覆盖旧版
- 只想校验 4 镜像和 AGENTS.md 一致性（`check` 模式）
- 部署完看到有问题，想知道该找谁修（skill-governor）

## 入口

读取并执行 `.claude/skills/skill-deploy/SKILL.md`。

## 参数

`$ARGUMENTS` — 可选，控制运行模式：

- 空 / `deploy` — 默认，跑完整 5 步部署 + 后平滑
- `check` — 只跑后平滑，不搬文件（预演模式）
- `check --strict` — 后平滑任一 FAIL 直接以非 0 退出，用于 CI
- `backup-only` — 只做备份，不覆盖

## 示例

```
/skill-deploy
/skill-deploy check
/skill-deploy check --strict
```

## 边界

- **本命令不改 skill 内容**。发现 4 镜像不一致时，只会给出报告和建议命令，让 `/skill-governor` 或人工来修
- 需要设计一整套多 skill 联动 package → 走 `/loop-engineer`
- 需要新增或升级某个 skill → 走 `/skill-governor`
