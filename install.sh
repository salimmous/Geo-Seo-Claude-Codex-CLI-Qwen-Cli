#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# GEO-SEO Skill Installer
# Installs the GEO-first SEO analysis tool for Claude Code, Codex CLI, and Qwen Code
# ============================================================

REPO_URL="https://github.com/zubair-trabzada/geo-seo-claude.git"
CLAUDE_DIR="${HOME}/.claude"
CODEX_DIR="${CODEX_HOME:-${HOME}/.codex}"
QWEN_DIR="${QWEN_HOME:-${HOME}/.qwen}"
TEMP_DIR=$(mktemp -d)
GEO_INSTALL_TARGET="${GEO_INSTALL_TARGET:-all}"

# Detect if running via curl pipe (no interactive input available)
INTERACTIVE=true
if [ ! -t 0 ]; then
    INTERACTIVE=false
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║      GEO-SEO Skill Installer             ║${NC}"
    echo -e "${BLUE}║   GEO-First AI Search Optimization       ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}→ $1${NC}"
}

cleanup() {
    rm -rf "$TEMP_DIR"
}

trap cleanup EXIT

TARGET_NAMES=()
TARGET_BASE_DIRS=()
TARGET_SKILLS_DIRS=()
TARGET_AGENTS_DIRS=()
TARGET_INSTALL_DIRS=()

add_target() {
    local target_name="$1"
    local target_base="$2"

    TARGET_NAMES+=("$target_name")
    TARGET_BASE_DIRS+=("$target_base")
    TARGET_SKILLS_DIRS+=("${target_base}/skills")
    TARGET_AGENTS_DIRS+=("${target_base}/agents")
    TARGET_INSTALL_DIRS+=("${target_base}/skills/geo")
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
                print_error "Invalid GEO_INSTALL_TARGET: ${GEO_INSTALL_TARGET}"
                echo "  Valid values: claude, codex, qwen, both, all"
                echo "  You can also pass a comma-separated list like: claude,qwen"
                exit 1
                ;;
        esac
    done

    if [ "${#TARGET_NAMES[@]}" -eq 0 ]; then
        print_error "No installation targets resolved from GEO_INSTALL_TARGET=${GEO_INSTALL_TARGET}"
        exit 1
    fi
}

