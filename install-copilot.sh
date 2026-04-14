#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────
# 🪨 Caveman Skills Installer — GitHub Copilot
#    Installs skills as VS Code prompt files and a
#    user-level custom instructions file for Copilot Chat.
# ─────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SOURCE="$SCRIPT_DIR/skills"

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

# ── Detect VS Code user prompts directory ────────────────

case "$(uname -s)" in
    Darwin)  VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User" ;;
    Linux)   VSCODE_USER_DIR="$HOME/.config/Code/User" ;;
    MINGW*|MSYS*|CYGWIN*) VSCODE_USER_DIR="${APPDATA:-$HOME/AppData/Roaming}/Code/User" ;;
    *)       VSCODE_USER_DIR="$HOME/.config/Code/User" ;;
esac

PROMPTS_DIR="$VSCODE_USER_DIR/prompts"
INSTRUCTIONS_FILE="$HOME/.config/github-copilot/caveman-instructions.md"

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

# ── Convert SKILL.md → .prompt.md ────────────────────────
# Strip YAML frontmatter, rewrap with Copilot prompt-file
# frontmatter (mode + description).

convert_skill() {
    local src="$1"
    local dest="$2"
    local description body esc_desc

    # Extract description from YAML frontmatter (single or multi-line).
    description=$(awk '
        /^---$/ { n++; next }
        n==1 && /^description:/ {
            sub(/^description:[[:space:]]*/, "")
            sub(/^>[[:space:]]*/, "")
            desc = $0
            while ((getline line) > 0 && line !~ /^---$/ && line !~ /^[a-zA-Z_-]+:/) {
                sub(/^[[:space:]]+/, " ", line)
                desc = desc line
            }
            sub(/^[[:space:]]+/, "", desc)
            sub(/[[:space:]]+$/, "", desc)
            print desc
            exit
        }
    ' "$src")

    [ -z "$description" ] && description="Caveman skill"

    # Body = everything after the closing --- of the frontmatter.
    body=$(awk '
        /^---$/ { n++; if (n==2) { started=1; next } }
        started { print }
    ' "$src")

    # Escape single quotes in description for YAML single-quoted string.
    esc_desc=$(printf '%s' "$description" | sed "s/'/''/g")

    {
        echo "---"
        echo "mode: 'ask'"
        echo "description: '${esc_desc}'"
        echo "---"
        echo ""
        echo "$body"
    } > "$dest"
}

# ── Install prompt files ─────────────────────────────────

mkdir -p "$PROMPTS_DIR"

for skill_dir in "$SKILLS_SOURCE"/*/; do
    skill_name=$(basename "$skill_dir")
    src="$skill_dir/SKILL.md"
    dest="$PROMPTS_DIR/${skill_name}.prompt.md"

    [ -f "$src" ] || continue

    if [ -f "$dest" ]; then
        echo -e "  ${YELLOW}↻${NC} $skill_name.prompt.md (overwriting)"
    else
        echo -e "  ${GREEN}+${NC} $skill_name.prompt.md"
    fi

    convert_skill "$src" "$dest"
done

echo ""
echo -e "${GREEN}✅ Prompt files installed to:${NC}"
echo -e "   $PROMPTS_DIR"
echo ""

# ── Install user-level custom instructions file ──────────

mkdir -p "$(dirname "$INSTRUCTIONS_FILE")"
cat > "$INSTRUCTIONS_FILE" <<'EOF'
# Caveman mode — custom instructions for GitHub Copilot

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
EOF

echo -e "${GREEN}✅ Instructions file written:${NC}"
echo -e "   $INSTRUCTIONS_FILE"
echo ""

# ── Always-on wiring instructions ────────────────────────

echo -e "${CYAN}Enable always-on caveman in Copilot Chat?${NC}"
echo ""
echo "  Two options — pick whichever you prefer:"
echo ""
echo -e "  ${YELLOW}Option A — Per-repo (recommended):${NC}"
echo "    Create .github/copilot-instructions.md in your repo. Copilot Chat"
echo "    auto-loads it. Easiest to copy ours:"
echo ""
echo "      mkdir -p .github && cp \"$INSTRUCTIONS_FILE\" .github/copilot-instructions.md"
echo ""
echo -e "  ${YELLOW}Option B — User-level (all repos, VS Code):${NC}"
echo "    Add to your VS Code user settings.json:"
echo ""
cat <<EOF
      "github.copilot.chat.codeGeneration.instructions": [
        { "file": "$INSTRUCTIONS_FILE" }
      ],
      "github.copilot.chat.commitMessageGeneration.instructions": [
        { "file": "$INSTRUCTIONS_FILE" }
      ],
      "github.copilot.chat.reviewSelection.instructions": [
        { "file": "$INSTRUCTIONS_FILE" }
      ]
EOF
echo ""
echo "    Also enable prompt files (if not already):"
echo ""
echo "      \"chat.promptFiles\": true"
echo ""

# ── Verify ───────────────────────────────────────────────

echo -e "${CYAN}Installed prompt files:${NC}"
for pf in "$PROMPTS_DIR"/caveman*.prompt.md; do
    [ -f "$pf" ] || continue
    name=$(basename "$pf" .prompt.md)
    echo -e "  ${GREEN}✓${NC} /$name"
done

echo ""
echo -e "${GREEN}Done.${NC} Restart VS Code. Invoke a skill from Copilot Chat with:"
echo ""
echo "  /caveman         — activate caveman mode"
echo "  /caveman-commit  — terse commit message"
echo "  /caveman-review  — one-line code review"
echo "  /caveman-compress — compress .md file"
echo "  /caveman-help    — reference card"
echo ""
echo "  Uninstall: ./uninstall-copilot.sh"
echo ""
