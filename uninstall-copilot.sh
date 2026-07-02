#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────
# 🪨 Caveman Skills Uninstaller — GitHub Copilot
# ─────────────────────────────────────────────────────────

TARGET_DIR="$HOME/.copilot/skills"
INSTRUCTIONS_FILE="$HOME/.copilot/copilot-instructions.md"
LEGACY_INSTRUCTIONS_FILE="$HOME/.config/github-copilot/caveman-instructions.md"
BLOCK_START="<!-- caveman-mode:start -->"
BLOCK_END="<!-- caveman-mode:end -->"

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
    target="$TARGET_DIR/$skill"
    if [ -d "$target" ]; then
        rm -rf "$target"
        echo -e "  ${RED}✕${NC} Removed $skill"
        ((REMOVED+=1))
    fi
done

if [ "$REMOVED" -eq 0 ]; then
    echo -e "  ${YELLOW}No caveman skills found in ${TARGET_DIR}${NC}"
else
    echo -e "\n  ${GREEN}Removed ${REMOVED} skill(s)${NC}"
    rmdir "$TARGET_DIR" 2>/dev/null || true
fi

# Remove caveman block from local Copilot CLI instructions.
if [ -f "$INSTRUCTIONS_FILE" ] && grep -q "$BLOCK_START" "$INSTRUCTIONS_FILE" 2>/dev/null; then
    temp_file=$(mktemp)
    awk -v start="$BLOCK_START" -v end="$BLOCK_END" '
        $0 == start { skip=1; next }
        $0 == end { skip=0; next }
        !skip { print }
    ' "$INSTRUCTIONS_FILE" > "$temp_file"
    mv "$temp_file" "$INSTRUCTIONS_FILE"
    echo -e "  ${RED}✕${NC} Removed caveman block from ${INSTRUCTIONS_FILE}"
    rmdir "$(dirname "$INSTRUCTIONS_FILE")" 2>/dev/null || true
fi

# Clean up files from older installer versions.
case "$(uname -s)" in
    Darwin)  VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User" ;;
    Linux)   VSCODE_USER_DIR="$HOME/.config/Code/User" ;;
    MINGW*|MSYS*|CYGWIN*) VSCODE_USER_DIR="${APPDATA:-$HOME/AppData/Roaming}/Code/User" ;;
    *)       VSCODE_USER_DIR="$HOME/.config/Code/User" ;;
esac

PROMPTS_DIR="$VSCODE_USER_DIR/prompts"
LEGACY_REMOVED=0

for skill in "${SKILLS[@]}"; do
    legacy_target="$PROMPTS_DIR/${skill}.prompt.md"
    if [ -f "$legacy_target" ]; then
        rm -f "$legacy_target"
        echo -e "  ${RED}✕${NC} Removed legacy $skill.prompt.md"
        ((LEGACY_REMOVED+=1))
    fi
done

if [ -f "$LEGACY_INSTRUCTIONS_FILE" ]; then
    rm -f "$LEGACY_INSTRUCTIONS_FILE"
    echo -e "  ${RED}✕${NC} Removed legacy ${LEGACY_INSTRUCTIONS_FILE}"
    rmdir "$(dirname "$LEGACY_INSTRUCTIONS_FILE")" 2>/dev/null || true
fi

echo ""
echo -e "${YELLOW}Note:${NC} If you copied caveman into any repo's"
echo "   .github/copilot-instructions.md, remove it there as well."
if [ "$LEGACY_REMOVED" -gt 0 ]; then
    echo "   Legacy VS Code prompt files were also removed."
fi
echo ""
echo -e "${GREEN}Done.${NC} Caveman extinct from Copilot. Normal mode restored."
echo ""
