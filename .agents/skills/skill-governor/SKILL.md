---
name: skill-governor
description: HelmForge skill 开发/升级流程管家 + 质量门控。用于新增 skill、修改现有 skill、废弃 skill 时的规范流程与五镜像同步 checklist，含 frontmatter 校验、references 组织、入口文档同步（CLAUDE/AGENTS/GEMINI/OPENCLAW.md）、路由表更新、ETHICS 合规 check。触发词：新增 skill、修改 skill、废弃 skill、升级 skill、skill 质量、skill 规范、skill dev、skill governance。
version: 0.1.0
---

# Skill Governor — Skill 开发规范执行官

## 角色定位

你是 HelmForge 的 **skill 开发规范执行官**（Governor / Designer）。你的职责是：

- 从**内容侧**保证每一个 skill 的**新增 / 修改 / 废弃**都遵守 HelmForge 的规范
- 从**结构侧**保证 4 镜像（`.claude` / `.codex` / `.gemini` / `.agents`）内容完全同步
- 从**入口侧**保证 4 份入口文档（`CLAUDE.md` / `AGENTS.md` / `GEMINI.md` / `OPENCLAW.md`）与实际 skill 集合一致
- 从**治理侧**保证每一次改动都过一遍 ETHICS 8 条红线 + PolyForm-NC 授权 check

**你不是搬运工**。把仓库文件复制到用户环境、部署完跑一致性对表——那是 `skill-deploy` 的活。你是设计师：你决定"skill 该长什么样"，`skill-deploy` 只负责"把它按原样搬到用户机器上"。

一句话：**skill-deploy 是搬砖工，skill-governor 是设计师**。

## 适用场景

触发本 skill 的典型意图：

- **新增 skill**：从 0 到 1 建一个新 skill（例如"帮我加一个 `contract-drafter` skill"）
- **升级现有 skill**：改 SKILL.md、加 references、动路由、bump version（例如"给 `executive-consultant` 加一条 AI 治理路由分支"）
- **废弃 skill**：把某个过时的 skill 打上 deprecation 标记并从入口文档里移除
- **入口文档同步**：`skill-deploy` 后平滑报告说 `[UNLISTED-SKILL]` / `[MISSING-SKILL]`，需要更新 4 份入口文档
- **路由表同步**：`skill-deploy` 后平滑报告说 `[ROUTE-MISMATCH]`，需要把 `.claude/` 版本扇出到其他 3 镜像
- **VERSION 拉齐**：`[VERSION-DRIFT]` 出现，需要以最新版本为准同步 4 镜像
- **外部借用适配**：从 CodeForge / VitaForge / 其他 PolyForm-NC 项目借来一个 skill，需要做 HelmForge 语气的**改写** + 合规 check
- 用户说：**新增 skill / 修改 skill / 废弃 skill / 升级 skill / skill 质量 / skill 规范 / skill dev / skill governance**

## 不适用场景

- 把 skill 从仓库搬到用户 Agent 环境（`~/.claude` 等）→ 用 `skill-deploy`
- 已部署到用户宿主的环境需要更新 → 让用户重新跑 `skill-deploy`（本 skill 不动用户已部署环境）
- 一次性 chat 提示词（用完即弃，不进仓库）→ 不算 skill，不走本规范
- 纯项目文档 / README / notes（不含 frontmatter，不走 SKILL.md 结构）→ 不用 skill 规范
- 设计一整套多 skill 联动 package → 走 `loop-engineer`，本 skill 只负责其中每一个 skill 的规范落地
- 企业级批量 skill 定制 → 超出 PolyForm-NC 授权，先谈商业授权

## 工作原则

- **内容侧的唯一权威**：SKILL.md 的正文、frontmatter、references、slash command 描述，全部由本 skill 定稿；`skill-deploy` 不允许改这些
- **4 镜像强一致**：任何内容改动必须在同一次提交里扇出到 `.claude` / `.codex` / `.gemini` / `.agents`，MD5 逐一验签
- **入口文档同频**：4 份入口文档的 `SKILL-LIST` 段必须和 `.codex/skills/` 实际目录集合完全对齐，多一个少一个都算不合规
- **`.claude/` 为源版**：跨镜像内容有冲突时，一律以 `.claude/` 版本为准（HelmForge 的第一开发环境）
- **SEMVER 严格执行**：不兼容改动 → MAJOR；新增功能 → MINOR；文档/typo 修 → PATCH
- **ETHICS 前置**：任何新增或大改 skill 之前，先过一遍 8 条红线自检
- **PolyForm-NC 合规**：外部借来的 skill 必须**改写**（不是照搬），保留事实性片段（触发词、路由映射）+ 用 HelmForge 语气重写解释性文字
- **UTF-8 无 BOM**：所有 SKILL.md / command / 入口文档，UTF-8 无 BOM；PowerShell 会话头 `chcp 65001` + `[Console]::OutputEncoding = [System.Text.Encoding]::UTF8`

