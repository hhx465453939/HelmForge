# 国内 API 供应商配置指南

> 本文档 for HelmForge — 企业掌舵者的 AI 经营驾驶舱。所有配置示例可直接用于驱动 HelmForge 的 18 skill。

**面向对象**：位于中国大陆、无法稳定访问 Anthropic 官方 API 的企业用户、创始人、CEO、总经理、职能高管，以及希望用国产大模型降低 AI 决策辅助成本的组织。

**HelmForge 与模型的关系**：HelmForge 的 18 个 skill（战略、财务、人力、法务、运营、风控、董事会、投融资、并购、传承、危机、公关、董秘、内审、合规、ESG、创新、数字化）本质上都是 prompt 层配置，与底层模型解耦。**任何 Anthropic API 协议兼容的供应商都能驱动 HelmForge**。国产旗舰模型（GLM-5.2、DeepSeek V4 Pro、Kimi K2.7、小米 MiMo v2.5）已经在企业场景（战略推演、财务分析、法务审阅、董事会材料生成）上具备足够能力。

---

## 一、为什么需要国内模型

Anthropic 官方 API（`api.anthropic.com`）在中国大陆存在以下问题：

1. **网络不可达**：官方端点对中国大陆 IP 不提供服务，需要跨境网络方案，不满足企业合规与稳定性要求。
2. **支付与开票**：Anthropic 结算走美元卡，国内企业财务入账、增值税发票、外汇管理流程复杂。
3. **数据合规**：企业内部经营数据（战略、财务、人事、客户）跨境传输可能触发《数据出境安全评估办法》《个人信息保护法》相关义务，需要评估。
4. **响应延迟**：即便通过跨境线路，长上下文任务（如董事会材料生成、并购尽调分析）的稳定性和延迟表现不理想。

**替代方案**：Claude Code / Claude Agent SDK 提供了 `ANTHROPIC_BASE_URL` 环境变量入口，可以把 API 请求路由到任何兼容 Anthropic Messages 协议的第三方端点。国产大模型厂商（智谱、DeepSeek、Moonshot Kimi、小米、硅基流动）都提供了官方 Anthropic 兼容端点，配置几个环境变量即可切换。

这也意味着：**HelmForge 用户不需要修改 skill 内容，只需要配置本地环境，就能用国产模型驱动整个企业管理 skill 网络**。

---

## 二、快速选型（HelmForge 场景视角）

| 供应商 | 主打模型 | 上下文 | HelmForge 推荐场景 |
|--------|---------|--------|--------------------|
| **智谱 GLM（推荐首选）** | `glm-5.2[1m]` | 1M | 战略推演、董事会材料、并购尽调（长上下文）、跨 skill 协同 |
| DeepSeek | `deepseek-v4-pro[1m]` | 1M | 高频批量任务：合同批量审阅、财报批量摘要、员工反馈批量归类 |
| Kimi K2.7 | `kimi-k2.7` | 256K | 循环型 agent 任务（内审、合规巡检），思考 token 更省 |
| 小米 MiMo v2.5 | `mimo-v2.5-pro[1m]` | 1M | 端云一体、生态整合场景 |
| 硅基流动 | 多家聚合 | 视模型 | 需要在多个开源模型间横向对比时 |

**HelmForge 官方建议**：先用 **智谱 GLM-5.2[1m]** 起步，覆盖 80% 掌舵者日常场景；对高频、成本敏感的批量任务再切换到 DeepSeek。

---

## 三、通用配置原理

Claude Code / Claude Agent SDK 识别的核心环境变量：

| 变量名 | 用途 |
|--------|------|
| `ANTHROPIC_BASE_URL` | 供应商 Anthropic 兼容端点 |
| `ANTHROPIC_AUTH_TOKEN` | 你的 API Key |
| `ANTHROPIC_MODEL` | 主力模型 ID（复杂任务，如战略、并购、董事会） |
| `ANTHROPIC_SMALL_FAST_MODEL` | 小快模型 ID（摘要、分类、路由等轻任务） |
| `CLAUDE_CODE_AUTO_COMPACT_WINDOW` | 上下文压缩阈值（要吃满 1M 上下文必须调） |