main() {
    print_header

    # ---- Check Prerequisites ----
    print_info "Checking prerequisites..."

    # Check for Git
    if ! command -v git &> /dev/null; then
        print_error "Git is required but not installed."
        echo "  Install: https://git-scm.com/downloads"
        exit 1
    fi
    print_success "Git found: $(git --version)"

    # Check for Python 3
    PYTHON_CMD=""
    if command -v python3 &> /dev/null; then
        PYTHON_CMD="python3"
    elif command -v python &> /dev/null; then
        PYTHON_VERSION=$(python --version 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
        if [ -n "$PYTHON_VERSION" ]; then
            MAJOR=$(echo "$PYTHON_VERSION" | cut -d. -f1)
            MINOR=$(echo "$PYTHON_VERSION" | cut -d. -f2)
            if [ "$MAJOR" -ge 3 ] && [ "$MINOR" -ge 8 ]; then
                PYTHON_CMD="python"
            fi
        fi
    fi

    if [ -z "$PYTHON_CMD" ]; then
        print_error "Python 3.8+ is required but not found."
        echo "  Install: https://www.python.org/downloads/"
        exit 1
    fi
    print_success "Python found: $($PYTHON_CMD --version)"

    # Select installation targets
    configure_targets "$GEO_INSTALL_TARGET"

    print_info "Installation target: ${GEO_INSTALL_TARGET}"

    HAS_CLAUDE=false
    HAS_CODEX=false
    HAS_QWEN=false
    if command -v claude &> /dev/null; then
        HAS_CLAUDE=true
        print_success "Claude Code CLI found"
    fi
    if command -v codex &> /dev/null; then
        HAS_CODEX=true
        print_success "Codex CLI found"
    fi
    if command -v qwen &> /dev/null; then
        HAS_QWEN=true
        print_success "Qwen Code CLI found"
    fi

    MISSING_TARGET_CLI=false
    for i in "${!TARGET_NAMES[@]}"; do
        target_name="${TARGET_NAMES[$i]}"
        if [ "$target_name" = "claude" ] && [ "$HAS_CLAUDE" = false ]; then
            print_warning "Claude Code CLI not found in PATH."
            echo "  Install: npm install -g @anthropic-ai/claude-code"
            MISSING_TARGET_CLI=true
        fi
        if [ "$target_name" = "codex" ] && [ "$HAS_CODEX" = false ]; then
            print_warning "Codex CLI not found in PATH."
            echo "  Install: https://github.com/openai/codex"
            MISSING_TARGET_CLI=true
        fi
        if [ "$target_name" = "qwen" ] && [ "$HAS_QWEN" = false ]; then
            print_warning "Qwen Code CLI not found in PATH."
            echo "  Install: npm install -g @qwen-code/qwen-code@latest"
            MISSING_TARGET_CLI=true
        fi
    done

    if [ "$MISSING_TARGET_CLI" = true ]; then
        echo ""
        if [ "$INTERACTIVE" = true ]; then
            read -p "Continue installation anyway? (y/n): " -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        else
            print_info "Non-interactive mode — continuing anyway..."
        fi
    fi

    # ---- Create Directories ----
    print_info "Creating directories..."

    for i in "${!TARGET_NAMES[@]}"; do
        skills_dir="${TARGET_SKILLS_DIRS[$i]}"
        agents_dir="${TARGET_AGENTS_DIRS[$i]}"
        install_dir="${TARGET_INSTALL_DIRS[$i]}"

        mkdir -p "$skills_dir"
        mkdir -p "$agents_dir"
        mkdir -p "$install_dir"
        mkdir -p "$install_dir/scripts"
        mkdir -p "$install_dir/schema"
        mkdir -p "$install_dir/hooks"
    done

    print_success "Directory structure created"

    # ---- Clone or Copy Repository ----
    print_info "Fetching GEO-SEO skill files..."

    # Check if running from the repo directory (local install)
    # BASH_SOURCE may be empty when piped via curl, so handle gracefully
    SCRIPT_DIR=""
    if [ -n "${BASH_SOURCE[0]:-}" ] && [ "${BASH_SOURCE[0]}" != "bash" ]; then
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)" || true
    fi

    if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/geo/SKILL.md" ]; then
        print_info "Installing from local directory..."
        SOURCE_DIR="$SCRIPT_DIR"
    else
        print_info "Cloning from repository..."
        git clone --depth 1 "$REPO_URL" "$TEMP_DIR/repo" || {
            print_error "Failed to clone repository. Check your internet connection."
            exit 1
        }
        SOURCE_DIR="${TEMP_DIR}/repo"
    fi

    SKILL_COUNT=$(find "$SOURCE_DIR/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
    AGENT_COUNT=$(find "$SOURCE_DIR/agents" -maxdepth 1 -type f -name "*.md" | wc -l | tr -d ' ')

    # ---- Install Assets ----
    for i in "${!TARGET_NAMES[@]}"; do
        target_name="${TARGET_NAMES[$i]}"
        skills_dir="${TARGET_SKILLS_DIRS[$i]}"
        agents_dir="${TARGET_AGENTS_DIRS[$i]}"
        install_dir="${TARGET_INSTALL_DIRS[$i]}"

        print_info "Installing assets for ${target_name}..."

        # Main skill
        cp -R "$SOURCE_DIR/geo/." "$install_dir/"

        # Sub-skills
        for skill_dir in "$SOURCE_DIR/skills"/*/; do
            if [ -d "$skill_dir" ]; then
                skill_name=$(basename "$skill_dir")
                target_dir="${skills_dir}/${skill_name}"
                mkdir -p "$target_dir"
                cp -R "$skill_dir/." "$target_dir/"
            fi
        done

        # Subagents
        for agent_file in "$SOURCE_DIR/agents/"*.md; do
            if [ -f "$agent_file" ]; then
                cp "$agent_file" "$agents_dir/"
            fi
        done

        # Utility scripts
        if [ -d "$SOURCE_DIR/scripts" ]; then
            cp -R "$SOURCE_DIR/scripts/." "$install_dir/scripts/"
            chmod +x "$install_dir/scripts/"*.py 2>/dev/null || true
        fi

        # Schema templates
        if [ -d "$SOURCE_DIR/schema" ]; then
            cp -R "$SOURCE_DIR/schema/." "$install_dir/schema/"
        fi

        # Hooks
        if [ -d "$SOURCE_DIR/hooks" ] && [ "$(ls -A "$SOURCE_DIR/hooks" 2>/dev/null)" ]; then
            cp -R "$SOURCE_DIR/hooks/." "$install_dir/hooks/"
            chmod +x "$install_dir/hooks/"* 2>/dev/null || true
        fi

        print_success "Installed GEO skill to ${install_dir}/"
    done

    # ---- Install Python Dependencies ----
    print_info "Installing Python dependencies..."

    if [ -f "$SOURCE_DIR/requirements.txt" ]; then
        $PYTHON_CMD -m pip install -r "$SOURCE_DIR/requirements.txt" --quiet 2>/dev/null && {
            print_success "Python dependencies installed"
        } || {
            print_warning "Some Python dependencies failed to install."
            echo "  Run manually: $PYTHON_CMD -m pip install -r requirements.txt"
            for install_dir in "${TARGET_INSTALL_DIRS[@]}"; do
                cp "$SOURCE_DIR/requirements.txt" "$install_dir/"
            done
        }
    fi

    # ---- Optional: Install Playwright ----
    if [ "$INTERACTIVE" = true ]; then
        echo ""
        read -p "Install Playwright for screenshots? (y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Installing Playwright browsers..."
            $PYTHON_CMD -m playwright install chromium 2>/dev/null && {
                print_success "Playwright Chromium installed"
            } || {
                print_warning "Playwright installation failed. Screenshots won't be available."
            }
        fi
    else
        print_info "Skipping Playwright (non-interactive mode). Install later with: python3 -m playwright install chromium"
    fi

    # ---- Verify Installation ----
    echo ""
    print_info "Verifying installation..."

    VERIFY_OK=true

    for i in "${!TARGET_NAMES[@]}"; do
        target_name="${TARGET_NAMES[$i]}"
        skills_dir="${TARGET_SKILLS_DIRS[$i]}"
        agents_dir="${TARGET_AGENTS_DIRS[$i]}"
        install_dir="${TARGET_INSTALL_DIRS[$i]}"

        print_info "Verification (${target_name})..."
        [ -f "$install_dir/SKILL.md" ] && print_success "Main skill file" || { print_error "Main skill file missing"; VERIFY_OK=false; }
        [ -d "$skills_dir/geo-audit" ] && print_success "Sub-skills directory" || { print_error "Sub-skills missing"; VERIFY_OK=false; }
        [ "$(find "$agents_dir" -maxdepth 1 -type f -name "geo-*.md" | wc -l | tr -d ' ')" -gt 0 ] && print_success "Agent files" || { print_error "Agent files missing"; VERIFY_OK=false; }
        [ -d "$install_dir/scripts" ] && print_success "Utility scripts" || { print_error "Scripts missing"; VERIFY_OK=false; }
        [ -d "$install_dir/schema" ] && print_success "Schema templates" || { print_error "Schema templates missing"; VERIFY_OK=false; }
    done

    # ---- Print Summary ----
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║        Installation Complete!             ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
    echo ""
    echo "  Targets:      ${TARGET_NAMES[*]}"
    for i in "${!TARGET_NAMES[@]}"; do
        echo "  Installed to: ${TARGET_INSTALL_DIRS[$i]}"
    done
    echo "  Skills:       ${SKILL_COUNT} sub-skills per target"
    echo "  Agents:       ${AGENT_COUNT} subagents per target"
    echo ""
    echo -e "${BLUE}Quick Start:${NC}"
    echo "  Claude Code:"
    echo "    /geo audit https://site.com"
    echo "    /geo quick https://site.com"
    echo "    /geo citability https://site.com/blog/article"
    echo ""
    echo "  Codex CLI (prompt examples):"
    echo "    Restart Codex if it was already open after installing the skill."
    echo "    Do not use /geo slash commands in Codex."
    echo "    Use \$geo and run a GEO audit for https://site.com"
    echo "    Use \$geo and run a quick GEO snapshot for https://site.com"
    echo ""
    echo "  Qwen Code:"
    echo "    First run may require Qwen OAuth authentication."
    echo "    qwen"
    echo "    /skills geo"
    echo "    geo"
    echo "    Run a GEO audit for https://site.com"
    echo ""
    echo -e "${BLUE}Claude Slash Commands:${NC}"
    echo "    /geo audit <url>      Full GEO + SEO audit"
    echo "    /geo quick <url>      60-second visibility snapshot"
    echo "    /geo citability <url> AI citation readiness score"
    echo "    /geo crawlers <url>   AI crawler access check"
    echo "    /geo llmstxt <url>    Analyze/generate llms.txt"
    echo "    /geo brands <url>     Brand mention scan"
    echo "    /geo platforms <url>  Platform-specific optimization"
    echo "    /geo schema <url>     Structured data analysis"
    echo "    /geo technical <url>  Technical SEO audit"
    echo "    /geo content <url>    Content quality & E-E-A-T"
    echo "    /geo report <url>     Client-ready GEO report"
    echo "    /geo report-pdf       Generate PDF report from audit data"
    echo ""
    echo "  Documentation: https://github.com/zubair-trabzada/geo-seo-claude"
    echo ""

    if [ "$VERIFY_OK" = false ]; then
        exit 1
    fi
}

main "$@"
