# Personality System

Cauldron's personality system allows your familiar to have distinct personalities with different communication styles, adaptive responses based on context, and relationship building over time.

## Features

### 🎭 Six Built-in Personalities

1. **Wise Mentor** (Default)
   - Patient teacher who explains thoroughly
   - Uses the Socratic method to help you learn
   - High patience, detailed explanations

2. **Sarcastic Debugger**
   - Witty companion with dry humor
   - Gently roasts bugs while being helpful
   - Concise, punchy responses with programming humor

3. **Enthusiastic Cheerleader**
   - Supportive and celebrating every win
   - Provides encouragement when things are tough
   - Positive and motivating

4. **Zen Master**
   - Calm philosopher focused on simplicity
   - Values elegant, minimal solutions
   - Measured wisdom and peaceful guidance

5. **Mad Scientist**
   - Experimental thinker suggesting creative approaches
   - Excited about edge cases and challenges
   - Balances wild ideas with practical value

6. **Pair Programmer**
   - Collaborative partner thinking out loud
   - Asks clarifying questions
   - Works through problems step-by-step with you

### 📊 Relationship Building

Your familiar remembers your interactions and builds a relationship with you over time:

- **Level 0-5**: Stranger → New Friend
- **Level 5-20**: Acquaintance (unlocks casual greetings)
- **Level 20-40**: Good Friend (remembers your preferences)
- **Level 40-60**: Trusted Companion (inside jokes and callbacks)
- **Level 60-80**: Close Bond (concise mode, assumes knowledge)
- **Level 80-100**: Soul Bond (proactive suggestions)

Each successful interaction increases your relationship level. The more you use Cauldron, the more familiar your familiar becomes!

### 🎯 Adaptive Responses

Your familiar adapts based on:

1. **Recent Error Rate** (HIGHEST PRIORITY)
   - If you're struggling with errors, becomes more patient
   - Provides more detailed, step-by-step guidance
   - Increases verbosity to help debug

2. **Project Complexity** (MEDIUM PRIORITY)
   - Complex projects get more detailed explanations
   - Considers edge cases more carefully

3. **Stress Indicators** (LOW PRIORITY)
   - Multiple retries trigger supportive responses
   - Adjusts tone based on your interaction patterns

### 🎨 Personality Traits

Each personality has configurable traits (0-10 scale):

- **Humor**: Level of playfulness and jokes
- **Verbosity**: Length and detail of responses
- **Formality**: Professional vs. casual tone
- **Patience**: Tolerance for mistakes and learning
- **Directness**: Direct answers vs. guiding questions

## Usage

### List Available Personalities

```fish
personality list
```

Shows all personalities with descriptions and indicates which is active.

### Show Current Status

```fish
personality show
```

Displays:
- Current active personality
- Relationship level and tier
- Total interactions and success rate
- Unlocked features
- Next milestone

### Set a Personality

```fish
# Global (all projects)
personality set sarcastic_debugger

# Project-specific (current git repo only)
personality set zen_master --project
```

### View Personality Details

```fish
personality info mad_scientist
```

Shows system prompt, traits, and configuration.

### View Traits

```fish
personality traits wise_mentor
```

Visual display of all personality traits.

### Reset Relationship

```fish
# Reset global relationship
personality reset

# Reset project-specific relationship
personality reset --project

# Reset ALL relationships (nuclear option)
personality reset --all
```

## Custom Personalities

### Create a Custom Personality

```fish
personality create my_helper
```

Interactive wizard walks you through:
1. Display name
2. Description
3. System prompt (multi-line)
4. Trait values (0-10 for each)

### Edit Existing Personality

```fish
personality edit my_helper
```

Modify trait values for existing personalities.

### Delete Custom Personality

```fish
personality delete my_helper
```

Only custom personalities can be deleted (built-ins are protected).

## Import/Export

### Export to JSON

```fish
# Export to default file
personality export sarcastic_debugger

# Export to specific file
personality export sarcastic_debugger ~/my_personality.json
```

### Import from JSON

```fish
personality import ~/downloaded_personality.json
```

Share personalities with others or back up your custom creations!

## Advanced Usage

### Per-Project Personalities

You can set different personalities for different projects:

```fish
# In your web project
cd ~/projects/webapp
personality set enthusiastic_cheerleader --project

# In your systems project
cd ~/projects/kernel
personality set zen_master --project

# Global default for everything else
personality set wise_mentor
```

### Relationship Mechanics

- **Successful interactions**: +1 to +5 points (scales with level)
- **Failed interactions**: No penalty, but no gain
- **Unlocked features**: Automatically granted at milestones
- **Decay**: Relationship levels don't decay (your familiar always remembers you)

### System Prompt Structure

When you `ask` a question, the system prompt is built as:

1. Base personality system prompt
2. Relationship modifiers (if level ≥ 20)
3. Error rate adaptations (if struggling)
4. Project complexity adjustments
5. Trait-based modifications
6. User profile
7. Project context
8. Conversation history
9. Current question

This creates a rich, context-aware AI that adapts to your needs!

## Tips

1. **Start with built-ins**: Try each personality to find your favorite
2. **Watch your relationship grow**: Check `personality show` periodically
3. **Use project-specific**: Different personalities for different work
4. **Create custom**: Make a personality that matches your exact preferences
5. **Export favorites**: Back up custom personalities you create
6. **Share with team**: Export and share team-specific personalities

## Troubleshooting

### Personality not changing responses?

- Restart your Fish shell: `exec fish`
- Verify personality is active: `personality show`
- Check migrations ran: Run `cauldron_update` or `cauldron_repair`

### Relationship not increasing?

- Make sure you're using `ask` (not direct curl commands)
- Check database: `sqlite3 $CAULDRON_DATABASE "SELECT * FROM familiar_relationship"`

### Custom personality import failed?

- Validate JSON: `cat file.json | jq '.'`
- Check required fields: name, display_name, description, system_prompt, traits

## Examples

### Creative Writing Helper

```fish
personality create creative_writer
# Display Name: Creative Writer
# Description: Helps with creative writing and storytelling
# System Prompt: You are a creative writing companion who helps develop stories, characters, and plots. Encourage creativity and provide constructive feedback on writing.
# Traits: humor=7, verbosity=8, formality=3, patience=9, directness=4
```

### Code Reviewer

```fish
personality create strict_reviewer
# Display Name: Strict Code Reviewer
# Description: Focuses on code quality, best practices, and potential issues
# System Prompt: You are a meticulous code reviewer. Point out bugs, security issues, performance problems, and style inconsistencies. Be direct but constructive.
# Traits: humor=2, verbosity=7, formality=8, patience=5, directness=9
```

### Beginner Tutor

```fish
personality create patient_tutor
# Display Name: Patient Tutor
# Description: Perfect for learning new concepts
# System Prompt: You are teaching someone who is new to programming. Break down complex concepts into simple terms. Use analogies and examples. Never assume prior knowledge.
# Traits: humor=5, verbosity=9, formality=4, patience=10, directness=3
```

## Migration Notes

If you're upgrading from an older version of Cauldron:

1. Run `cauldron_update` to apply migrations
2. Default personality is set to "Wise Mentor"
3. Relationship starts at level 0
4. Your conversation history is preserved
5. Old `ask` commands still work (backward compatible)

The personality system is fully backward compatible. If the migrations haven't run, `ask` falls back to the original behavior.
