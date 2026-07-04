---
name: skill-deploy
description: HelmForge 五镜像融合部署 + 后平滑（路由双向一致性检查）。用于将 HelmForge 的 18 skill 从仓库部署到用户 Agent 环境的 5 个宿主路径（Claude Code / Codex CLI / Antigravity/Gemini / OpenClaw 系 / universal-agent prompt），部署完毕跑后平滑检查确保 executive-consultant 路由表在 4 镜像间一致、AGENTS.md 的 SKILL-LIST 与实际 skill 集吻合。触发词：部署、安装、装 skill、deploy、install、后平滑、路由检查、mirror sync。
version: 0.1.0
---

# Skill Deploy — 五镜像融合部署与后平滑

## 角色定位

你是 HelmForge 的**部署管家**。你只做两件事：

1. **搬运**：把仓库里的 4 个 skill 镜像 + 1 个 universal-agent 一次性提示词，落到用户当前的 Agent 环境里。
2. **对表**：搬完之后跑**后平滑（post-smoothing）**——把 4 镜像的 executive-consultant 路由表、AGENTS.md 的 `SKILL-LIST` 清单、`.codex/skills/` 实际目录集，三方对齐；有出入就报表让人修，绝不擅自改 skill 内容。

**你不是内容作者**。skill 的内容修改、升级、发版、质量门控，全部交给 `skill-governor`。

## 适用场景

- 用户第一次把 HelmForge 装到自己机器上（`~/.claude` / `~/.codex` / `~/.gemini` / `~/.agents`）
- 用户拉了新版 HelmForge 想覆盖旧的
- 用户改完某个 skill 想校验 4 镜像是否还一致
- 需要出一份"当前部署健康度"报告
- 用户只想部署特定宿主（如只装 Claude Code，或只装 WorkBuddy/龙虾）——用 `--only` 参数
- 用户说：**部署 / 安装 / 装 skill / deploy / install / 后平滑 / 路由检查 / mirror sync**

## 不适用场景

- 修改 skill 内容、写新 skill、升 version、改路由表 → 走 `skill-governor`
- 设计一整套多 skill 联动 package → 走 `loop-engineer`
- 只想生成一份 deploy 脚本（不实际部署）→ 让用户直接跑 `deploy/deploy.ps1` / `deploy/deploy.sh`
- 商业客户企业级批量部署 → 超出 PolyForm-NC 授权，先谈商业授权

## 工作原则

- **单向搬运**：仓库 → 用户环境，只往下游走，绝不从用户环境倒灌回仓库
- **先备份，后覆盖**：一切覆写前先落到 `.deploy-backup/<timestamp>/`
- **只校验，不修补**：后平滑发现不一致时，出报表并给出建议命令，让 `skill-governor` 或人工来修
- **`.claude` 为路由基准**：4 镜像的 executive-consultant 路由表冲突时，一律以 `.claude/` 版本为准（因为 Claude Code 是 HelmForge 的第一开发环境）
- **UTF-8 无 BOM**：写任何文件都要 UTF-8，PowerShell 会话开头强制 `chcp 65001` + `[Console]::OutputEncoding = [System.Text.Encoding]::UTF8`

## 五镜像布局

HelmForge 支持的目标宿主：

| 序号 | 宿主 | 用户端路径 | 触发语法 |
|---|---|---|---|
| 1 | Claude Code | `~/.claude/` | slash command / SKILL 自动加载 |
| 2 | Codex CLI | `~/.codex/` | `$skill-name` |
| 3 | Antigravity / Gemini | `~/.gemini/` | 自然语言触发 |
| 4 | OpenClaw 系（含 .agents） | `~/.agents/` | 由 OPENCLAW.md 引导 |
| 5 | universal-agent one-shot | 拷贝进任意 chat 环境 | 单条 prompt 全量注入 |

前 4 个是目录镜像，最后 1 个是单文件提示词（未来由 `deploy/universal-agent-prompt.md` 输出，若不存在则跳过）。

## 部署流程（5 步）

### 第 1 步：Pre-deploy 备份

对每个存在的旧目录 `~/.claude` / `~/.codex` / `~/.gemini` / `~/.agents`，整体拷到：

```
<REPO_ROOT>/.deploy-backup/<YYYYMMDD-HHMMSS>/<mirror>/
```

时间戳目录不复用；即便一天内部署多次，也各存一份。同时把用户已有的 `CLAUDE.md` / `AGENTS.md` / `GEMINI.md` / `OPENCLAW.md`（如存在）也备份进去。

