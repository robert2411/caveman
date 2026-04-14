#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────
# 🪨 Caveman Skills Installer
#    Installs skills to ~/.claude/skills/
#    Works with Claude Code and OpenCode
# ─────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SOURCE="$SCRIPT_DIR/skills"
TARGET_DIR="$HOME/.claude/skills"
CLAUDE_MD="$HOME/.claude/CLAUDE.md"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo ""
echo -e "${CYAN}🪨 Caveman Skills Installer${NC}"
echo -e "${CYAN}   why use many token when few token do trick${NC}"
echo ""

# ── Verify source files exist ────────────────────────────

if [ ! -d "$SKILLS_SOURCE" ]; then
    echo -e "${RED}Error: skills/ directory not found next to this script.${NC}"
    echo "Make sure you extracted the zip and run install.sh from inside caveman-skills/."
    exit 1
fi

SKILL_COUNT=$(find "$SKILLS_SOURCE" -name "SKILL.md" | wc -l | tr -d ' ')
if [ "$SKILL_COUNT" -eq 0 ]; then
    echo -e "${RED}Error: No SKILL.md files found in skills/ directory.${NC}"
    exit 1
fi

echo -e "Found ${GREEN}${SKILL_COUNT}${NC} skills to install."
echo ""

# ── Install skills ───────────────────────────────────────

mkdir -p "$TARGET_DIR"

for skill_dir in "$SKILLS_SOURCE"/*/; do
    skill_name=$(basename "$skill_dir")
    dest="$TARGET_DIR/$skill_name"

    if [ -d "$dest" ]; then
        echo -e "  ${YELLOW}↻${NC} $skill_name (overwriting)"
    else
        echo -e "  ${GREEN}+${NC} $skill_name"
    fi

    rm -rf "$dest"
    cp -r "$skill_dir" "$dest"
done

echo ""
echo -e "${GREEN}✅ Skills installed to ${TARGET_DIR}${NC}"
echo ""

# ── Always-on caveman mode ───────────────────────────────

echo -e "${CYAN}Make caveman always active?${NC}"
echo "  This adds an instruction to ~/.claude/CLAUDE.md so caveman mode"
echo "  activates at the start of every Claude Code and OpenCode session."
echo ""
echo "  You can always deactivate mid-session by saying \"stop caveman\""
echo "  or \"normal mode\"."
echo ""

read -rp "Enable always-on caveman? [y/N] " ALWAYS_ON

if [[ "$ALWAYS_ON" =~ ^[Yy]$ ]]; then
    # Pick intensity
    echo ""
    echo "  Which intensity level?"
    echo "    1) lite  — drop filler, keep sentence structure"
    echo "    2) full  — drop articles, fragments OK (default)"
    echo "    3) ultra — max compression, abbreviations, arrows"
    echo ""
    read -rp "  Level [1/2/3] (default: 2): " LEVEL_CHOICE

    case "$LEVEL_CHOICE" in
        1) LEVEL="lite" ;;
        3) LEVEL="ultra" ;;
        *) LEVEL="full" ;;
    esac

    CAVEMAN_BLOCK="
## Caveman mode
Always use caveman mode (${LEVEL} intensity). Load the caveman skill at session start. Drop articles, filler, pleasantries, hedging. Fragments OK. Technical terms exact. Code blocks unchanged. \"stop caveman\" or \"normal mode\" to revert."

    # Check if caveman block already exists
    if [ -f "$CLAUDE_MD" ] && grep -q "## Caveman mode" "$CLAUDE_MD" 2>/dev/null; then
        # Replace existing block (from ## Caveman mode to next ## or EOF)
        # Use a temp file approach for portability
        TEMP_FILE=$(mktemp)
        awk '
            /^## Caveman mode/ { skip=1; next }
            /^## / && skip { skip=0 }
            !skip { print }
        ' "$CLAUDE_MD" > "$TEMP_FILE"
        echo "$CAVEMAN_BLOCK" >> "$TEMP_FILE"
        mv "$TEMP_FILE" "$CLAUDE_MD"
        echo -e "  ${YELLOW}↻${NC} Updated caveman block in ${CLAUDE_MD}"
    else
        # Append
        mkdir -p "$(dirname "$CLAUDE_MD")"
        echo "$CAVEMAN_BLOCK" >> "$CLAUDE_MD"
        echo -e "  ${GREEN}+${NC} Added caveman block to ${CLAUDE_MD}"
    fi

    echo -e "  ${GREEN}✅ Always-on caveman (${LEVEL}) enabled${NC}"
else
    echo -e "  ${CYAN}Skipped.${NC} Use /caveman to activate manually per session."
fi

echo ""

# ── Verify ───────────────────────────────────────────────

echo -e "${CYAN}Installed skills:${NC}"
for skill_dir in "$TARGET_DIR"/caveman*/; do
    if [ -f "$skill_dir/SKILL.md" ]; then
        skill_name=$(basename "$skill_dir")
        echo -e "  ${GREEN}✓${NC} /$(echo "$skill_name" | sed 's/^caveman$/caveman/')"
    fi
done

echo ""
echo -e "${GREEN}Done.${NC} Start Claude Code or OpenCode. Caveman ready."
echo ""
echo "  Activate:   /caveman  or  /caveman lite  or  /caveman ultra"
echo "  Deactivate: \"stop caveman\" or \"normal mode\""
echo "  Help:       /caveman-help"
echo "  Uninstall:  ./uninstall.sh"
echo ""
