# Familiar Memory System 🧠

## Overview

The Familiar Memory System adds context awareness and persistent memory to your AI companion, making it truly intelligent and personalized. Your familiar now remembers your conversations, understands your projects, and learns your preferences.

## Features

### 1. **Conversation History** 💬
- Automatically saves all interactions with your familiar
- Retrieve past conversations with the `recall` command
- Search through conversation history
- Session-based memory (remembers context within a terminal session)

### 2. **Project Context Awareness** 🗂️
- Automatically detects project type (Node.js, Python, Rust, Go, etc.)
- Recognizes frameworks (React, Next.js, Vue, etc.)
- Identifies package managers (npm, pnpm, yarn, cargo, etc.)
- Tracks git repository information
- Stores project-specific metadata

### 3. **User Preferences** ⚙️
- Save global preferences (e.g., preferred editor, coding style)
- Store project-specific preferences
- Customize familiar behavior per project
- Persistent across sessions

### 4. **Session Management** 🔄
- Tracks terminal sessions
- Maintains conversation continuity within a session
- Associates conversations with working directory and project

---

## Commands

### `ask` - Enhanced AI Queries

The `ask` command now includes context awareness and conversation memory.

```bash
# Basic query (now with context awareness)
ask "How should I structure this API?"

# Include more conversation history
ask "Explain my last question in more detail" -c 10

# Markdown formatted response
ask "Show me an example" -m

# Don't save this conversation to memory
ask "Quick question" -n
```

**New Options:**
- `-c, --context N` - Include N previous conversations in context (default: 5)
- `-n, --no-memory` - Don't save this conversation to memory
- `-m, --markdown` - Return response in markdown format

### `recall` - View Conversation History

Retrieve and search through past conversations.

```bash
# Show last 10 conversations from current session
recall

# Show last 20 conversations
recall -l 20

# Show all conversations across all sessions
recall -a

# Search for specific topics
recall -s "typescript"
recall -s "API design"

# Output as JSON
recall -f json

# Combine options
recall -a -l 50 -s "debugging"
```

**Options:**
- `-l, --limit N` - Limit results to N conversations (default: 10)
- `-a, --all` - Show all conversations, not just current session
- `-f, --format TYPE` - Output format: text, json (default: text)
- `-s, --search TERM` - Search for conversations containing TERM

### `remember` - Save Preferences

Teach your familiar your preferences and coding style.

```bash
# Save project-specific preference
remember coding_style "prefer strict TypeScript with explicit types"

# Save global preference
remember -g editor "neovim"

# Save framework preference
remember preferred_framework "Next.js"

# List all saved preferences
remember --list
```

**Options:**
- `-g, --global` - Save as global preference (applies everywhere)
- `-p, --project` - Save as project-specific preference (default)
- `-l, --list` - List all saved preferences

**Example Preferences:**
```bash
remember coding_style "functional programming, immutability"
remember test_framework "vitest"
remember linter_config "strict ESLint with Airbnb rules"
remember deployment_platform "Vercel"
remember database "PostgreSQL with Prisma ORM"
```

### `forget` - Clear History or Preferences

Remove conversation history or preferences.

```bash
# Clear current session's conversations
forget -s

# Clear all conversation history (with confirmation)
forget -a

# Remove a specific preference
forget -p coding_style

# Skip confirmation prompt
forget -a -y
```

**Options:**
- `-s, --session` - Clear conversation history for current session
- `-a, --all` - Clear all conversation history
- `-p, --preference KEY` - Remove a specific preference
- `-y, --yes` - Skip confirmation prompt

**Safety:**
- Deleting all history requires typing "yes" (not just "y")
- Session-based deletion only affects current session
- Preference deletion can be undone by setting again

### `context` - View/Update Project Context

View or update the detected project context.

```bash
# Show current context
context

# Refresh and display context
context -r

# Update project context in database
context -u
```

**Options:**
- `-u, --update` - Update context for current project
- `-r, --refresh` - Refresh and display current context

