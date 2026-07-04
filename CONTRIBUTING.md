# Contributing to HelmForge

> **⚓ HelmForge — 企业掌舵者的 AI 经营驾驶舱**
>
> 欢迎来到 HelmForge 社区。本项目面向企业实控人、CEO、创始人与经营副驾驶,
> 汇聚 18 个可编排 skill（战略/财务/法律/HR/谈判/秘书/情报 …），
> 组成一套以人为舵、以 AI 为副驾的经营指挥系统。

我们相信 **正和博弈（positive-sum）**、**专业主义** 与 **合规优先**：
好的贡献让每一位掌舵者少走弯路，而不是让某一家公司独享红利。
本项目以 **PolyForm Noncommercial 1.0.0** 授权，所有贡献者与使用者
均须遵守 [`LICENSE`](./LICENSE) 与 [`ETHICS.md`](./ETHICS.md) 中的 **8 条经营红线**。

如果你也想参与，请从下面三条路径任选其一。

---

## 一、三条贡献路径（Three Contribution Paths）

### Path A · 报告问题 / 建议新 skill（最轻）

面向所有用户，不需要写代码。

- 提交地址: <https://github.com/hhx465453939/HelmForge/issues>
- 建议使用的 Issue 类型:
  - `bug` — skill 输出错误、部署脚本报错、四镜像不一致
  - `skill-suggestion` — 建议新增或拆分 skill
  - `doc-improvement` — README / CLAUDE.md / 路由表条目不清晰
  - `discussion` — 使用心得、经营场景讨论

**什么样的 Issue 会被优先处理**：

- Bug: 附最小可复现步骤（命令 / 输入 / 期望 vs 实际输出 / 环境）
- Skill 建议: 说明**具体经营场景 + 现有 skill 为何不够用 + 期望产出物**
- 文档: 指出具体行号或段落，并给出改写建议

---

### Path B · 手动 PR 改进已有 skill（中等）

适合熟悉 Git 工作流的贡献者。

1. **Fork** `hhx465453939/HelmForge` 到你的账号。
2. 创建分支，命名遵循 `<type>/<scope>`：
   - `fix/finance-manager-npv-formula`
   - `feat/global-legal-counsel-cross-border`
   - `docs/routing-table-clarify`
   - `refactor/skill-deploy-post-smoothing`
3. 修改 skill 时**必须**遵循 [`skill-governor`](./.claude/skills/skill-governor/SKILL.md) 的开发规范
   （frontmatter、references 拆分、命名等），详见本文第三节。
4. **四镜像同步是硬性要求**：`.claude/` / `.codex/` / `.gemini/` / `.agents/`
   四份镜像必须 MD5 一致（或明确说明有意分叉的原因）。
   使用 [`skill-deploy`](./.claude/skills/skill-deploy/SKILL.md) 的
   post-smoothing 流程本地验证：

   ```powershell
   # 项目根目录
   pwsh ./deploy/deploy-all.ps1   # 会自动做四镜像融合去重 + post-smoothing 校验
   ```

5. Commit 遵循 Conventional Commits + AI 辅助 trailer（详见第四节）。
6. 提交 PR，套用第五节的 **PR 模板**（AI 辅助披露栏必填）。
7. 等待 owner review → merge。

---

### Path C · Agent 自进化（Agent Self-Evolution） — 最酷的玩法

> HelmForge 的招牌玩法：**让 agent 自己改进自己**。
> 你的 agent（Claude / GLM / DeepSeek / Gemini …）在使用某个 skill 时发现瑕疵,
> 就地调用 `/skill-governor` 优化，四镜像同步，fork 仓库并发起 PR。
> 全程 human-in-the-loop：你确认方向和 PR 内容，agent 完成执行动作。

**典型自进化循环（self-evolution loop）**：

```
使用 skill  →  发现改进点  →  /skill-governor 起草改写方案
   →  改写 SKILL.md / references
   →  post-smoothing 四镜像同步
   →  fork HelmForge  →  git branch feat/xxx
   →  commit（AI trailer）  →  gh pr create（AI 辅助披露栏）
   →  你 review & 提交
```

**具体示例 prompt**（可直接复制给你的 agent）：

