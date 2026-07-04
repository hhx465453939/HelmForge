# HelmForge 部署指南 — 差异化选择

> 一句话：**部署 HelmForge 之前，请先判断你的 Agent 宿主属于哪一类**。不同宿主用不同镜像，别 `--yes` 一把梭把不需要的都装了。

本文档 **同时是给人看的选择指南，也是给 Agent 看的自检脚本**。文末有 [Agent 自检 Prompt](#-agent-自检-prompt) 可以直接贴给智能体让它自己判断。

---

## 📦 5 种部署形态一览

| 形态 | 目标宿主 | 是否需要克隆仓库 | 用什么部署 |
|---|---|---|---|
| **A. 本地 CLI — Claude Code** | Anthropic 官方 CLI | ✅ 需要 | `--only claude` |
| **B. 本地 CLI — Codex CLI** | OpenAI 官方 CLI | ✅ 需要 | `--only codex` |
| **C. 本地 CLI — Antigravity / Gemini CLI** | Google 系 | ✅ 需要 | `--only gemini` |
| **D. 桌面 Agent — WorkBuddy / OpenClaw / 龙虾** | 腾讯 WorkBuddy · OpenClaw 社区版 · 傅盛系"小龙虾" | ✅ 需要 | `--only agents`（等价：`--only workbuddy`） |
| **E. 在线 Agent — GPT / 豆包 / Claude.ai / 元宝 / Kimi Web** | 浏览器里的对话式 AI | ❌ 无需本地 | 见 [E. 在线 Agent 玩法](#-e-在线-agent-玩法) |

---

## 🎯 决策树 — 3 秒选出方案

```
你怎么用 AI?
├─ 本地终端 / IDE 里跑                     → 走 A / B / C（挑你实际用的那一款）
├─ 装了 WorkBuddy 或 OpenClaw 桌面工具       → 走 D
├─ 浏览器 chat.openai.com / doubao.com     → 走 E（打包上传方案）
└─ 混合（比如白天 Claude Code + 手机豆包）    → A + E 组合
```

**核心原则**：只装你实际会用的那一套。装多了不会互相干扰，但会占硬盘、污染 backup、拉长 post-smoothing check。

---

## 🅰️ A. 本地 CLI — Claude Code 独立部署

**适用**：你已经在用 `claude` CLI（Anthropic 官方 / 智谱 GLM 反代 / 硅基流动等 Anthropic 兼容端点）。

```bash
git clone https://github.com/hhx465453939/HelmForge.git
cd HelmForge

# macOS / Linux / WSL / Git Bash
bash ./deploy/deploy.sh --yes --only claude

# Windows PowerShell
powershell -ExecutionPolicy Bypass -File .\deploy\deploy.ps1 -Yes -Only claude
```

**部署到**：`~/.claude/commands/` + `~/.claude/skills/` + `~/.claude/scripts/`

**验证**：重启 `claude` 后输入 `/` 应看到 `/executive-consultant`、`/finance-manager` 等 16 个命令。

---

## 🅱️ B. 本地 CLI — Codex CLI 独立部署

**适用**：你在用 `codex` OpenAI 官方 CLI。

```bash
bash ./deploy/deploy.sh --yes --only codex        # 或 PowerShell -Only codex
```

**部署到**：`~/.codex/skills/`

**验证**：`codex` 会话中提到"帮我做财务分析"等触发词，应自动调用 `$finance-manager`。

---

## 🅲 C. 本地 CLI — Antigravity / Gemini CLI 独立部署

**适用**：你在用 Google 系（Gemini CLI 或未来的 Antigravity）。

```bash
bash ./deploy/deploy.sh --yes --only gemini       # 或 --only antigravity（别名）
```

**部署到**：`~/.gemini/skills/`

> ⚠️ **状态**：`.gemini/skills/` 内容按 Gemini CLI 格式撰写。Antigravity 正式规范发布后可能会做小幅适配。当前可正常加载。

---

## 🅳 D. 桌面 Agent — WorkBuddy / OpenClaw / 龙虾 独立部署

**适用**：
- 腾讯 **WorkBuddy**（OpenClaw 开箱即用版）
- 社区版 **OpenClaw**
- 傅盛系"小龙虾" Agent
- 一切遵循 OpenClaw 技能标准的宿主

```bash
bash ./deploy/deploy.sh --yes --only agents       # 或 --only workbuddy / --only openclaw
```

**部署到**：`~/.agents/skills/`（等 WorkBuddy / OpenClaw 自动扫描的目录）

**手动安装（如自动扫描不到）**：
- 拖拽 `.agents/skills/executive-consultant/` 到 WorkBuddy 聊天框
- 或复制到 `~/.workbuddy/skills/` / `~/.openclaw/skills/` 全局共享目录
- 或用命令 `workbuddy skill install .agents/skills/<skill-name>` 逐个安装

**验证**：WorkBuddy 内输入"帮我诊断公司财务健康"，应触发 `finance-manager` skill 并按财务健康输出合同回复。

---

## 🌐 E. 在线 Agent 玩法 — GPT / 豆包 / Claude.ai / 元宝 / Kimi Web

**适用**：你不装本地 CLI，只在浏览器里用 chat.openai.com、doubao.com、claude.ai、yuanbao.tencent.com、kimi.moonshot.cn 等。

这种情况下你没有"部署到磁盘"这个概念，改走**内容注入**：

### E-1. Custom GPT / Claude Projects / 豆包智能体 / 元宝助手 玩法

各家在线平台都支持"上传知识库"，把 HelmForge 的 skill 内容作为知识库：

```bash
# 打包某一个 skill（比如财务管家）成压缩包
cd HelmForge
tar -czf finance-manager.tar.gz \
  .claude/skills/finance-manager/SKILL.md \
  .claude/skills/finance-manager/references/

# 或整包（谨慎：可能超上传限制，各平台 20~200MB 不等）
tar -czf HelmForge-skills.tar.gz .claude/skills/ .claude/commands/
```

**上传步骤**（以 ChatGPT Custom GPT 为例，其他平台类推）：
1. Custom GPT 设置 → Knowledge → 上传 `finance-manager.tar.gz`（或解压后的单个 `SKILL.md` + `references/*.md`）
2. Instructions 里粘贴：
   ```
   你是 HelmForge 的 finance-manager skill。严格遵循知识库中 SKILL.md 定义的
   身份、工作原则、默认输出合同。用户提问时先检索 references/ 匹配子领域，
   给出「财务健康一句话判断 + 关键比率表 + 风险点 + 改善建议」结构化输出。
   ```
3. 保存 → 现在这个 Custom GPT 就是「HelmForge 财务管家在线版」。

### E-2. 单会话临时注入玩法（无需保存 GPT）

在豆包 / Claude.ai / 元宝的普通对话里，第一条消息直接贴：

```
【接下来的对话中，请扮演 HelmForge finance-manager skill。以下是你的完整 SKILL.md：】

<粘贴 .claude/skills/finance-manager/SKILL.md 全文，约 200 行>

【规则】：
- 严格按 SKILL.md 的「默认输出合同」结构输出
- 触发词命中就路由到对应模块
- 不确定时问澄清问题，不编造数据
```

⚠️ 单会话方式**上下文占用大**，只推荐用于短时任务。长期用还是 E-1。

### E-3. 主调度在线版（executive-consultant → 各子 skill）

如果想让在线 Agent 具备完整"驾驶舱"体验：

1. 上传整个 `.claude/skills/` 目录到知识库
2. 上传 `CLAUDE.md`（或 `AGENTS.md`）作为主入口
3. Instructions 用：
   ```
   你是 HelmForge executive-consultant 主调度。用户描述经营场景后，
   按 executive-consultant/SKILL.md 的「Package 主调度协议 → 路由逻辑」
   分诊，加载对应子 skill 的 SKILL.md + references 回答。
   涉及财务/预算/战略深度问题时严格调用 finance-manager / budget-architect / strategy-cfo 的输出合同。
   ```

---

## 🔀 混合部署 — 全量 + 精选

如果你既有本地 Claude Code、也想在 WorkBuddy 里用，还想在 ChatGPT 里搞个 Custom GPT：

```bash
# 本地一次装 Claude + WorkBuddy 两个宿主
bash ./deploy/deploy.sh --yes --only claude,agents

# 然后另外打包给 ChatGPT
tar -czf HelmForge-online.tar.gz .claude/skills/ .claude/commands/
```

---

## 🔁 全量部署（默认，装 4 个本地镜像）

如果你就是想一次全装（占硬盘不心疼）：

```bash
bash ./deploy/deploy.sh --yes                    # 装 .claude + .codex + .gemini + .agents
powershell -ExecutionPolicy Bypass -File .\deploy\deploy.ps1 -Yes
```

---

## 🤖 Agent 自检 Prompt（推荐！让智能体自己判断）

把下面这段完整贴给你的 Agent（不管是 Claude Code、Codex、豆包、还是浏览器 GPT）：

````text
你现在需要帮我部署 HelmForge (https://github.com/hhx465453939/HelmForge)。

请先执行以下自检，判断我的宿主环境属于 A / B / C / D / E 哪一类，
然后给出对应的一句话部署命令：

【自检步骤】
1. 你自己是哪一款 Agent？（Claude Code / Codex / Gemini / Antigravity / WorkBuddy / 龙虾 / OpenClaw / ChatGPT / 豆包 / 元宝 / Kimi Web / 其他）
2. 你运行在什么环境？（本地终端 CLI / 桌面 App / 浏览器）
3. 我是否已经把 HelmForge 仓库克隆到本地？（本地能读到 E:/... 或 ~/HelmForge 就是有）

【判定表】
- Claude Code (本地) → 类型 A → `bash ./deploy/deploy.sh --yes --only claude`
- Codex CLI (本地) → 类型 B → `--only codex`
- Antigravity / Gemini CLI (本地) → 类型 C → `--only gemini`
- WorkBuddy / OpenClaw / 龙虾 (本地桌面) → 类型 D → `--only agents`
- 浏览器里的 GPT / 豆包 / Claude.ai / 元宝 / Kimi (在线) → 类型 E → 走内容注入，不跑 deploy 脚本

【产出】
1. 判定的类型（A/B/C/D/E）+ 一句话理由
2. 具体到我的 OS（Windows PowerShell 还是 macOS/Linux bash）的部署命令
3. 部署完成后我需要做什么验证（怎么确认 skill 生效）
4. 如果是类型 E，告诉我需要哪些文件、上传到哪、Instructions 写什么

【禁止】
- 不要 --yes 一把梭装 4 个镜像，除非我明确说"我全都要"
- 不要跳过环境自检直接给命令
- 不要把类型 E 的内容注入方案当成类型 A/B/C/D 的本地部署来处理

准备好了就开始自检。
````

---

## 📎 参考

- **主 skill spec**：[`.claude/skills/skill-deploy/SKILL.md`](../.claude/skills/skill-deploy/SKILL.md) — 5 步部署流程 + 4 项后平滑 check 的权威定义
- **skill 开发规范**：[`.claude/skills/skill-governor/SKILL.md`](../.claude/skills/skill-governor/SKILL.md)
- **在线 API 提供商**：[`docs/cn-api-providers.md`](./cn-api-providers.md) — GLM / DeepSeek / Kimi / MiMo / 硅基流动
- **License**：[`LICENSE`](../LICENSE) — PolyForm Noncommercial 1.0.0（永久非商业，商业授权另议）
- **ETHICS**：[`ETHICS.md`](../ETHICS.md) — 8 条企业经营红线，任何部署形态都适用

有部署问题请到 [GitHub Issues](https://github.com/hhx465453939/HelmForge/issues) 开单，标签用 `deploy`。
