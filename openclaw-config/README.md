# Google Ads Skills - OpenClaw 部署指南

本目录包含 Google Ads Skills 项目的 **OpenClaw 专用部署配置**，支持一键部署完整的 Google Ads 多智能体系统。

## 📋 目录结构

```
openclaw-config/
├── config-template.json    # OpenClaw 配置模板
├── deploy-openclaw.sh     # 一键部署脚本
└── README.md             # 本文件
```

## 🚀 快速开始

### 前提条件
1. 已安装 OpenClaw 并正常运行
2. 已配置 Discord 频道（主频道 + 3个子区）
3. 已安装 `jq` 命令行工具

### 部署步骤

#### 步骤 1: 设置环境变量（可选）
```bash
# 设置 OpenClaw 目录（如果不在默认位置）
export OPENCLAW_HOME="/path/to/your/.openclaw"

# 设置 Discord 频道 ID（部署前需要在 Discord 中创建）
export DISCORD_MAIN_CHANNEL_ID="123456789012345678"
export DISCORD_STRATEGY_CHANNEL_ID="123456789012345679"
export DISCORD_OPTIMIZATION_CHANNEL_ID="123456789012345680"
export DISCORD_PUBLISHING_CHANNEL_ID="123456789012345681"
```

#### 步骤 2: 运行部署脚本
```bash
# 进入项目目录
cd /path/to/toufang-skill

# 运行部署脚本
chmod +x openclaw-config/deploy-openclaw.sh
./openclaw-config/deploy-openclaw.sh
```

#### 步骤 3: 验证部署
```bash
# 检查服务状态
openclaw gateway status

# 检查 agents 列表
openclaw agent list | grep google-ads
```

## 🔧 配置说明

### 1. Discord 频道结构要求
部署前需要在 Discord 服务器中创建以下结构：

```
Google Ads 主频道 (DISCORD_MAIN_CHANNEL_ID)
├── 绑定: google-ads-orchestrator
├── strategy 子区 (DISCORD_STRATEGY_CHANNEL_ID)
│   └── 绑定: google-ads-strategy
├── optimization 子区 (DISCORD_OPTIMIZATION_CHANNEL_ID)
│   └── 绑定: google-ads-optimization
└── publishing 子区 (DISCORD_PUBLISHING_CHANNEL_ID)
    └── 绑定: google-ads-publishing
```

### 2. 部署脚本功能
部署脚本会自动完成以下操作：

1. **环境检查** - 验证 OpenClaw 安装和必要工具
2. **配置备份** - 备份原 openclaw.json 配置
3. **文件复制** - 复制所有 Google Ads skills 到 OpenClaw
4. **服务器地址更新** - 更新 manifest.json 中的服务器地址
5. **系统提示词优化** - 添加 OpenClaw 特定指令
6. **配置生成** - 生成完整的 OpenClaw 配置片段
7. **配置合并** - 合并到主 openclaw.json 文件
8. **工作空间创建** - 创建所有 agents 的工作空间
9. **服务重启** - 重启 OpenClaw 服务加载新配置

### 3. 生成的配置内容
部署脚本会添加以下配置到 `openclaw.json`：

#### Agents 定义
```json
{
  "id": "google-ads-orchestrator",
  "name": "Google Ads Orchestrator",
  "workspace": "...",
  "model": "deepseek/deepseek-chat",
  "subagents": {
    "allowAgents": ["google-ads-strategy", "google-ads-optimization", "google-ads-publishing"]
  }
}
```

#### Agent-to-Agent 权限
```json
"agentToAgent": {
  "enabled": true,
  "allow": [
    "google-ads-orchestrator",
    "google-ads-strategy",
    "google-ads-optimization",
    "google-ads-publishing"
  ]
}
```

#### Discord 绑定
```json
{
  "agentId": "google-ads-orchestrator",
  "match": {
    "channel": "discord",
    "peer": {
      "kind": "channel",
      "id": "DISCORD_MAIN_CHANNEL_ID"
    }
  }
}
```

## 🧪 测试部署

### 测试 1: 服务状态
```bash
openclaw gateway status
```

### 测试 2: Agents 列表
```bash
openclaw agent list | grep google-ads
```

### 测试 3: Discord 功能
在 Discord 中发送测试消息：

1. **主频道测试** (Orchestrator):
   ```
   @Bot 帮我策划一个母亲节护肤礼盒的广告活动
   ```

2. **子区测试** (直接访问):
   - strategy 子区: 策略规划请求
   - optimization 子区: 效果优化请求
   - publishing 子区: 发布执行请求

## 🔄 更新和卸载

### 更新配置
```bash
# 重新运行部署脚本
./openclaw-config/deploy-openclaw.sh
```

### 卸载配置
1. 手动从 `openclaw.json` 中删除 Google Ads 相关配置
2. 删除 skills 目录中的 Google Ads 文件
3. 删除 workspace 目录
4. 重启 OpenClaw 服务

## 🚨 故障排除

### 常见问题 1: jq 命令未找到
```bash
# Ubuntu/Debian
sudo apt-get install jq

# macOS
brew install jq
```

### 常见问题 2: Discord 频道绑定失败
- 确认频道 ID 正确
- 确认 Bot 有频道访问权限
- 检查 Discord 配置中的 `allow` 设置

### 常见问题 3: Agents 无法互相调用
- 检查 `subagents.allowAgents` 配置
- 检查 `agentToAgent.allow` 配置
- 确认所有 agents 都已正确配置

### 常见问题 4: 服务重启失败
```bash
# 手动重启
openclaw gateway restart

# 检查日志
tail -f /tmp/openclaw/openclaw-*.log
```

## 📊 部署成功标志

✅ 所有检查项通过
✅ 配置备份创建成功
✅ Skills 文件复制完成
✅ 服务器地址更新完成
✅ 配置合并成功
✅ 工作空间创建完成
✅ OpenClaw 服务重启成功
✅ Agents 在列表中可见
✅ Discord 频道绑定正常
✅ 多 agent 协作功能正常

## 📞 支持

如有问题，请：
1. 检查部署脚本输出日志
2. 查看 OpenClaw 日志文件
3. 参考 OpenClaw 官方文档
4. 在项目 Issues 中提出问题

---

**版本**: 1.0.0  
**最后更新**: 2026-04-09  
**兼容性**: OpenClaw 2026.3+