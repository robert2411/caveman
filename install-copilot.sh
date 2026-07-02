#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────
# 🪨 Caveman Skills Installer — GitHub Copilot
#    Installs agent skills and local custom instructions for
#    GitHub Copilot CLI.
# ─────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SOURCE="$SCRIPT_DIR/skills"
TARGET_DIR="$HOME/.copilot/skills"
INSTRUCTIONS_FILE="$HOME/.copilot/copilot-instructions.md"
BLOCK_START="<!-- caveman-mode:start -->"
BLOCK_END="<!-- caveman-mode:end -->"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo -e "${CYAN}🪨 Caveman Skills Installer — GitHub Copilot${NC}"
echo -e "${CYAN}   why use many token when few token do trick${NC}"
echo ""

# ── Verify source ────────────────────────────────────────

if [ ! -d "$SKILLS_SOURCE" ]; then
    echo -e "${RED}Error: skills/ directory not found next to this script.${NC}"
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

    [ -f "$skill_dir/SKILL.md" ] || continue

    if [ -d "$dest" ]; then
        echo -e "  ${YELLOW}↻${NC} $skill_name (overwriting)"
    else
        echo -e "  ${GREEN}+${NC} $skill_name"
    fi

    rm -rf "$dest"
    cp -r "$skill_dir" "$dest"
done

echo ""
echo -e "${GREEN}✅ Skills installed to:${NC}"
echo -e "   $TARGET_DIR"
echo ""

# ── Install local custom instructions block ──────────────

mkdir -p "$(dirname "$INSTRUCTIONS_FILE")"

CAVEMAN_BLOCK=$(cat <<EOF
$BLOCK_START
## Caveman mode

Respond terse like smart caveman. All technical substance stay. Only fluff die.

Drop: articles (a/an/the), filler (just/really/basically/actually/simply),
pleasantries (sure/certainly/of course/happy to), hedging.
Fragments OK. Short synonyms. Technical terms exact. Code blocks unchanged.
Errors quoted exact.

Pattern: [thing] [action] [reason]. [next step].

Code, commits, PRs: write normal prose.
"stop caveman" or "normal mode": revert to standard prose this session.

Auto-clarity — drop caveman mode for:
- Security warnings
- Irreversible / destructive action confirmations
- Multi-step sequences where fragment order risks misread
- When user asks to clarify or repeats a question
Resume caveman after the clear part is done.
$BLOCK_END
EOF
)

if [ -f "$INSTRUCTIONS_FILE" ] && grep -q "$BLOCK_START" "$INSTRUCTIONS_FILE" 2>/dev/null; then
    temp_file=$(mktemp)
    awk -v start="$BLOCK_START" -v end="$BLOCK_END" '
        $0 == start { skip=1; next }
        $0 == end { skip=0; next }
        !skip { print }
    ' "$INSTRUCTIONS_FILE" > "$temp_file"
    {
        cat "$temp_file"
        printf '\n%s\n' "$CAVEMAN_BLOCK"
    } > "$INSTRUCTIONS_FILE"
    rm -f "$temp_file"
    echo -e "${YELLOW}↻${NC} Updated caveman block in:"
else
    {
        [ ! -s "$INSTRUCTIONS_FILE" ] || printf '\n'
        printf '%s\n' "$CAVEMAN_BLOCK"
    } >> "$INSTRUCTIONS_FILE"
    echo -e "${GREEN}+${NC} Added caveman block to:"
fi
echo -e "   $INSTRUCTIONS_FILE"
echo ""

echo -e "${CYAN}Notes:${NC}"
echo "  Copilot CLI loads local instructions from:"
echo "    $INSTRUCTIONS_FILE"
echo ""
echo "  For repo-scoped always-on behavior instead, copy that block into:"
echo "    .github/copilot-instructions.md"
echo ""
echo "  If Copilot CLI is already running, reload skills with:"
echo "    /skills reload"
echo "  Then confirm with:"
echo "    /skills info caveman"
echo ""

# ── Verify ───────────────────────────────────────────────

echo -e "${CYAN}Installed skills:${NC}"
for skill_dir in "$TARGET_DIR"/caveman*/; do
    [ -f "$skill_dir/SKILL.md" ] || continue
    name=$(basename "$skill_dir")
    echo -e "  ${GREEN}✓${NC} /$name"
done

echo ""
echo -e "${GREEN}Done.${NC} Start or reload Copilot CLI. Invoke a skill with:"
echo ""
echo "  /caveman         — activate caveman mode"
echo "  /caveman-commit  — terse commit message"
echo "  /caveman-review  — one-line code review"
echo "  /caveman-compress — compress .md file"
echo "  /caveman-help    — reference card"
echo ""
echo "  Uninstall: ./uninstall-copilot.sh"
echo ""