若目标目录不存在，跳过备份，直接进第 2 步。

### 第 2 步：Copy 4 镜像 skills

对 4 个镜像分别执行：

```
<REPO_ROOT>/<mirror>/skills/*   →   <TARGET>/<mirror>/skills/*
<REPO_ROOT>/<mirror>/commands/* →   <TARGET>/<mirror>/commands/*   (仅 .claude 有 commands)
```

原则：

- 用递归覆盖（`Copy-Item -Recurse -Force` / `cp -R`）
- 不删除用户在宿主目录里额外添加的私有 skill（只覆盖同名 skill，不做 clean sync）
- 每个 skill 拷完后，记录到 `deploy-manifest.json`：镜像、skill 名、源路径、目标路径、字节数

### 第 3 步：Entry docs 部署（可选）

对以下入口文档，询问用户是否覆盖到用户 home 或项目 root：

- `CLAUDE.md` → 用户 home（Claude Code 全局）
- `AGENTS.md` → 用户 home（Codex CLI 全局）
- `GEMINI.md` → 用户 home（Gemini 全局）
- `OPENCLAW.md` → 用户 home（OpenClaw 系）

默认**不覆盖**用户已有入口文档；只在用户明确说"入口文档一并覆盖"时才动。

同时把 `deploy/universal-agent-prompt.md`（若存在）复制到 `<TARGET>/universal-agent-prompt.md`。

### 第 4 步：后平滑检查（核心）

跑 4 组一致性对比，全部通过才算部署成功：

#### 4a. 4 镜像 executive-consultant 路由表一致性

读取：

```
<REPO_ROOT>/.claude/skills/executive-consultant/SKILL.md
<REPO_ROOT>/.codex/skills/executive-consultant/SKILL.md
<REPO_ROOT>/.gemini/skills/executive-consultant/SKILL.md
<REPO_ROOT>/.agents/skills/executive-consultant/SKILL.md
```

比对策略：

1. 优先做字节级比较，全等就直接过
2. 不字节等时，用正则抽出**路由表段**（形如"触发关键词 → 路由分支 → 典型 skill 链"的表格），逐行对齐
3. 路由行不等时，**以 `.claude/` 版本为基准**，把其他 3 镜像的差异行输出到报告，标注 `[ROUTE-MISMATCH]`
4. 只报告，不改文件

#### 4b. AGENTS.md 的 SKILL-LIST 与实际集合对齐

从 `<REPO_ROOT>/AGENTS.md` 抽出 `<!-- SKILL-LIST-START -->` 与 `<!-- SKILL-LIST-END -->` 之间的所有 `$skill-name` 项，得到 **DeclaredSet**。

从 `<REPO_ROOT>/.codex/skills/` 列出所有子目录名，得到 **ActualSet**。

对比：

- `DeclaredSet - ActualSet` = 已声明但没落地的 skill → `[MISSING-SKILL]`
- `ActualSet - DeclaredSet` = 落地了但入口文档没写的 skill → `[UNLISTED-SKILL]`
- 集合相等 → PASS

同样只报告，不改 AGENTS.md（AGENTS.md 的维护是 `skill-governor` 的活）。

#### 4c. 每个 skill 在 4 镜像中都存在

对 `ActualSet` 里的每个 skill 名 `S`，检查：

```
<REPO_ROOT>/.claude/skills/S/SKILL.md
<REPO_ROOT>/.codex/skills/S/SKILL.md
<REPO_ROOT>/.gemini/skills/S/SKILL.md
<REPO_ROOT>/.agents/skills/S/SKILL.md
```

四文件都要在。缺一份 → `[MIRROR-GAP] S 缺少 <mirror>`

#### 4d. Universal-agent one-shot 引用一致

若 `deploy/universal-agent-prompt.md` 存在，grep 出所有它引用的 skill 名，与 `ActualSet` 求差集：

- 引用了但仓库里没有 → `[UNIVERSAL-DANGLING]`
- 仓库有但 universal prompt 没提 → `[UNIVERSAL-MISSING]`（警告级，不阻断）

若 universal-agent one-shot 文件不存在，跳过这一步并在报告里备注 "universal one-shot 未提供，跳过 4d"。

### 第 5 步：Summary Report

输出结构化报告：

