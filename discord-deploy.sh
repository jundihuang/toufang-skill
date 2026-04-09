#!/bin/bash
# Discord Main Agent 自动部署脚本
# 使用方法: 在 Discord 中 @MainAgent 然后提供这个脚本的内容

set -e  # 遇到错误立即停止

echo "🚀 开始部署 Google Ads Skills 到 OpenClaw..."

# ===== 配置区域（需要根据实际情况修改）=====
OPENCLAW_PATH="/path/to/openclaw"
SKILLS_PATH="$OPENCLAW_PATH/skills"
PROJECT_REPO="https://github.com/your-username/toufang-skill.git"
SERVER_PORT="8080"
# ===========================================

# Step 1: 环境检查
echo "📋 Step 1: 检查环境..."
if [ ! -d "$OPENCLAW_PATH" ]; then
    echo "❌ OpenClaw 路径不存在: $OPENCLAW_PATH"
    echo "请修改脚本中的 OPENCLAW_PATH 变量"
    exit 1
fi

if [ ! -d "$SKILLS_PATH" ]; then
    echo "❌ Skills 目录不存在: $SKILLS_PATH"
    echo "正在创建..."
    mkdir -p "$SKILLS_PATH"
fi

# Step 2: 克隆项目
echo "📥 Step 2: 克隆项目文件..."
cd "$SKILLS_PATH"
if [ -d "google-ads-temp" ]; then
    rm -rf google-ads-temp
fi

git clone "$PROJECT_REPO" google-ads-temp

# Step 3: 移动文件
echo "📁 Step 3: 组织文件结构..."
mv google-ads-temp/google-ads-*-agent/ ./
mv google-ads-temp/google-ads-skills-architecture.md ./
mv google-ads-temp/README.md ./google-ads-README.md
rm -rf google-ads-temp

# Step 4: 更新服务器地址
echo "🌐 Step 4: 更新服务器配置..."
SERVER_IP=$(hostname -I | awk '{print $1}')
echo "检测到服务器IP: $SERVER_IP"

find "$SKILLS_PATH/google-ads-"* -name "manifest.json" -exec sed -i "s|https://openclaw.local|http://${SERVER_IP}:${SERVER_PORT}|g" {} \;

# Step 5: 验证文件
echo "🔍 Step 5: 验证文件完整性..."
REQUIRED_FILES=(
    "google-ads-orchestrator-agent/manifest.json"
    "google-ads-orchestrator-agent/prompts/system.md"
    "google-ads-strategy-agent/manifest.json"
    "google-ads-strategy-agent/prompts/system.md"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$SKILLS_PATH/$file" ]; then
        echo "❌ 缺少必要文件: $file"
        exit 1
    fi
done

# Step 6: 创建输出目录
echo "📂 Step 6: 创建输出和日志目录..."
mkdir -p /var/www/openclaw-results/google-ads/
mkdir -p /var/log/openclaw/google-ads/
touch /var/log/openclaw/google-ads/strategy.log
touch /var/log/openclaw/google-ads/orchestrator.log

# Step 7: 更新 OpenClaw 配置
echo "⚙️  Step 7: 更新 OpenClaw 配置..."
cat > "$OPENCLAW_PATH/google-ads-skills.json" << EOF
{
  "skills": [
    {
      "name": "google-ads-orchestrator-agent",
      "enabled": true,
      "manifestPath": "$SKILLS_PATH/google-ads-orchestrator-agent/manifest.json",
      "systemPromptPath": "$SKILLS_PATH/google-ads-orchestrator-agent/prompts/system.md"
    },
    {
      "name": "google-ads-strategy-agent",
      "enabled": true,
      "manifestPath": "$SKILLS_PATH/google-ads-strategy-agent/manifest.json",
      "systemPromptPath": "$SKILLS_PATH/google-ads-strategy-agent/prompts/system.md"
    },
    {
      "name": "google-ads-optimization-agent",
      "enabled": false,
      "manifestPath": "$SKILLS_PATH/google-ads-optimization-agent/manifest.json",
      "systemPromptPath": "$SKILLS_PATH/google-ads-optimization-agent/prompts/system.md"
    },
    {
      "name": "google-ads-publishing-agent",
      "enabled": false,
      "manifestPath": "$SKILLS_PATH/google-ads-publishing-agent/manifest.json",
      "systemPromptPath": "$SKILLS_PATH/google-ads-publishing-agent/prompts/system.md"
    }
  ]
}
EOF

# Step 8: 重启服务
echo "🔄 Step 8: 重启 OpenClaw 服务..."
if systemctl is-active --quiet openclaw; then
    systemctl restart openclaw
    echo "OpenClaw 服务已重启"
elif command -v pm2 &> /dev/null; then
    pm2 restart openclaw
    echo "OpenClaw (PM2) 服务已重启"
else
    echo "⚠️  请手动重启 OpenClaw 服务"
fi

# 等待服务启动
sleep 5

# Step 9: 验证部署
echo "✅ Step 9: 验证部署结果..."
echo "已部署的 Google Ads Skills:"
ls -d "$SKILLS_PATH"/google-ads-*-agent/ 2>/dev/null || echo "❌ 未找到 skills 目录"

echo ""
echo "🎉 部署完成！"
echo ""
echo "📋 下一步:"
echo "1. 检查 OpenClaw 配置: $OPENCLAW_PATH/openclaw.json"
echo "2. 手动合并 google-ads-skills.json 到主配置"
echo "3. 在 Discord 中测试: @YourBot 帮我策划广告活动"
echo ""
echo "🔧 如遇问题，请检查日志:"
echo "   tail -f /var/log/openclaw/google-ads/orchestrator.log"