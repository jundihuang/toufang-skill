# Google Ads Publishing Agent

## 这是什么？

这是投放执行阶段使用的主 Skill。

它负责把策略和广告内容真正整理成可同步到广告平台的发布对象，并返回执行结果。

## 它负责什么？

- 校验发布所需字段是否齐全
- 将策略内容映射为平台对象
- 创建或更新 campaign、ad group、ads、assets
- 同步预算、关键词、受众、出价等配置
- 返回发布成功、失败、缺失信息和对象 ID

## 适合什么时候用？

适用于这些场景：

- 已经有策略方案，准备正式发布
- 想把生成的广告内容同步到 Google Ads
- 想知道发布失败在哪一步

## 输入

- Strategy Skill 输出
- 平台信息
- 账户标识
- 发布模式
- Campaign / Ad Group / Asset Group 对象
- 广告素材对象
- 关键词、受众、预算、出价配置

## 示例

- 输入示例：`examples/mothers-day.publish.input.json`
- 输出示例：`examples/mothers-day.publish.output.json`

## 输出

- 发布前校验结果
- 即将执行的对象清单
- 发布结果
- 错误原因
- 缺失字段
- 平台对象 ID
- 各对象级执行状态

## 不负责什么？

- 不负责生成投放策略
- 不负责投后监控与报表

## 当前说明

如果没有接入真实 Google Ads API，这个 Skill 当前只能作为“发布协议与执行骨架”使用，不能视为已经具备真实自动发布能力。