```
我在使用 /finance-manager 时发现它对亏损公司的估值方案不够完整
（当前只覆盖 DCF 与相对估值，缺少早期亏损公司的替代方法）。请：

1. 调用 /skill-governor 优化 .claude/skills/finance-manager/references/dcf-valuation.md，
   补充"亏损公司估值方法论"章节，覆盖:
     - VC 法（Venture Capital Method）
     - 超额收益法（Excess Earnings）
     - NAV / 净资产法
     - 期权定价法（Real Options / Black-Scholes 视角）
   并在文首标注适用边界（早期 / 转型期 / 周期底部 / 一次性亏损）。

2. 修改完成后调用 skill-deploy 的 post-smoothing 流程，
   验证 .claude / .codex / .gemini / .agents 四镜像 MD5 一致。

3. Fork hhx465453939/HelmForge，建分支 feat/finance-manager-loss-valuation。
   commit message 用 conventional commits，附 HelmForge AI trailer。

4. gh pr create，PR body 使用 HelmForge CONTRIBUTING.md 的 PR 模板，
   "AI 辅助披露"栏必填（列出用到的 skill、模型、我是否人工审阅）。

5. 完成后把 PR 链接贴给我，我最终审阅。
```

**另一类 self-evolution 场景**（新 skill 孵化）：

```
在多次经营对话里，我反复要求某个功能（例如"帮我盯竞品定价"、
"帮我跟踪政策窗口"），你观察到这已经形成稳定的工作流。请：

1. 用 /skill-governor 起草一个新 skill：pricing-radar（或 policy-radar）。
2. 完成 SKILL.md + references/ + scripts/ 骨架，跑 4-mirror sync。
3. 更新 CLAUDE.md / AGENTS.md / GEMINI.md / OPENCLAW.md 入口路由表。
4. Fork + PR，按 CONTRIBUTING.md Path C 流程走。
```

- **PolyForm-NC 合规改写**：如果你的 agent 借用了外部（例如 CodeForge / VitaForge）
  的 skill 骨架，请务必按
  [`.claude/skills/skill-governor/SKILL.md`](./.claude/skills/skill-governor/SKILL.md)
  中的 **PolyForm-NC 合规改写流程** 章节做非 verbatim 改写，不要整段照搬。

---

## 二、Skill 开发标准（Skill Dev Standards）

所有 skill 必须通过 [`skill-governor`](./.claude/skills/skill-governor/SKILL.md)
定义的规范。这里只列硬性 checklist，详细约定请阅读 skill-governor 本身。

- **目录结构**（每个 skill 一个目录）：
  ```
  .claude/skills/<skill-name>/
    ├── SKILL.md               # 必需，含 frontmatter
    ├── references/            # 可选，长文档拆分
    ├── scripts/               # 可选，可执行脚本
    └── templates/             # 可选，产出物模板
  ```
- **SKILL.md frontmatter**（YAML）：
  - `name`: kebab-case 英文（例：`finance-manager`）
  - `description`: 一句话说明触发场景（中英均可）
  - `version`: 语义化版本（如 `1.2.0`）
- **命名约定**：skill 目录名与 frontmatter `name` **完全一致**；kebab-case；仅英文。
- **正文语言**：SKILL.md 正文可用中文；示例、代码、路径保持英文原文。
- **四镜像同步**（Mandatory）：`.claude/` / `.codex/` / `.gemini/` / `.agents/`
  同一 skill 的 SKILL.md **MD5 一致**（`skill-deploy` post-smoothing 会校验）。
  如果需要针对某个 harness 有意分叉，请在 PR body 里明确说明理由。
- **入口文档同步**：新增 / 重命名 / 弃用 skill 时，同步更新根目录
  `CLAUDE.md` / `AGENTS.md` / `GEMINI.md` / `OPENCLAW.md` 的路由表与 skill 列表。
- **红线**：所有 skill 必须遵守 [`ETHICS.md`](./ETHICS.md) 的 8 条红线（不做贿赂设计 /
  不做税务规避 / 不做证据造假 / 不做人格贬损 / 不越境法律代理 / 不做医疗诊断代理 /
  不做金融牌照业务代理 / 不做规避监管的对外话术）。

---

## 三、Commit 规范

采用 **Conventional Commits**，附 HelmForge AI 辅助 trailer。

**格式**：

```
<type>(<scope>): <subject>

<body>

🤖 Generated with HelmForge (skill-governor + skill-deploy)
Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
```