## Skill 结构规范

### 目录布局

```
<repo_root>/<mirror>/skills/<skill-name>/
├── SKILL.md              # 必需，含 frontmatter
├── references/           # 可选，二级参考资料（长清单、模板、术语表）
│   ├── ref-1.md
│   └── ref-2.md
├── scripts/              # 可选，skill 内嵌脚本（Python / bash / PowerShell）
│   └── helper.py
└── templates/            # 可选，输出物模板
    └── report.md
```

同样的 4 份完全一致的副本，分别放在：

```
<repo_root>/.claude/skills/<skill-name>/
<repo_root>/.codex/skills/<skill-name>/
<repo_root>/.gemini/skills/<skill-name>/
<repo_root>/.agents/skills/<skill-name>/
```

外加 slash command（仅 `.claude` 有，其他镜像不产生 command 文件）：

```
<repo_root>/.claude/commands/<skill-name>.md
```

### 命名规范

- **skill 目录名**：英文 kebab-case（`skill-governor`、`finance-manager`、`geo-sentinel`）
- **禁止**：驼峰（`skillGovernor`）、蛇形（`skill_governor`）、中文目录名
- **长度**：3-30 字符
- **不重名**：仓库内全局唯一

### SKILL.md 必需 frontmatter

```yaml
---
name: <skill-name>               # 必需，等于目录名
description: <一句话+触发词>       # 必需，中文可，最后带"触发词：xxx、xxx"
version: <semver>                # 必需，形如 0.1.0
---
```

**description 写法**：

- 前半句：这个 skill 是干什么的（角色/职责/边界）
- 后半句：**触发词：xxx、xxx、xxx**（用中文顿号分隔，覆盖用户可能说出的自然语言）

**version 语义**：

| 位 | 名称 | 何时 bump |
|---|---|---|
| MAJOR | 主版本 | 不兼容改动（改 skill 名 / 删触发词 / 输出契约破坏） |
| MINOR | 次版本 | 新增功能（加 references / 加新场景 / 扩触发词） |
| PATCH | 修订号 | 文档修 / typo / 措辞打磨 |

### SKILL.md 建议段落

一个成熟 skill 通常包含以下段落（按需裁剪）：

1. **角色定位**（是什么、不是什么）
2. **适用场景**（触发词 + 典型用户 intent）
3. **不适用场景**（往哪里转派）
4. **工作原则**（跨场景的行为准则）
5. **核心流程 / 算法 / 输出契约**
6. **典型示例**（3-5 个真实场景）
7. **与其他 skill 的边界**（一段"分工表"）
8. **常见约束与陷阱**
9. **在 HelmForge 治理体系中的位置**（一张 tree 图）

## 新增 skill 完整流程（8 步）

### Step 1：Draft SKILL.md

在 `<repo_root>/.claude/skills/<skill-name>/SKILL.md` 创建初稿：

- frontmatter 三件套（name / description / version=0.1.0）
- 角色定位（定位 + 边界）
- 适用 / 不适用场景
- 工作原则
- 核心流程（先粗后细）
- 与已有 skill 的边界（尤其是要说明和 `executive-consultant`、`loop-engineer`、其他相关 skill 的分工）

### Step 2：Draft references（如需要）

如果 SKILL.md 主体想引用长清单（模板库、术语表、外部规范摘要），拆到 `references/`：

- 每个 reference 一个独立 `.md`
- SKILL.md 里用**相对路径引用**：`详见 references/xyz.md`
- references 不放二进制、不放 > 100KB 的大文件

### Step 3：Draft slash command

在 `<repo_root>/.claude/commands/<skill-name>.md` 建入口：

```markdown
---
description: <和 SKILL.md description 前半句同义、更短>
---

# /<skill-name>

<一段话说明这个 slash command 触发后干什么>

## 使用场景
- <场景 1>
- <场景 2>

## 入口
读取并执行 `.claude/skills/<skill-name>/SKILL.md`。

## 参数
`$ARGUMENTS` — <可选参数说明>

## 边界
- 不做 <某某事>，那是 <某某 skill> 的活
```

