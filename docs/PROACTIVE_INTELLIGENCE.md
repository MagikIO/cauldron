# Proactive Intelligence

Cauldron's Proactive Intelligence transforms your familiar from a reactive assistant into an active helper that watches, learns, and assists automatically.

## Overview

Instead of waiting for you to ask for help, Proactive Intelligence monitors your shell activity and provides timely assistance:

- **Error Watcher** - Detects command failures and offers solutions
- **Git Guardian** - Reminds you about uncommitted changes and branch status
- **Process Monitor** - Alerts when long-running commands complete
- **Pattern Detector** - Notices repeated tasks and suggests automation

## Quick Start

### Enable Proactive Intelligence

```fish
# Enable for the first time
remember enable_proactive_suggestions true

# Or use the convenience command
proactive enable
```

### Shell Integration

Add the appropriate integration to your shell config:

**Fish Shell** (`~/.config/fish/config.fish`):
```fish
source ~/.config/cauldron/integrations/proactive.fish
```

**Bash** (`~/.bashrc`):
```bash
source ~/.config/cauldron/integrations/proactive.bash
```

**Zsh** (`~/.zshrc`):
```zsh
source ~/.config/cauldron/integrations/proactive.zsh
```

## Features

### 1. Error Watcher

Monitors every command execution and offers help when things fail.

**Example:**
```fish
$ npm test
# ... tests fail ...

🔮 Your familiar senses something amiss...
   "That test failed. Want help analyzing the error? [Y/n]"
```

**Features:**
- Skips benign failures (simple commands like `ls`, quick checks)
- Provides context-aware suggestions for git, npm, cargo, and more
- Can auto-suggest solutions or ask first
- Stores error history for pattern analysis

**Configuration:**
```fish
remember proactive.error_watcher.enabled true
remember proactive.error_watcher.auto_suggest false  # Ask before suggesting
remember proactive.error_watcher.min_delay_ms 1000   # Skip very fast failures
```

### 2. Git Guardian

Watches your git repository and reminds you about important changes.

**Example:**
```fish
$ ls  # After working for 30 minutes

🔮 Your familiar whispers...
   "You have 3 uncommitted files. Ready to commit? [Y/n]
   On branch 'feature/new-ui': 3 modified/staged files, 2 untracked
   Try: git status && git add -A && git commit"
```

**Features:**
- Detects uncommitted changes
- Tracks time since last commit
- Monitors branch divergence (ahead/behind remote)
- Suggests git commands for common workflows
- Non-intrusive (max once per 5 minutes)

**Triggers alerts when:**
- 5+ uncommitted files (configurable)
- 30+ minutes since last commit (configurable)
- Branch has diverged from remote
- Branch is significantly ahead/behind remote

**Configuration:**
```fish
remember proactive.git_guardian.enabled true
remember proactive.git_guardian.check_interval 10            # Check every 10 commands
remember proactive.git_guardian.uncommitted_threshold 5      # Alert at 5+ files
remember proactive.git_guardian.time_threshold_minutes 30    # Alert after 30 min
```

### 3. Process Monitor

Tracks long-running commands and alerts you when they complete.

**Example:**
```fish
$ npm run build
# ... takes 3 minutes 42 seconds ...

🔮 Your familiar alerts you...
   "✓ Command completed: npm run build
   Duration: 3m 42s | Exit code: 0
   Build successful! Consider running tests next."
```

**Features:**
- Monitors command duration
- Shows completion notification for long processes
- Provides context-aware suggestions
- Tracks statistics for optimization insights
- Optional desktop notifications (if notify-send available)

**Configuration:**
```fish
remember proactive.process_monitor.enabled true
remember proactive.process_monitor.threshold_ms 60000    # Alert after 60 seconds
remember proactive.process_monitor.show_stats true       # Show detailed stats
```

### 4. Pattern Detector

Analyzes your command history to detect repeated patterns and suggests automation.

**Example:**
```fish
# After running this sequence 3 times:
$ git status
$ git add .
$ git commit -m "Update"

🔮 Your familiar notices a pattern...
   "I noticed you repeat this sequence:
   1. git status
   2. git add .
   3. git commit -m "Update"

   Want me to create a function 'git_quick_commit'?"
```

**Features:**
- Detects 3+ command sequences
- Identifies frequently repeated individual commands
- Finds commands always run together
- Suggests aliases for common commands
- Suggests functions for workflows
- Learns from your patterns

**Patterns detected:**
- **Command sequences**: Series of 2-4 commands run in order
- **Repeated commands**: Individual commands used frequently
- **Command chains**: Commands consistently run within 10 seconds of each other

**Configuration:**
```fish
remember proactive.pattern_detector.enabled true
remember proactive.pattern_detector.check_interval 20       # Check every 20 commands
remember proactive.pattern_detector.min_frequency 3         # Trigger at 3 repetitions
remember proactive.pattern_detector.lookback_commands 100   # Analyze last 100 commands
```

## Commands

### Main Command: `proactive`

```fish
proactive [command]
```

**Commands:**
- `on`, `enable` - Enable proactive intelligence
- `off`, `disable` - Disable proactive intelligence
- `status` - Show current status and statistics
- `alerts` - Show pending alerts
- `clear` - Dismiss all alerts
- `patterns` - Show detected command patterns
- `help` - Show help message

### Examples

**Check status:**
```fish
$ proactive status

Proactive Intelligence Status
==============================

Status: ENABLED

Active features:
  ✓ Error Watcher - Monitors command failures
  ✓ Git Guardian - Watches for uncommitted changes
  ✓ Process Monitor - Alerts on long-running commands
  ✓ Pattern Detector - Suggests automation

Recent activity:
  • 2 pending alerts
  • 5 errors in last hour
  • 3 detected patterns
```

