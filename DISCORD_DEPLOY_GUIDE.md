# 🤖 Discord Main Agent 快速部署指南

## 👋 给 Discord Main Agent 的说明

**你的身份**: OpenClaw 的 Main Agent，负责管理 Discord 中的其他 agents

**你的任务**: 部署 Google Ads Skills 项目到当前服务器

**项目信息**:
- 名称: Google Ads Skills (投放策略+优化分析)
- 类型: Multi-agent system (4个专业agents)
- 用途: Google Ads 广告全流程管理

---

## 📋 部署前检查清单

请先确认以下信息，然后告诉我结果:

1. **服务器基本信息**:
   ```bash
   hostname -I
   whoami
   which openclaw-cli
   ```

2. **OpenClaw 安装路径**:
   ```bash
   find / -name "openclaw.json" 2>/dev/null
   ```

3. **当前 Discord 状态**:
   ```bash
   openclaw-cli discord status
   ```

---

## 🚀 三种部署方式（选择一种）

### 方式 A: 全自动脚本部署 (推荐)

执行以下命令:
```bash
# 下载并运行部署脚本
curl -o /tmp/discord-deploy.sh https://raw.githubusercontent.com/your-username/toufang-skill/main/discord-deploy.sh
chmod +x /tmp/discord-deploy.sh
sudo /tmp/discord-deploy.sh
```

### 方式 B: 交互式部署 (更安全)

逐步执行以下命令:
```bash
# 1. 准备环境
cd /path/to/openclaw/skills/
mkdir -p google-ads-backup

# 2. 克隆项目
git clone https://github.com/your-username/toufang-skill.git google-ads-temp

# 3. 检查内容
ls -la google-ads-temp/
read -p "检查文件，确认继续? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    mv google-ads-temp/google-ads-*-agent/ ./
    rm -rf google-ads-temp
fi
```

### 方式 C: 完全手动部署 (最安全)

按照 `OPENCLAW_DEPLOYMENT_GUIDE.md` 中的详细步骤手动执行

---

## 🔧 配置文件更新

部署完成后，请更新 OpenClaw 主配置:

```bash
# 1. 备份原配置
cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.backup

# 2. 查看新配置
cat /path/to/openclaw/google-ads-skills.json

# 3. 手动合并到主配置
# 或使用 jq 工具自动合并
jq -s '.[0] * .[1]' ~/.openclaw/openclaw.json /path/to/openclaw/google-ads-skills.json > ~/.openclaw/openclaw-new.json

# 4. 替换原配置
mv ~/.openclaw/openclaw-new.json ~/.openclaw/openclaw.json
```

---

## 🧪 部署验证

执行以下命令验证部署:

```bash
# 1. 检查文件
find /path/to/openclaw/skills/ -name "*google-ads*" -type d

# 2. 验证配置
cat ~/.openclaw/openclaw.json | grep google-ads

# 3. 测试 agents
openclaw-cli agent test google-ads-strategy-agent
```

---

## 💬 Discord 测试指令

部署完成后，在 Discord 中测试:

```
@YourBot 帮我策划一个母亲节护肤礼盒的广告活动

@YourBot 我要做 Google Ads，从哪里开始？

@YourBot 测试 Google Ads Orchestrator Agent
```

---

## 📊 部署成功标志

✅ 所有文件已复制到 skills 目录
✅ manifest.json 中的服务器地址已更新
✅ OpenClaw 配置文件包含新的 skills
✅ `openclaw-cli agent list` 显示 Google Ads agents
✅ Discord Bot 能响应 Google Ads 相关请求

---

## 🚨 常见问题解决

### 问题: Skills 未加载
```bash
# 检查文件权限
ls -la /path/to/openclaw/skills/google-ads-*/manifest.json

# 修复权限
chmod 644 /path/to/openclaw/skills/google-ads-*/manifest.json
```

### 问题: 配置文件错误
```bash
# 恢复备份
cp ~/.openclaw/openclaw.json.backup ~/.openclaw/openclaw.json

# 重新合并配置
jq -s '.[0] * .[1]' ~/.openclaw/openclaw.json.backup /path/to/openclaw/google-ads-skills.json > ~/.openclaw/openclaw.json
```

### 问题: Discord Bot 无响应
```bash
# 重启 Discord 相关服务
systemctl restart openclaw-discord
# 或
pm2 restart openclaw-discord
```

---

## 📞 部署完成后

请回复以下信息:

```
✅ 部署状态: [成功/失败/部分成功]
📁 文件位置: [实际安装路径]
🔧 配置状态: [已更新/需要手动更新]
🧪 测试结果: [Discord 响应情况]
🚨 遇到问题: [如有问题请描述]
```

---

**预计部署时间**: 10-15 分钟
**难度等级**: ⭐⭐☆☆☆ (中等)
**风险等级**: ⭐☆☆☆☆ (低风险，有备份机制)