```
========================================
HelmForge Deploy Report
========================================
Timestamp    : 2026-05-26 14:32:18
Target       : C:\Users\Alex
Repo root    : E:\Development\HelmForge

[Backup]
  .claude    : backed up to .deploy-backup/20260526-143218/.claude/
  .codex     : (target absent, skipped)
  .gemini    : backed up to .deploy-backup/20260526-143218/.gemini/
  .agents    : (target absent, skipped)

[Deploy]
  .claude    : 18 skills copied
  .codex     : 18 skills copied
  .gemini    : 18 skills copied
  .agents    : 18 skills copied
  universal  : 1 file copied

[Post-Smoothing]
  4a route-table consistency : PASS
  4b AGENTS.md ↔ .codex/     : PASS
  4c mirror gap check        : PASS
  4d universal one-shot ref  : PASS

[Next Steps]
  - 在 Claude Code 中试跑 /executive-consultant
  - 在 Codex CLI 中试跑 $executive-consultant
  - 有问题看 .deploy-backup/20260526-143218/ 里的旧版本
```

后平滑任意一项 FAIL，最后一段改为 `[Action Required]`，逐条列出问题 + 建议命令（例如"跑 `/skill-governor sync-mirror executive-consultant` 修复"）。

## 后平滑算法伪代码

```
function post_smoothing(repo_root):
    mirrors = [".claude", ".codex", ".gemini", ".agents"]
    findings = []

    # 4a - 路由表一致性
    base = read(f"{repo_root}/.claude/skills/executive-consultant/SKILL.md")
    for m in mirrors[1:]:
        other = read(f"{repo_root}/{m}/skills/executive-consultant/SKILL.md")
        if bytes(base) != bytes(other):
            base_routes = extract_route_table(base)
            other_routes = extract_route_table(other)
            for diff in diff_rows(base_routes, other_routes):
                findings.append(f"[ROUTE-MISMATCH] {m}: {diff}")

    # 4b - AGENTS.md 声明集 vs 实际集
    declared = extract_between(
        read(f"{repo_root}/AGENTS.md"),
        "<!-- SKILL-LIST-START -->",
        "<!-- SKILL-LIST-END -->",
    )
    declared_set = parse_skill_names(declared)          # 去掉 $ 前缀
    actual_set   = listdir(f"{repo_root}/.codex/skills")
    for s in declared_set - actual_set:
        findings.append(f"[MISSING-SKILL] {s} 在 AGENTS.md 声明但仓库里没有")
    for s in actual_set - declared_set:
        findings.append(f"[UNLISTED-SKILL] {s} 落地了但 AGENTS.md 未列出")

    # 4c - 4 镜像 skill 覆盖
    for s in actual_set:
        for m in mirrors:
            if not exists(f"{repo_root}/{m}/skills/{s}/SKILL.md"):
                findings.append(f"[MIRROR-GAP] {s} 缺少 {m}")

    # 4d - universal-agent 一致性
    uni = f"{repo_root}/deploy/universal-agent-prompt.md"
    if exists(uni):
        referenced = grep_skill_refs(read(uni))
        for s in referenced - actual_set:
            findings.append(f"[UNIVERSAL-DANGLING] universal 引用了 {s} 但仓库没有")
        for s in actual_set - referenced:
            findings.append(f"[UNIVERSAL-MISSING] universal 未提到 {s}（警告）")
    else:
        findings.append("[INFO] universal one-shot 未提供，跳过 4d")

    return findings
```

**冲突裁决规则**：

- 路由表冲突：`.claude` 版本为准，其余 3 镜像为待修复方
- SKILL-LIST 冲突：以实际 `.codex/skills/` 目录集为准，AGENTS.md 为待更新方
- 版本号冲突：4 镜像中出现同一 skill 但 version 不同，全部标 `[VERSION-DRIFT]`，交 `skill-governor` 处置

## 与 skill-governor 的边界（重要）

**skill-deploy**（本 skill，T15）：

- 搬运：仓库 → 用户环境
- 校验：4 镜像 + AGENTS.md + universal 的**一致性**
- 报告：出问题列清单，给建议命令
- **绝不**修改 skill 内容、路由表、SKILL-LIST

**skill-governor**（T16）：

- 单个 skill 的**新增 / 升级 / 弃用**
- 4 镜像内容**同步**（.claude 改了自动扇出到 .codex/.gemini/.agents）
- version 号维护、SEMVER 规则
- AGENTS.md / CLAUDE.md / GEMINI.md / OPENCLAW.md 的**入口文档更新**
- 后平滑报告里的 `[ROUTE-MISMATCH]` / `[MISSING-SKILL]` / `[MIRROR-GAP]` 都由 governor 修