**重要规则**：如果模型支持 1M 上下文，模型名要带 `[1m]` 后缀，同时把 `CLAUDE_CODE_AUTO_COMPACT_WINDOW` 设为 `1000000`，否则 Claude Code 用默认压缩窗口，等于白开长上下文。Kimi K2.7 的 256K 上下文对应 `262144`。

---

## 四、智谱 GLM-5.2（HelmForge 推荐旗舰）

**申请入口**：
- 大陆：<https://open.bigmodel.cn/>（bigmodel MaaS 平台）
- 海外：<https://z.ai/>（z.ai 智谱海外站，含 GLM Coding Plan 订阅）

**推荐模型**：
- 主力：`glm-5.2[1m]` — 1M 上下文，能力对标 Claude Sonnet 4.6，是 HelmForge 战略/并购/董事会材料的首选
- 小快：`glm-4.7` — 用于 skill 内部的短摘要、路由、分类

**端点**：`https://api.z.ai/api/anthropic`（当前官方主推）

### 4.1 Linux / macOS (bash / zsh)

```bash
export ANTHROPIC_BASE_URL=https://api.z.ai/api/anthropic
export ANTHROPIC_AUTH_TOKEN=your-glm-api-key
export ANTHROPIC_MODEL="glm-5.2[1m]"
export ANTHROPIC_SMALL_FAST_MODEL=glm-4.7
export CLAUDE_CODE_AUTO_COMPACT_WINDOW=1000000
export API_TIMEOUT_MS=3000000
claude
```

### 4.2 Windows PowerShell

```powershell
$env:ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic"
$env:ANTHROPIC_AUTH_TOKEN="your-glm-api-key"
$env:ANTHROPIC_MODEL="glm-5.2[1m]"
$env:ANTHROPIC_SMALL_FAST_MODEL="glm-4.7"
$env:CLAUDE_CODE_AUTO_COMPACT_WINDOW="1000000"
$env:API_TIMEOUT_MS="3000000"
claude
```

### 4.3 Windows CMD

```cmd
set ANTHROPIC_BASE_URL=https://api.z.ai/api/anthropic
set ANTHROPIC_AUTH_TOKEN=your-glm-api-key
set ANTHROPIC_MODEL=glm-5.2[1m]
set ANTHROPIC_SMALL_FAST_MODEL=glm-4.7
set CLAUDE_CODE_AUTO_COMPACT_WINDOW=1000000
set API_TIMEOUT_MS=3000000
claude
```

> 官方文档：<https://docs.z.ai/devpack/tool/claude>（含最新模型清单、GLM Coding Plan 计费说明）
>
> 境内用户如果 z.ai 端点访问慢，可以试 `open.bigmodel.cn/api/anthropic` 端点作为备份。

---

## 五、DeepSeek（高性价比批量首选）

**申请入口**：<https://platform.deepseek.com/>

**推荐模型**：
- 主力：`deepseek-v4-pro[1m]` — 1M 上下文，性价比极高
- 小快：`deepseek-v4-flash[1m]` — 用于批量摘要、批量分类

**端点**：`https://api.deepseek.com/anthropic`

### 5.1 bash / zsh

```bash
export ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic
export ANTHROPIC_AUTH_TOKEN=your-deepseek-api-key
export ANTHROPIC_MODEL="deepseek-v4-pro[1m]"
export ANTHROPIC_SMALL_FAST_MODEL="deepseek-v4-flash[1m]"
export CLAUDE_CODE_AUTO_COMPACT_WINDOW=1000000
claude
```

### 5.2 PowerShell

```powershell
$env:ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"
$env:ANTHROPIC_AUTH_TOKEN="your-deepseek-api-key"
$env:ANTHROPIC_MODEL="deepseek-v4-pro[1m]"
$env:ANTHROPIC_SMALL_FAST_MODEL="deepseek-v4-flash[1m]"
$env:CLAUDE_CODE_AUTO_COMPACT_WINDOW="1000000"
claude
```

