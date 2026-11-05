#!/usr/bin/env bash
# 项目规范初始化脚本 (跨平台版本)
# 用法: ./init-project.sh [目标项目路径]
#
# 兼容性:
#   - macOS: 原生 bash
#   - Linux: 原生 bash
#   - Windows: Git Bash (需安装 Git for Windows)

set -e

# 检测操作系统
detect_os() {
    case "$(uname -s)" in
        Darwin*)    echo "macos" ;;
        Linux*)     echo "linux" ;;
        CYGWIN*|MINGW*|MSYS*) echo "windows" ;;
        *)          echo "unknown" ;;
    esac
}

OS_TYPE=$(detect_os)

# 颜色输出 (Git Bash 和 Unix 终端都支持)
if [[ "$OS_TYPE" == "windows" ]]; then
    # Git Bash 支持 ANSI 颜色
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
else
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
fi

# 获取目标目录和脚本目录
TARGET_DIR="${1:-.}"
SPEC_DIR="$(cd "$(dirname "$0")" && pwd)"

# Windows 下转换路径为 Unix 风格
if [[ "$OS_TYPE" == "windows" ]]; then
    TARGET_DIR=$(cygpath -u "$TARGET_DIR" 2>/dev/null || echo "$TARGET_DIR")
    SPEC_DIR=$(cygpath -u "$SPEC_DIR" 2>/dev/null || echo "$SPEC_DIR")
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}项目规范初始化脚本${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "操作系统: ${GREEN}$OS_TYPE${NC}"
echo -e "目标项目: ${GREEN}$TARGET_DIR${NC}"
echo -e "规范模板: ${GREEN}$SPEC_DIR${NC}"
echo ""

# 检查目标目录
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}错误: 目标目录不存在: $TARGET_DIR${NC}"
    exit 1
fi