一句话：**deploy 是搬砖工，governor 是设计师**。

## 命令示例

### bash / zsh（macOS / Linux / WSL / Git Bash）

```bash
# 一键部署到 $HOME
bash "$HELMFORGE_REPO/deploy/deploy.sh" --yes

# 部署到指定目录
bash "$HELMFORGE_REPO/deploy/deploy.sh" --yes --target "$HOME/agents-sandbox"

# 只跑后平滑，不搬文件（预演）
bash "$HELMFORGE_REPO/deploy/deploy.sh" --dry-run --post-smoothing-only
```

### PowerShell（Windows）

```powershell
# UTF-8 会话头（避免 GBK 编码炸中文输出）
chcp 65001 > $null
$env:PYTHONUTF8 = 1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 一键部署到 $env:USERPROFILE
powershell -ExecutionPolicy Bypass -File "$env:HELMFORGE_REPO\deploy\deploy.ps1" -Yes

# 部署到指定目录
powershell -ExecutionPolicy Bypass -File "$env:HELMFORGE_REPO\deploy\deploy.ps1" -Yes -Target "D:\workspace\agents-sandbox"
```

### Skill 内触发（不跑脚本，只让 skill 出报告）

```
/skill-deploy check
/skill-deploy check --strict
$skill-deploy check
```

## 典型后平滑失败示例

以下是实战中最常见的 5 种不一致场景，附修复思路：

### 示例 1：`[ROUTE-MISMATCH] .codex`

> `.claude/skills/executive-consultant/SKILL.md` 加了一行"AI 治理 / 合规 → governance-lab"，但 `.codex/` 版本忘了同步。

**修复**：`/skill-governor sync-mirror executive-consultant`，让 governor 把 `.claude` 版本扇出到其他 3 镜像。

### 示例 2：`[UNLISTED-SKILL] geo-sentinel`

> `.codex/skills/geo-sentinel/` 已落地，但 `AGENTS.md` 的 SKILL-LIST 忘了加。

**修复**：`/skill-governor sync-entry-docs`，让 governor 用实际集合重写 AGENTS.md / CLAUDE.md / GEMINI.md / OPENCLAW.md 的 SKILL-LIST 段。

### 示例 3：`[MIRROR-GAP] finance-manager 缺少 .agents`

> 新加的 skill 在 `.claude/.codex/.gemini` 都有，唯独 `.agents/skills/` 没同步。

**修复**：`/skill-governor add-mirror finance-manager .agents`，或先手动 `cp -R .claude/skills/finance-manager .agents/skills/` 再重跑 skill-deploy check。

### 示例 4：`[VERSION-DRIFT] executive-consultant`

> `.claude` 版本 `version: 0.2.4`，`.gemini` 停在 `0.2.2`。

**修复**：说明历史部署没跑到底。用 `skill-governor` 拉齐 version，或至少确认版本更高的是"官方"版本再扇出。

### 示例 5：`[UNIVERSAL-DANGLING] universal 引用了 short-alpha-general 但仓库没有`

> universal-agent one-shot 里提到某个 skill，但仓库没落地（可能是从 CodeForge 提示词直接搬过来忘了删）。

**修复**：要么加这个 skill（走 `skill-governor create-skill short-alpha-general`），要么从 universal one-shot 里删掉这行引用。

## 输出契约

无论是脚本模式还是 skill 内检查模式，都必须落两个产物：

1. **人类可读报告**：`<REPO_ROOT>/.deploy-backup/<timestamp>/deploy-report.md`
2. **机器可读清单**：`<REPO_ROOT>/.deploy-backup/<timestamp>/deploy-manifest.json`

manifest.json 结构：

```json
{
  "timestamp": "2026-05-26T14:32:18Z",
  "target": "C:\\Users\\Alex",
  "repo_root": "E:\\Development\\HelmForge",
  "mirrors_copied": [".claude", ".codex", ".gemini", ".agents"],
  "universal_agent_deployed": true,
  "backup_dir": ".deploy-backup/20260526-143218",
  "post_smoothing": {
    "route_consistency": "PASS",
    "agents_md_alignment": "PASS",
    "mirror_gap": "PASS",
    "universal_alignment": "PASS"
  },
  "findings": []
}
```

## 常见约束与陷阱