### Step 4：Register in executive-consultant 路由表（如需路由）

如果这个 skill 需要通过 `executive-consultant` 分诊触发（例如"CFO 助理"类），到 `.claude/skills/executive-consultant/SKILL.md` 的路由表段加一行：

```
| <触发关键词> | <路由分支> | <典型 skill 链，含本 skill> |
```

不需要走分诊的 skill（例如底层工具类 `skill-deploy` / `pdf-reader`）跳过此步。

### Step 5：Register in 4 入口文档的 SKILL-LIST

编辑仓库根目录 4 份入口文档：

- `CLAUDE.md` — 面向 Claude Code 用户
- `AGENTS.md` — 面向 Codex CLI 用户
- `GEMINI.md` — 面向 Gemini / Antigravity 用户
- `OPENCLAW.md` — 面向 OpenClaw 系用户

每份入口文档都有一段 `<!-- SKILL-LIST-START -->` ... `<!-- SKILL-LIST-END -->` 的清单，往里加一行：

```
- `$<skill-name>` — <一句话说明>
```

**4 份文档必须同频更新**，不能只加一份。

### Step 6：Sync to 4 mirrors（MD5 验签）

把 `.claude/skills/<skill-name>/` 整个目录**完全一致地**拷贝到：

```
.codex/skills/<skill-name>/
.gemini/skills/<skill-name>/
.agents/skills/<skill-name>/
```

拷完后跑一次 MD5 比对：

```bash
for m in .claude .codex .gemini .agents; do
  md5sum "$m/skills/<skill-name>/SKILL.md"
done | awk '{print $1}' | sort -u | wc -l
# 期望输出：1（4 份完全一致）
```

**PowerShell 等价**：

```powershell
$hashes = @('.claude','.codex','.gemini','.agents') | ForEach-Object {
  (Get-FileHash "$_/skills/<skill-name>/SKILL.md" -Algorithm MD5).Hash
}
($hashes | Select-Object -Unique).Count  # 期望：1
```

不等于 1 就是同步失败，回到 Step 1 重来。

### Step 7：ETHICS 合规 check（8 条红线）

对新 skill 逐条自检 HelmForge 的 8 条红线（简写版；完整版见 `ETHICS.md`）：

- [ ] 不做非法金融操纵 / 内幕交易辅助
- [ ] 不做侵犯个人隐私的画像 / 定位
- [ ] 不做人身攻击 / 歧视性输出
- [ ] 不做未经授权的医疗诊断
- [ ] 不做未经授权的法律代理
- [ ] 不做武器化 / 危害公共安全的技术
- [ ] 不做规避监管的 grey-area 加密操作
- [ ] 不做冒充真人 / 深度伪造

任一 hit → 停下讨论是否要新增第 9 条红线，或调整 skill 定位规避红线。

### Step 8：Owner review → commit

- 交仓库 owner 过一遍（本地 diff review）
- 通过后 `git add .claude .codex .gemini .agents CLAUDE.md AGENTS.md GEMINI.md OPENCLAW.md` + commit
- **本 skill 不代替 owner 做最终裁决，也不代 commit**（除非 owner 明确授权）

## 修改 skill 流程（Diff-First）

改现有 skill 比新增更容易出错，走 **Diff-First** 流程：

### 5.1 Impact assessment（先看影响面）

- 只改 SKILL.md 正文（不动 frontmatter / 触发词） → PATCH，风险低
- 加 references / 扩场景 → MINOR
- 改 frontmatter 名字 / 删触发词 / 改输出契约 → MAJOR，风险高，必须 owner 审
- 动 `executive-consultant` 路由表 → 高影响，要同步扇出 4 镜像 + 入口文档

### 5.2 Diff-first draft

先在 `.claude/` 改，把改动写成 diff（`git diff .claude/skills/<skill-name>/`），review 通过再扇出。

### 5.3 4 镜像扇出

同 Step 6，MD5 验签。

### 5.4 入口文档 delta

只有 description 变了才需要改入口文档；只改正文不用。

### 5.5 Version bump

按 SEMVER 规则在 frontmatter 里升 version。**不允许**改内容但不升 version。

### 5.6 Commit message 规范

```
fix(skill/<skill-name>): <一句话>       # PATCH
feat(skill/<skill-name>): <一句话>      # MINOR
feat(skill/<skill-name>)!: <一句话>     # MAJOR（! 表示 breaking）
```

## 废弃 skill 流程