### 5.3 CMD

```cmd
set ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic
set ANTHROPIC_AUTH_TOKEN=your-deepseek-api-key
set ANTHROPIC_MODEL=deepseek-v4-pro[1m]
set ANTHROPIC_SMALL_FAST_MODEL=deepseek-v4-flash[1m]
set CLAUDE_CODE_AUTO_COMPACT_WINDOW=1000000
claude
```

**典型 HelmForge 场景**：内审 skill 批量扫描 100 份合同的合规风险条款、人力 skill 批量分析员工满意度调研的开放题。

---

## 六、Kimi K2.7-Code（256K 上下文，循环 agent 友好）

**申请入口**：
- <https://kimi.com/>（Kimi Code 平台，Coding 专用 Key）
- 文档：<https://platform.kimi.ai/docs/guide/agent-support>

**推荐模型**：`kimi-k2.7-code`
- 1T 总参 / 32B 激活的 MoE 模型
- **256K 上下文**（对应 `CLAUDE_CODE_AUTO_COMPACT_WINDOW=262144`）
- 思考 token 相比 K2.6 减少约 30%，长循环 agent 场景成本优势明显

**端点变更提醒**：老端点 `api.moonshot.cn/anthropic` 在新的 Kimi Code 平台 Key（`sk-kimi-` 前缀）下会返回 401，请使用 `https://api.kimi.com/coding/`。

### 6.1 bash / zsh

```bash
export ANTHROPIC_BASE_URL=https://api.kimi.com/coding/
export ANTHROPIC_AUTH_TOKEN=your-kimi-api-key
export ANTHROPIC_MODEL=kimi-k2.7-code
export ANTHROPIC_DEFAULT_OPUS_MODEL=kimi-k2.7-code
export ANTHROPIC_DEFAULT_SONNET_MODEL=kimi-k2.7-code
export ANTHROPIC_DEFAULT_HAIKU_MODEL=kimi-k2.7-code
export CLAUDE_CODE_SUBAGENT_MODEL=kimi-k2.7-code
export CLAUDE_CODE_AUTO_COMPACT_WINDOW=262144
export ENABLE_TOOL_SEARCH=false
claude
```

### 6.2 PowerShell

```powershell
$env:ANTHROPIC_BASE_URL="https://api.kimi.com/coding/"
$env:ANTHROPIC_AUTH_TOKEN="your-kimi-api-key"
$env:ANTHROPIC_MODEL="kimi-k2.7-code"
$env:ANTHROPIC_DEFAULT_OPUS_MODEL="kimi-k2.7-code"
$env:ANTHROPIC_DEFAULT_SONNET_MODEL="kimi-k2.7-code"
$env:ANTHROPIC_DEFAULT_HAIKU_MODEL="kimi-k2.7-code"
$env:CLAUDE_CODE_SUBAGENT_MODEL="kimi-k2.7-code"
$env:CLAUDE_CODE_AUTO_COMPACT_WINDOW="262144"
$env:ENABLE_TOOL_SEARCH="false"
claude
```

### 6.3 CMD

```cmd
set ANTHROPIC_BASE_URL=https://api.kimi.com/coding/
set ANTHROPIC_AUTH_TOKEN=your-kimi-api-key
set ANTHROPIC_MODEL=kimi-k2.7-code
set ANTHROPIC_DEFAULT_OPUS_MODEL=kimi-k2.7-code
set ANTHROPIC_DEFAULT_SONNET_MODEL=kimi-k2.7-code
set ANTHROPIC_DEFAULT_HAIKU_MODEL=kimi-k2.7-code
set CLAUDE_CODE_SUBAGENT_MODEL=kimi-k2.7-code
set CLAUDE_CODE_AUTO_COMPACT_WINDOW=262144
set ENABLE_TOOL_SEARCH=false
claude
```

**HelmForge 典型场景**：合规 skill 做全年内控循环巡检、危机 skill 做 24 小时舆情跟踪，K2.7 的低思考 token + 256K 窗口很适合。

