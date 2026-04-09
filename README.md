# Google Ads Skills

一个面向 Google Ads 投放全流程的 Skill 项目。

这套项目不是单一的“大而全助手”，而是按照真实投放阶段拆成 3 个主 Skill，再通过一个总控 Skill 串起来，适合在一个对话里完成从投放前规划到投放后优化的闭环。

## 项目目标

这套 Skills 主要解决 3 类问题：

1. 投放前不知道该怎么定目标、拆人群、做策略、写文案
2. 已经有方案，但不知道怎么把广告内容同步到投放平台
3. 广告上线后，不知道怎么监控数据、找问题、提优化建议和生成报告

对应地，项目被设计成 3 个主 Skill：

- `google-ads-strategy-agent`
- `google-ads-publishing-agent`
- `google-ads-optimization-agent`

以及 1 个总控入口：

- `google-ads-orchestrator-agent`

## 推荐使用方式

### 1. 投放前

使用 [google-ads-strategy-agent/README.md](/Users/aimmy/Desktop/skills/google-ads-strategy-agent/README.md)

它负责：

- 目标分析
- 投放策略
- 关键词与人群方向
- 素材和文案生成
- 基础搭建建议

适合：

- 新活动从 0 到 1 规划
- 节日营销活动设计
- 搜索广告文案和素材方向生成

### 2. 投放发布

使用 [google-ads-publishing-agent/README.md](/Users/aimmy/Desktop/skills/google-ads-publishing-agent/README.md)

它负责：

- 校验发布所需字段
- 将策略和广告内容映射成平台对象
- 执行或模拟执行发布
- 返回对象级执行结果

适合：

- 已经有策略方案，准备发到 Google Ads
- 想先做发布前校验
- 想知道发布失败卡在哪一步

### 3. 投放后优化

使用 [google-ads-optimization-agent/README.md](/Users/aimmy/Desktop/skills/google-ads-optimization-agent/README.md)

它负责：

- 表现数据整理
- 问题诊断
- 优化建议
- 日报、周报、活动复盘

适合：

- 广告上线后监控效果
- 分析 CTR、CPA、ROAS 异常
- 生成阶段性报告和复盘结论

### 4. 单入口全流程

使用 [google-ads-orchestrator-agent/README.md](/Users/aimmy/Desktop/skills/google-ads-orchestrator-agent/README.md)

它负责：

- 识别用户当前处于哪个阶段
- 选择合适的主 Skill
- 在需要时串联多个 Skill
- 汇总结果给用户

如果你想让用户“只和一个入口对话”，这是推荐入口。

## 项目结构

### 对外主入口

- [google-ads-strategy-agent](/Users/aimmy/Desktop/skills/google-ads-strategy-agent)
- [google-ads-publishing-agent](/Users/aimmy/Desktop/skills/google-ads-publishing-agent)
- [google-ads-optimization-agent](/Users/aimmy/Desktop/skills/google-ads-optimization-agent)
- [google-ads-orchestrator-agent](/Users/aimmy/Desktop/skills/google-ads-orchestrator-agent)

### 架构文档

- [google-ads-skills-architecture.md](/Users/aimmy/Desktop/skills/google-ads-skills-architecture.md)

### 历史参考实现

- [google-ads-campaign-agent](/Users/aimmy/Desktop/skills/google-ads-campaign-agent)

### 内部参考目录

这些目录是之前的细粒度拆分版本，当前保留作为内部参考，不建议作为对外主入口：

- [google-ads-brief-agent](/Users/aimmy/Desktop/skills/google-ads-brief-agent)
- [google-ads-audience-keyword-agent](/Users/aimmy/Desktop/skills/google-ads-audience-keyword-agent)
- [google-ads-creative-agent](/Users/aimmy/Desktop/skills/google-ads-creative-agent)
- [google-ads-setup-agent](/Users/aimmy/Desktop/skills/google-ads-setup-agent)
- [google-ads-data-ingestion-agent](/Users/aimmy/Desktop/skills/google-ads-data-ingestion-agent)
- [google-ads-performance-agent](/Users/aimmy/Desktop/skills/google-ads-performance-agent)
- [google-ads-reporting-agent](/Users/aimmy/Desktop/skills/google-ads-reporting-agent)

## 每个 Skill 里有什么

每个主 Skill 基本都包含这些文件：

- `README.md`
- `manifest.json`
- `prompts/system.md`
- `schemas/*.json`
- `examples/*.json`

可以这样理解：

