# OpenClaw Discord Agent 部署指南

这份指南专门为 Discord 中的 Main Agent 设计，用于自动部署 Google Ads Skills 项目。

## 📋 部署总览

**目标**: 在已配置 OpenClaw + Discord 的服务器上部署 Google Ads Skills 项目

**项目地址**: `https://github.com/your-username/toufang-skill.git` (请替换为实际地址)

**部署时间**: 约 15-20 分钟

**所需权限**: 服务器 SSH 访问、文件写入权限、OpenClaw 配置权限

---

## 🚀 第一步：项目克隆和准备

### Agent 执行指令：

```bash
# 1. 进入 OpenClaw skills 目录
cd /path/to/openclaw/skills/

# 2. 克隆项目
git clone https://github.com/your-username/toufang-skill.git google-ads-skills-temp

# 3. 移动文件到正确位置
mv google-ads-skills-temp/google-ads-orchestrator-agent ./
mv google-ads-skills-temp/google-ads-strategy-agent ./
mv google-ads-skills-temp/google-ads-optimization-agent ./
mv google-ads-skills-temp/google-ads-publishing-agent ./
mv google-ads-skills-temp/google-ads-skills-architecture.md ./

# 4. 清理临时文件
rm -rf google-ads-skills-temp

# 5. 验证目录结构
ls -la | grep google-ads
```

**预期输出**:
```
google-ads-orchestrator-agent/
google-ads-strategy-agent/
google-ads-optimization-agent/
google-ads-publishing-agent/
```

---

## ⚙️ 第二步：修改配置文件

### Agent 执行指令：

```bash
# 1. 备份原配置
cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.backup

# 2. 获取服务器实际地址
echo "当前服务器地址: $(hostname -I | awk '{print $1}')"
echo "OpenClaw 端口: $(grep -r 'port' ~/.openclaw/openclaw.json | head -1)"
```

### 配置文件生成（Agent 需要执行）:

**创建新的 openclaw.json**:
```bash
cat > ~/.openclaw/openclaw_new_skills.json << 'EOF'
{
  "skills": [
    {
      "name": "google-ads-orchestrator-agent",
      "enabled": true,
      "manifestPath": "/path/to/openclaw/skills/google-ads-orchestrator-agent/manifest.json",
      "systemPromptPath": "/path/to/openclaw/skills/google-ads-orchestrator-agent/prompts/system.md",
      "description": "Google Ads 全流程编排助手"
    },
    {
      "name": "google-ads-strategy-agent",
      "enabled": true,
      "manifestPath": "/path/to/openclaw/skills/google-ads-strategy-agent/manifest.json",
      "systemPromptPath": "/path/to/openclaw/skills/google-ads-strategy-agent/prompts/system.md",
      "description": "Google Ads 投放前策略规划"
    },
    {
      "name": "google-ads-publishing-agent",
      "enabled": false,
      "manifestPath": "/path/to/openclaw/skills/google-ads-publishing-agent/manifest.json",
      "systemPromptPath": "/path/to/openclaw/skills/google-ads-publishing-agent/prompts/system.md",
      "description": "Google Ads 广告发布（待开发）"
    },
    {
      "name": "google-ads-optimization-agent",
      "enabled": false,
      "manifestPath": "/path/to/openclaw/skills/google-ads-optimization-agent/manifest.json",
      "systemPromptPath": "/path/to/openclaw/skills/google-ads-optimization-agent/prompts/system.md",
      "description": "Google Ads 效果优化（待开发）"
    }
  ],
  "discord": {
    "primaryAgent": "google-ads-orchestrator-agent",
    "fallbackAgents": ["google-ads-strategy-agent"]
  }
}
EOF
```

**合并到主配置**:
```bash
# Agent 需要手动合并或使用 jq 工具
# 如果有 jq 工具：
jq -s '.[0] * .[1]' ~/.openclaw/openclaw.json ~/.openclaw/openclaw_new_skills.json > ~/.openclaw/openclaw_merged.json
mv ~/.openclaw/openclaw_merged.json ~/.openclaw/openclaw.json
```

---

## 🔧 第三步：更新服务器地址

### Agent 执行指令：

```bash
# 获取服务器信息
SERVER_IP=$(hostname -I | awk '{print $1}')
SERVER_PORT=8080  # 根据实际情况调整

# 更新所有 manifest.json 中的服务器地址
find /path/to/openclaw/skills/google-ads-* -name "manifest.json" -exec sed -i "s|https://openclaw.local|http://${SERVER_IP}:${SERVER_PORT}|g" {} \;

# 验证修改
grep -r "http://" /path/to/openclaw/skills/google-ads-*/manifest.json
```

---

## 🤖 第四步：创建 Discord 专用提示词

### Agent 执行指令：

