function ask -a query
  # Version Number
  set -l func_version "2.0.0"
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
      echo "Ask a question to the llama3.2 model with context awareness"
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

  # Build enhanced system prompt with context
  set -l system_prompt "You are this user's (Antonio) familiar named Azul. The user is familiar with fish shell, typescript, and some C#. He uses He/Him pronouns, smokes cannabis, likes spicy foods, and is lactose-intolerant."

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

  if set -q _flag_markdown
    set ai_response (curl -s -X POST http://localhost:11434/api/generate \
      -H "Content-Type: application/json" \
      -d '{
          "model": "llama3.2",
          "prompt": "'"$system_prompt"'",
          "stream": false
      }')

      set familiar_response (echo $ai_response | jq '.response' | sed 's/\\n/\n/g; s/\\t/\t/g')

      # Now we remove the first and last characters from the string
      set familiar_response (echo $familiar_response | sed 's/^.\(.*\).$/\1/')

      # Store the full response for saving to memory
      set response_text $familiar_response

      printf "$familiar_response" | glow
  else
    curl -s -X POST http://localhost:11434/api/generate \
        -H "Content-Type: application/json" \
        -d '{
            "model": "llama3.2",
            "prompt": "'"$system_prompt"'"
        }' | while read -l line
            set response (echo $line | jq -r '.response')
            set done (echo $line | jq -r '.done')

            if test -n "$response"
                set response_text "$response_text$response"
                echo -n (echo "$response" | sed 's/\\n/\n/g')  # Stream the response with newlines
            end

            if test "$done" = "true"
                break
            end
        end

    echo ""  # Print a newline at the end
  end

  # Save conversation to memory (unless --no-memory flag is set)
  if not set -q _flag_no_memory
      if functions -q __save_conversation
          __save_conversation "$query" "$response_text" "ask" 2>/dev/null
      end
  end
end