- `README.md`：说明这个 Skill 做什么、什么时候用
- `manifest.json`：Skill 的接口定义
- `prompts/`：提示词约束
- `schemas/`：输入输出 JSON 结构
- `examples/`：示例输入输出

## 如何上手

如果你是第一次看这个项目，建议按这个顺序：

1. 先看 [google-ads-skills-architecture.md](/Users/aimmy/Desktop/skills/google-ads-skills-architecture.md)
2. 再看 [google-ads-orchestrator-agent/README.md](/Users/aimmy/Desktop/skills/google-ads-orchestrator-agent/README.md)
3. 如果你只关心某一个阶段，再进入对应主 Skill 的 `README`
4. 打开对应目录下的 `examples/*.json`，照着示例准备输入

## 示例入口

### Strategy

- [google-ads-strategy-agent/examples/mothers-day.strategy.input.json](/Users/aimmy/Desktop/skills/google-ads-strategy-agent/examples/mothers-day.strategy.input.json)
- [google-ads-strategy-agent/examples/mothers-day.strategy.output.json](/Users/aimmy/Desktop/skills/google-ads-strategy-agent/examples/mothers-day.strategy.output.json)

### Publishing

- [google-ads-publishing-agent/examples/mothers-day.publish.input.json](/Users/aimmy/Desktop/skills/google-ads-publishing-agent/examples/mothers-day.publish.input.json)
- [google-ads-publishing-agent/examples/mothers-day.publish.output.json](/Users/aimmy/Desktop/skills/google-ads-publishing-agent/examples/mothers-day.publish.output.json)

### Optimization

- [google-ads-optimization-agent/examples/performance-low-roas.input.json](/Users/aimmy/Desktop/skills/google-ads-optimization-agent/examples/performance-low-roas.input.json)
- [google-ads-optimization-agent/examples/performance-low-roas.output.json](/Users/aimmy/Desktop/skills/google-ads-optimization-agent/examples/performance-low-roas.output.json)

### Orchestrator

- [google-ads-orchestrator-agent/examples/full-funnel.input.json](/Users/aimmy/Desktop/skills/google-ads-orchestrator-agent/examples/full-funnel.input.json)
- [google-ads-orchestrator-agent/examples/full-funnel.output.json](/Users/aimmy/Desktop/skills/google-ads-orchestrator-agent/examples/full-funnel.output.json)

## 当前边界

这套项目当前已经完成的是：

- Skill 分层设计
- 主入口目录结构
- 基础 prompt / manifest / schema
- 示例输入输出

这套项目当前还没有默认保证的是：

- 已经接通真实 Google Ads API
- 已经接通 GA4 / Merchant Center
- 已经支持真实自动发布
- 已经支持真实自动拉数

也就是说，目前它更准确地说是：

`可用于设计、集成、演示和后续实现的 Skill 项目骨架`

而不是已经 fully production-ready 的广告自动化系统。

## OpenClaw 部署

### 一键部署到 OpenClaw
项目包含完整的 OpenClaw 配置，支持一键部署多智能体系统：

```bash
# 1. 克隆项目
git clone https://github.com/jundihuang/toufang-skill.git
cd toufang-skill

# 2. 设置 Discord 频道 ID（部署前需要在 Discord 中创建）
export DISCORD_MAIN_CHANNEL_ID="你的主频道ID"
export DISCORD_STRATEGY_CHANNEL_ID="策略子区ID"
export DISCORD_OPTIMIZATION_CHANNEL_ID="优化子区ID"
export DISCORD_PUBLISHING_CHANNEL_ID="发布子区ID"

# 3. 运行部署脚本
chmod +x openclaw-config/deploy-openclaw.sh
./openclaw-config/deploy-openclaw.sh
```

### OpenClaw 配置特点
- **完整的 4-agent 系统**：Orchestrator + Strategy + Optimization + Publishing
- **自动配置**：一键完成所有 OpenClaw 配置
- **Discord 集成**：自动绑定 Discord 频道和子区
- **工作空间创建**：自动创建各 agent 的工作空间
- **权限配置**：自动配置 agent-to-agent 调用权限

详细部署指南见：[openclaw-config/README.md](openclaw-config/README.md)

## 建议的下一步

如果继续往下做，优先级建议是：

1. 继续细化 `google-ads-publishing-agent` 的平台对象结构
2. 继续细化 `google-ads-optimization-agent` 的报表维度和诊断输入
3. 为 orchestrator 增加更完整的路由与拼装逻辑
4. 在有外部接口条件时接入真实 Google Ads / GA4 数据能力

