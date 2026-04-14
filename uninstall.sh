#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────
# 🪨 Caveman Skills Uninstaller
# ─────────────────────────────────────────────────────────

TARGET_DIR="$HOME/.claude/skills"
CLAUDE_MD="$HOME/.claude/CLAUDE.md"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo -e "${CYAN}🪨 Caveman Skills Uninstaller${NC}"
echo ""

SKILLS=(caveman caveman-commit caveman-review caveman-compress caveman-help)
REMOVED=0

for skill in "${SKILLS[@]}"; do
    if [ -d "$TARGET_DIR/$skill" ]; then
        rm -rf "$TARGET_DIR/$skill"
        echo -e "  ${RED}✕${NC} Removed $skill"
        ((REMOVED++))
    fi
done

if [ "$REMOVED" -eq 0 ]; then
    echo -e "  ${YELLOW}No caveman skills found in ${TARGET_DIR}${NC}"
else
    echo -e "\n  ${GREEN}Removed ${REMOVED} skill(s)${NC}"
fi

# Remove always-on block from CLAUDE.md
if [ -f "$CLAUDE_MD" ] && grep -q "## Caveman mode" "$CLAUDE_MD" 2>/dev/null; then
    TEMP_FILE=$(mktemp)
    awk '
        /^## Caveman mode/ { skip=1; next }
        /^## / && skip { skip=0 }
        !skip { print }
    ' "$CLAUDE_MD" > "$TEMP_FILE"
    mv "$TEMP_FILE" "$CLAUDE_MD"
    echo -e "  ${RED}✕${NC} Removed caveman block from ${CLAUDE_MD}"
fi

echo ""
echo -e "${GREEN}Done.${NC} Caveman extinct. Normal mode restored."
echo ""
