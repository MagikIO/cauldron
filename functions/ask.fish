function ask -a query
  # Version Number
  set -l func_version "1.3.5"
  # Flag options
  set -l options v/version h/help m/markdown
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
      echo "Ask a question to the llama3.2 model"
      echo
      echo "Options:"
      echo "  -v, --version  Show the version number"
      echo "  -h, --help     Show this help message"
      echo "  -m, --markdown  Return the response in markdown format"
      echo
      echo "Examples:"
      echo "  ask 'What is the meaning of life?'"
      echo "  ask 'What is the meaning of life?' -m"
      return
  end

  set response_text ""

  if set -q _flag_markdown
    set ai_response (curl -s -X POST http://localhost:11434/api/generate \
      -H "Content-Type: application/json" \
      -d '{
          "model": "llama3.2",
          "prompt": "You are this user\'s (Antonio) familiar named Azul. The use is familiar in fish shell, typescript, and some C#. He uses He/Him pronouns, smokes cannabis, likes spicy foods, and is lactose-intolerant. You respond to questions in markdown format. You have been asked: '"$query"'",
          "stream": false
      }')

      set familiar_response (echo $ai_response | jq '.response' | sed 's/\\n/\n/g; s/\\t/\t/g')

      # Now we remove the first and last characters from the string
      set familiar_response (echo $familiar_response | sed 's/^.\(.*\).$/\1/')

      printf "$familiar_response" | glow
  else
    curl -s -X POST http://localhost:11434/api/generate \
        -H "Content-Type: application/json" \
        -d '{
            "model": "llama3.2",
            "prompt": "You are a programming witch\'s familiar named Lazul. You respond to questions in markdown format. You have been asked: '"$query"'"
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
end