- `type`: `feat` / `fix` / `docs` / `refactor` / `test` / `chore`
- `scope`: skill 名（如 `finance-manager`）、阶段（`p1`-`p5`）、或子系统（`deploy` / `docs`）
- `subject`: 现在时祈使句，首字母小写，不加句号
- **AI 辅助 commit 必须** 附 `🤖 Generated with HelmForge (…)` trailer
  和 `Co-Authored-By:` 行（列出实际参与的模型 / agent）

**示例**：

```
feat(finance-manager): add loss-company valuation methods

- add VC method, excess earnings, NAV, real options
- update references/dcf-valuation.md
- sync 4 mirrors (MD5 verified)

Closes #42

🤖 Generated with HelmForge (skill-governor + skill-deploy)
Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
```

---

## 四、PR 模板（Pull Request Template）

打开 PR 时，请复制以下模板到 PR body 并逐项填写。**AI 辅助披露栏为必填**。

```markdown
## Summary
<1-3 bullets 概括本次改动的目的与效果>

## Changes
- Skill: <name(s), e.g. finance-manager>
- Type: new / edit / deprecation
- Mirrors updated:
  - [ ] .claude
  - [ ] .codex
  - [ ] .gemini
  - [ ] .agents

## Verification
- [ ] 四镜像 MD5 一致（或已在下方注明有意分叉理由）
- [ ] 入口文档已更新（CLAUDE.md / AGENTS.md / GEMINI.md / OPENCLAW.md）
- [ ] 路由表已更新（若新增 skill 或改变触发词）
- [ ] ETHICS.md 8 条红线自检通过
- [ ] `skill-deploy` post-smoothing PASS

## AI 辅助披露（AI-assisted disclosure，mandatory）
- Used skills: <e.g. /skill-governor, /finance-manager, /skill-deploy>
- Model / agent used: <e.g. Claude Opus 4.7 (1M), GLM-5.2, Gemini 2.5 Pro>
- Reviewed & edited by human: yes / no + notes
- 是否涉及外部素材借用: yes / no
  - 若 yes: 是否按 skill-governor 的 PolyForm-NC 合规改写流程处理: yes / no

## Related
Closes #<issue-number>
```

> **备注**：AI 辅助披露不是形式主义。HelmForge 是"人类掌舵 + AI 副驾驶"的系统，
> 我们希望社区始终清楚每一次改动背后的人机分工，便于评审、回溯与责任归属。

---

## 五、License 与伦理提醒

- **License**: [PolyForm Noncommercial 1.0.0](./LICENSE)
  - 非商业使用（个人 / 教育 / 科研 / 非营利 / 内部评估）**永久免费**
  - **商业使用需另行书面授权**（SaaS 化部署 / 嵌入商业产品 / 对外提供服务的生产部署等）
  - **本项目不会转为其他 OSS License**，PolyForm-NC 永久默认
  - 商业授权申请: 见 [`ETHICS.md`](./ETHICS.md) § 3.2（`helmforge-commercial@example.com`，占位待替换）
- **ETHICS**: [`ETHICS.md`](./ETHICS.md) 的 **8 条经营红线是硬约束**，任何 skill / PR / issue
  不得触碰。触发红线会立即导致 License 终止（PolyForm-NC § Violations）。
- **外部借用**：如从 CodeForge / VitaForge 或其他 PolyForm-NC 项目借用骨架，
  必须走 [`skill-governor`](./.claude/skills/skill-governor/SKILL.md) 的
  **PolyForm-NC 合规改写流程**，禁止 verbatim 复制。

---

## 六、社区价值观（Community Values）

HelmForge 是一份献给企业掌舵者的 **公共利益 skill pack**：把经营 know-how、
财务底层原理、法律边界、谈判战术、行政节奏这些原本只在少数顾问、律所、
投行、家办里流转的能力，交回到每一位创业者、经营者、家族传承人手里。

请贡献那些**让这套系统对下一位掌舵者更有用**的东西：
更准的模板、更清晰的边界、更真实的案例、更负责的红线。

对彼此保持尊重，对使用者保持诚实，对 ETHICS 保持敬畏。
不要提交任何违反 [`ETHICS.md`](./ETHICS.md) 的内容——
让 HelmForge 始终是那把**值得放在船长手边的舵**。

⚓ **Forge your enterprise. Take the helm.**
