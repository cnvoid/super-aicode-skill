#!/usr/bin/env bash
set -euo pipefail

# Super AI Code Skill — 一键安装脚本 (Linux / macOS)
# 用法:
#   bash install.sh             全局安装
#   bash install.sh --project   安装到当前项目
#   bash install.sh --update    更新已有安装

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

INSTALL_MODE="global"
PROFILE="balanced"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 解析参数
while [[ $# -gt 0 ]]; do
    case "$1" in
        --project)
            INSTALL_MODE="project"
            shift
            ;;
        --update)
            INSTALL_MODE="update"
            shift
            ;;
        --profile)
            PROFILE="$2"
            shift 2
            ;;
        --help|-h)
            echo "用法: bash install.sh [选项]"
            echo ""
            echo "选项:"
            echo "  --project     安装到当前项目 (.opencode/skills/)"
            echo "  --update      更新已有安装"
            echo "  --profile     指定预置策略 (balanced|strict|minimal, 默认 balanced)"
            echo "  --help        显示帮助"
            exit 0
            ;;
        *)
            echo -e "${RED}未知参数: $1${NC}"
            exit 1
            ;;
    esac
done

echo -e "${GREEN}=== Super AI Code Skill 安装 ===${NC}"
echo ""

# 检查必要文件
if [[ ! -d "$SCRIPT_DIR/super-core" ]]; then
    echo -e "${RED}错误: 未找到 super-core 目录，请从项目根目录运行此脚本${NC}"
    exit 1
fi

# 确定目标路径
if [[ "$INSTALL_MODE" == "project" ]]; then
    if [[ ! -f "./.opencode/opencode.json" && ! -f "./opencode.json" ]]; then
        echo -e "${YELLOW}警告: 当前目录未检测到 opencode 项目配置${NC}"
        echo -e "${YELLOW}继续安装到项目级 skills 目录...${NC}"
    fi
    SKILL_DIR="$(pwd)/.opencode/skills/super-aicode"
    CONFIG_FILE="$(pwd)/.super.yaml"
else
    SKILL_DIR="$HOME/.config/opencode/skills/super-aicode"
    CONFIG_FILE="$HOME/.super.yaml"
fi

echo "安装模式: $INSTALL_MODE"
echo "目标路径: $SKILL_DIR"
echo "配置文件: $CONFIG_FILE"
echo "预置策略: $PROFILE"
echo ""

# 创建目录
mkdir -p "$SKILL_DIR"

# 已存在则提示
if [[ "$INSTALL_MODE" == "update" ]] && [[ -d "$SKILL_DIR" ]]; then
    echo -e "${YELLOW}更新模式: 覆盖已有文件...${NC}"
fi

# 复制技能文件
echo "复制技能文件..."
for dir in super-core super-frontend super-backend-{java,node,go,python,common} super-design-icon super-deploy super-config super-api-doc super-test super-log super-sse; do
    if [[ -d "$SCRIPT_DIR/$dir" ]]; then
        cp -r "$SCRIPT_DIR/$dir" "$SKILL_DIR/"
        echo "  ✓ $dir"
    fi
done

# 复制配置模板和预置策略
echo "复制配置模板..."
cp -r "$SCRIPT_DIR/profiles" "$SKILL_DIR/" 2>/dev/null && echo "  ✓ profiles" || true
cp -r "$SCRIPT_DIR/templates" "$SKILL_DIR/" 2>/dev/null && echo "  ✓ templates" || true

# 创建全局配置文件（仅全局安装时）
if [[ "$INSTALL_MODE" == "global" ]]; then
    if [[ -f "$CONFIG_FILE" ]]; then
        echo -e "${YELLOW}配置文件已存在，跳过创建: $CONFIG_FILE${NC}"
        echo -e "${YELLOW}如需重置，请删除该文件后重新安装${NC}"
    else
        cp "$SCRIPT_DIR/templates/global.yaml" "$CONFIG_FILE"
        echo "  ✓ 全局配置已创建: $CONFIG_FILE"
    fi
fi

# 验证
echo ""
echo -e "${GREEN}=== 安装完成 ===${NC}"
echo ""

# 统计
SKILL_COUNT=$(find "$SKILL_DIR" -maxdepth 2 -name "SKILL.md" | wc -l | tr -d ' ')
PROMPT_COUNT=$(find "$SKILL_DIR" -name "*.md" -path "*/prompts/*" | wc -l | tr -d ' ')
echo "已安装技能: $SKILL_COUNT 个"
echo "已安装规则: $PROMPT_COUNT 条"
echo ""

# 后续步骤
echo -e "${YELLOW}后续步骤:${NC}"
echo "  1. 编辑配置文件: $CONFIG_FILE"
echo "  2. 重启 OpenCode / Claude Code"
echo ""

if [[ "$INSTALL_MODE" == "project" ]]; then
    echo -e "${YELLOW}项目配置提示:${NC}"
    echo "  如需覆盖全局规则，在项目根目录创建 .super.yaml"
    echo "  模板: cp $SKILL_DIR/templates/project.yaml ./.super.yaml"
    echo ""
fi

echo -e "${GREEN}验证方式:${NC}"
echo "  在 Agent 中输入 "写一个创建订单的 REST 接口""
echo "  预期 Agent 先输出任务方案，再按规则生成代码并自检"
