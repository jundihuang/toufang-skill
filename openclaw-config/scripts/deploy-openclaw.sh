#!/bin/bash

# OpenClaw Google Ads系统一键部署脚本
# 作者: Jayce
# 版本: 1.0.0

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
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

# 检查依赖
check_dependencies() {
    log_info "检查系统依赖..."
    
    # 检查OpenClaw是否安装
    if ! command -v openclaw &> /dev/null; then
        log_error "OpenClaw未安装，请先安装OpenClaw"
        exit 1
    fi
    
    # 检查jq是否安装（用于JSON处理）
    if ! command -v jq &> /dev/null; then
        log_warning "jq未安装，正在安装..."
        sudo apt-get update && sudo apt-get install -y jq
    fi
    
    log_success "依赖检查完成"
}

# 备份现有配置
backup_config() {
    local config_path="$HOME/.openclaw/config.json"
    
    if [ -f "$config_path" ]; then
        local backup_path="$config_path.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "备份现有配置: $backup_path"
        cp "$config_path" "$backup_path"
        log_success "配置备份完成"
    else
        log_warning "未找到现有配置，跳过备份"
    fi
}

# 获取服务器地址
get_server_address() {
    log_info "检测服务器地址..."
    
    # 尝试获取公网IP
    if command -v curl &> /dev/null; then
        PUBLIC_IP=$(curl -s https://api.ipify.org || echo "localhost")
    else
        PUBLIC_IP="localhost"
    fi
    
    # 获取主机名
    HOSTNAME=$(hostname)
    
    # 获取OpenClaw网关地址
    if openclaw gateway status &> /dev/null; then
        GATEWAY_URL="http://$PUBLIC_IP:3000"
    else
        GATEWAY_URL="http://localhost:3000"
    fi
    
    log_success "服务器地址: $PUBLIC_IP"
    log_success "主机名: $HOSTNAME"
    log_success "网关地址: $GATEWAY_URL"
}

# 更新配置模板
update_config_template() {
    log_info "更新配置模板..."
    
    local template_path="$(dirname "$0")/../templates/config-template.json"
    local temp_path="/tmp/config-template-updated.json"
    
    # 复制模板
    cp "$template_path" "$temp_path"
    
    # 更新服务器地址（如果需要）
    if [ -n "$PUBLIC_IP" ] && [ "$PUBLIC_IP" != "localhost" ]; then
        log_info "更新配置中的服务器地址: $PUBLIC_IP"
        
        # 使用jq更新配置
        jq --arg ip "$PUBLIC_IP" \
           --arg hostname "$HOSTNAME" \
           --arg gateway "$GATEWAY_URL" \
           '.plugins.discord.channels.main.description = "Google Ads系统控制频道 - 服务器: \($hostname) (\($ip))" |
            .workspaces["google-ads"].path = "/home/ubuntu/.openclaw/workspace-google-ads" |
            .description = "Google Ads投放优化系统 - 部署于 \($hostname) (\($ip))"' \
           "$temp_path" > "${temp_path}.tmp"
        
        mv "${temp_path}.tmp" "$temp_path"
    fi
    
    log_success "配置模板更新完成"
}

# 部署agents配置
deploy_agents_config() {
    log_info "部署agents配置..."
    
    local config_path="$HOME/.openclaw/config.json"
    local temp_path="/tmp/config-template-updated.json"
    
    # 检查现有配置
    if [ -f "$config_path" ]; then
        log_info "合并到现有配置..."
        
        # 备份现有agents配置
        if jq -e '.agents' "$config_path" > /dev/null 2>&1; then
            log_warning "现有配置中已存在agents，将进行合并"
            
            # 合并agents配置
            jq --slurpfile new "$temp_path" \
               '.agents = ($new[0].agents * .agents) |
                .agentToAgent = ($new[0].agentToAgent * .agentToAgent) |
                .plugins.discord = ($new[0].plugins.discord // .plugins.discord) |
                .workspaces = ($new[0].workspaces * .workspaces)' \
               "$config_path" > "${config_path}.tmp"
        else
            # 直接合并整个配置
            jq --slurpfile new "$temp_path" \
               '. += $new[0]' \
               "$config_path" > "${config_path}.tmp"
        fi
        
        mv "${config_path}.tmp" "$config_path"
    else
        log_info "创建新配置..."
        cp "$temp_path" "$config_path"
    fi
    
    # 设置正确的权限
    chmod 600 "$config_path"
    
    log_success "agents配置部署完成"
}

# 创建工作空间
create_workspace() {
    log_info "创建工作空间..."
    
    local workspace_path="/home/ubuntu/.openclaw/workspace-google-ads"
    
    # 创建工作空间目录
    mkdir -p "$workspace_path"
    mkdir -p "$workspace_path/memory"
    
    # 创建工作空间文件
    cat > "$workspace_path/SOUL.md" << 'EOF'
# SOUL.md - Google Ads投放优化系统

## 工作空间
这是Google Ads投放优化系统的专用工作空间，包含5个专业agents协同工作。

## Agents
1. **google-ads-orchestrator** - 总协调员
2. **google-ads-strategist** - 策略制定专家
3. **google-ads-creative** - 创意文案专家
4. **google-ads-analyst** - 数据分析专家
5. **google-ads-optimizer** - 投放优化专家

## 创建时间
$(date)

## 说明
此工作空间由OpenClaw Google Ads系统一键部署脚本自动创建。
EOF
    
    cat > "$workspace_path/AGENTS.md" << 'EOF'
# AGENTS.md - Google Ads工作空间

## Agents配置说明

### 1. google-ads-orchestrator (总协调员)
- **职责**: 接收用户需求，分发任务，协调工作流程
- **可调用的子agents**: strategist, creative, analyst, optimizer
- **调用方式**: 使用sessions_spawn工具

### 2. google-ads-strategist (策略专家)
- **专长**: 广告策略、预算分配、目标受众分析
- **输出**: 策略报告、预算建议、投放计划

### 3. google-ads-creative (创意专家)
- **专长**: 广告文案、创意设计、着陆页优化
- **输出**: 广告文案、创意建议、A/B测试计划

### 4. google-ads-analyst (数据分析专家)
- **专长**: 数据监控、效果分析、报告生成
- **输出**: 数据报告、可视化图表、优化建议

### 5. google-ads-optimizer (投放优化专家)
- **专长**: 关键词优化、出价调整、质量分提升
- **输出**: 优化方案、否定关键词、效果预测

## 工作流程
1. 用户在Discord发送需求
2. Orchestrator分析需求类型
3. 调用相应的专业agent
4. 专业agent完成任务
5. Orchestrator整合结果并返回
EOF
    
    cat > "$workspace_path/TOOLS.md" << 'EOF'
# TOOLS.md - Google Ads工具配置

## 核心工具
- **Google Ads API**: 广告账户管理、数据获取
- **Google Analytics**: 网站流量分析
- **Google Search Console**: 搜索表现监控
- **Data Studio**: 数据可视化报告

## 第三方工具
- **SEMrush**: 关键词研究和竞品分析
- **Ahrefs**: 外链分析和SEO监控
- **Hotjar**: 用户行为分析
- **Optimizely**: A/B测试平台

## 内部工具
- **OpenClaw sessions_spawn**: agents间任务分发
- **Discord消息工具**: 用户沟通和结果返回
- **文件读写工具**: 策略文档保存和读取
EOF
    
    cat > "$workspace_path/USER.md" << 'EOF'
# USER.md - 用户信息

## 默认用户
- **名称**: Google Ads管理员
- **时区**: Asia/Shanghai (GMT+8)
- **偏好**: 数据驱动决策、详细报告、可视化图表

## 项目上下文
- **行业**: 电商、SaaS、教育、金融等
- **目标**: 提升广告ROI、降低获客成本、提高转化率
- **预算范围**: 从中小预算到企业级投放

## 沟通风格
- 偏好结构化报告
- 需要数据支撑的建议
- 明确的行动步骤
- 定期进度更新
EOF
    
    log_success "工作空间创建完成: $workspace_path"
}

# 重启OpenClaw服务
restart_openclaw() {
    log_info "重启OpenClaw服务..."
    
    # 停止服务
    if openclaw gateway status &> /dev/null; then
        log_info "停止OpenClaw网关..."
        openclaw gateway stop || true
        sleep 2
    fi
    
    # 启动服务
    log_info "启动OpenClaw网关..."
    openclaw gateway start
    
    # 等待服务启动
    sleep 5
    
    # 检查服务状态
    if openclaw gateway status &> /dev/null; then
        log_success "OpenClaw服务启动成功"
    else
        log_error "OpenClaw服务启动失败，请手动检查"
        exit 1
    fi
}

# 验证部署
verify_deployment() {
    log_info "验证部署..."
    
    # 检查配置文件
    if [ -f "$HOME/.openclaw/config.json" ]; then
        log_success "配置文件存在"
        
        # 检查agents配置
        AGENT_COUNT=$(jq '.agents | length' "$HOME/.openclaw/config.json")
        log_success "已配置 $AGENT_COUNT 个agents"
    else
        log_error "配置文件不存在"
        exit 1
    fi
    
    # 检查工作空间
    if [ -d "/home/ubuntu/.openclaw/workspace-google-ads" ]; then
        log_success "工作空间创建成功"
    else
        log_error "工作空间创建失败"
        exit 1
    fi
    
    log_success "部署验证完成"
}

# 显示部署摘要
show_summary() {
    echo ""
    echo "========================================="
    echo "        OpenClaw Google Ads系统部署完成"
    echo "========================================="
    echo ""
    echo "📊 部署摘要:"
    echo "  • 配置了 5 个专业agents"
    echo "  • 创建了专用工作空间"
    echo "  • 集成了Discord控制频道"
    echo "  • 服务已重启并运行"
    echo ""
    echo "🔧 Agents列表:"
    echo "  1. google-ads-orchestrator - 总协调员"
    echo "  2. google-ads-strategist   - 策略专家"
    echo "  3. google-ads-creative     - 创意专家"
    echo "  4. google-ads-analyst      - 数据分析"
    echo "  5. google-ads-optimizer    - 投放优化"
    echo ""
    echo "💬 使用方式:"
    echo "  在Discord频道发送广告需求"
    echo "  Orchestrator会自动协调专业agents处理"
    echo ""
    echo "📁 工作空间: /home/ubuntu/.openclaw/workspace-google-ads"
    echo "⚙️  配置文件: $HOME/.openclaw/config.json"
    echo ""
    echo "🚀 开始使用: 在Discord中@google-ads-orchestrator"
    echo "========================================="
}

# 主函数
main() {
    echo ""
    echo "🚀 OpenClaw Google Ads系统一键部署"
    echo "========================================="
    
    # 检查是否以root运行
    if [ "$EUID" -eq 0 ]; then 
        log_warning "不建议以root用户运行，请使用普通用户"
        read -p "是否继续? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    # 执行部署步骤
    check_dependencies
    backup_config
    get_server_address
    update_config_template
    deploy_agents_config
    create_workspace
    restart_openclaw
    verify_deployment
    show_summary
    
    log_success "部署完成！"
}

# 运行主函数
main "$@"