---

## 七、小米 MiMo v2.5-pro（1M 上下文）

**申请入口**：小米开放平台 / Xiaomi Token Plan 站点。

**推荐模型**：`mimo-v2.5-pro[1m]`（主力）/ `mimo-v2.5[1m]`（小快）

**端点**：`https://token-plan-cn.xiaomimimo.com/anthropic`

### 7.1 bash / zsh

```bash
export ANTHROPIC_BASE_URL=https://token-plan-cn.xiaomimimo.com/anthropic
export ANTHROPIC_AUTH_TOKEN=your-mimo-api-key
export ANTHROPIC_MODEL="mimo-v2.5-pro[1m]"
export ANTHROPIC_SMALL_FAST_MODEL="mimo-v2.5[1m]"
export CLAUDE_CODE_AUTO_COMPACT_WINDOW=1000000
claude
```

### 7.2 PowerShell

```powershell
$env:ANTHROPIC_BASE_URL="https://token-plan-cn.xiaomimimo.com/anthropic"
$env:ANTHROPIC_AUTH_TOKEN="your-mimo-api-key"
$env:ANTHROPIC_MODEL="mimo-v2.5-pro[1m]"
$env:ANTHROPIC_SMALL_FAST_MODEL="mimo-v2.5[1m]"
$env:CLAUDE_CODE_AUTO_COMPACT_WINDOW="1000000"
claude
```

### 7.3 CMD

```cmd
set ANTHROPIC_BASE_URL=https://token-plan-cn.xiaomimimo.com/anthropic
set ANTHROPIC_AUTH_TOKEN=your-mimo-api-key
set ANTHROPIC_MODEL=mimo-v2.5-pro[1m]
set ANTHROPIC_SMALL_FAST_MODEL=mimo-v2.5[1m]
set CLAUDE_CODE_AUTO_COMPACT_WINDOW=1000000
claude
```

---

## 八、硅基流动（SiliconFlow，多模型聚合网关）

**申请入口**：<https://cloud.siliconflow.cn/>

硅基流动一个 Key 通过官方脚本可以在多家国产开源模型（Kimi-K2、DeepSeek-V3、ERNIE-4.5、Kimi-Dev-72B 等）间无缝切换，适合还在评估阶段的团队。

**一键安装脚本**（Linux/macOS）：

```bash
bash -c "$(curl -fsSL https://static01.siliconflow.cn/cdn/assets/claude_code_with_siliconcloud_install_0716.sh)"
```

按提示粘贴 SiliconCloud API Key、方向键选模型即可。

**手动配置示例**（PowerShell，以 DeepSeek-V3 为例）：

```powershell
$env:ANTHROPIC_BASE_URL="https://api.siliconflow.cn/anthropic"
$env:ANTHROPIC_AUTH_TOKEN="your-siliconflow-api-key"
$env:ANTHROPIC_MODEL="Pro/deepseek-ai/DeepSeek-V3"
claude
```

**官方文档**：<https://docs.siliconflow.cn/cn/usercases/use-siliconcloud-in-ClaudeCode>

**HelmForge 建议**：硅基流动主要作为"多模型横向对比 + 试错"的入口，正式生产建议切到对应厂商官方端点，稳定性和 SLA 更可控。

---

## 九、settings.json 持久化配置（推荐）

环境变量的问题是每次开新终端都要重设。**Claude Code 官方推荐用 `~/.claude/settings.json` 持久化**，重开终端也生效。

