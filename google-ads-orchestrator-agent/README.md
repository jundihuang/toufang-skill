# Google Ads Orchestrator Agent

## 这是什么？

这是三段式 Google Ads Skills 的总控入口。

它不替代底层主 skill，而是负责：

- 识别用户当前处于哪个投放阶段
- 决定应该调用哪个主 skill
- 把前一个 skill 的输出传给下一个 skill
- 汇总为用户真正需要的结果

## 对外主工作流

1. `google-ads-strategy-agent`
2. `google-ads-publishing-agent`
3. `google-ads-optimization-agent`

## 典型用法

- 用户要做投放前规划：调用 `google-ads-strategy-agent`
- 用户要正式发布广告：调用 `google-ads-publishing-agent`
- 用户要看投后表现和报告：调用 `google-ads-optimization-agent`
- 用户要一个对话走完整流程：由 orchestrator 负责串联

## 示例

- 输入示例：`examples/full-funnel.input.json`
- 输出示例：`examples/full-funnel.output.json`

## 当前边界

当前仓库里先落地的是“编排定义与接口骨架”，不是已经接好所有平台 API 的运行时系统。
