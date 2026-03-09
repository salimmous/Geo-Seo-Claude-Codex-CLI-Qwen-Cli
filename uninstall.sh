#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# GEO-SEO Skill Uninstaller
# ============================================================

CLAUDE_DIR="${HOME}/.claude"
CODEX_DIR="${CODEX_HOME:-${HOME}/.codex}"
QWEN_DIR="${QWEN_HOME:-${HOME}/.qwen}"
GEO_INSTALL_TARGET="${GEO_INSTALL_TARGET:-all}"

INTERACTIVE=true
if [ ! -t 0 ]; then
    INTERACTIVE=false
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TARGET_NAMES=()
TARGET_SKILLS_DIRS=()
TARGET_AGENTS_DIRS=()

add_target() {
    local target_name="$1"
    local target_base="$2"

    TARGET_NAMES+=("$target_name")
    TARGET_SKILLS_DIRS+=("${target_base}/skills")
    TARGET_AGENTS_DIRS+=("${target_base}/agents")
}

has_target() {
    local candidate="$1"
    local existing

    [ "${#TARGET_NAMES[@]}" -eq 0 ] && return 1

    for existing in "${TARGET_NAMES[@]}"; do
        if [ "$existing" = "$candidate" ]; then
            return 0
        fi
    done

    return 1
}

configure_targets() {
    local raw_targets normalized_targets
    local token compact_token
    local -a requested_targets

    raw_targets="$1"
    normalized_targets="$(printf '%s' "$raw_targets" | tr '[:upper:]' '[:lower:]')"
    case "$normalized_targets" in
        both)
            normalized_targets="claude,codex"
            ;;
        all)
            normalized_targets="claude,codex,qwen"
            ;;
    esac

    IFS=',' read -r -a requested_targets <<< "$normalized_targets"
    for token in "${requested_targets[@]}"; do
        compact_token="${token//[[:space:]]/}"
        [ -z "$compact_token" ] && continue

        if has_target "$compact_token"; then
            continue
        fi

        case "$compact_token" in
            claude)
                add_target "claude" "$CLAUDE_DIR"
                ;;
            codex)
                add_target "codex" "$CODEX_DIR"
                ;;
            qwen)
                add_target "qwen" "$QWEN_DIR"
                ;;
            *)
                echo -e "${RED}Invalid GEO_INSTALL_TARGET: ${GEO_INSTALL_TARGET}${NC}"
                echo "Valid values: claude, codex, qwen, both, all"
                echo "You can also pass a comma-separated list like: claude,qwen"
                exit 1
                ;;
        esac
    done

    if [ "${#TARGET_NAMES[@]}" -eq 0 ]; then
        echo -e "${RED}No uninstall targets resolved from GEO_INSTALL_TARGET=${GEO_INSTALL_TARGET}${NC}"
        exit 1
    fi
}

configure_targets "$GEO_INSTALL_TARGET"

echo ""
echo -e "${YELLOW}GEO-SEO Skill Uninstaller${NC}"
echo ""
echo "This will remove the following:"
echo ""

# List what will be removed
for i in "${!TARGET_NAMES[@]}"; do
    target_name="${TARGET_NAMES[$i]}"
    skills_dir="${TARGET_SKILLS_DIRS[$i]}"
    agents_dir="${TARGET_AGENTS_DIRS[$i]}"

    echo "  [${target_name}]"
    [ -d "$skills_dir/geo" ] && echo "    → ${skills_dir}/geo/"
    for skill_dir in "$skills_dir"/geo-*/; do
        [ -d "$skill_dir" ] && echo "    → ${skill_dir}"
    done
    for agent_file in "$agents_dir"/geo-*.md; do
        [ -f "$agent_file" ] && echo "    → ${agent_file}"
    done
done

echo ""
if [ "$INTERACTIVE" = true ]; then
    read -p "Are you sure you want to uninstall? (y/n): " -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Uninstall cancelled."
        exit 0
    fi
else
    echo "Non-interactive mode detected — proceeding with uninstall."
fi

echo ""

# Remove by target
for i in "${!TARGET_NAMES[@]}"; do
    target_name="${TARGET_NAMES[$i]}"
    skills_dir="${TARGET_SKILLS_DIRS[$i]}"
    agents_dir="${TARGET_AGENTS_DIRS[$i]}"

    # Remove main skill
    if [ -d "$skills_dir/geo" ]; then
        rm -rf "$skills_dir/geo"
        echo -e "${GREEN}✓ [${target_name}] Removed main skill${NC}"
    fi

    # Remove sub-skills
    for skill_dir in "$skills_dir"/geo-*/; do
        if [ -d "$skill_dir" ]; then
            skill_name=$(basename "$skill_dir")
            rm -rf "$skill_dir"
            echo -e "${GREEN}✓ [${target_name}] Removed ${skill_name}${NC}"
        fi
    done

    # Remove agents
    for agent_file in "$agents_dir"/geo-*.md; do
        if [ -f "$agent_file" ]; then
            agent_name=$(basename "$agent_file")
            rm -f "$agent_file"
            echo -e "${GREEN}✓ [${target_name}] Removed ${agent_name}${NC}"
        fi
    done
done

echo ""
echo -e "${GREEN}GEO-SEO skill has been uninstalled.${NC}"
echo ""
echo "Note: Python dependencies were not removed."
echo "To remove them manually:"
echo "  pip uninstall beautifulsoup4 requests lxml playwright Pillow validators"
echo ""
