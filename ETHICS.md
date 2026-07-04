# ETHICS.md — HelmForge 企业经营伦理红线

> **⚓ Forge your enterprise. Take the helm.**
>
> 本文件定义 HelmForge 全部使用场景下不可逾越的**八条企业经营红线**。
> License（PolyForm Noncommercial 1.0.0）授权的是合法、合规、负责任的非商业用途；
> 任何违反下列红线的使用，**立即触发 License 终止**（详见第 5 节）。

---

## 1. 目的与范围

本文件适用于 HelmForge 项目的**所有使用形态**，包括但不限于：

- 个人 / 教育 / 科研 / 非营利 / 内部测试场景下的安装、部署、二次开发与调用
- 18 个 skill 中的任意单一调用或组合调用
- 经商业授权协议另行许可后的企业生产部署（授权后仍受本红线约束）

**HelmForge 不替代律师 / 会计师 / 审计师 / 税务师 / 内审 / 合规官 / 公证 / 监管机构**的专业意见。
本红线为 **AI 经营副驾驶的使用约束**，不构成法律意见。

---

## 2. 八条企业经营红线（与设计稿 §8.2 同源）

| # | 红线 | 中文条目 | 禁止用途说明 |
|---|---|---|---|
| 1 | 🚫 Anti-commercial-bribery | 反商业贿赂 | 禁止用于设计 / 策划 / 执行任何形式的贿赂、回扣、利益输送、政商灰色操作、隐性佣金、虚开发票冲账等行为 |
| 2 | 🚫 Anti-financial-fraud | 反财务欺诈 | 禁止用于财务造假、虚假陈述、报表操纵、收入/成本跨期调节、业绩粉饰、关联交易非公允定价、隐瞒负债 |
| 3 | 🚫 Anti-monopoly | 反垄断 | 禁止用于价格操纵、市场瓜分、串通投标、滥用市场支配地位、排他性协议设计、经营者集中规避申报 |
| 4 | 🚫 Anti-money-laundering | 反洗钱 | 禁止用于洗钱、资金通道设计、规避外汇管制、虚拟资产匿名混币、空壳公司架构搭建用于掩盖资金来源 |
| 5 | 🔒 Data-privacy | 数据隐私 | 处理企业 / 客户 / 员工 / 合作伙伴敏感数据须脱敏，遵守数据跨境合规（GDPR / PIPL / CCPA / 各国数据保护法） |
| 6 | ⚖️ Compliance-boundary | 合规边界 | 不替代律师 / 会计师 / 审计师 / 税务师专业意见；**重大决策须人类复核**，AI 输出仅供讨论参考 |
| 7 | 🤝 Human-in-loop | 人在回路 | 重大经营决策（投资 / 裁员 / 并购 / 披露 / 战略转型 / 重大合同 / 重大融资）**必须人类最终拍板**，AI 仅作参谋 |
| 8 | 🌱 ESG-encouragement | ESG 鼓励 | 鼓励负责任、可持续的经营决策；反对短视逐利、生态破坏、社会代价外溢、子孙后代透支 |

### 2.1 红线判定原则

当用户请求落入或疑似落入上表任一红线时，HelmForge 应：

1. **立即拒绝**生成涉嫌违法的内容（话术 / 模板 / 数据 / 决策建议）
2. **明确说明**触发的红线编号与原因
3. **给出合规替代**（如适用）：将违法意图改写为合法等价诉求
4. **保留日志**：触发记录写入用户本地 worklog，便于事后审计

---

## 3. 商业使用授权流程

HelmForge 默认以 **PolyForm Noncommercial License 1.0.0** 授权（详见 [LICENSE](./LICENSE) § Noncommercial Purposes）。

### 3.1 何为"商业使用"

下列任一情形即构成商业使用：

- ❌ SaaS / 付费服务 / 订阅 / API 计费
- ❌ 嵌入商业产品或商业工作流（含 SaaS 化部署、对外提供服务的内部生产部署）
- ❌ 用作咨询 / 培训 / 课程 / 出版等收费交付物的核心引擎
- ❌ 在盈利性组织（含个体经营、合伙、公司、外资、合资）的生产经营环境中常规调用

下列**不构成**商业使用：

