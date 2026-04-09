# 🤖 Discord Main Agent 部署指令

**你现在是什么角色**: Discord 中的 Main Agent，负责部署 Google Ads Skills 项目

**你的任务**: 在已配置 OpenClaw + Discord 的服务器上部署 Google Ads Skills

**项目地址**: `https://github.com/your-username/toufang-skill.git`

**预计时间**: 15-20 分钟

---

## 🚀 开始部署（按顺序执行）

### Step 1: 项目克隆
```bash
cd /path/to/openclaw/skills/
git clone https://github.com/your-username/toufang-skill.git google-ads-temp
mv google-ads-temp/google-ads-*-agent/ ./
rm -rf google-ads-temp
ls -la | grep google-ads
```

### Step 2: 更新配置
```bash
# 获取服务器信息
SERVER_IP=$(hostname -I | awk '{print $1}')
echo "服务器IP: $SERVER_IP"

# 更新所有 manifest.json 中的服务器地址
find /path/to/openclaw/skills/google-ads-* -name "manifest.json" -exec sed -i "s|https://openclaw.local|http://${SERVER_IP}:8080|g" {} \;
```

### Step 3: 验证文件结构
```bash
# 检查必要文件是否存在
for agent in google-ads-orchestrator-agent google-ads-strategy-agent google-ads-optimization-agent google-ads-publishing-agent; do
  echo "检查 $agent:"
  ls -l /path/to/openclaw/skills/$agent/manifest.json
  ls -l /path/to/openclaw/skills/$agent/prompts/system.md
done
```

### Step 4: 更新 OpenClaw 配置
```bash
# 创建新 skills 配置
cat > ~/.openclaw/google-ads-skills.json << 'EOF'
{
  "skills": [
    {
      "name": "google-ads-orchestrator-agent",
      "enabled": true,
      "manifestPath": "/path/to/openclaw/skills/google-ads-orchestrator-agent/manifest.json",
      "systemPromptPath": "/path/to/openclaw/skills/google-ads-orchestrator-agent/prompts/system.md"
    },
    {
      "name": "google-ads-strategy-agent",
      "enabled": true,
      "manifestPath": "/path/to/openclaw/skills/google-ads-strategy-agent/manifest.json",
      "systemPromptPath": "/path/to/openclaw/skills/google-ads-strategy-agent/prompts/system.md"
    }
  ]
}
EOF

# 合并到主配置（如果有 jq 工具）
jq -s '.[0] * .[1]' ~/.openclaw/openclaw.json ~/.openclaw/google-ads-skills.json > ~/.openclaw/openclaw-new.json
mv ~/.openclaw/openclaw-new.json ~/.openclaw/openclaw.json
```

### Step 5: 重启服务
```bash
systemctl restart openclaw
sleep 5
systemctl status openclaw
```

### Step 6: 验证部署
```bash
# 检查 skills 是否加载
openclaw-cli agent list | grep google-ads

# 查看日志
tail -20 /var/log/openclaw/agent.log
```

---

## 🧪 Discord 测试指令

部署完成后，在 Discord 中测试：

```
@YourBot 帮我策划一个母亲节护肤礼盒的广告活动，预算2万美元，美国市场，目标是销量转化
```

---

## ✅ 成功标志

1. ✅ 所有 google-ads-* 文件夹已创建
2. ✅ manifest.json 中的服务器地址已更新
3. ✅ OpenClaw 配置文件包含新的 skills
4. ✅ `openclaw-cli agent list` 显示 Google Ads agents
5. ✅ Discord Bot 能响应策略规划请求

---

## 🚨 如果遇到问题

### Skills 未加载:
```bash
# 检查文件路径
find /path/to/openclaw/skills/ -name "manifest.json" | grep google-ads

# 检查文件权限
chmod 644 /path/to/openclaw/skills/google-ads-*/manifest.json
```

### 服务启动失败:
```bash
# 查看错误日志
journalctl -u openclaw -n 50

# 检查配置语法
cat ~/.openclaw/openclaw.json | jq .
```

### Discord 无响应:
```bash
# 测试 Discord 连接
openclaw-cli discord status

# 重启相关服务
systemctl restart openclaw-discord
```

---

**重要提醒**:
- 将 `/path/to/openclaw/` 替换为实际的 OpenClaw 安装路径
- 将 GitHub 地址替换为实际的项目地址
- 根据服务器配置调整端口和服务名称

**部署完成后，请在 Discord 中回复 "✅ Google Ads Skills 部署完成"，并提供测试结果。**