# 读取菜单选项；整次输入有效后才交给调用方，避免保留无效输入中的部分选择。
read_menu_choices() {
    local max_choice="$1"
    local choice valid

    while true; do
        MENU_CHOICES=()
        if ! IFS=$' \t' read -r -a MENU_CHOICES; then
            echo -e "${RED}输入已结束，已停止初始化。${NC}" >&2
            exit 1
        fi

        valid=yes
        if [ ${#MENU_CHOICES[@]} -eq 0 ]; then
            valid=no
        fi

        for choice in "${MENU_CHOICES[@]}"; do
            # 先校验格式和长度，避免非数字报错及超大整数溢出。
            if ! [[ "$choice" =~ ^[1-9][0-9]*$ ]] || [ ${#choice} -gt ${#max_choice} ]; then
                valid=no
                break
            fi
            if [ "$choice" -gt "$max_choice" ]; then
                valid=no
                break
            fi
            if [ "$choice" -eq "$max_choice" ] && [ ${#MENU_CHOICES[@]} -gt 1 ]; then
                valid=no
                break
            fi
        done

        if [ "$valid" = "yes" ]; then
            return 0
        fi
        echo -e "${RED}无效选项，请重新选择（1-${max_choice}）${NC}"
        echo "多选用空格分隔；跳过只能单独选择。"
    done
}

read_yes_no() {
    while true; do
        if ! read -r YES_NO_CHOICE; then
            echo -e "${RED}输入已结束，已停止初始化。${NC}" >&2
            exit 1
        fi
        case "$YES_NO_CHOICE" in
            y|Y) YES_NO_CHOICE=y; return 0 ;;
            n|N) YES_NO_CHOICE=n; return 0 ;;
            *) echo -e "${RED}无效选项，请重新输入 y 或 n${NC}" ;;
        esac
    done
}

# 检查是否已经初始化
if [ -f "$TARGET_DIR/AGENTS.md" ]; then
    echo -e "${YELLOW}警告: 检测到已存在 AGENTS.md${NC}"
    echo -e "是否继续？这将覆盖现有配置。(y/n)"
    read_yes_no
    continue_init="$YES_NO_CHOICE"
    if [ "$continue_init" != "y" ]; then
        echo "已取消初始化"
        exit 0
    fi
fi

# 跨平台 sed 函数
safe_sed() {
    local pattern="$1"
    local file="$2"

    if [[ "$OS_TYPE" == "macos" ]]; then
        # macOS 需要显式指定备份后缀
        sed -i.bak "$pattern" "$file"
        rm -f "${file}.bak"
    else
        # Linux 和 Git Bash (Windows) 使用 GNU sed
        sed -i "$pattern" "$file"
    fi
}

# 1. 复制基础规范
echo -e "\n${BLUE}[1/6] 复制基础规范...${NC}"

# 创建备份
if [ -f "$TARGET_DIR/AGENTS.md" ]; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S 2>/dev/null || date +%Y%m%d)
    cp "$TARGET_DIR/AGENTS.md" "$TARGET_DIR/AGENTS.md.backup.$TIMESTAMP"
    echo -e "${YELLOW}已备份现有 AGENTS.md${NC}"
fi

# 复制 base 目录内容（包括隐藏文件）
# 将旧模式的 Skills 目录链接替换为实体目录，避免向链接目标写入。
if [ -L "$TARGET_DIR/.claude/skills" ]; then
    rm "$TARGET_DIR/.claude/skills"
fi
cp -r "$SPEC_DIR/base/." "$TARGET_DIR/"
echo -e "${GREEN}✓ 基础规范已复制${NC}"

# 2. 选择技术栈
echo -e "\n${BLUE}[2/6] 选择技术栈${NC}"
echo ""

# 动态读取可用的规则文件
AVAILABLE_BACKEND=()
AVAILABLE_FRONTEND=()
AVAILABLE_MIDDLEWARE=()

# 扫描 optional-rules/ 目录
if [ -d "$SPEC_DIR/optional-rules/backend" ]; then
    for file in "$SPEC_DIR/optional-rules/backend"/*.md; do
        if [ -f "$file" ]; then
            filename=$(basename "$file" .md)
            AVAILABLE_BACKEND+=("$filename")
        fi
    done
fi

if [ -d "$SPEC_DIR/optional-rules/frontend" ]; then
    for file in "$SPEC_DIR/optional-rules/frontend"/*.md; do
        if [ -f "$file" ]; then
            filename=$(basename "$file" .md)
            AVAILABLE_FRONTEND+=("$filename")
        fi
    done
fi

if [ -d "$SPEC_DIR/optional-rules/middleware" ]; then
    for file in "$SPEC_DIR/optional-rules/middleware"/*.md; do
        if [ -f "$file" ]; then
            filename=$(basename "$file" .md)
            AVAILABLE_MIDDLEWARE+=("$filename")
        fi
    done
fi

# 后端语言选择
SELECTED_BACKEND=()
if [ ${#AVAILABLE_BACKEND[@]} -gt 0 ]; then
    echo -e "${YELLOW}选择后端语言 (输入编号，多选用空格分隔，如: 1 2):${NC}"
    for i in "${!AVAILABLE_BACKEND[@]}"; do
        # 首字母大写显示
        name="${AVAILABLE_BACKEND[$i]}"
        display_name=$(echo "${name:0:1}" | tr '[:lower:]' '[:upper:]')${name:1}
        echo "$((i+1))) $display_name"
    done
    echo "$((${#AVAILABLE_BACKEND[@]}+1))) 跳过"

    read_menu_choices "$((${#AVAILABLE_BACKEND[@]}+1))"

    for choice in "${MENU_CHOICES[@]}"; do
        if [ "$choice" -le "${#AVAILABLE_BACKEND[@]}" ] && [ "$choice" -gt 0 ]; then
            SELECTED_BACKEND+=("${AVAILABLE_BACKEND[$((choice-1))]}")
        elif [ "$choice" -eq "$((${#AVAILABLE_BACKEND[@]}+1))" ]; then
            : # 跳过
        fi
    done
else
    echo -e "${YELLOW}未找到后端规则文件，跳过${NC}"
fi

# 前端框架选择
SELECTED_FRONTEND=()
if [ ${#AVAILABLE_FRONTEND[@]} -gt 0 ]; then
    echo -e "\n${YELLOW}选择前端框架:${NC}"
    for i in "${!AVAILABLE_FRONTEND[@]}"; do
        name="${AVAILABLE_FRONTEND[$i]}"
        display_name=$(echo "${name:0:1}" | tr '[:lower:]' '[:upper:]')${name:1}
        echo "$((i+1))) $display_name"
    done
    echo "$((${#AVAILABLE_FRONTEND[@]}+1))) 跳过"

    read_menu_choices "$((${#AVAILABLE_FRONTEND[@]}+1))"

    for choice in "${MENU_CHOICES[@]}"; do
        if [ "$choice" -le "${#AVAILABLE_FRONTEND[@]}" ] && [ "$choice" -gt 0 ]; then
            SELECTED_FRONTEND+=("${AVAILABLE_FRONTEND[$((choice-1))]}")
        elif [ "$choice" -eq "$((${#AVAILABLE_FRONTEND[@]}+1))" ]; then
            : # 跳过
        fi
    done
else
    echo -e "${YELLOW}未找到前端规则文件，跳过${NC}"
fi

# 中间件选择
SELECTED_MIDDLEWARE=()
if [ ${#AVAILABLE_MIDDLEWARE[@]} -gt 0 ]; then
    echo -e "\n${YELLOW}选择中间件 (输入编号，多选用空格分隔):${NC}"
    for i in "${!AVAILABLE_MIDDLEWARE[@]}"; do
        name="${AVAILABLE_MIDDLEWARE[$i]}"
        display_name=$(echo "${name:0:1}" | tr '[:lower:]' '[:upper:]')${name:1}
        echo "$((i+1))) $display_name"
    done
    echo "$((${#AVAILABLE_MIDDLEWARE[@]}+1))) 跳过"

    read_menu_choices "$((${#AVAILABLE_MIDDLEWARE[@]}+1))"

    for choice in "${MENU_CHOICES[@]}"; do
        if [ "$choice" -le "${#AVAILABLE_MIDDLEWARE[@]}" ] && [ "$choice" -gt 0 ]; then
            SELECTED_MIDDLEWARE+=("${AVAILABLE_MIDDLEWARE[$((choice-1))]}")
        elif [ "$choice" -eq "$((${#AVAILABLE_MIDDLEWARE[@]}+1))" ]; then
            : # 跳过
        fi
    done
else
    echo -e "${YELLOW}未找到中间件规则文件，跳过${NC}"
fi

# 显示选择摘要
echo -e "\n${GREEN}已选择:${NC}"
[ ${#SELECTED_BACKEND[@]} -gt 0 ] && echo -e "  后端: ${SELECTED_BACKEND[*]}"
[ ${#SELECTED_FRONTEND[@]} -gt 0 ] && echo -e "  前端: ${SELECTED_FRONTEND[*]}"
[ ${#SELECTED_MIDDLEWARE[@]} -gt 0 ] && echo -e "  中间件: ${SELECTED_MIDDLEWARE[*]}"

# 3. 复制选中的规则
echo -e "\n${BLUE}[3/6] 复制技术栈规则...${NC}"

# 创建 tech-stack 目录
mkdir -p "$TARGET_DIR/docs/rules/tech-stack"

ENABLED_RULES=""

# 复制后端规则
for lang in "${SELECTED_BACKEND[@]}"; do
    src_file="$SPEC_DIR/optional-rules/backend/${lang}.md"
    dst_file="$TARGET_DIR/docs/rules/tech-stack/${lang}.md"
    if [ -f "$src_file" ]; then
        cp "$src_file" "$dst_file"
        echo -e "${GREEN}✓ 已复制 ${lang}.md${NC}"
        lang_upper=$(echo "$lang" | tr '[:lower:]' '[:upper:]')
        ENABLED_RULES="${ENABLED_RULES}- [${lang_upper}后端规则](docs/rules/tech-stack/${lang}.md)\n"
    else
        echo -e "${RED}✗ 未找到: $src_file${NC}"
    fi
done

# 复制前端规则
for framework in "${SELECTED_FRONTEND[@]}"; do
    src_file="$SPEC_DIR/optional-rules/frontend/${framework}.md"
    dst_file="$TARGET_DIR/docs/rules/tech-stack/${framework}.md"
    if [ -f "$src_file" ]; then
        cp "$src_file" "$dst_file"
        echo -e "${GREEN}✓ 已复制 ${framework}.md${NC}"
        framework_cap=$(echo "${framework:0:1}" | tr '[:lower:]' '[:upper:]')${framework:1}
        ENABLED_RULES="${ENABLED_RULES}- [${framework_cap}前端规则](docs/rules/tech-stack/${framework}.md)\n"
    else
        echo -e "${RED}✗ 未找到: $src_file${NC}"
    fi
done

# 复制中间件规则
for mw in "${SELECTED_MIDDLEWARE[@]}"; do
    src_file="$SPEC_DIR/optional-rules/middleware/${mw}.md"
    dst_file="$TARGET_DIR/docs/rules/tech-stack/${mw}.md"
    if [ -f "$src_file" ]; then
        cp "$src_file" "$dst_file"
        echo -e "${GREEN}✓ 已复制 ${mw}.md${NC}"
        mw_upper=$(echo "$mw" | tr '[:lower:]' '[:upper:]')
        ENABLED_RULES="${ENABLED_RULES}- [${mw_upper}中间件规则](docs/rules/tech-stack/${mw}.md)\n"
    else
        echo -e "${RED}✗ 未找到: $src_file${NC}"
    fi
done

# 4. 配置选项
echo -e "\n${BLUE}[4/6] 配置选项${NC}"
echo ""

# 固定关闭快速参考生成和 Git 约束简化，不再询问。
gen_quick_ref=n
simplify_git=n

# Skills 固定使用复制两份。
skill_mode=1

# 5. 应用配置
echo -e "\n${BLUE}[5/6] 应用配置...${NC}"

# 将完整 Skills 正文复制到 Claude 目录，替换模板或旧配置中的引用入口。
mkdir -p "$TARGET_DIR/.claude/skills"
cp -r "$TARGET_DIR/.agents/skills/." "$TARGET_DIR/.claude/skills/"
echo -e "${GREEN}✓ Skills 已复制两份${NC}"

# 更新 AGENTS.md 中的启用规则列表
if [ -n "$ENABLED_RULES" ]; then
    echo -e "更新 AGENTS.md..."
    if [ -f "$TARGET_DIR/AGENTS.md" ]; then
        # 使用 awk 代替复杂的 sed
        awk -v rules="$ENABLED_RULES" '
        /^已启用技术栈规则：/ {
            print "已启用技术栈规则："
            print ""
            printf "%s", rules
            print ""
            next
        }
        /^已启用技术栈规则：/,/^$/ {
            if (/^$/) next
            if (/^- \[.*\]\(docs\/rules\//) next
            if (/复制可选模块后/) next
        }
        { print }
        ' "$TARGET_DIR/AGENTS.md" > "$TARGET_DIR/AGENTS.md.tmp"
        mv "$TARGET_DIR/AGENTS.md.tmp" "$TARGET_DIR/AGENTS.md"
    fi
    echo -e "${GREEN}✓ AGENTS.md 已更新${NC}"
fi

# 6. 自动检测项目信息
echo -e "\n${BLUE}[6/6] 检测项目信息...${NC}"

# 检测构建工具和测试命令
BUILD_CMD=""
DETECTED_FRONTEND_PATH=""
DETECTED_BACKEND_PATH=""

cd "$TARGET_DIR"

# Java 项目
if [ -f "pom.xml" ]; then
    BUILD_CMD="mvn clean test"
    DETECTED_BACKEND_PATH=$(find . -type d -path "*/src/main/java" 2>/dev/null | head -1 | sed 's|^\./||')
    echo -e "${GREEN}✓ 检测到 Maven 项目${NC}"
elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
    if [[ "$OS_TYPE" == "windows" ]]; then
        BUILD_CMD="gradlew.bat test"
    else
        BUILD_CMD="./gradlew test"
    fi
    DETECTED_BACKEND_PATH=$(find . -type d -path "*/src/main/java" -o -path "*/src/main/kotlin" 2>/dev/null | head -1 | sed 's|^\./||')
    echo -e "${GREEN}✓ 检测到 Gradle 项目${NC}"
fi

# Python 项目
if [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then
    BUILD_CMD="pytest"
    DETECTED_BACKEND_PATH=$(find . -maxdepth 2 -type d \( -name "src" -o -name "app" \) 2>/dev/null | head -1 | sed 's|^\./||')
    echo -e "${GREEN}✓ 检测到 Python 项目${NC}"
fi

# Go 项目
if [ -f "go.mod" ]; then
    BUILD_CMD="go test ./..."
    DETECTED_BACKEND_PATH="."
    echo -e "${GREEN}✓ 检测到 Go 项目${NC}"
fi

# Node.js 项目
if [ -f "package.json" ]; then
    if [ -z "$BUILD_CMD" ]; then
        BUILD_CMD="npm test"
    fi

    # 检测前端框架和路径
    if grep -q "\"vue\"" package.json 2>/dev/null; then
        DETECTED_FRONTEND_PATH=$(find . -maxdepth 2 -type d -name "src" 2>/dev/null | head -1 | sed 's|^\./||')
        echo -e "${GREEN}✓ 检测到 Vue 项目${NC}"
    elif grep -q "\"react\"" package.json 2>/dev/null; then
        DETECTED_FRONTEND_PATH=$(find . -maxdepth 2 -type d -name "src" 2>/dev/null | head -1 | sed 's|^\./||')
        echo -e "${GREEN}✓ 检测到 React 项目${NC}"
    fi
fi

cd - > /dev/null

# 更新 AGENTS.md 的项目事实表
if [ -f "$TARGET_DIR/AGENTS.md" ]; then
    echo -e "更新项目事实表..."

    if [ -n "$BUILD_CMD" ]; then
        safe_sed "s|构建、检查、测试入口.*|构建、检查、测试入口 \| $BUILD_CMD \||" "$TARGET_DIR/AGENTS.md"
    fi

    if [ -n "$DETECTED_FRONTEND_PATH" ]; then
        safe_sed "s|前端及源码路径.*|前端及源码路径 \| $DETECTED_FRONTEND_PATH \||" "$TARGET_DIR/AGENTS.md"
    fi

    if [ -n "$DETECTED_BACKEND_PATH" ]; then
        safe_sed "s|后端及源码路径.*|后端及源码路径 \| $DETECTED_BACKEND_PATH \||" "$TARGET_DIR/AGENTS.md"
    fi

    echo -e "${GREEN}✓ 项目事实表已更新${NC}"
fi

# 合并 OpenSpec 配置 (如果存在)
if [ -f "$SPEC_DIR/openspec-config.example.yaml" ]; then
    if [ -f "$TARGET_DIR/openspec/config.yaml" ]; then
        echo -e "\n${YELLOW}检测到现有 OpenSpec 配置${NC}"
        echo -e "是否合并示例配置？(y/n)"
        read_yes_no
        merge_openspec="$YES_NO_CHOICE"

        if [ "$merge_openspec" = "y" ]; then
            # 简单追加方式（安全但可能重复）
            echo -e "\n# === 从模板合并的配置 ===" >> "$TARGET_DIR/openspec/config.yaml"
            cat "$SPEC_DIR/openspec-config.example.yaml" >> "$TARGET_DIR/openspec/config.yaml"
            echo -e "${GREEN}✓ OpenSpec 配置已合并${NC}"
            echo -e "${YELLOW}  请手动检查并删除重复项${NC}"
        fi
    else
        # 不存在则直接复制
        if [ -d "$TARGET_DIR/openspec" ]; then
            cp "$SPEC_DIR/openspec-config.example.yaml" "$TARGET_DIR/openspec/config.yaml"
            echo -e "${GREEN}✓ OpenSpec 配置已创建${NC}"
        fi
    fi
fi

# 完成
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}✅ 初始化完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 显示摘要
echo -e "${BLUE}配置摘要:${NC}"
echo -e "  • 操作系统: $OS_TYPE"
echo -e "  • 已复制基础规范到: $TARGET_DIR"
[ ${#SELECTED_BACKEND[@]} -gt 0 ] && echo -e "  • 后端技术栈: ${SELECTED_BACKEND[*]}"
[ ${#SELECTED_FRONTEND[@]} -gt 0 ] && echo -e "  • 前端技术栈: ${SELECTED_FRONTEND[*]}"
[ ${#SELECTED_MIDDLEWARE[@]} -gt 0 ] && echo -e "  • 中间件: ${SELECTED_MIDDLEWARE[*]}"
[ -n "$BUILD_CMD" ] && echo -e "  • 测试命令: $BUILD_CMD"

echo ""
echo -e "${BLUE}下一步建议:${NC}"
echo -e "  1. 检查并完善 ${YELLOW}AGENTS.md${NC} 中的项目事实表"
echo -e "  2. 验证测试命令: ${YELLOW}$BUILD_CMD${NC}"
echo -e "  3. 在 Claude Code 中刷新会话或运行 ${YELLOW}/reload${NC}"
echo -e "  4. 检查 Skills 是否正确加载: ${YELLOW}grill-me、grilling、project-*${NC}"
echo ""

# 创建初始化记录
mkdir -p "$TARGET_DIR/.claude"
cat > "$TARGET_DIR/.claude/init-log.txt" << EOF
初始化时间: $(date)
操作系统: $OS_TYPE
选择的技术栈:
  - 后端: ${SELECTED_BACKEND[*]:-无}
  - 前端: ${SELECTED_FRONTEND[*]:-无}
  - 中间件: ${SELECTED_MIDDLEWARE[*]:-无}

配置选项:
  - 快速参考: $gen_quick_ref
  - 简化 Git 约束: $simplify_git
  - Skills 模式: $skill_mode

检测到的信息:
  - 构建命令: $BUILD_CMD
  - 前端路径: $DETECTED_FRONTEND_PATH
  - 后端路径: $DETECTED_BACKEND_PATH
EOF

echo -e "${GREEN}初始化日志已保存: .claude/init-log.txt${NC}"
