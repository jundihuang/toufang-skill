# Google Ads Campaign Agent (OpenClaw Skill)

> 当前状态：历史参考版单体 Skill。建议优先使用三段式主 Skill：
> `google-ads-strategy-agent`、`google-ads-publishing-agent`、`google-ads-optimization-agent`。

## 这是什么？

这是一个“Google 广告投放助手”。它不会替你去点 Google Ads 后台按钮，而是把你提供的信息整理成：

- **投放策略**（怎么投、投哪些类型、预算怎么分）
- **广告文案/素材方向**（标题、描述、卖点、CTA）
- **数据分析解释**（为什么 CTR 低、为什么没转化）
- **下一步优化动作**（先做什么、怎么验证是否有效）

你可以把它理解成：一个很懂投放逻辑的“同学/助教”，帮你把思路写成一份清晰的作业答案。

## 最小闭环（MVP）能做什么？

### A. 投放前（Planning）

你输入活动信息 → 它输出：

- `GoalSummary`：一句话目标总结
- `StrategyPlan`：投放策略建议
- `CreativePack`：标题/描述/卖点/CTA/素材方向
- `SetupGuide`：把策略翻译成“后台怎么搭建”的建议

### B. 投放后（Performance）

你输入投放数据 → 它输出：

- `Diagnostics`：把问题分成“曝光/点击/转化”等类别，并解释原因
- `OptimizationActions`：下一步优化动作（P0/P1/P2 优先级）+ 怎么验证

## 文件结构（你会用到的）

- `manifest.json`：这个 Skill 的说明（名字、版本、输入输出定义）
- `schemas/`：输入输出的数据结构定义（JSON Schema）
  - `planning-input.schema.json`
  - `performance-input.schema.json`
  - `agent-output.schema.json`
- `prompts/`：提示词（把模型当成“会写作业的同学”怎么说）
  - `system.md`
  - `planning.md`
  - `setup.md`
  - `analysis.md`
- `examples/`：示例输入输出（你可以照着填）
  - `mothers-day.input.json`
  - `mothers-day.output.json`
  - 其他对照用例
- `eval/`：自检清单（可选，但很有用）
  - `checklist.md`

## 你怎么用它？（最简单方式：照着 examples 填）

1. 先打开 `examples/mothers-day.input.json` 看看要填什么。
2. 把你的活动信息照着填成一个 JSON（就像填表）。
3. 把 JSON 作为“输入”给 Agent（OpenClaw 如何喂输入，取决于你那边的集成方式）。
4. 你会拿到一个结构化 JSON 输出（见 `examples/mothers-day.output.json`）。

## 字段怎么理解？（零基础解释）

- **campaign**：一次“活动投放计划”，就像一次“主题活动作业”。
- **adGroup**：campaign 里的小分组，通常按“关键词意图/品类/人群”分。
- **CTR**：点击率，表示看到广告的人里有多少人点了。\n  - CTR 低：通常是“广告不够吸引人”或“展示给了不对的人”。\n
- **CPC**：每次点击花多少钱。
- **Conversion**：你想要用户做的事（下单/注册/加购等）。
- **CPA**：每次转化花多少钱（越低通常越好）。
- **ROAS**：广告回报率，简单理解：花 1 块广告费带来多少销售额。\n

## 注意（很重要）

- 它给的是**建议**，不保证结果；如果你没提供数据，它会用“假设/待验证”的方式写清楚。
- 不要把账号密码、密钥、信用卡信息放进输入里。
