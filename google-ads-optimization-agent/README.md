# Google Ads Optimization Agent

## 这是什么？

这是投放后使用的主 Skill。

它把广告平台数据、站内数据和转化数据连接起来，完成监控、诊断、改进建议和报告生成。

## 它负责什么？

- 拉取或接收表现数据
- 标准化表现快照
- 判断问题类型
- 输出改进建议和优先级动作
- 生成日报、周报和活动复盘
- 沉淀经验和可复用结论

## 适合什么时候用？

适用于这些场景：

- 广告已经上线，想看表现
- 想知道为什么 CTR / CPA / ROAS 异常
- 想拿到下一步优化动作
- 想自动生成日报或活动复盘

## 输入

- 广告平台数据
- 站内行为数据
- 转化和收入数据
- 当前结构摘要
- 历史基线

## 示例

- 输入示例：`examples/performance-low-roas.input.json`
- 输出示例：`examples/performance-low-roas.output.json`

## 输出

- Performance Snapshot
- Diagnostics
- Optimization Actions
- Daily / Weekly Summary
- Campaign Retrospective
- Learnings

## 不负责什么？

- 不负责投放前策略生成
- 不直接负责广告平台发布

## 当前说明

如果没有接入真实平台与分析工具，这个 Skill 目前可以先接手工报表或外部系统整理后的 JSON，再输出监控、诊断和报告。
