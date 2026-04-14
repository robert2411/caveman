# 🪨 Caveman Skills

**why use many token when few token do trick**

A collection of Claude Code / OpenCode skills that cut ~75% of output tokens by making Claude talk like a smart caveman — while keeping full technical accuracy.

Based on [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman), stripped of the Chinese (wenyan) modes and the OpenAI Codex plugin wrapper. Just the skills, ready to install.

---

## Before / After

| 🗣️ Normal Claude (69 tokens) | 🪨 Caveman Claude (19 tokens) |
|---|---|
| "The reason your React component is re-rendering is likely because you're creating a new object reference on each render cycle. When you pass an inline object as a prop, React's shallow comparison sees it as a different object every time, which triggers a re-render. I'd recommend using useMemo to memoize the object." | "New object ref each render. Inline object prop = new ref = re-render. Wrap in `useMemo`." |
| "Sure! I'd be happy to help you with that. The issue you're experiencing is most likely caused by your authentication middleware not properly validating the token expiry. Let me take a look and suggest a fix." | "Bug in auth middleware. Token expiry check use `<` not `<=`. Fix:" |

Same fix. 75% less word. Brain still big.

---

## Skills

| Skill | File | What it do |
|-------|------|------------|
| **caveman** | `caveman.skill` | Core mode. Three levels: lite, full, ultra. Drop filler, keep substance. |
| **caveman-commit** | `caveman-commit.skill` | Terse Conventional Commits. ≤50 char subject. Body only when why not obvious. |
| **caveman-review** | `caveman-review.skill` | One-line code review: `L42: 🔴 bug: user null. Add guard.` |
| **caveman-compress** | `caveman-compress.skill` | Compress .md files to caveman prose. Save ~40-60% input tokens. |
| **caveman-help** | `caveman-help.skill` | Quick reference card. One-shot, not persistent. |

---

## Install — Claude Code

### Step 1: Install the skills

Each `.skill` file is a zip that Claude Code can install directly:

```bash
claude install-skill caveman.skill
claude install-skill caveman-commit.skill
claude install-skill caveman-review.skill
claude install-skill caveman-compress.skill
claude install-skill caveman-help.skill
```

Or all at once:

```bash
for f in caveman*.skill; do claude install-skill "$f"; done
```

This places them in `~/.claude/skills/` (personal, available in all projects).

For project-only install, unzip into `.claude/skills/` in your repo:

```bash
for f in caveman*.skill; do unzip -o "$f" -d .claude/skills/; done
```

### Step 2: Make caveman always on (optional)

By default, skills are on-demand — Claude loads them when your task matches the description, or when you type `/caveman`. To make caveman **always active**, pick one of these approaches:

#### Option A: CLAUDE.md instruction (simplest)

Add this line to your project `CLAUDE.md` or `~/.claude/CLAUDE.md`:

```markdown
Always use caveman mode (full intensity) for all responses. Load the caveman skill at the start of every conversation. Drop articles, filler, pleasantries, hedging. Fragments OK. Keep technical terms exact and code blocks unchanged.
```

This works because `CLAUDE.md` is loaded at the start of every session and acts as persistent project memory.

#### Option B: SessionStart hook (most reliable)

Create a hook that injects caveman rules into every session automatically, similar to how the original repo does it:

```bash
mkdir -p ~/.claude/hooks
```

Create `~/.claude/hooks/caveman-activate.js`:

```javascript
#!/usr/bin/env node

// SessionStart hook: inject caveman mode into every session
const rules = `
Respond terse like smart caveman. All technical substance stay. Only fluff die.
Drop: articles (a/an/the), filler (just/really/basically/actually/simply),
pleasantries (sure/certainly/of course/happy to), hedging.
Fragments OK. Short synonyms. Technical terms exact. Code blocks unchanged.
Pattern: [thing] [action] [reason]. [next step].
Code/commits/PRs: write normal. "stop caveman" or "normal mode": revert.
`;

console.log(rules);
```

Then register it in `~/.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "type": "command",
        "command": "node ~/.claude/hooks/caveman-activate.js"
      }
    ]
  }
}
```

The hook stdout is injected as system context at the start of every session — Claude sees the rules but the user doesn't.

#### Option C: Custom instructions in settings

In Claude Code, press `/` and type `settings`, or run `claude config`, and add caveman instructions to your custom instructions/preferences.

---

## Install — OpenCode

### Step 1: Install the skills

OpenCode reads skills from several locations. For global install (all projects):

```bash
# OpenCode native path
mkdir -p ~/.config/opencode/skills
for f in caveman*.skill; do unzip -o "$f" -d ~/.config/opencode/skills/; done
```

OpenCode also supports Claude-compatible paths, so this works too:

