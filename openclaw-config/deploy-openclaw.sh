#!/bin/bash
# Google Ads Skills - OpenClaw 一键部署脚本
# 版本: 1.0.0
# 描述: 自动部署完整的 Google Ads 多智能体系统到 OpenClaw

set -e  # 遇到错误立即停止

echo "🚀 Google Ads Skills - OpenClaw 部署开始"
echo "=========================================="

# ===== 配置区域 =====
# 用户需要根据实际情况修改这些变量
OPENCLAW_HOME="${OPENCLAW_HOME:-$HOME/.openclaw}"
DEFAULT_MODEL="${DEFAULT_MODEL:-deepseek/deepseek-chat}"
SERVER_PORT="18789"

# Discord 频道 ID (部署前需要在 Discord 中创建)
DISCORD_MAIN_CHANNEL_ID="${DISCORD_MAIN_CHANNEL_ID:-CHANNEL_ID_PLACEHOLDER}"
DISCORD_STRATEGY_CHANNEL_ID="${DISCORD_STRATEGY_CHANNEL_ID:-CHANNEL_ID_PLACEHOLDER}"
DISCORD_OPTIMIZATION_CHANNEL_ID="${DISCORD_OPTIMIZATION_CHANNEL_ID:-CHANNEL_ID_PLACEHOLDER}"
DISCORD_PUBLISHING_CHANNEL_ID="${DISCORD_PUBLISHING_CHANNEL_ID:-CHANNEL_ID_PLACEHOLDER}"

# ===== 颜色定义 =====
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ===== 工具函数 =====
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_command() {
    if ! command -v $1 &> /dev/null; then
        log_error "命令 '$1' 未找到，请先安装"
        exit 1
    fi
}

# ===== 步骤 1: 环境检查 =====
log_info "步骤 1: 检查环境..."

# 检查必要命令
check_command "jq"
check_command "openclaw"

# 检查 OpenClaw 目录
if [ ! -d "$OPENCLAW_HOME" ]; then
    log_error "OpenClaw 目录不存在: $OPENCLAW_HOME"
    log_error "请先安装 OpenClaw 或设置正确的 OPENCLAW_HOME 环境变量"
    exit 1
fi

# 检查 OpenClaw 配置文件
if [ ! -f "$OPENCLAW_HOME/openclaw.json" ]; then
    log_error "OpenClaw 配置文件不存在: $OPENCLAW_HOME/openclaw.json"
    exit 1
fi

# 备份原配置
BACKUP_FILE="$OPENCLAW_HOME/openclaw.json.backup.$(date +%s)"
cp "$OPENCLAW_HOME/openclaw.json" "$BACKUP_FILE"
log_success "已备份原配置到: $BACKUP_FILE"

# ===== 步骤 2: 复制 Skills 文件 =====
log_info "步骤 2: 复制 Skills 文件..."

SKILLS_DIR="$OPENCLAW_HOME/skills"
if [ ! -d "$SKILLS_DIR" ]; then
    mkdir -p "$SKILLS_DIR"
    log_success "创建 Skills 目录: $SKILLS_DIR"
fi

# 获取当前脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# 复制 Google Ads skills
for skill_dir in "$PROJECT_ROOT"/google-ads-*-agent; do
    if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        cp -r "$skill_dir" "$SKILLS_DIR/"
        log_success "复制: $skill_name"
    fi
done

# ===== 步骤 3: 更新服务器地址 =====
log_info "步骤 3: 更新服务器地址..."

SERVER_IP=$(hostname -I | awk '{print $1}')
if [ -z "$SERVER_IP" ]; then
    SERVER_IP="127.0.0.1"
    log_warning "无法获取服务器IP，使用默认: $SERVER_IP"
fi

find "$SKILLS_DIR/google-ads-"* -name "manifest.json" -exec sed -i "s|https://openclaw.local|http://${SERVER_IP}:${SERVER_PORT}|g" {} \;
log_success "更新服务器地址为: http://${SERVER_IP}:${SERVER_PORT}"

# ===== 步骤 4: 更新系统提示词 =====
log_info "步骤 4: 更新系统提示词（添加 OpenClaw 特定指令）..."

# 更新 Orchestrator 系统提示词
ORCHESTRATOR_PROMPT="$SKILLS_DIR/google-ads-orchestrator-agent/prompts/system.md"
if [ -f "$ORCHESTRATOR_PROMPT" ]; then
    cat >> "$ORCHESTRATOR_PROMPT" << 'EOF'

## OpenClaw 环境说明
- 你运行在 OpenClaw 平台上
- 可以使用 `sessions_spawn` 工具调用其他 agents:
  - `google-ads-strategy` - 策略规划
  - `google-ads-optimization` - 效果优化  
  - `google-ads-publishing` - 广告发布
- 在 Discord 环境中工作，需要适配 Discord 格式
EOF
    log_success "更新 Orchestrator 系统提示词"
fi

# ===== 步骤 5: 生成 OpenClaw 配置 =====
log_info "步骤 5: 生成 OpenClaw 配置..."