**View alerts:**
```fish
$ proactive alerts

Pending Alerts:
===============
error: Command failed: npm test
git: You have 3 uncommitted files
pattern: Detected repeated sequence (5 times)
```

**Clear alerts:**
```fish
$ proactive clear
All alerts dismissed.
```

**View patterns:**
```fish
$ proactive patterns

Detected Patterns:
==================
git status && git add . && git commit    (frequency: 5)
docker ps -a                             (frequency: 8)
npm run dev                              (frequency: 12)
```

## Advanced Configuration

### Per-Project Settings

You can configure proactive intelligence per project:

```fish
# In your project directory
cd ~/projects/my-app

# Set project-specific preferences
remember -p proactive.git_guardian.check_interval 5
remember -p proactive.error_watcher.auto_suggest true
```

### Disable Specific Features

```fish
# Disable just the git guardian
remember proactive.git_guardian.enabled false

# Disable just pattern detection
remember proactive.pattern_detector.enabled false

# Keep other features active
```

### Adjust Sensitivity

**Less intrusive:**
```fish
remember proactive.git_guardian.check_interval 20         # Check less often
remember proactive.git_guardian.uncommitted_threshold 10  # Higher threshold
remember proactive.pattern_detector.min_frequency 5       # Require more repetitions
```

**More proactive:**
```fish
remember proactive.git_guardian.check_interval 5          # Check more often
remember proactive.git_guardian.uncommitted_threshold 3   # Lower threshold
remember proactive.error_watcher.auto_suggest true        # Auto-suggest solutions
```

## Database Schema

Proactive Intelligence stores data in SQLite tables:

### `command_history`
Tracks every command execution:
- Command text
- Exit code
- Duration
- Timestamp
- Working directory

### `proactive_alerts`
Stores notifications and suggestions:
- Alert type (error, git, process, pattern)
- Priority (low, medium, high)
- Message and suggestion
- Dismissal status

### `command_patterns`
Records detected patterns:
- Pattern hash (for deduplication)
- Command sequence
- Frequency count
- Last seen timestamp
- Automation suggestion

### `monitored_processes`
Tracks long-running processes:
- Process ID
- Command
- Start time
- Alert threshold
- Completion status

## Views for Analysis

Query proactive intelligence data:

```fish
# Recent errors
sqlite3 $CAULDRON_DATABASE "SELECT * FROM recent_errors LIMIT 10;"

# Pending alerts
sqlite3 $CAULDRON_DATABASE "SELECT * FROM pending_alerts;"

# Active patterns
sqlite3 $CAULDRON_DATABASE "SELECT * FROM active_patterns;"

# Long-running commands
sqlite3 $CAULDRON_DATABASE "SELECT * FROM long_running_commands;"
```

## Privacy & Performance

**Data Storage:**
- All data stored locally in SQLite
- No external communication
- Automatic cleanup (7 days for alerts, 30 days for old patterns)
- Limited to 1000 commands per session in history

**Performance:**
- Background execution (doesn't slow down shell)
- Minimal overhead (~1-5ms per command)
- Periodic checks (not every command)
- Smart caching and deduplication

**Control:**
- Disable anytime with `proactive off`
- Clear data with database cleanup
- Per-feature toggles
- Adjustable thresholds

## Troubleshooting

### Proactive Intelligence Not Working

1. **Check if enabled:**
   ```fish
   proactive status
   ```

2. **Verify database:**
   ```fish
   echo $CAULDRON_DATABASE
   test -f $CAULDRON_DATABASE && echo "Database exists" || echo "Database missing"
   ```

3. **Check shell integration:**
   ```fish
   functions | grep __cauldron_proactive
   ```

4. **Reinitialize:**
   ```fish
   __init_proactive
   ```

### Too Many/Too Few Notifications

Adjust sensitivity:

```fish
# Too many notifications
remember proactive.git_guardian.check_interval 20
remember proactive.pattern_detector.min_frequency 5

# Too few notifications
remember proactive.git_guardian.check_interval 5
remember proactive.pattern_detector.min_frequency 2
```

### Performance Issues

Disable expensive features:

```fish
# Disable pattern detection (most expensive)
remember proactive.pattern_detector.enabled false

# Reduce lookback window
remember proactive.pattern_detector.lookback_commands 50
```

## Examples & Use Cases

### Development Workflow

Proactive Intelligence helps during development:

1. **Catches test failures** and suggests fixes
2. **Reminds to commit** after making changes
3. **Alerts when builds complete** while you work on other things
4. **Suggests aliases** for your common git workflows

### DevOps & Operations

Useful for long-running operations:

1. **Monitors deployments** and alerts on completion
2. **Detects failed scripts** and suggests debugging
3. **Tracks docker operations** and suggests optimizations
4. **Notices repeated manual tasks** and suggests automation

### Learning & Optimization

Helps improve your workflow:

1. **Shows command patterns** you didn't realize you had
2. **Suggests aliases/functions** for efficiency
3. **Tracks error patterns** to identify recurring issues
4. **Monitors command durations** to spot slow operations

## Contributing

Found a bug or have a suggestion? The proactive intelligence system is modular and extensible:

- `functions/__proactive_*.fish` - Core monitoring functions
- `data/proactive_schema.sql` - Database schema
- `integrations/proactive.*` - Shell integrations
- `tests/unit/test_proactive.fish` - Test suite

## See Also

- [Memory System](./MEMORY_SYSTEM.md) - Context awareness and conversation history
- [Familiar Guide](./FAMILIAR.md) - Your AI companion
- [Ask Command](./ASK.md) - Interactive AI assistance
