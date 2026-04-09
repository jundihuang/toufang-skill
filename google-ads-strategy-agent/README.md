# Google Ads Strategy Agent

## 这是什么？

这是投放前使用的主 Skill。

它把用户的一次广告需求，整理成从目标分析到投放策略、再到素材和内容生成的一整套方案。

## 它负责什么？

- 分析业务目标
- 梳理活动背景和约束
- 拆解目标人群
- 规划关键词与搜索意图方向
- 推荐广告类型和投放路径
- 规划预算与阶段节奏
- 生成广告文案和素材方向
- 给出基础搭建建议

## 适合什么时候用？

适用于这些场景：

- 准备新投一个活动
- 不知道该选哪种广告类型
- 想先得到完整策略再去投放
- 需要生成搜索广告标题、描述、卖点和 CTA

## 输入

- 活动名称
- 主题
- 产品与价格信息
- 投放市场与语言
- 时间周期
- 预算
- 转化目标
- KPI 目标
- 历史经验
- 特殊限制

## 示例

- 输入示例：`examples/mothers-day.strategy.input.json`
- 输出示例：`examples/mothers-day.strategy.output.json`

## 输出

- Goal Summary
- Strategy Plan
- Audience / Keyword Directions
- Creative Pack
- Setup Guide
- 启动后一周建议动作

## 不负责什么？

- 不直接向 Google Ads 平台发布广告
- 不直接拉取真实平台数据
- 不负责正式投后报表