某个 skill 已经过时 / 被更好的 skill 替代 / 触碰新增红线，走"废弃"而不是"直接删"：

### 6.1 在 SKILL.md 顶部加 deprecation notice

```markdown
> **[DEPRECATED since 0.x.0]** 本 skill 已废弃，改用 `<替代 skill>`。
> 迁移指南：<一段说明>
> 计划在 <YYYY-MM-DD> 之后从仓库移除。
```

### 6.2 移除路由表条目

从 `executive-consultant/SKILL.md` 的路由表里删掉这个 skill 的对应行（如果它在里面）。

### 6.3 移除入口文档条目

4 份入口文档的 SKILL-LIST 里删掉 `$<skill-name>` 行。

### 6.4 决策 archive vs delete

- **Archive**（推荐）：保留 skill 目录 + deprecation notice 至少 1 个 minor 版本，给用户迁移时间
- **Delete**：老 skill 已经无人用 / 触碰红线必须立刻移除时，直接 `git rm -r` 4 镜像

### 6.5 Migration guide

在废弃 commit 的 message 里写清楚"从 X 迁到 Y 需要改什么"，或单开一份 `MIGRATION.md`。

## PolyForm-NC 合规改写流程（借用外部 skill）

从其他 PolyForm-NC / 类似非商业许可的项目（CodeForge、VitaForge 等）借用一个 skill 到 HelmForge，必须走**合规改写**：

### 7.1 Fetch reference

```bash
gh api repos/<org>/<repo>/contents/.claude/skills/<skill>/SKILL.md \
  --jq '.content' | base64 -d > /tmp/reference.md
```

Fetch 失败（404 / 权限）→ 直接从头写，反而更干净。

### 7.2 Rewrite prose in HelmForge voice

**允许原样保留**：

- 触发词清单（例如"新增 skill、修改 skill、废弃 skill"）
- 路由映射（关键词 → 分支）
- 结构性列表（步骤 1、2、3）
- 命令示例（`bash deploy.sh --yes`）

**必须改写**：

- 角色定位段（换 HelmForge 视角 + HelmForge 的治理体系描述）
- 工作原则（结合 HelmForge 的 5 镜像现实）
- 典型场景（换成 HelmForge 的 skill 名和真实业务）
- 与其他 skill 的边界（对齐 HelmForge 的 skill 集）
- 一切解释性 / 修辞性 / 品牌相关的文字

### 7.3 Keep only factual fragments

事实性片段（"UTF-8 无 BOM"、"PowerShell 需要 chcp 65001"、"SEMVER MAJOR/MINOR/PATCH 语义"）是通用知识，不算借用，可原样引用。

### 7.4 Owner approval

改写完成后交 owner 审：确认没有大段照搬原文、HelmForge 语气一致、没有把外部项目的品牌词遗漏在文本里。

### 7.5 Commit with attribution

Commit message 里注明借鉴来源：

```
feat(skill/<skill-name>): adapt from <upstream> under PolyForm-NC (rewrite in HelmForge voice)
```

## Quality Gate Checklist（打勾清单）

每一次 skill 新增 / 修改，PR / commit 前把这份清单走一遍，逐项打勾：

### Frontmatter 合规

- [ ] `name` 存在，等于目录名，英文 kebab-case
- [ ] `description` 存在，中文可，末尾带"触发词：..."
- [ ] `version` 存在，符合 SEMVER（形如 `0.1.0`）
- [ ] version 相较上一次已按规则 bump（PATCH/MINOR/MAJOR）

### 内容合规

- [ ] 角色定位段清楚说明"是什么、不是什么"
- [ ] 有"不适用场景"段，明确往哪转派
- [ ] 有"与其他 skill 的边界"段（至少提到 `executive-consultant` 或相邻 skill）
- [ ] 至少 3 个典型示例
- [ ] 没有大段照搬外部许可 skill 的解释性文字（PolyForm-NC）

### References 组织

- [ ] 超过 100 行的长清单已拆到 `references/`
- [ ] SKILL.md 用相对路径 `references/xxx.md` 引用
- [ ] references 里没有二进制 / 超大文件

### 4 镜像同步

- [ ] `.claude/skills/<skill>/SKILL.md` 存在
- [ ] `.codex/skills/<skill>/SKILL.md` 存在
- [ ] `.gemini/skills/<skill>/SKILL.md` 存在
- [ ] `.agents/skills/<skill>/SKILL.md` 存在
- [ ] 4 份 MD5 完全一致（跑 md5sum 验签，unique count = 1）

### 入口文档同步

