#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────
# 🪨 Caveman Skills Uninstaller — GitHub Copilot
# ─────────────────────────────────────────────────────────

case "$(uname -s)" in
    Darwin)  VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User" ;;
    Linux)   VSCODE_USER_DIR="$HOME/.config/Code/User" ;;
    MINGW*|MSYS*|CYGWIN*) VSCODE_USER_DIR="${APPDATA:-$HOME/AppData/Roaming}/Code/User" ;;
    *)       VSCODE_USER_DIR="$HOME/.config/Code/User" ;;
esac

PROMPTS_DIR="$VSCODE_USER_DIR/prompts"
INSTRUCTIONS_FILE="$HOME/.config/github-copilot/caveman-instructions.md"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo -e "${CYAN}🪨 Caveman Skills Uninstaller — GitHub Copilot${NC}"
echo ""

SKILLS=(caveman caveman-commit caveman-review caveman-compress caveman-help)
REMOVED=0

for skill in "${SKILLS[@]}"; do
    target="$PROMPTS_DIR/${skill}.prompt.md"
    if [ -f "$target" ]; then
        rm -f "$target"
        echo -e "  ${RED}✕${NC} Removed $skill.prompt.md"
        ((REMOVED++))
    fi
done

if [ "$REMOVED" -eq 0 ]; then
    echo -e "  ${YELLOW}No caveman prompt files found in ${PROMPTS_DIR}${NC}"
else
    echo -e "\n  ${GREEN}Removed ${REMOVED} prompt file(s)${NC}"
fi

# Remove user-level instructions file
if [ -f "$INSTRUCTIONS_FILE" ]; then
    rm -f "$INSTRUCTIONS_FILE"
    echo -e "  ${RED}✕${NC} Removed ${INSTRUCTIONS_FILE}"
    # Clean up empty parent dir
    rmdir "$(dirname "$INSTRUCTIONS_FILE")" 2>/dev/null || true
fi

echo ""
echo -e "${YELLOW}Note:${NC} If you wired caveman into VS Code settings.json"
echo "   (github.copilot.chat.*.instructions), remove those entries manually."
echo "   If you copied caveman to any repo's .github/copilot-instructions.md,"
echo "   delete it there as well."
echo ""
echo -e "${GREEN}Done.${NC} Caveman extinct from Copilot. Normal mode restored."
echo ""