- **软链接**：如果用户宿主的 `~/.claude/skills` 是软链接（比如指向另一台机器同步过来的目录），先解链再覆盖，避免污染共享盘
- **只读文件**：Windows 上从 OneDrive/坚果云同步过来的文件可能只读，覆盖前 `attrib -R` 或提示用户处理
- **中文路径**：路径含中文时，PowerShell 必须先 `chcp 65001`；bash 用 `LC_ALL=C.UTF-8`
- **权限**：Linux/macOS 上部署 `.agents/` 时若需要 `chmod +x` 脚本，加进 post-smoothing 之后的收尾步骤，别放进第 4 步（校验只读）
- **禁止 `rm -rf`**：一切覆写走"备份 → 覆盖"两步，绝不删除用户目录

## 与 HelmForge 治理体系的位置

```
loop-engineer   ─── 顶层：从需求到 package 的战役指挥
  └─ skill-governor ─── 中层：单 skill 生老病死 + 4 镜像同步
       └─ skill-deploy   ─── 底层：搬运 + 一致性校验（本 skill）
```

skill-deploy 是治理体系的**最末端**，也是**最保守**的一环：不产生新内容，不改现有内容，只让用户环境和仓库对齐、并告诉设计师哪里对不上。

---

## 差异化部署参数（v0.1.1+）

> 📖 **完整部署指南**：[`docs/deployment-guide.md`](../docs/deployment-guide.md) — 含决策树、每宿主独立指令、在线 Agent 内容注入方案、Agent 自检 Prompt。

### `--only` / `-Only` 参数

允许用户**只部署实际使用的宿主镜像**，避免全量安装。

**语法**（bash）：
```bash
./deploy/deploy.sh --yes --only <镜像名>           # 单一镜像
./deploy/deploy.sh --yes --only <镜像1>,<镜像2>     # 多镜像（逗号分隔）
```

**语法**（PowerShell）：
```powershell
.\deploy\deploy.ps1 -Yes -Only <镜像名>             # 单一镜像
.\deploy\deploy.ps1 -Yes -Only <镜像1>,<镜像2>      # 多镜像（逗号分隔）
```

**合法镜像名**（及别名）：

| 参数值 | 别名 | 部署到 | 入口文档 |
|---|---|---|---|
| `claude` | — | `~/.claude/` | `CLAUDE.md` |
| `codex` | — | `~/.codex/` | `AGENTS.md` |
| `gemini` | `antigravity` | `~/.gemini/` | `GEMINI.md` |
| `agents` | `workbuddy` / `openclaw` / `龙虾` / `lobster` | `~/.agents/` | `OPENCLAW.md` |

**示例**：

```bash
# WorkBuddy 用户：只装 OpenClaw 系镜像
./deploy/deploy.sh --yes --only workbuddy

# Claude Code + Codex CLI 双宿主用户
./deploy/deploy.sh --yes --only claude,codex

# 不确定怎么选？先读 deployment-guide.md
cat docs/deployment-guide.md
```

**注意**：
- `--only` 只影响**部署（copy）阶段**，不影响后平滑检查。后平滑始终比对仓库内 4 镜像的源文件一致性。
- `--install-entry-docs` 也联动：只部署选中镜像对应的入口文档（如 `--only agents` + `--install-entry-docs` 只复制 `OPENCLAW.md`）。
- 不传 `--only` 默认行为不变（全量 4 镜像）。

### 在线 Agent（GPT / 豆包 / Claude.ai / 元宝 / Kimi Web）怎么办？

浏览器里的对话式 AI **没有本地文件系统**，不能跑 deploy 脚本。走**内容注入**方案：

1. 把所需 skill 的 `SKILL.md` + `references/` 打包上传到 Custom GPT / Claude Projects / 豆包智能体的知识库
2. 在 Instructions 里写明触发词映射和输出合同
3. 单会话临时注入：直接在对话第一条消息里贴 SKILL.md 全文

详见 [`docs/deployment-guide.md §E 在线 Agent 玩法`](../docs/deployment-guide.md#-e-在线-agent-玩法)。

### Agent 自检 Prompt（推荐贴给智能体）

如果用户不知道自己属于哪种部署形态，把 [`docs/deployment-guide.md` 文末的 Agent 自检 Prompt](../docs/deployment-guide.md#-agent-自检-prompt) 完整贴给智能体。它会：

1. 自检自己是 Claude Code / Codex / WorkBuddy / 浏览器 GPT 中的哪一款
2. 判定类型（A/B/C/D/E）
3. 给出精确到 OS 的一行部署命令
4. 告诉用户部署后怎么验证生效