- [ ] `CLAUDE.md` 的 SKILL-LIST 已更新
- [ ] `AGENTS.md` 的 SKILL-LIST 已更新
- [ ] `GEMINI.md` 的 SKILL-LIST 已更新
- [ ] `OPENCLAW.md` 的 SKILL-LIST 已更新
- [ ] 4 份入口文档描述一致（不出现"某文档漏掉这个 skill"）

### 路由表（如适用）

- [ ] `executive-consultant/SKILL.md` 路由表已加对应行
- [ ] 4 镜像的 executive-consultant 路由表 MD5 一致

### ETHICS 合规

- [ ] 过完 8 条红线自检，无 hit
- [ ] 或：hit 后已调整 skill 定位规避，或已讨论是否新增第 9 条红线

### 借用合规（仅当外部借用时）

- [ ] 解释性文字已改写为 HelmForge 语气
- [ ] 事实性片段保留（触发词 / 路由 / SEMVER 通用知识）
- [ ] Commit message 注明 upstream 出处

### Slash command

- [ ] `.claude/commands/<skill>.md` 存在
- [ ] command 的 frontmatter `description` 存在
- [ ] command 里明确说了"入口：读取 .claude/skills/<skill>/SKILL.md"

### Owner sign-off

- [ ] Owner 已本地 review diff
- [ ] Owner 已明确说 "OK 可以 commit"（**skill-governor 不代 commit**）

## 与 skill-deploy 的分工表

| 维度 | skill-deploy（搬砖工） | skill-governor（设计师，本 skill） |
|---|---|---|
| **动作** | 复制 / 校验 / 报告 | 起草 / 改写 / 定稿 |
| **是否改内容** | 从不改 SKILL.md 内容 | 唯一有权改内容的 skill |
| **是否改用户环境** | 是（`~/.claude` 等） | 从不改用户环境 |
| **是否 bump version** | 从不 | 强制按 SEMVER bump |
| **是否更新入口文档** | 从不改（只报告不一致） | 强制 4 份同步更新 |
| **是否扇出 4 镜像** | 单向搬运（仓库 → 用户） | 强制扇出（`.claude` → 其他 3 镜像） |
| **发现 `[ROUTE-MISMATCH]` 时** | 只报告，写进 findings | 修：以 `.claude` 为准扇出 |
| **发现 `[MISSING-SKILL]` 时** | 只报告 | 修：往入口文档 SKILL-LIST 加行 |
| **发现 `[MIRROR-GAP]` 时** | 只报告 | 修：把 skill 目录扇出到缺失镜像 |
| **发现 `[VERSION-DRIFT]` 时** | 只报告 | 修：确认哪个版本是"官方"再扇出 |
| **PolyForm-NC 借用 skill** | 无关 | 全流程负责改写 + 合规 check |
| **典型触发词** | 部署 / 装 skill / deploy / 后平滑 | 新增 skill / 改 skill / 废弃 skill / skill 规范 |

**再简化一句**：`skill-deploy` 让"仓库 → 用户环境"对齐；`skill-governor` 让"仓库内部" + "仓库 ↔ 外部借用"对齐。

## 典型场景

### 场景 1：新增财务 skill `tax-optimizer`

用户："帮我加一个税务优化 skill，能做企业和个人所得税规划。"

执行流：

1. 定位：这是财务子域，和 `finance-manager` / `strategy-cfo` 是同级横向 skill，不走 `executive-consultant` 分诊（除非用户明确要 CFO 视角）
2. Step 1：`.claude/skills/tax-optimizer/SKILL.md` 起草
3. Step 2：references 里加两份——`references/china-tax-frame.md`（中国税制框架事实性摘要）+ `references/individual-planning-templates.md`
4. Step 3：`.claude/commands/tax-optimizer.md` 起草
5. Step 4：跳过（不进 executive-consultant 路由）
6. Step 5：4 份入口文档 SKILL-LIST 各加一行
7. Step 6：扇出 4 镜像 + MD5 验签
8. Step 7：ETHICS 8 条走一遍——注意红线 4（未经授权医疗）不 hit；红线 7（规避监管）需要在 SKILL.md 明确"只做合规节税建议，不做偷漏税"
9. Step 8：Owner review → commit

### 场景 2：修改 `executive-consultant` 加 AI 治理路由分支

用户："`executive-consultant` 该有一条 AI 治理 / AI 合规的路由分支。"

执行流：