编辑 `~/.claude/settings.json`（Windows 是 `C:\Users\<你>\.claude\settings.json`，不存在就新建），以 GLM-5.2 为例：

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "your-glm-api-key",
    "ANTHROPIC_MODEL": "glm-5.2[1m]",
    "ANTHROPIC_SMALL_FAST_MODEL": "glm-4.7",
    "CLAUDE_CODE_AUTO_COMPACT_WINDOW": "1000000",
    "API_TIMEOUT_MS": "3000000",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "glm-4.7",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "glm-5.2[1m]",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "glm-5.2[1m]"
  }
}
```

保存后重开 `claude`。在 Claude Code 里输 `/status` 查看实际模型；用 `/model` 切换；用 `/effort` 调推理力度。

**HelmForge 项目级建议**：把 settings.json 放在 `~/.claude/`（用户级）而不是仓库根目录。API Key 属于个人凭据，不进 git。

---

## 十、多供应商一键切换（HelmForge 掌舵者场景）

企业实际使用中，掌舵者可能在同一天里：
- 早上用 GLM 做战略推演
- 中午用 DeepSeek 批量审 100 份合同
- 晚上用 Kimi 跑合规循环巡检

写个 shell / PowerShell 函数即可秒切。

### 10.1 bash / zsh（加到 `~/.bashrc` 或 `~/.zshrc`）

```bash
# 把 Key 放到 ~/.secrets.env（chmod 600 + .gitignore），再 source 它
# source ~/.secrets.env

hf-glm() {
  export ANTHROPIC_BASE_URL=https://api.z.ai/api/anthropic
  export ANTHROPIC_AUTH_TOKEN=$GLM_KEY
  export ANTHROPIC_MODEL="glm-5.2[1m]"
  export ANTHROPIC_SMALL_FAST_MODEL=glm-4.7
  export CLAUDE_CODE_AUTO_COMPACT_WINDOW=1000000
  echo "HelmForge: switched to GLM-5.2 (1M ctx)"
}

hf-deepseek() {
  export ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic
  export ANTHROPIC_AUTH_TOKEN=$DEEPSEEK_KEY
  export ANTHROPIC_MODEL="deepseek-v4-pro[1m]"
  export ANTHROPIC_SMALL_FAST_MODEL="deepseek-v4-flash[1m]"
  export CLAUDE_CODE_AUTO_COMPACT_WINDOW=1000000
  echo "HelmForge: switched to DeepSeek V4 Pro (1M ctx)"
}

hf-kimi() {
  export ANTHROPIC_BASE_URL=https://api.kimi.com/coding/
  export ANTHROPIC_AUTH_TOKEN=$KIMI_KEY
  export ANTHROPIC_MODEL=kimi-k2.7-code
  export ANTHROPIC_DEFAULT_OPUS_MODEL=kimi-k2.7-code
  export ANTHROPIC_DEFAULT_SONNET_MODEL=kimi-k2.7-code
  export ANTHROPIC_DEFAULT_HAIKU_MODEL=kimi-k2.7-code
  export CLAUDE_CODE_AUTO_COMPACT_WINDOW=262144
  export ENABLE_TOOL_SEARCH=false
  echo "HelmForge: switched to Kimi K2.7-Code (256K ctx)"
}

hf-mimo() {
  export ANTHROPIC_BASE_URL=https://token-plan-cn.xiaomimimo.com/anthropic
  export ANTHROPIC_AUTH_TOKEN=$MIMO_KEY
  export ANTHROPIC_MODEL="mimo-v2.5-pro[1m]"
  export ANTHROPIC_SMALL_FAST_MODEL="mimo-v2.5[1m]"
  export CLAUDE_CODE_AUTO_COMPACT_WINDOW=1000000
  echo "HelmForge: switched to Xiaomi MiMo v2.5 (1M ctx)"
}
```

用法：`hf-glm && claude`

### 10.2 PowerShell（加到 `$PROFILE`）

```powershell
function hf-glm {
  $env:ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic"
  $env:ANTHROPIC_AUTH_TOKEN=$env:GLM_KEY
  $env:ANTHROPIC_MODEL="glm-5.2[1m]"
  $env:ANTHROPIC_SMALL_FAST_MODEL="glm-4.7"
  $env:CLAUDE_CODE_AUTO_COMPACT_WINDOW="1000000"
  Write-Host "HelmForge: switched to GLM-5.2 (1M ctx)" -ForegroundColor Cyan
}

