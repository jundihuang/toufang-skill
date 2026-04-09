#!/usr/bin/env python3
"""
OpenClaw Google Ads系统提示词更新脚本
自动更新agents的系统提示词，添加OpenClaw特定指令和最佳实践
"""

import json
import os
import sys
import argparse
from pathlib import Path

class PromptUpdater:
    def __init__(self, config_path=None):
        """初始化提示词更新器"""
        self.config_path = config_path or os.path.expanduser("~/.openclaw/config.json")
        self.backup_path = f"{self.config_path}.backup.{os.path.basename(__file__)}"
        
    def load_config(self):
        """加载OpenClaw配置"""
        try:
            with open(self.config_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except FileNotFoundError:
            print(f"错误: 配置文件不存在: {self.config_path}")
            sys.exit(1)
        except json.JSONDecodeError as e:
            print(f"错误: 配置文件JSON格式错误: {e}")
            sys.exit(1)
    
    def backup_config(self):
        """备份配置文件"""
        import shutil
        shutil.copy2(self.config_path, self.backup_path)
        print(f"✅ 配置文件已备份到: {self.backup_path}")
    
    def get_agent_prompts(self):
        """获取agents的当前提示词"""
        config = self.load_config()
        agents = config.get('agents', {})
        
        prompts = {}
        for agent_id, agent_config in agents.items():
            prompts[agent_id] = agent_config.get('systemPrompt', '')
        
        return prompts
    
    def update_agent_prompt(self, agent_id, current_prompt):
        """更新单个agent的提示词"""
        # 基础OpenClaw指令
        openclaw_instructions = """
## OpenClaw特定指令

### 工具使用
1. **sessions_spawn**: 用于调用其他agents
   - 格式: sessions_spawn({"task": "任务描述", "agentId": "目标agent-id"})
   - 示例: sessions_spawn({"task": "分析广告数据", "agentId": "google-ads-analyst"})

2. **message工具**: 用于Discord通信
   - 发送消息: message({"action": "send", "message": "内容"})
   - 回复消息: 使用 [[reply_to_current]] 标签

3. **文件操作**: 使用read/write/edit工具处理文档
   - 读取: read({"path": "文件路径"})
   - 写入: write({"path": "文件路径", "content": "内容"})

### 工作流程最佳实践
1. **任务接收**: 从Orchestrator接收明确的任务描述
2. **专业执行**: 专注于自己的专业领域
3. **结果返回**: 提供结构化、可操作的输出
4. **错误处理**: 遇到问题及时反馈给Orchestrator

### Discord环境适配
- 使用简洁明了的语言
- 重要信息使用**加粗**或`代码块`
- 长内容使用文件附件或分多条消息
- 及时响应，保持沟通顺畅
"""
        
        # agent特定指令
        agent_specific = self._get_agent_specific_instructions(agent_id)
        
        # 合并提示词
        if current_prompt:
            # 检查是否已包含OpenClaw指令
            if "## OpenClaw特定指令" in current_prompt:
                print(f"⚠️  {agent_id} 的提示词已包含OpenClaw指令，跳过更新")
                return current_prompt
            
            # 在现有提示词后添加
            updated_prompt = f"{current_prompt.rstrip()}\n\n{openclaw_instructions}\n{agent_specific}"
        else:
            # 创建新的提示词
            agent_name = self._get_agent_name(agent_id)
            base_prompt = f"你是{agent_name}，Google Ads投放优化系统的专业agent。"
            updated_prompt = f"{base_prompt}\n\n{openclaw_instructions}\n{agent_specific}"
        
        return updated_prompt.strip()
    
    def _get_agent_name(self, agent_id):
        """获取agent的友好名称"""
        names = {
            "google-ads-orchestrator": "Google Ads总协调员",
            "google-ads-strategist": "Google Ads策略制定专家",
            "google-ads-creative": "Google Ads创意文案专家",
            "google-ads-analyst": "Google Ads数据分析专家",
            "google-ads-optimizer": "Google Ads投放优化专家"
        }
        return names.get(agent_id, agent_id)
    
    def _get_agent_specific_instructions(self, agent_id):
        """获取agent特定的指令"""
        instructions = {
            "google-ads-orchestrator": """
### Orchestrator特定指令
1. **需求分析**: 仔细分析用户需求，确定需要调用的专业agents
2. **任务分发**: 使用sessions_spawn调用相应的专业agent
3. **进度监控**: 使用sessions_list检查子agents状态
4. **结果整合**: 汇总各agents的结果，提供完整的解决方案
5. **用户沟通**: 及时向用户反馈进度和结果

### 可调用的子agents
- **google-ads-strategist**: 用于策略制定、预算规划、受众分析
- **google-ads-creative**: 用于文案创作、创意设计、着陆页优化
- **google-ads-analyst**: 用于数据分析、效果监控、报告生成
- **google-ads-optimizer**: 用于关键词优化、出价调整、质量分提升

### 工作流程示例
1. 用户: "我想推广母亲节护肤礼盒"
2. 你: 分析需求 → 需要策略、创意、优化
3. 调用: strategist(策略) + creative(创意) + optimizer(优化)
4. 等待: 使用sessions_yield等待结果
5. 整合: 汇总策略报告+创意文案+优化方案
6. 返回: 完整的Google Ads投放方案
""",
            
            "google-ads-strategist": """
### Strategist特定指令
1. **策略制定**: 基于产品特点和目标市场制定投放策略
2. **预算规划**: 根据ROI目标合理分配预算
3. **受众分析**: 深入研究目标用户画像
4. **竞品研究**: 分析竞争对手的广告策略
5. **时间规划**: 制定投放时间表和节奏

### 输出要求
- 提供详细的策略文档
- 包含预算分配表格
- 明确的目标受众描述
- 具体的KPI指标
- 可执行的行动计划
""",
            
            "google-ads-creative": """
### Creative特定指令
1. **文案创作**: 撰写吸引人的广告标题和描述
2. **创意设计**: 提供视觉元素和设计建议
3. **着陆页优化**: 优化转化路径和用户体验
4. **A/B测试**: 设计测试方案验证效果
5. **品牌一致性**: 保持品牌调性和风格统一

### 输出要求
- 提供多个版本的广告文案
- 包含创意设计说明
- 详细的着陆页优化建议
- A/B测试计划和指标
- 品牌调性指导原则
""",
            
            "google-ads-analyst": """
### Analyst特定指令
1. **数据监控**: 实时监控广告投放数据
2. **效果分析**: 分析CTR、CPC、CVR等关键指标
3. **问题诊断**: 识别表现不佳的原因
4. **机会发现**: 发现优化和增长机会
5. **报告生成**: 创建数据驱动的分析报告

### 输出要求
- 清晰的数据可视化图表
- 深入的数据分析洞察
- 具体的问题诊断结果
- 可行的优化建议
- 定期报告模板
""",
            
            "google-ads-optimizer": """
### Optimizer特定指令
1. **关键词优化**: 研究和优化关键词列表
2. **出价调整**: 基于效果调整出价策略
3. **质量分提升**: 优化广告相关性、点击率、着陆页体验
4. **否定关键词**: 管理否定关键词排除无效流量
5. **排名优化**: 提升广告展示位置和可见度

### 输出要求
- 优化的关键词列表
- 详细的出价调整方案
- 质量分提升策略
- 否定关键词建议
- 排名优化效果预测
"""
        }
        
        return instructions.get(agent_id, "")
    
    def update_all_prompts(self, dry_run=False):
        """更新所有agents的提示词"""
        config = self.load_config()
        
        if 'agents' not in config:
            print("错误: 配置文件中未找到agents配置")
            sys.exit(1)
        
        updated_count = 0
        skipped_count = 0
        
        print("🔍 检查agents提示词...")
        
        for agent_id in config['agents']:
            current_prompt = config['agents'][agent_id].get('systemPrompt', '')
            updated_prompt = self.update_agent_prompt(agent_id, current_prompt)
            
            if current_prompt != updated_prompt:
                if not dry_run:
                    config['agents'][agent_id]['systemPrompt'] = updated_prompt
                print(f"✅  更新 {agent_id} 的提示词")
                updated_count += 1
            else:
                print(f"⏭️  跳过 {agent_id} (无需更新)")
                skipped_count += 1
        
        if not dry_run and updated_count > 0:
            # 备份原配置
            self.backup_config()
            
            # 保存更新后的配置
            with open(self.config_path, 'w', encoding='utf-8') as f:
                json.dump(config, f, indent=2, ensure_ascii=False)
            
            print(f"\n🎉 成功更新 {updated_count} 个agents的提示词")
            print(f"📁 配置文件: {self.config_path}")
            print(f"💾 备份文件: {self.backup_path}")
        elif dry_run:
            print(f"\n🔍 模拟运行: 将更新 {updated_count} 个agents的提示词")
            print("   使用 --apply 参数实际应用更改")
        else:
            print(f"\n✅ 所有agents的提示词已是最新，无需更新")
        
        return updated_count
    
    def create_prompt_template(self, output_path):
        """创建提示词模板文件"""
        template = {
            "orchestrator": self.update_agent_prompt("google-ads-orchestrator", ""),
            "strategist": self.update_agent_prompt("google-ads-strategist", ""),
            "creative": self.update_agent_prompt("google-ads-creative", ""),
            "analyst": self.update_agent_prompt("google-ads-analyst", ""),
            "optimizer": self.update_agent_prompt("google-ads-optimizer", "")
        }
        
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(template, f, indent=2, ensure_ascii=False)
        
        print(f"📄 提示词模板已保存到: {output_path}")
        return template

def main():
    parser = argparse.ArgumentParser(description='OpenClaw Google Ads系统提示词更新工具')
    parser.add_argument('--config', help='OpenClaw配置文件路径', default=None)
    parser.add_argument('--dry-run', action='store_true', help='模拟运行，不实际修改')
    parser.add_argument('--apply', action='store_true', help='实际应用更改')
    parser.add_argument('--template', help='创建提示词模板文件', metavar='OUTPUT_PATH')
    parser.add_argument('--list', action='store_true', help='列出当前agents和提示词')
    
    args = parser.parse_args()
    
    updater = PromptUpdater(args.config)
    
    if args.list:
        print("📋 当前agents列表:")
        prompts = updater.get_agent_prompts()
        for agent_id, prompt in prompts.items():
            print(f"\n🔹 {agent_id}:")
            if prompt:
                preview = prompt[:100] + "..." if len(prompt) > 100 else prompt
                print(f"   提示词预览: {preview}")
            else:
                print("   提示词: (空)")
        return
    
    if args.template:
        updater.create_prompt_template(args.template)
        return
    
    # 默认行为：更新提示词
    dry_run = args.dry_run or not args.apply
    updater.update_all_prompts(dry_run=dry_run)
    
    if dry_run and not args.dry_run:
        print("\n💡 提示: 使用 --apply 参数实际应用更改")

if __name__ == "__main__":
    main()