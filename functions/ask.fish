function ask -a query
  # Version Number
  set -l func_version "3.0.0"
  # Flag options
  set -l options v/version h/help m/markdown c/context= n/no-memory
  argparse -n ask $options -- $argv

  if test -z "$query"
      echo "Usage: ask <question>"
      return 1
  end

  if set -q _flag_version
      echo $func_version
      return
  end

  if set -q _flag_help
      echo "Usage: ask <question>"
      echo "Version: $func_version"
      echo "Ask a question to the llama3.2 model with personality and context awareness"
      echo
      echo "Options:"
      echo "  -v, --version    Show the version number"
      echo "  -h, --help       Show this help message"
      echo "  -m, --markdown   Return the response in markdown format"
      echo "  -c, --context    Amount of conversation history to include (default: 5)"
      echo "  -n, --no-memory  Don't save this conversation to memory"
      echo
      echo "Examples:"
      echo "  ask 'What is the meaning of life?'"
      echo "  ask 'What is the meaning of life?' -m"
      echo "  ask 'Explain my last question' -c 10"
      echo
      echo "Your familiar's personality affects how they respond."
      echo "Use 'personality list' to see available personalities."
      echo "Use 'personality show' to see your relationship status."
      return
  end

  # Initialize context amount
  set -l context_limit 5
  if set -q _flag_context
      set context_limit $_flag_context
  end

  # Gather current context
  set -l current_context ""
  if functions -q __gather_context
      set current_context (__gather_context)
  end

  # Get conversation history
  set -l conversation_history ""
  if functions -q __get_conversation_history
      set conversation_history (__get_conversation_history $context_limit "session" 2>/dev/null)
  end

  # Get user information from database
  set -l user_name (sqlite3 "$CAULDRON_DATABASE" "
      SELECT preference_value FROM user_preferences
      WHERE preference_key = 'user_name' AND project_path IS NULL
  " 2>/dev/null)

  set -l user_pronouns (sqlite3 "$CAULDRON_DATABASE" "
      SELECT preference_value FROM user_preferences
      WHERE preference_key = 'user_pronouns' AND project_path IS NULL
  " 2>/dev/null)

  set -l familiar_name (sqlite3 "$CAULDRON_DATABASE" "
      SELECT preference_value FROM user_preferences
      WHERE preference_key = 'familiar_name' AND project_path IS NULL
  " 2>/dev/null)

  # Use environment variables as fallback
  if test -z "$user_name"; and set -q CAULDRON_USER_NAME
      set user_name $CAULDRON_USER_NAME
  end

  if test -z "$user_pronouns"; and set -q CAULDRON_USER_PRONOUNS
      set user_pronouns $CAULDRON_USER_PRONOUNS
  end

  if test -z "$familiar_name"; and set -q CAULDRON_FAMILIAR_NAME
      set familiar_name $CAULDRON_FAMILIAR_NAME
  end

  # Build personality-aware system prompt
  set -l system_prompt
  if functions -q __build_personality_prompt
      set system_prompt (__build_personality_prompt)
  else
      # Fallback if personality system not available
      if test -n "$familiar_name"
          set system_prompt "You are this user's familiar named $familiar_name."
      else
          set system_prompt "You are this user's familiar."
      end
  end

  # Add user profile context
  set -l user_context (sqlite3 "$CAULDRON_DATABASE" "
      SELECT preference_value FROM user_preferences
      WHERE preference_key = 'user_profile' AND project_path IS NULL
  " 2>/dev/null)

  if test -n "$user_context"
      set system_prompt "$system_prompt\n\nUser Profile: $user_context"
  else if test -n "$user_name"
      # Build user profile from individual preferences
      set user_context "User: $user_name"
      if test -n "$user_pronouns"
          set user_context "$user_context ($user_pronouns)"
      end
      set system_prompt "$system_prompt\n\nUser Profile: $user_context"
  else
      # Default user context for backward compatibility
      set system_prompt "$system_prompt\n\nUser: Developer. Familiar with fish shell and programming."
  end

  # Add project context if available
  if test -n "$current_context"
      set system_prompt "$system_prompt\n\nCurrent Context: $current_context"
  end

  # Add conversation history if available
  if test -n "$conversation_history"
      set system_prompt "$system_prompt\n\nRecent conversation history: $conversation_history"
  end

  set system_prompt "$system_prompt\n\nYou respond to questions in markdown format. You have been asked: $query"

  set response_text ""
  set -l response_file (mktemp)

  if set -q _flag_markdown
    # Build JSON payload using jq to properly escape the prompt
    set -l json_payload (jq -n --arg model "llama3.2" --arg prompt "$system_prompt" '{
      model: $model,
      prompt: $prompt,
      stream: false
    }')

    set ai_response (curl -s -X POST http://localhost:11434/api/generate \
      -H "Content-Type: application/json" \
      -d "$json_payload")

      set familiar_response (echo $ai_response | jq '.response' | sed 's/\\n/\n/g; s/\\t/\t/g')

      # Now we remove the first and last characters from the string
      set familiar_response (echo $familiar_response | sed 's/^.\(.*\).$/\1/')

      # Store the full response for saving to memory
      set response_text $familiar_response

      printf "$familiar_response" | bat --language="md" --theme="auto" --paging=never
  else
    # Build JSON payload using jq to properly escape the prompt
    set -l json_payload (jq -n --arg model "llama3.2" --arg prompt "$system_prompt" '{
      model: $model,
      prompt: $prompt
    }')

    # Check if richify is available for enhanced markdown streaming
    if test -f "$HOME/.local/share/richify/richify.py"
        curl -s -X POST http://localhost:11434/api/generate \
            -H "Content-Type: application/json" \
            -d "$json_payload" | while read -l line
                set response (echo $line | jq -r '.response')
                set done (echo $line | jq -r '.done')

                if test -n "$response"
                    echo -n "$response" >> $response_file
                    printf "%s" "$response"  # Stream to richify without sed processing
                end

                if test "$done" = "true"
                    break
                end
            end | uv run --script "$HOME/.local/share/richify/richify.py"
    else
        curl -s -X POST http://localhost:11434/api/generate \
            -H "Content-Type: application/json" \
            -d "$json_payload" | while read -l line
                set response (echo $line | jq -r '.response')
                set done (echo $line | jq -r '.done')

                if test -n "$response"
                    echo -n "$response" >> $response_file
                    printf "%s" "$response"  # Use printf instead of echo -n with sed
                end

                if test "$done" = "true"
                    break
                end
            end
    end

    echo ""  # Print a newline at the end
    set response_text (cat $response_file)
  end

  # Save conversation to memory (unless --no-memory flag is set)
  if not set -q _flag_no_memory
      if functions -q __save_conversation
          __save_conversation "$query" "$response_text" "ask" 2>/dev/null
      end
  end

  # Track interaction for relationship building
  if functions -q __track_interaction
      # Consider the interaction successful if we got a response
      if test -n "$response_text"
          __track_interaction --success 2>/dev/null
      else
          __track_interaction --failure 2>/dev/null
      end
  end

  # Clean up temp file
  rm -f $response_file
end
