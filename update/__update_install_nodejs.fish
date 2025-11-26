#!/usr/bin/env fish

function __update_install_nodejs -d 'Install Node.js dependencies using pnpm or npm'
  # Parameters:
  #   $argv[1] - log file path (required)
  # 
  # Returns: 0 on success

  set -l node_log $argv[1]

  if test -z "$node_log"
    echo "Error: Log file path required"
    return 1
  end

  if command -q pnpm
    cd "$CAULDRON_PATH" && pnpm install >> "$node_log" 2>&1
    echo 'pnpm:ok' >> "$node_log"
  else if command -q npm
    cd "$CAULDRON_PATH" && npm install >> "$node_log" 2>&1
    echo 'npm:ok' >> "$node_log"
  else
    echo 'none:skip' >> "$node_log"
  end

  return 0
end
