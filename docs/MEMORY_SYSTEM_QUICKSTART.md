# Memory System Quick Start 🚀

## What's New?

Your familiar just got a major upgrade! It now has:

- **🧠 Conversation Memory** - Remembers all your interactions
- **🗂️ Project Context Awareness** - Understands what you're working on
- **⚙️ User Preferences** - Learns your coding style and preferences
- **🔄 Session Continuity** - Maintains context within terminal sessions

## Installation Check

### Required Dependencies

The memory system requires:
- ✅ SQLite3 CLI tool (`sqlite3`)
- ✅ jq (JSON processor)
- ✅ Git (for project context detection)

**Check installation:**
```bash
command -v sqlite3 || echo "⚠️  Please install sqlite3"
command -v jq || echo "⚠️  Please install jq"
command -v git || echo "✅ Git not required but recommended"
```

**Install missing dependencies:**
```bash
# Linux (Debian/Ubuntu)
sudo apt-get install sqlite3 jq git

# macOS
brew install sqlite3 jq git
```

### Verify Installation

```bash
# Check if database exists
ls -la $CAULDRON_DATABASE

# Should show: /path/to/cauldron/data/cauldron.db
```

## 5-Minute Quick Start

### 1. Initialize Memory System (if needed)

If you installed Cauldron before the memory system was added:

```bash
__init_memory
```

You should see: `✓ Memory system initialized successfully`

### 2. Try Context Awareness

```bash
# Check what your familiar knows about your current project
context

# You'll see JSON output with:
# - Current directory
# - Git info (if in a repo)
# - Detected languages
# - Framework
# - Package manager
```

### 3. Ask a Question

```bash
# The familiar now has context about your project!
ask "How should I structure this project?"

# If you're in a Next.js project, it will suggest Next.js-specific patterns
# If you're in a Rust project, it will suggest Rust-specific patterns
```

### 4. Remember a Preference

```bash
# Teach your familiar your coding style
remember coding_style "prefer functional programming with TypeScript"

# Save your preferred tools
remember test_framework "vitest"
remember linter "ESLint with strict rules"
```

### 5. Recall Past Conversations

```bash
# See your recent conversations
recall

# Search for specific topics
recall -s "authentication"

# See all conversations across all sessions
recall -a -l 20
```

### 6. Ask a Follow-up Question

```bash
# First question
ask "What's the difference between map and forEach?"

# Follow-up (it remembers the previous question!)
ask "Which one should I use for this project?"

# The familiar uses conversation history to provide contextual answers
```

## Common Commands

### Memory Commands

```bash
# View conversation history
recall                    # Last 10 from current session
recall -a                 # All sessions
recall -s "topic"         # Search conversations

# Manage preferences
remember key value        # Save preference
remember --list           # View all preferences
forget -p key            # Remove preference

# Project context
context                   # View current context
context -u                # Update project context in DB

# Clear history
forget -s                 # Clear session history
forget -a                 # Clear all history (careful!)
```

### Enhanced Ask Command

```bash
# Basic (now with context awareness)
ask "your question"

# Include more conversation history
ask "explain that in more detail" -c 10

# Don't save to memory (private question)
ask "quick question" -n

# Markdown output
ask "show me code" -m
```

## How Context Awareness Works

### Example 1: Project-Specific Advice

```bash
# In a React project
cd ~/my-react-app
ask "How should I manage state?"
# → Suggests React hooks (useState, useReducer, Context API)

# In a Vue project
cd ~/my-vue-app
ask "How should I manage state?"
# → Suggests Vuex or Pinia
```

### Example 2: Conversation Continuity

```bash
ask "What are the benefits of TypeScript?"
# AI explains TypeScript benefits

ask "Should I use it for small projects?"
# AI remembers you were asking about TypeScript
# and provides contextual answer

ask "Show me an example"
# AI provides a TypeScript example
```

### Example 3: Learning Your Style

```bash
# Save your preferences
remember coding_style "immutable data, pure functions, no classes"
remember architecture "microservices with event-driven design"

# Later...
ask "How should I structure this API?"
# AI uses your preferences in the response
```

## Project Context Detection

The familiar automatically detects:

### Languages
- JavaScript/TypeScript (package.json, tsconfig.json)
- Python (requirements.txt, setup.py, pyproject.toml)
- Rust (Cargo.toml)
- Go (go.mod)
- Ruby (Gemfile)
- Fish Shell (fish_plugins)

### Frameworks
- React, Next.js, Vue, Angular (from package.json)
- More to come!

### Package Managers
- npm, pnpm, yarn (Node.js)
- poetry, pip (Python)
- cargo (Rust)
- go mod (Go)
- bundler (Ruby)

### Git Information
- Repository root
- Current branch
- Remote URL
- Uncommitted changes count

## Troubleshooting

### "Memory system not initialized"

```bash
# Run initialization
__init_memory

# Check session
echo $CAULDRON_SESSION_ID

# If empty, initialize session
__init_session
```

### "sqlite3: command not found"

```bash
# Install sqlite3
sudo apt-get install sqlite3  # Linux
brew install sqlite3           # macOS
```

### No conversation history showing

```bash
# Check database
sqlite3 $CAULDRON_DATABASE "SELECT COUNT(*) FROM conversation_history;"

# If error, re-initialize
__init_memory
```

### Context not being detected

```bash
# Manually refresh
context -r

# Update database
context -u
```

## Privacy Note

All data is stored **locally** in: `$CAULDRON_DATABASE`

Nothing is sent to external servers except:
- Your questions to Ollama (running locally on your machine)
- AI responses from Ollama

Your code, files, and private data stay on your machine.

## Next Steps

1. ✅ Install required dependencies (sqlite3, jq)
2. ✅ Initialize memory system (`__init_memory`)
3. ✅ Try asking questions with context
4. ✅ Save your coding preferences
5. ✅ Explore conversation history
6. 📖 Read full docs: [MEMORY_SYSTEM.md](MEMORY_SYSTEM.md)

## Examples to Try

```bash
# 1. Project understanding
cd ~/your-project
context -u
ask "Analyze this project structure and suggest improvements"

# 2. Learning sessions
remember learning_goal "master React hooks"
ask "Explain useState vs useEffect"
ask "Show me a practical example"
ask "What are common mistakes?"
recall -s "React"  # Review what you learned

# 3. Code review assistant
ask "Review this function for potential bugs"
remember code_review_checklist "security, performance, readability"
ask "What should I check in code reviews?"

# 4. Architecture planning
remember architecture "clean architecture, DDD"
ask "How should I structure a new microservice?"
context -u  # Save project context
```

---

**Need help?** Run any command with `-h` or `--help`:

```bash
ask -h
recall -h
remember -h
forget -h
context -h
```

**Full documentation:** [MEMORY_SYSTEM.md](MEMORY_SYSTEM.md)

---

May your familiar remember all your magical moments! 🪄🧠