```bash
# 为每个 agent 创建 Discord 专用系统提示词

# 1. Orchestrator Agent Discord 版本
cat > /path/to/openclaw/skills/google-ads-orchestrator-agent/prompts/discord.md << 'EOF'
你是 Google Ads 全流程编排助手，运行在 Discord 环境中。

## Discord 环境特性
- 响应要简洁，避免过长消息
- 使用 Discord 格式化（代码块、emoji）
- 复杂结果使用文件附件
- 支持多轮对话和追问

## 工作流程
1. 分析用户在 Discord 中的需求
2. 调用对应的专业 agents
3. 返回 Discord 友好的结果格式

## 可调用 Agents
- ✅ google-ads-strategy-agent (策略规划)
- ❌ google-ads-publishing-agent (即将上线)
- ❌ google-ads-optimization-agent (即将上线)

## 输出格式
使用 Discord 消息特性，保持简洁友好。
EOF

# 2. Strategy Agent Discord 版本
cat > /path/to/openclaw/skills/google-ads-strategy-agent/prompts/discord.md << 'EOF'
你是 Google Ads 投放前策略助手，在 Discord 中为用户提供策略规划服务。

## Discord 环境要求
- 输出简洁但完整
- 使用 emoji 提升可读性
- 复杂策略用文件附件

## 工作模式
用户可以用自然语言描述需求，你负责：
1. 理解业务目标和约束
2. 生成完整策略规划
3. 提供可执行的建议

## 输出格式
始终输出 JSON 格式，适配 Discord 展示。
EOF
```

---

## 📁 第五步：创建输出目录

### Agent 执行指令：

```bash
# 创建结果输出目录
mkdir -p /var/www/openclaw-results/google-ads/
chown -R openclaw:openclaw /var/www/openclaw-results/
chmod -R 755 /var/www/openclaw-results/

# 创建日志目录
mkdir -p /var/log/openclaw/google-ads/
touch /var/log/openclaw/google-ads/strategy.log
touch /var/log/openclaw/google-ads/orchestrator.log
chown -R openclaw:openclaw /var/log/openclaw/google-ads/
```

---

## 🔄 第六步：重启 OpenClaw 服务

### Agent 执行指令：

```bash
# 重启 OpenClaw 服务
systemctl restart openclaw

# 或者使用 PM2（如果使用 PM2）
pm2 restart openclaw

# 等待服务启动
sleep 10

# 检查服务状态
systemctl status openclaw
# 或
pm2 status openclaw
```

---

## ✅ 第七步：验证部署

### Agent 执行验证指令：

```bash
# 1. 检查 skills 是否加载
openclaw-cli agent list | grep google-ads

# 2. 检查配置文件语法
cat ~/.openclaw/openclaw.json | jq .

# 3. 查看 Discord 连接状态
openclaw-cli discord status

# 4. 检查日志
tail -20 /var/log/openclaw/google-ads/orchestrator.log
```

### Discord 测试指令（在 Discord 中执行）：

```
@YourBot 帮我测试 Google Ads Strategy Agent 是否正常工作
```

**预期响应**:
```
✅ Google Ads Strategy Agent 运行正常！

📊 当前已加载的 Google Ads Skills:
- ✅ google-ads-orchestrator-agent
- ✅ google-ads-strategy-agent
- ❌ google-ads-publishing-agent (即将上线)
- ❌ google-ads-optimization-agent (即将上线)

💬 您可以开始使用策略规划功能了！
```

---

## 🎯 第八步：功能测试

### 测试场景 1: 策略规划

```
@YourBot 帮我策划一个母亲节护肤礼盒的美国市场广告活动，预算2万美元，目标是销量转化
```

### 测试场景 2: 完整流程

```
@YourBot 我要为新产品做 Google Ads 推广，从策略到发布，你能帮我做什么？
```

---

## 🚨 故障排除

### 问题 1: Skills 未加载
```bash
# 检查文件权限
ls -la /path/to/openclaw/skills/google-ads-*/manifest.json

# 修复权限
chmod -R 644 /path/to/openclaw/skills/google-ads-*/manifest.json
chmod -R 644 /path/to/openclaw/skills/google-ads-*/prompts/*.md
```

### 问题 2: Discord Bot 无响应
```bash
# 检查 Discord 连接
openclaw-cli discord test

# 重启 Discord 服务
systemctl restart openclaw-discord
```

### 问题 3: 配置文件错误
```bash
# 验证 JSON 语法
cat ~/.openclaw/openclaw.json | jq .

# 恢复备份
cp ~/.openclaw/openclaw.json.backup ~/.openclaw/openclaw.json
```

---

## 📚 部署完成后的下一步

1. **测试基础功能**: 验证 Strategy Agent 和 Orchestrator Agent
2. **优化 Discord 体验**: 调整输出格式和响应速度
3. **添加更多功能**: 逐步启用 Publishing 和 Optimization Agents
4. **监控运行状态**: 定期检查日志和性能指标

---

## 🎉 部署成功标志

✅ 所有 Google Ads skills 文件就位
✅ OpenClaw 配置文件更新完成
✅ Discord Bot 能响应 Google Ads 相关指令
✅ Strategy Agent 能输出完整的策略规划
✅ Orchestrator Agent 能正确路由用户需求

部署完成后，用户就可以在 Discord 中直接使用完整的 Google Ads 策略规划功能了！