function hf-deepseek {
  $env:ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"
  $env:ANTHROPIC_AUTH_TOKEN=$env:DEEPSEEK_KEY
  $env:ANTHROPIC_MODEL="deepseek-v4-pro[1m]"
  $env:ANTHROPIC_SMALL_FAST_MODEL="deepseek-v4-flash[1m]"
  $env:CLAUDE_CODE_AUTO_COMPACT_WINDOW="1000000"
  Write-Host "HelmForge: switched to DeepSeek V4 Pro (1M ctx)" -ForegroundColor Cyan
}

function hf-kimi {
  $env:ANTHROPIC_BASE_URL="https://api.kimi.com/coding/"
  $env:ANTHROPIC_AUTH_TOKEN=$env:KIMI_KEY
  $env:ANTHROPIC_MODEL="kimi-k2.7-code"
  $env:ANTHROPIC_DEFAULT_OPUS_MODEL="kimi-k2.7-code"
  $env:ANTHROPIC_DEFAULT_SONNET_MODEL="kimi-k2.7-code"
  $env:ANTHROPIC_DEFAULT_HAIKU_MODEL="kimi-k2.7-code"
  $env:CLAUDE_CODE_AUTO_COMPACT_WINDOW="262144"
  $env:ENABLE_TOOL_SEARCH="false"
  Write-Host "HelmForge: switched to Kimi K2.7-Code (256K ctx)" -ForegroundColor Cyan
}

function hf-mimo {
  $env:ANTHROPIC_BASE_URL="https://token-plan-cn.xiaomimimo.com/anthropic"
  $env:ANTHROPIC_AUTH_TOKEN=$env:MIMO_KEY
  $env:ANTHROPIC_MODEL="mimo-v2.5-pro[1m]"
  $env:ANTHROPIC_SMALL_FAST_MODEL="mimo-v2.5[1m]"
  $env:CLAUDE_CODE_AUTO_COMPACT_WINDOW="1000000"
  Write-Host "HelmForge: switched to Xiaomi MiMo v2.5 (1M ctx)" -ForegroundColor Cyan
}
```

用法：`hf-glm; claude`

---

## 十一、成本对比（2026-07，仅供参考）

| 供应商 | 输入价格（¥/M tokens） | 输出价格（¥/M tokens） | HelmForge 场景成本参考 |
|--------|-----------------------|------------------------|-----------------------|
| DeepSeek V4 Pro | 约 1 元 | 约 8 元 | 一份完整并购尽调报告（20 万 tokens 输入 + 5 万 tokens 输出）约 0.6 元 |
| **GLM-5.2[1m]**（Coding Plan） | 起步 20 元/月订阅制 | 起步 20 元/月订阅制 | 中小企业 CEO 单人月度使用完全够 |
| Kimi K2.7-Code | 约 6.7 元（$0.95/M）* | 约 28 元（$4.00/M）* | 一次全年合规循环巡检（100 万 tokens）约 34 元 |
| 小米 MiMo v2.5-pro | 视订阅计划 | 视订阅计划 | 参考小米官方定价页 |
| 硅基流动 | 视具体模型 | 视具体模型 | 混合定价，按选定模型走 |
| Anthropic Claude Opus 4（对照） | 约 108 元（$15/M） | 约 540 元（$75/M） | 单份并购报告约 40 元 |

\* Kimi 按 USD 计价，¥/M 按 7 汇率折算，实际以官方为准。

**成本结论**：
- **降本首选**：GLM Coding Plan 订阅制 — 中小企业 CEO 月度成本可控制在 20-50 元
- **批量首选**：DeepSeek V4 Pro — 单价最低，适合内审、合同批量审阅、员工反馈归类
- **循环首选**：Kimi K2.7 — 思考 token 少 30%，长循环 agent 巡检省钱
- **一句话**：相比直连 Anthropic Opus，用国产模型驱动 HelmForge 通常能省 90% 以上

---

## 十二、验证配置生效

```bash
# 1. 检查环境变量
echo $ANTHROPIC_BASE_URL         # Linux/macOS/Git Bash
# 或
$env:ANTHROPIC_BASE_URL          # PowerShell

# 2. 启动 Claude Code
claude

