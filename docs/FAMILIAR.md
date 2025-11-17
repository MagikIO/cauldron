# Your Familiar: AI Companion Guide

Welcome to the guide for your magical AI companion. In the tradition of witches and wizards, your familiar is here to assist you in your terminal adventures.

## Table of Contents

- [What is a Familiar?](#what-is-a-familiar)
- [Getting Started](#getting-started)
- [Core Commands](#core-commands)
- [Emotions & Moods](#emotions--moods)
- [Character Selection](#character-selection)
- [AI Integration](#ai-integration)
- [Customization](#customization)
- [Advanced Usage](#advanced-usage)
- [Troubleshooting](#troubleshooting)

---

## What is a Familiar?

In magical lore, a familiar is a supernatural entity that assists witches and wizards. In Cauldron, your familiar is an AI-powered companion that:

- **Communicates** with you through ASCII art characters
- **Assists** with coding questions and tasks
- **Responds** with various emotional states
- **Enhances** your terminal experience with personality

Your familiar is not just a tool—it's a companion that adds magic to your command line.

---

## Getting Started

### Prerequisites

For basic familiar functionality:
- Cauldron installation complete
- cowsay installed

For AI-powered features:
- Ollama installed
- llama3.2 model downloaded

### First Interaction

```bash
# Say hello to your familiar
familiar "Hello! I'm excited to work with you!"

# Your familiar responds with:
#  _______________________________________
# < Hello! I'm excited to work with you! >
#  ---------------------------------------
#         \   ^__^
#          \  (oo)\_______
#             (__)\       )\/\
#                 ||----w |
#                 ||     ||
```

---

## Core Commands

### `familiar`

Your main interface for communication.

```bash
familiar [OPTIONS] <message>
```

**Basic Usage:**
```bash
familiar "What's the weather like?"
familiar "I need help with my code"
familiar "Tell me a programming joke"
```

### `f-says`

Make your familiar speak directly (wrapper for cowsay).

```bash
f-says "This is what I'm saying!"
```

### `f-thinks`

Make your familiar think (thought bubble instead of speech).

```bash
f-thinks "I wonder if recursion ever stops..."
```

Output uses thought bubbles:
```
 o  _________________________________
  o< I wonder if recursion ever stops... >
    ---------------------------------
```

### `ask`

Query the AI model for intelligent responses.

```bash
ask "How do I write a binary search in Python?"
```

This uses Ollama to provide AI-generated responses, optionally rendered as markdown.

---

## Emotions & Moods

Your familiar can express different emotional states, affecting its appearance.

### Available Emotions

```bash
# Borg Mode - Robotic, assimilated
familiar "Resistance is futile" --borg
# Eyes: = =

# Dead Mode - Game over
familiar "I have ceased to function" --dead
# Eyes: X X

# Stoned Mode - Relaxed, chill
familiar "Everything is groovy, man" --stoned
# Eyes: *.*

# Paranoid Mode - Nervous, worried
familiar "They're watching us!" --paranoid
# Eyes: @ @

# Drunk Mode - Tipsy
familiar "Hic! Code now, debug later!" --drunk
# Tongue extended

# Greedy Mode - Money-focused
familiar "Show me the money!" --greedy
# Eyes: $ $
```

### Emotion Effects

| Emotion | Eye Style | Mood |
|---------|-----------|------|
| Default | `oo` | Normal |
| Borg | `==` | Robotic |
| Dead | `XX` | Expired |
| Stoned | `**` | Relaxed |
| Paranoid | `@@` | Nervous |
| Drunk | Extended tongue | Tipsy |
| Greedy | `$$` | Money-focused |

### Using Emotions Effectively

```bash
# Celebrate success
familiar "Build passed! All tests green!" --greedy

# Report errors
familiar "Segmentation fault occurred" --dead

# Share concerns
familiar "This code smells fishy..." --paranoid

# After long debugging session
familiar "Finally found the bug!" --stoned
```

---

## Character Selection

Choose from various ASCII art characters for your familiar.

### Available Characters

Located in `$CAULDRON_PATH/data/`:

#### Trogdor (The Burninator)
```bash
familiar "Burninating the countryside!" --trogdor
```

#### Yoda (Star Wars Master)
```bash
familiar "Debug you must. Patient you should be." --yoda
```

#### Vault-Boy (Fallout)
```bash
familiar "War never changes, but bugs do!" --vault-boy
```

#### Wheatley (Portal 2)
```bash
familiar "I'm not just a regular moron. I'm the moron who's gonna solve this!" --wheatley
```

#### Wilfred (Dog)
```bash
familiar "Who's a good developer? You are!" --wilfred
```

#### Woodstock (Peanuts)
```bash
familiar "Tweet tweet (It works on my machine)" --woodstock
```

### Listing Available Characters

```bash
__list_familiars
```

### Character Previews

Each character brings personality:

```bash
# Wise advice from Yoda
familiar "Code review, you need" --yoda

# Enthusiastic from Vault-Boy
familiar "Thumbs up for that commit!" --vault-boy

# Slightly unhinged from Wheatley
familiar "This is fine. Everything is fine." --wheatley
```

---

## AI Integration

Your familiar can leverage AI for intelligent assistance.

### The `ask` Function

Query the llama3.2 model:

```bash
# Basic question
ask "Explain closures in JavaScript"

# Code help
ask "How do I parse JSON in Python?"

# Best practices
ask "What's the best way to handle errors in Go?"
```

### Response Modes

```bash
# Rendered markdown (default, requires glow)
ask "What is a promise in JavaScript?"

# Raw output (for piping)
ask -r "List sorting algorithms" | less

# Save to file
ask "Write a README template" > template.md
```

### AI Requirements

1. **Install Ollama:**
   ```bash
   curl -fsSL https://ollama.com/install.sh | sh
   ```

2. **Pull the model:**
   ```bash
   ollama pull llama3.2
   ```

3. **Verify:**
   ```bash
   ollama list
   # Should show llama3.2
   ```

### AI Capabilities

Your familiar can help with:

- **Code explanations** - "What does this regex do?"
- **Debugging** - "Why might this cause a null pointer?"
- **Best practices** - "How should I structure this API?"
- **Learning** - "Explain monads simply"
- **Problem solving** - "How do I optimize this query?"

---

## Customization

Make your familiar truly yours.

### Creating Custom Characters

1. **Create a cow file:**
   ```bash
   $EDITOR $CAULDRON_PATH/data/my_familiar.cow
   ```

2. **Use the cowsay format:**
   ```
   $the_cow = <<"EOC";
           $thoughts
            $thoughts
              /\_/\
             ( o.o )
              > ^ <
   EOC
   ```

3. **Use your character:**
   ```bash
   familiar "Hello!" --my_familiar
   ```

### Custom Emotions

Edit `familiar/familiar.fish` to add emotions:

```fish
# Add to switch statement
case "zen"
    set emotion "-e '~~'"
```

Usage:
```bash
familiar "Inner peace achieved" --zen
```

### Default Character

Set a default familiar in your Fish config:

```fish
# ~/.config/fish/config.fish
set -g DEFAULT_FAMILIAR "yoda"
```

### Speech Patterns

Modify how your familiar speaks:

```fish
# Custom f-says with prefix
function my-familiar-says
    echo "🔮 " | f-says $argv
end
```

---

## Advanced Usage

### Combining with Other Commands

```bash
# Pipe output through familiar
git status | familiar

# Use in scripts
function deploy
    familiar "Starting deployment..." --paranoid
    ./deploy.sh
    familiar "Deployment complete!" --greedy
end

# Conditional messages
if test $status -eq 0
    familiar "Success!" --greedy
else
    familiar "Failed!" --dead
end
```

### Familiar in Prompts

Add familiar to your Fish prompt:

```fish
function fish_prompt
    if test $status -ne 0
        f-thinks "Last command failed" --dead
    end
    # Normal prompt
    echo (prompt_pwd) '> '
end
```

### Notification System

```bash
# Alert on long-running tasks
function notify-on-complete
    $argv
    if test $status -eq 0
        familiar "Task complete!" --greedy
    else
        familiar "Task failed!" --dead
    end
end

# Usage
notify-on-complete make build
```

### Familiar Scripts

Create themed scripts:

```fish
#!/usr/bin/env fish

# morning-standup.fish
familiar "Good morning! Let's review..." --stoned

echo "Git status:"
git status --short

echo ""
familiar "Any blockers?" --paranoid

echo "Yesterday's commits:"
git log --oneline --since="yesterday"
```

### Logging with Familiar

```fish
function log-with-familiar
    set message $argv[1]
    set level $argv[2]

    switch $level
        case "error"
            familiar $message --dead
        case "warning"
            familiar $message --paranoid
        case "success"
            familiar $message --greedy
        case "*"
            familiar $message
    end
end

log-with-familiar "Database connected" "success"
```

---

## Troubleshooting

### Common Issues

#### 1. "Command not found: cowsay"

```bash
# Install cowsay
installs cowsay
```

#### 2. Character not displaying correctly

```bash
# Check if cow file exists
ls $CAULDRON_PATH/data/*.cow

# Verify character name
familiar "test" --trogdor
```

#### 3. AI features not working

```bash
# Check Ollama status
ollama list

# Verify model is available
ollama show llama3.2

# Test Ollama directly
echo "test" | ollama run llama3.2
```

#### 4. Emotions not applying

```bash
# Check syntax
familiar "message" --emotion_name

# Verify emotion exists in familiar.fish
grep "case" ~/.config/fish/functions/familiar.fish
```

#### 5. Unicode characters not rendering

Ensure your terminal supports UTF-8:
```bash
echo $LANG
# Should include UTF-8
```

### Diagnostic Commands

```bash
# Test basic functionality
f-says "Basic test"

# Test emotions
familiar "Emotion test" --borg

# Test AI
ask "Test query"

# Check installation
which cowsay
echo $CAULDRON_PATH
```

---

## Best Practices

### 1. Use Appropriate Emotions

Match the emotion to the situation:
- Success → `--greedy`
- Failure → `--dead`
- Warning → `--paranoid`
- Processing → `--stoned`

### 2. Keep Messages Concise

```bash
# Good
familiar "Build failed at line 42" --dead

# Too verbose
familiar "The build process has encountered a critical error..." --dead
```

### 3. Integrate into Workflows

```bash
# Pre-commit hook
familiar "Running pre-commit checks..." --paranoid
run_tests
familiar "All checks passed!" --greedy
```

### 4. Respect Your Familiar

Remember, your familiar is here to help! Treat it as a companion in your development journey.

---

## Fun Examples

### Morning Greeting
```bash
familiar "Rise and shine! Time to code!" --stoned
```

### Code Review
```bash
familiar "Let me review this... Hmm, interesting approach." --paranoid
```

### Successful Deploy
```bash
familiar "Ship it! 🚀" --greedy
```

### Friday Afternoon
```bash
familiar "Is it beer o'clock yet?" --drunk
```

### Bug Fixed
```bash
familiar "The bug has been vanquished!" --trogdor
```

### Complex Problem
```bash
familiar "Patience you must have, young developer" --yoda
```

---

## The Philosophy

Your familiar represents the idea that development doesn't have to be lonely or boring. With a companion at your side, even the most tedious debugging session can have a touch of magic.

The familiar system embodies:
- **Personality** - Adding character to the terminal
- **Assistance** - AI-powered help when you need it
- **Feedback** - Visual and emotional response to your actions
- **Fun** - Making coding enjoyable

---

## Next Steps

- **Customize** your familiar's appearance
- **Create** new characters and emotions
- **Integrate** AI features into your workflow
- **Share** your custom familiars with the community

---

May your familiar guide you well on your coding adventures! 🪄🐟

*"With a familiar by your side, no bug can hide."*