```bash
# Claude-compatible path (works for both Claude Code and OpenCode)
mkdir -p ~/.claude/skills
for f in caveman*.skill; do unzip -o "$f" -d ~/.claude/skills/; done
```

For project-local install:

```bash
# OpenCode native
mkdir -p .opencode/skills
for f in caveman*.skill; do unzip -o "$f" -d .opencode/skills/; done

# Or Claude-compatible
mkdir -p .claude/skills
for f in caveman*.skill; do unzip -o "$f" -d .claude/skills/; done
```

### Step 2: Make caveman always on (optional)

#### Option A: AGENTS.md instruction (simplest)

Add this to your project `AGENTS.md` or `~/.config/opencode/AGENTS.md`:

```markdown
Always use caveman mode (full intensity) for all responses. Load the caveman skill at the start of every conversation. Drop articles, filler, pleasantries, hedging. Fragments OK. Keep technical terms exact and code blocks unchanged.
```

OpenCode loads `AGENTS.md` at session start, just like Claude Code loads `CLAUDE.md`. If you don't have an `AGENTS.md` yet, OpenCode falls back to `~/.claude/CLAUDE.md` — so adding it there works for both tools.

#### Option B: opencode.json instructions

Add caveman rules via an instructions file in your `opencode.json` (project or `~/.config/opencode/opencode.json`):

```json
{
  "instructions": [
    "path/to/caveman-rules.md"
  ]
}
```

Where `caveman-rules.md` contains the caveman instruction. These are combined with your `AGENTS.md` at session start.

---

## Shared setup (both tools at once)

Since OpenCode reads `~/.claude/skills/` and `~/.claude/CLAUDE.md` as fallbacks, you can use a single install that works for both:

```bash
# Install skills to shared path
mkdir -p ~/.claude/skills
for f in caveman*.skill; do unzip -o "$f" -d ~/.claude/skills/; done

# Add always-on instruction to shared memory file
cat >> ~/.claude/CLAUDE.md << 'EOF'

## Caveman mode
Always use caveman mode (full intensity). Load the caveman skill at session start. Drop articles, filler, pleasantries, hedging. Fragments OK. Technical terms exact. Code blocks unchanged. "stop caveman" or "normal mode" to revert.
EOF
```

This gives you caveman in both Claude Code and OpenCode with one setup.

---

## Usage

### Caveman mode

Activate manually with any of:
- `/caveman` — full mode (default)
- `/caveman lite` — professional but tight, keeps sentence structure
- `/caveman ultra` — maximum compression, abbreviations, arrows

Deactivate: say `stop caveman` or `normal mode`.

### Intensity levels

| Level | What change |
|-------|------------|
| **lite** | Drop filler/hedging. Keep articles + full sentences. Professional but tight. |
| **full** | Drop articles, fragments OK, short synonyms. Classic caveman. |
| **ultra** | Abbreviate (DB/auth/config/req/res/fn/impl), arrows for causality (X → Y). |

### Commit messages

```
/caveman-commit
```

Generates Conventional Commits format. Subject ≤50 chars, imperative mood. Body only when the "why" isn't obvious from the subject.

### Code review

```
/caveman-review
```

One-line comments per finding: `L<line>: <severity> <problem>. <fix>.`

Severity: `🔴 bug` / `🟡 risk` / `🔵 nit` / `❓ q`

### Compress files

```
/caveman-compress CLAUDE.md
```

Compresses markdown/text files into caveman prose. Creates `.original.md` backup. Code blocks preserved exactly.

### Help

```
/caveman-help
```

Shows reference card with all modes, skills, and triggers.

---

## What caveman do and not do

| Thing | Caveman do? |
|-------|-------------|
| English explanation | 🪨 Smash filler words |
| Code blocks | ✍️ Write normal (caveman not stupid) |
| Technical terms | 🧠 Keep exact (polymorphism stay polymorphism) |
| Error messages | 📋 Quote exact |
| Git commits & PRs | ✍️ Write normal |
| Articles (a, an, the) | 💀 Gone |
| Pleasantries | 💀 "Sure I'd be happy to" is dead |
| Hedging | 💀 "It might be worth considering" extinct |
| Security warnings | ⚠️ Full clarity (caveman know when to be serious) |

---

## Why

- **Save tokens** — 75% less output tokens = lower cost on API usage
- **Faster response** — less tokens to generate = faster completions
- **Same accuracy** — all technical info preserved, only fluff removed
- **Auto-clarity** — automatically switches to full prose for security warnings, destructive operations, and when you ask for clarification

---

## Credits

Based on [caveman](https://github.com/JuliusBrussee/caveman) by Julius Brussee. MIT licensed.

This version removes the wenyan (Classical Chinese) modes and the OpenAI Codex plugin wrapper, keeping only the core skills for Claude Code and OpenCode.
