# OpenClaw Google Ads投放优化系统

## 🚀 项目简介

这是一个基于OpenClaw的Google Ads投放优化系统，包含5个专业agents协同工作，提供从策略制定到投放优化的完整AI解决方案。

## ✨ 核心特性

- **🤖 5个专业agents协同工作**：策略、创意、分析、优化、协调各司其职
- **🔗 智能任务分发**：Orchestrator自动分析需求并调用专业agents
- **💬 Discord集成**：通过Discord频道进行自然语言交互
- **📊 数据驱动决策**：基于数据分析的优化建议
- **🔄 持续学习**：自动保存历史记录和最佳实践
- **⚡ 一键部署**：自动化配置和部署流程

## 🏗️ 系统架构

```
用户需求 → Discord频道 → Orchestrator → 专业agents → 整合结果 → 返回用户
```

### Agents组成

| Agent | 角色 | 核心能力 |
|-------|------|----------|
| **Orchestrator** | 总协调员 | 需求分析、任务分发、结果整合 |
| **Strategist** | 策略专家 | 广告策略、预算规划、受众分析 |
| **Creative** | 创意专家 | 文案创作、创意设计、着陆页优化 |
| **Analyst** | 数据分析专家 | 数据监控、效果分析、报告生成 |
| **Optimizer** | 投放优化专家 | 关键词优化、出价调整、质量分提升 |

## 🚀 快速开始

### 前提条件

- OpenClaw已安装并运行
- Discord bot已配置并邀请到服务器
- Python 3.8+ 和 bash 环境

### 一键部署

```bash
# 1. 下载部署包
git clone https://github.com/jundihuang/toufang-skill.git
cd toufang-skill/openclaw-config

# 2. 运行部署脚本
chmod +x scripts/deploy-openclaw.sh
./scripts/deploy-openclaw.sh
```

### 手动配置

1. **复制配置文件**
   ```bash
   cp templates/config-template.json ~/.openclaw/config.json
   ```

2. **更新Discord频道ID**
   ```bash
   # 编辑配置文件，替换YOUR_CHANNEL_ID
   nano ~/.openclaw/config.json
   ```

3. **更新系统提示词**
   ```bash
   python3 scripts/update-prompts.py --apply
   ```

4. **重启服务**
   ```bash
   openclaw gateway restart
   ```

## 💬 使用方法

### 基本使用

在Discord频道中直接发送需求：

```
@google-ads-orchestrator 我想推广新产品，预算10000元
```

### 详细需求格式

```
@google-ads-orchestrator

产品: 智能家居设备
预算: 8000元
目标: 获取200个leads
时间: 2周
特殊要求: 重点投放一线城市
```

### 特定功能调用

```
# 只调用策略制定
@google-ads-orchestrator strategist: 制定Q2广告策略

# 只调用创意文案
@google-ads-orchestrator creative: 需要母亲节促销文案

# 只调用数据分析
@google-ads-orchestrator analyst: 分析上月广告效果

# 只调用投放优化
@google-ads-orchestrator optimizer: 优化搜索广告出价
```

## 📁 项目结构

```
openclaw-config/
├── README.md                    # 本文件
├── README-openclaw.md          # 详细部署指南
├── scripts/
│   ├── deploy-openclaw.sh      # 一键部署脚本
│   └── update-prompts.py       # 提示词更新脚本
├── templates/
│   └── config-template.json    # OpenClaw配置模板
└── workspace-templates/        # 工作空间模板文件
```

## ⚙️ 配置说明

### Discord配置

1. 创建Discord文本频道
2. 获取频道ID（开启开发者模式）
3. 在配置文件中更新 `channelId`
4. 确保bot有发送消息和创建子区的权限

### Agents配置

每个agent都有：
- 唯一的ID和名称
- 专业的systemPrompt
- 允许调用的子agents列表
- 专用工作空间路径

### 工作空间

系统会自动创建：
- `/home/ubuntu/.openclaw/workspace-google-ads/`
- 包含SOUL.md、AGENTS.md等基础文件
- memory目录用于存储历史记录

## 🔧 维护和更新

### 更新提示词

```bash
# 检查当前提示词
python3 scripts/update-prompts.py --list

# 更新所有agents的提示词
python3 scripts/update-prompts.py --apply
```

### 备份配置

```bash
# 自动备份（部署脚本包含）
cp ~/.openclaw/config.json ~/.openclaw/config.json.backup.$(date +%Y%m%d)
```

### 查看日志

```bash
# OpenClaw服务日志
journalctl -u openclaw-gateway -f

# Discord插件日志
tail -f ~/.openclaw/logs/discord.log
```

## 🐛 故障排除

### 常见问题

1. **Agents无法调用**
   - 检查 `agentToAgent` 配置
   - 确认orchestrator有 `canSpawn` 权限

2. **Discord消息发送失败**
   - 检查频道ID是否正确
   - 确认bot有发送消息权限
   - 检查网络连接

3. **工作空间创建失败**
   - 检查目录权限
   - 手动创建缺失的目录

### 服务状态检查

```bash
# 检查OpenClaw服务
openclaw gateway status

# 检查agents状态
openclaw agents list

# 测试Discord连接
openclaw plugins discord test
```

## 📈 使用案例

### 案例1：新产品推广
```
用户: @google-ads-orchestrator 推广新款蓝牙耳机，预算5000元
流程:
1. Orchestrator分析需求
2. 调用Strategist制定策略
3. 调用Creative创作文案
4. 调用Optimizer优化投放
5. 整合完整方案返回
```

### 案例2：效果优化
```
用户: @google-ads-orchestrator 分析上周广告数据并优化
流程:
1. Orchestrator接收需求
2. 调用Analyst分析数据
3. 调用Optimizer提供优化建议
4. 返回分析报告和优化方案
```

### 案例3：节日营销
```
用户: @google-ads-orchestrator 母亲节促销活动，预算10000元
流程:
1. Orchestrator识别节日营销需求
2. 调用Strategist制定节日策略
3. 调用Creative创作节日文案
4. 调用Optimizer优化节日关键词
5. 返回完整的节日营销方案
```

## 🔄 扩展开发

### 添加新的Agent

1. 在 `config-template.json` 中添加新的agent配置
2. 更新 `agentToAgent` 权限
3. 创建专业的systemPrompt
4. 运行部署脚本更新配置

### 集成新工具

1. 在 `TOOLS.md` 中记录工具配置
2. 更新agents的systemPrompt包含工具使用说明
3. 测试工具集成效果

### 自定义工作流程

1. 修改Orchestrator的systemPrompt
2. 调整任务分发逻辑
3. 优化结果整合方式
4. 测试新的工作流程

## 📚 相关资源

- [OpenClaw官方文档](https://docs.openclaw.ai)
- [Discord开发者文档](https://discord.com/developers/docs)
- [Google Ads API文档](https://developers.google.com/google-ads/api)
- [OpenClaw Discord社区](https://discord.com/invite/clawd)

## 👥 贡献指南

1. Fork本仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建Pull Request

## 📄 许可证

本项目基于MIT许可证开源 - 查看 [LICENSE](LICENSE) 文件了解详情

## 🙏 致谢

- 感谢OpenClaw团队提供的强大AI代理平台
- 感谢所有贡献者的代码和想法
- 感谢用户的使用和反馈

---

**版本**: 1.0.0  
**最后更新**: 2026-04-09  
**作者**: Jayce  
**状态**: 🟢 生产就绪