**Context Information:**
- Current working directory
- Git repository details (branch, remote, uncommitted changes)
- Primary programming language
- All detected languages
- Framework (if detected)
- Package manager
- Session information

---

## Setup & Installation

### Automatic Setup (for new installs)

The memory system is automatically initialized during Cauldron installation. The database tables are created from `data/schema.sql`.

### Manual Setup (for existing installations)

If you installed Cauldron before the memory system was added, run:

```bash
# Initialize the memory system
__init_memory

# This will:
# - Create necessary database tables
# - Set up session tracking
# - Initialize default preferences
```

### Session Initialization

Sessions are automatically initialized when you open a new terminal. To manually initialize:

```bash
__init_session
```

---

## How It Works

### Conversation Flow

1. **You ask a question**: `ask "How do I optimize this query?"`
2. **Context is gathered**:
   - Current directory
   - Git repository status
   - Project type and languages
   - Recent conversation history (last 5 by default)
3. **Enhanced prompt is built**:
   - Your question
   - Current context
   - Conversation history
   - User preferences
4. **AI responds** with context-aware answer
5. **Conversation is saved** to database with full context snapshot

### Context Awareness Example

```bash
# In a Next.js project
cd ~/my-nextjs-app

ask "How should I handle authentication?"
# AI knows you're in a Next.js project and suggests Next-Auth

remember auth_provider "Clerk"

ask "Show me an example"
# AI uses Clerk (from your preference) in the example
```

### Session Continuity

```bash
# Start of session
ask "What's the difference between useState and useReducer?"

# Later in same session
ask "Which one should I use for this component?"
# AI remembers the previous question and has context
```

---

## Database Schema

### Tables

#### `conversation_history`
Stores all interactions with the familiar.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key |
| session_id | TEXT | Foreign key to sessions |
| timestamp | INTEGER | Unix timestamp |
| query | TEXT | User's question |
| response | TEXT | AI's response |
| context_snapshot | TEXT | JSON snapshot of context |
| model | TEXT | AI model used (default: llama3.2) |
| command_type | TEXT | Command used (ask, familiar, etc.) |
| success | INTEGER | Whether query succeeded |

#### `project_context`
Stores project-specific information.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key |
| project_path | TEXT | Unique project path |
| project_name | TEXT | Name of project |
| git_remote | TEXT | Git remote URL |
| primary_language | TEXT | Main programming language |
| languages | TEXT | All detected languages |
| framework | TEXT | Detected framework |
| package_manager | TEXT | Package manager in use |
| last_updated | INTEGER | Last update timestamp |
| metadata | TEXT | Full context JSON |

#### `user_preferences`
Stores global and project-specific preferences.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key |
| preference_key | TEXT | Preference name |
| preference_value | TEXT | Preference value |
| project_path | TEXT | NULL for global, path for project-specific |
| created_at | INTEGER | Creation timestamp |
| updated_at | INTEGER | Last update timestamp |

#### `sessions`
Tracks terminal sessions.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key |
| session_id | TEXT | Unique session identifier |
| started_at | INTEGER | Session start timestamp |
| ended_at | INTEGER | Session end timestamp (NULL if active) |
| working_directory | TEXT | Initial working directory |
| project_path | TEXT | Git root or working directory |
| shell_pid | INTEGER | Fish shell process ID |

### Views

#### `recent_conversations`
Shows the 100 most recent conversations with formatted timestamps.

#### `current_session_history`
Shows all conversations from the current active session.

---

## Advanced Usage

### Custom Context in Prompts

The familiar automatically includes context in AI prompts. The context includes:

```json
{
  "cwd": "/path/to/project",
  "git": {
    "root": "/path/to/project",
    "branch": "main",
    "remote": "git@github.com:user/repo.git",
    "has_changes": true,
    "uncommitted_files": 5
  },
  "project": {
    "primary_language": "typescript",
    "languages": "typescript,javascript",
    "framework": "nextjs",
    "package_manager": "pnpm"
  },
  "session_id": "1234567890_12345",
  "timestamp": 1234567890
}
```

### Querying the Database Directly