- ✅ 个人学习 / 研究 / 实验用途
- ✅ 教育 / 科研 / 非营利组织的内部使用（即便接受捐赠 / 政府资助）
- ✅ 公共安全 / 卫生 / 环保 / 政府机构的公共服务用途
- ✅ 商业企业的**纯内部评估 / 测试 / 原型验证**（不进入生产决策流）
- ✅ 公平使用（fair use）权利下的引用 / 评论 / 学术研究

### 3.2 商业授权申请

如需商业使用，须另行签署书面商业授权协议。请联系：

> **邮箱（占位，owner 待替换）**: `helmforge-commercial@example.com`

申请邮件请包含：

- 申请人 / 申请主体（机构名称、注册地、统一社会信用代码 / 工商注册号）
- 拟使用范围（哪些 skill、是否生产部署、预计调用量级）
- 数据合规承诺（脱敏 / 跨境 / 隐私 / 安全）
- 红线承诺（书面同意遵守本 ETHICS.md §2 全部条款）

商业授权**不**改变 PolyForm-NC 的**永久非商业**默认条款，亦**不**包含 Change Date 转开源条款（参见 §4）。

---

## 4. 报告与反馈

### 4.1 举报伦理违规

发现任何 HelmForge 使用者涉嫌违反本红线，可通过以下渠道举报：

- **GitHub Issues**: <https://github.com/hhx465453939/HelmForge/issues>（公开渠道，建议脱敏后提交）
- **邮箱（占位）**: `helmforge-commercial@example.com`（标题前缀 `[ETHICS]`）

举报内容应包括：

- 涉嫌违反的具体红线编号（§2 中的 1–8）
- 客观证据（截图、链接、时间戳、对话片段）
- 涉事主体（如方便披露，便于追溯）

### 4.2 反馈与改进建议

对红线条款本身的修订建议（如新增行业特定红线、细化判定标准），同样欢迎通过 Issues 提交。

---

## 5. 违规处理

根据 PolyForm Noncommercial 1.0.0 § Violations 条款：

> The first time you are notified in writing that you have violated any of these terms,
> or done anything with the software not covered by your licenses, your licenses can
> nonetheless continue if you come into full compliance with these terms, and take
> practical steps to correct past violations, within 32 days of receiving notice.
> Otherwise, all your licenses end immediately.

**HelmForge 项目方对违规处理的处置原则：**

1. **首次书面通知**：通过 Issues 或邮件发出违规通知，给予 32 天整改窗口
2. **整改验收**：违规方需完成整改并书面承诺，由项目方复核
3. **立即终止**：涉及红线 1–4（反贿赂 / 反欺诈 / 反垄断 / 反洗钱）的故意违规，**直接终止 License**，不适用 32 天宽限
4. **追溯效力**：License 终止后，违规方此前所有基于 HelmForge 的衍生作品使用权同步终止
5. **法律保留**：项目方保留向监管机关、司法机关提供配合的合法权利

---

## 附录 A：红线判定流程图（文字版）

```
用户请求 → 是否落入 §2 任一红线？
            │
            ├─ 是 ─→ 是否红线 1-4？
            │       │
            │       ├─ 是 ─→ 直接拒绝 + 说明红线 + 给出合规替代
            │       └─ 否 ─→ 拒绝 + 说明红线 + 引导人类复核（§6 / §7）
            │
            └─ 否 ─→ 是否重大决策？
                    │
                    ├─ 是 ─→ 提供建议但标注"需人类最终拍板"（§7 人在回路）
                    └─ 否 ─→ 正常输出 + worklog 记录
```

## 附录 B：术语对照

| 中文 | 英文 | 来源 |
|---|---|---|
| 反商业贿赂 | Anti-commercial-bribery | UN Anti-Corruption / 中国《反不正当竞争法》§7 |
| 反财务欺诈 | Anti-financial-fraud | SOX / 中国《会计法》§9 |
| 反垄断 | Anti-monopoly | 中国《反垄断法》/ EU Competition Law |
| 反洗钱 | Anti-money-laundering | FATF / 中国《反洗钱法》 |
| 数据隐私 | Data-privacy | GDPR / PIPL / CCPA |
| 合规边界 | Compliance-boundary | HelmForge 项目自定 |
| 人在回路 | Human-in-loop | AI 治理通用原则（OECD / NIST AI RMF） |
| ESG 鼓励 | ESG-encouragement | UN PRI / SASB / 中国《ESG 评价通则》 |

---

_Document version: 1.0 · Effective date: 2026-07-04 · Maintained by HelmForge contributors_