# 创建配置片段
CONFIG_FRAGMENT="$OPENCLAW_HOME/google-ads-config-fragment.json"
cat > "$CONFIG_FRAGMENT" << EOF
{
  "agents": {
    "list": [
      {
        "id": "google-ads-orchestrator",
        "name": "Google Ads Orchestrator",
        "workspace": "$OPENCLAW_HOME/workspace-google-ads",
        "model": "$DEFAULT_MODEL",
        "subagents": {
          "allowAgents": [
            "google-ads-strategy",
            "google-ads-optimization",
            "google-ads-publishing"
          ]
        }
      },
      {
        "id": "google-ads-strategy",
        "name": "Google Ads Strategy",
        "workspace": "$OPENCLAW_HOME/workspace-google-ads-strategy",
        "model": "$DEFAULT_MODEL"
      },
      {
        "id": "google-ads-optimization",
        "name": "Google Ads Optimization",
        "workspace": "$OPENCLAW_HOME/workspace-google-ads-optimization",
        "model": "$DEFAULT_MODEL"
      },
      {
        "id": "google-ads-publishing",
        "name": "Google Ads Publishing",
        "workspace": "$OPENCLAW_HOME/workspace-google-ads-publishing",
        "model": "$DEFAULT_MODEL"
      }
    ]
  },
  "tools": {
    "agentToAgent": {
      "enabled": true,
      "allow": [
        "google-ads-orchestrator",
        "google-ads-strategy",
        "google-ads-optimization",
        "google-ads-publishing"
      ]
    }
  },
  "bindings": [
    {
      "agentId": "google-ads-orchestrator",
      "match": {
        "channel": "discord",
        "peer": {
          "kind": "channel",
          "id": "$DISCORD_MAIN_CHANNEL_ID"
        }
      }
    },
    {
      "agentId": "google-ads-strategy",
      "match": {
        "channel": "discord",
        "peer": {
          "kind": "channel",
          "id": "$DISCORD_STRATEGY_CHANNEL_ID"
        }
      }
    },
    {
      "agentId": "google-ads-optimization",
      "match": {
        "channel": "discord",
        "peer": {
          "kind": "channel",
          "id": "$DISCORD_OPTIMIZATION_CHANNEL_ID"
        }
      }
    },
    {
      "agentId": "google-ads-publishing",
      "match": {
        "channel": "discord",
        "peer": {
          "kind": "channel",
          "id": "$DISCORD_PUBLISHING_CHANNEL_ID"
        }
      }
    }
  ]
}
EOF

log_success "生成配置片段: $CONFIG_FRAGMENT"

# ===== 步骤 6: 合并配置 =====
log_info "步骤 6: 合并配置到 OpenClaw 主配置..."

# 使用 jq 合并配置
if jq -s '.[0] * .[1]' "$OPENCLAW_HOME/openclaw.json" "$CONFIG_FRAGMENT" > "$OPENCLAW_HOME/openclaw-new.json"; then
    mv "$OPENCLAW_HOME/openclaw-new.json" "$OPENCLAW_HOME/openclaw.json"
    log_success "配置合并成功"
else
    log_error "配置合并失败，使用备份恢复"
    cp "$BACKUP_FILE" "$OPENCLAW_HOME/openclaw.json"
    exit 1
fi

# ===== 步骤 7: 创建工作空间 =====
log_info "步骤 7: 创建工作空间..."

mkdir -p "$OPENCLAW_HOME/workspace-google-ads"
mkdir -p "$OPENCLAW_HOME/workspace-google-ads-strategy"
mkdir -p "$OPENCLAW_HOME/workspace-google-ads-optimization"
mkdir -p "$OPENCLAW_HOME/workspace-google-ads-publishing"

# 创建基础配置文件
for workspace in "google-ads" "google-ads-strategy" "google-ads-optimization" "google-ads-publishing"; do
    cat > "$OPENCLAW_HOME/workspace-$workspace/SOUL.md" << EOF
# SOUL.md - $workspace

## 工作空间
这是 $workspace 的专用工作空间。

## 创建时间
$(date)

## 说明
此文件由 Google Ads Skills 部署脚本自动创建。
EOF
    
    cat > "$OPENCLAW_HOME/workspace-$workspace/AGENTS.md" << EOF
# AGENTS.md - $workspace 工作空间

## 目录结构
\`\`\`
workspace-$workspace/
├── SOUL.md          # 身份定义
├── AGENTS.md        # 工作空间说明
├── USER.md          # 用户信息（待补充）
├── TOOLS.md         # 工具配置（待补充）
└── memory/          # 记忆目录
\`\`\`

## 创建时间
$(date)
EOF
    
    mkdir -p "$OPENCLAW_HOME/workspace-$workspace/memory"
    log_success "创建工作空间: $workspace"
done

# ===== 步骤 8: 重启 OpenClaw 服务 =====
log_info "步骤 8: 重启 OpenClaw 服务..."

if openclaw gateway restart; then
    log_success "OpenClaw 服务重启成功"
else
    log_warning "OpenClaw 服务重启失败，请手动重启"
fi

# 等待服务启动
sleep 3

# ===== 步骤 9: 验证部署 =====
log_info "步骤 9: 验证部署..."

echo ""
echo "✅ Google Ads Skills 部署完成！"
echo ""
echo "📋 部署摘要:"
echo "  - OpenClaw 目录: $OPENCLAW_HOME"
echo "  - Skills 目录: $SKILLS_DIR/google-ads-*-agent"
echo "  - 工作空间: $OPENCLAW_HOME/workspace-google-ads-*"
echo "  - 配置备份: $BACKUP_FILE"
echo ""
echo "🔧 配置的 Discord 频道:"
echo "  - 主频道: $DISCORD_MAIN_CHANNEL_ID (Orchestrator)"
echo "  - 策略子区: $DISCORD_STRATEGY_CHANNEL_ID (Strategy)"
echo "  - 优化子区: $DISCORD_OPTIMIZATION_CHANNEL_ID (Optimization)"
echo "  - 发布子区: $DISCORD_PUBLISHING_CHANNEL_ID (Publishing)"
echo ""
echo "🚨 重要提醒:"
echo "  1. 请确保 Discord 频道/子区已创建"
echo "  2. 如果频道ID是占位符，请手动更新 openclaw.json"
echo "  3. 测试命令: openclaw gateway status"
echo ""
echo "🎉 现在可以在 Discord 中使用 Google Ads 多智能体系统了！"