```bash
# View all preferences
sqlite3 $CAULDRON_DATABASE "SELECT * FROM user_preferences;"

# Count conversations
sqlite3 $CAULDRON_DATABASE "SELECT COUNT(*) FROM conversation_history;"

# Recent conversations
sqlite3 $CAULDRON_DATABASE "SELECT * FROM recent_conversations LIMIT 10;"

# Project context
sqlite3 $CAULDRON_DATABASE "SELECT * FROM project_context;"
```

### Integration with Scripts

```fish
#!/usr/bin/env fish

# Save project-specific preference
function setup-project
    context -u
    remember coding_style "functional programming"
    remember test_framework "vitest"
    remember deployment "Vercel"

    echo "Project configured!"
end

# Review recent work
function review-today
    recall -l 20 | grep (date +%Y-%m-%d)
end

# Search for specific topics
function find-conversations -a topic
    recall -a -s "$topic"
end
```

---

## Troubleshooting

### Memory system not working

```bash
# Check if database exists
ls -la $CAULDRON_DATABASE

# Initialize memory system
__init_memory

# Check session
echo $CAULDRON_SESSION_ID
```

### No conversation history showing

```bash
# Check if session is initialized
__init_session

# Verify conversations are being saved
sqlite3 $CAULDRON_DATABASE "SELECT COUNT(*) FROM conversation_history;"
```

### Context not being detected

```bash
# Manually refresh context
context -r

# Update project context
context -u

# Check if functions are loaded
functions -q __gather_context
```

### Database errors

```bash
# Check database integrity
sqlite3 $CAULDRON_DATABASE "PRAGMA integrity_check;"

# Backup database
cp $CAULDRON_DATABASE $CAULDRON_DATABASE.backup

# Re-initialize (will preserve data with IF NOT EXISTS)
__init_memory
```

---

## Privacy & Data

### What gets stored?

- Your questions to the familiar
- AI responses
- Project context (languages, frameworks, etc.)
- Git repository information (branch, remote URL)
- Your preferences
- Session metadata (working directory, timestamps)

### What doesn't get stored?

- File contents
- Passwords or secrets
- Environment variables (except what you explicitly save with `remember`)
- Private git data beyond branch and remote

### Data Location

All data is stored locally in: `$CAULDRON_DATABASE` (typically `~/.config/cauldron/data/cauldron.db`)

### Clearing Data

```bash
# Clear all conversation history
forget -a -y

# Remove specific preferences
forget -p preference_name

# Delete entire database (nuclear option)
rm $CAULDRON_DATABASE
# Then re-initialize
__init_memory
```

---

## Future Enhancements

Planned features for the memory system:

- [ ] Proactive suggestions based on detected patterns
- [ ] Error monitoring and automatic help
- [ ] Git integration (suggest commit messages based on changes)
- [ ] Team sharing (export/import preferences)
- [ ] Analytics (most asked topics, productivity insights)
- [ ] Multi-model support (GPT, Claude API, etc.)
- [ ] Voice mode (conversation via speech)

---

## Examples & Use Cases

### Learning a New Language

```bash
# Start learning Rust
cd ~/rust-project
remember language_goal "learning Rust, beginner level"

ask "What are ownership and borrowing in Rust?"
# Later...
ask "Can you explain that last concept with an example?"
# AI remembers the previous conversation
```

### Project Onboarding

```bash
# New developer joining project
cd ~/company-project
context -u
remember architecture "microservices with event sourcing"
remember code_review_process "require 2 approvals"

recall -a  # See what others have asked
```

### Debugging Session

```bash
ask "Why might this async function hang?"
# Try some solutions...
ask "That didn't work, what else could it be?"
# AI remembers the context and previous suggestions

# Later, review what worked
recall -s "async function hang"
```

### Cross-Project Patterns

```bash
# In project A
remember error_handling "use Result types, no exceptions"

# In project B (same preference applies)
ask "How should I handle errors here?"
# AI uses your global error_handling preference
```

---

## Contributing

Have ideas for the memory system? Check out [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines on submitting enhancements.

---

May your familiar remember all your magical journeys! 🪄🧠