# 3. 在 Claude Code 会话里
> /status
# 检查显示的 model / endpoint 是否为你配置的

# 4. 调用一个 HelmForge skill 试试
> 我是一家 SaaS 公司的 CEO，年营收 5000 万，正在考虑并购一个 300 万营收的竞品，帮我做战略推演
# HelmForge 应会路由到战略 + 并购 skill 联合输出
```

---

## 十三、常见问题

### Q1：环境变量设了但 Claude Code 不生效？
必须在**同一个终端会话**里先设变量再启动 `claude`。PowerShell 的 `$env:` 是进程级作用域，关窗口就没了；要持久化用 `~/.claude/settings.json` 或加到 `$PROFILE`。

### Q2：401 Unauthorized？
- API Key 拼错、含空格、含换行
- Key 过期或没充值
- 用错端点（Kimi Code 平台的 `sk-kimi-` Key 只能配 `api.kimi.com/coding/`，配到老的 `api.moonshot.cn` 会 401）

### Q3：`model not found`？
- 模型名过时（供应商每几个月会 rev 一次），去官方文档查最新
- 忘了 `[1m]` 后缀（1M 上下文模型必须带）

### Q4：企业数据合规担心？
- 国产供应商在境内提供服务，不涉及跨境传输
- 但仍建议评估：脱敏后再喂 → 敏感字段（客户手机号、身份证、财务明细）掩码 → 战略级机密走本地私有部署（大部分厂商都提供私有化方案）
- HelmForge 的 skill 本身不采集用户数据，敏感度取决于你输入了什么

### Q5：能同时配多个 Key 让 HelmForge 各 skill 用不同模型吗？
Claude Code 环境变量是全局的，同一时刻只走一家供应商。如果要 skill 级路由，需要在 HelmForge skill 里显式指定模型（未来版本考虑加入 skill-level model routing）。当前建议：用第 10 节的切换函数按会话切。

### Q6：HelmForge 的 18 skill 用国产模型能力够吗？
实测（内部评估基准）：
- **战略、并购、董事会、投融资**（重推理）：GLM-5.2[1m] 表现接近 Claude Sonnet 4.6，可用
- **财务、内审、法务、合规**（结构化任务）：DeepSeek V4 Pro 和 GLM-5.2 都很稳
- **公关、危机、传承**（重语言表达）：GLM-5.2 中文表达略优于 DeepSeek
- **人力、运营、风控、ESG、创新、数字化、董秘、传承**：主流国产旗舰均可用

结论：**国产旗舰模型完全能承接 HelmForge 全部 18 skill 的生产使用**。

---

## 十四、企业内使用的合规建议

1. **不要把 API Key 提交到 git**：全部走本地环境变量或 `~/.claude/settings.json`，加入 `.gitignore`
2. **敏感数据脱敏**：客户 PII、员工薪酬、董事会未公开事项在输入前做掩码
3. **服务分级**：战略级机密 → 私有部署 / 本地小模型；一般管理事项 → 云端 API
4. **审计留痕**：`~/.claude/` 下可保留对话日志（各家 SDK 自带），必要时纳入企业内控留档
5. **供应商合规资质**：企业采购 API 服务时索取供应商的等保备案、算法备案、数据处理协议

---

## 十五、与 HelmForge 主流程的衔接

配好本文档描述的国内 API 后：

1. 安装 Claude Code：`npm install -g @anthropic-ai/claude-code`
2. 用本指南任一节配好环境变量或 settings.json
3. 启动 `claude`
4. 在 Claude Code 会话里加载 HelmForge skill（参考 [README.md](../README.md) 的一句话部署 prompt）
5. 使用 18 个 skill 中任一个（战略、财务、人力、法务、运营、风控、董事会、投融资、并购、传承、危机、公关、董秘、内审、合规、ESG、创新、数字化）

---

## 反馈与贡献

- 新供应商 / 新模型 → 欢迎提 PR 补充
- 配置踩坑 → 到 HelmForge Issues 反馈
- 相关话题：`docs`, `national-api`, `helmforge-config`