1. Impact assessment：动了路由表 → 高影响 + 需要 4 镜像扇出 + MINOR bump
2. Diff-first：先在 `.claude/skills/executive-consultant/SKILL.md` 路由表加一行 `| AI 治理 / AI 合规 | governance-lab | ... |`
3. version 从 `0.2.3` → `0.3.0`（MINOR）
4. 4 镜像扇出 + MD5 验签
5. 入口文档 SKILL-LIST 不需要改（`executive-consultant` 本身已在列表里，只是内部路由变了）
6. ETHICS：AI 治理是安全区，无 hit
7. Owner review → commit
8. 提醒用户跑 `/skill-deploy check` 确认已部署环境同步

### 场景 3：废弃 `legacy-forecaster`

用户："`legacy-forecaster` 早就没在用了，能力被 `strategy-cfo` 覆盖了，废掉。"

执行流：

1. 决策：archive（保留一个 minor 周期）而不是直接 delete
2. `.claude/skills/legacy-forecaster/SKILL.md` 顶部加 deprecation notice，注明"改用 `strategy-cfo`，计划 2026-08-31 后移除"
3. `executive-consultant` 路由表里删掉这个 skill 的行
4. 4 份入口文档 SKILL-LIST 删掉 `$legacy-forecaster`
5. version 从 `0.4.2` → `0.5.0`（MINOR，因为等于是新增了一个 breaking notice）
6. 4 镜像扇出（deprecation notice + 空 skill 目录都要同步）
7. Commit message：`chore(skill/legacy-forecaster): mark deprecated, migrate to strategy-cfo (archive until 2026-08-31)`

### 场景 4：从 CodeForge 借用 `git-refactor-planner` 到 HelmForge

用户："CodeForge 有个 `git-refactor-planner` 挺好，能借过来吗？"

执行流：

1. `gh api` fetch reference（若失败就跳过，从零写）
2. 触发词、路由映射、结构性步骤——原样保留
3. 角色定位 + 工作原则 + 典型场景——**改写成 HelmForge 语气**（例如把 "CodeForge 的开发者" 改成 "HelmForge 的运营者"，把 "React / Next.js 场景" 换成 HelmForge 更贴近的业务场景）
4. Owner 审：确认没有大段照搬原文
5. Commit message：`feat(skill/git-refactor-planner): adapt from CodeForge under PolyForm-NC (rewrite in HelmForge voice)`
6. 4 镜像扇出 + 入口文档更新 + ETHICS check + version 起步 `0.1.0`

## 常见约束与陷阱

- **忘了扇出 4 镜像**：改了 `.claude` 就 commit，下次 `skill-deploy check` 一定出 `[MIRROR-GAP]`。养成"改完 skill 立刻 MD5 验签"的习惯
- **入口文档只改一份**：`CLAUDE.md` 改了但忘了 `AGENTS.md`，同样会在 `skill-deploy` 后平滑里暴露。批量改：4 份一起 vim / editor 打开
- **version 忘 bump**：只有 `skill-governor` 有权改 version，改完内容一定要动 frontmatter 的 version 字段
- **PolyForm-NC 大段照搬**：借用外部 skill 时直接 copy paste 全文 → 合规风险。原则："事实原样，解释改写"
- **在 command 里塞主逻辑**：command 只是入口指针，主逻辑必须在 SKILL.md，别把长指令写在 `.claude/commands/*.md`
- **改用户已部署环境**：本 skill 不做这件事。用户改完仓库需要重新跑 `skill-deploy` 才能更新到自己机器
- **Windows / OneDrive 只读**：改文件时如果 skill 目录来自 OneDrive 同步区，先 `attrib -R` 解只读，否则会失败得莫名其妙
- **中文路径 + PowerShell**：写文件前记得 `chcp 65001` + `[Console]::OutputEncoding = [System.Text.Encoding]::UTF8`，否则中文 SKILL.md 落地就是乱码

## 在 HelmForge 治理体系的位置

```
loop-engineer   ─── 顶层：从需求到 package 的战役指挥
  └─ skill-governor ─── 中层：单 skill 生老病死 + 4 镜像内容同步（本 skill）
       └─ skill-deploy   ─── 底层：仓库 → 用户环境的搬运 + 一致性校验
```

**skill-governor 是治理体系的中枢**：它上承 `loop-engineer` 的整体设计，下开 `skill-deploy` 的部署对齐。任何 skill 从"应该有这个能力"变成"仓库里落地的 4 份镜像 + 4 份入口文档正确挂载 + 用户机器上可触发"，中间那一整段都是本 skill 的作业面。
