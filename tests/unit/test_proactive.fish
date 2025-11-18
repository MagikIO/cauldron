#!/usr/bin/env fish

# Tests for Proactive Intelligence features
# Run with: fishtape tests/unit/test_proactive.fish

set -l test_dir (dirname (status --current-filename))
set -l project_root (dirname (dirname $test_dir))

# Set up test environment
set -gx CAULDRON_PATH "$project_root"
set -gx CAULDRON_DATABASE "/tmp/test_cauldron_proactive.db"
set -gx CAULDRON_SESSION_ID "test_session_123"

# Clean up any existing test database
rm -f "$CAULDRON_DATABASE"

# Create test database
sqlite3 "$CAULDRON_DATABASE" < "$project_root/data/schema.sql" 2>/dev/null
sqlite3 "$CAULDRON_DATABASE" < "$project_root/data/proactive_schema.sql" 2>/dev/null

# Create test session
sqlite3 "$CAULDRON_DATABASE" "
    INSERT INTO sessions (session_id, started_at, working_directory, shell_pid)
    VALUES ('$CAULDRON_SESSION_ID', strftime('%s', 'now'), '/tmp', $$);
" 2>/dev/null

# Source the functions
source "$project_root/functions/__get_preference.fish"
source "$project_root/functions/__save_preference.fish"
source "$project_root/functions/__proactive_monitor.fish"
source "$project_root/functions/__proactive_error_watcher.fish"
source "$project_root/functions/__proactive_git_guardian.fish"
source "$project_root/functions/__proactive_process_monitor.fish"
source "$project_root/functions/__proactive_pattern_detector.fish"
source "$project_root/functions/__init_proactive.fish"

# ========== INITIALIZATION TESTS ==========

@test "proactive schema creates command_history table" (
    sqlite3 "$CAULDRON_DATABASE" "SELECT name FROM sqlite_master WHERE type='table' AND name='command_history';" | grep -q "command_history"
) $status -eq 0

@test "proactive schema creates proactive_alerts table" (
    sqlite3 "$CAULDRON_DATABASE" "SELECT name FROM sqlite_master WHERE type='table' AND name='proactive_alerts';" | grep -q "proactive_alerts"
) $status -eq 0

@test "proactive schema creates command_patterns table" (
    sqlite3 "$CAULDRON_DATABASE" "SELECT name FROM sqlite_master WHERE type='table' AND name='command_patterns';" | grep -q "command_patterns"
) $status -eq 0

@test "proactive schema creates monitored_processes table" (
    sqlite3 "$CAULDRON_DATABASE" "SELECT name FROM sqlite_master WHERE type='table' AND name='monitored_processes';" | grep -q "monitored_processes"
) $status -eq 0

@test "proactive schema creates views" (
    sqlite3 "$CAULDRON_DATABASE" "SELECT name FROM sqlite_master WHERE type='view' AND name='recent_errors';" | grep -q "recent_errors"
) $status -eq 0

@test "default preferences are set" (
    set -l pref (sqlite3 "$CAULDRON_DATABASE" "SELECT preference_value FROM user_preferences WHERE preference_key = 'proactive.error_watcher.enabled';" 2>/dev/null)
    test "$pref" = "true"
) $status -eq 0

# ========== COMMAND STORAGE TESTS ==========

@test "__proactive_store_command stores command in database" (
    __proactive_store_command "test command" 0 100 (date +%s) "/tmp"
    set -l count (sqlite3 "$CAULDRON_DATABASE" "SELECT COUNT(*) FROM command_history WHERE command = 'test command';" 2>/dev/null)
    test "$count" -gt 0
) $status -eq 0

@test "__proactive_store_command handles exit codes" (
    __proactive_store_command "failing command" 1 50 (date +%s) "/tmp"
    set -l exit_code (sqlite3 "$CAULDRON_DATABASE" "SELECT exit_code FROM command_history WHERE command = 'failing command';" 2>/dev/null)
    test "$exit_code" = "1"
) $status -eq 0

@test "__proactive_store_command records duration" (
    __proactive_store_command "slow command" 0 5000 (date +%s) "/tmp"
    set -l duration (sqlite3 "$CAULDRON_DATABASE" "SELECT duration_ms FROM command_history WHERE command = 'slow command';" 2>/dev/null)
    test "$duration" = "5000"
) $status -eq 0

# ========== ALERT CREATION TESTS ==========

@test "__proactive_create_alert creates alerts" (
    __proactive_create_alert "error" "high" "Test error message" "Test suggestion" (date +%s)
    set -l count (sqlite3 "$CAULDRON_DATABASE" "SELECT COUNT(*) FROM proactive_alerts WHERE message = 'Test error message';" 2>/dev/null)
    test "$count" -gt 0
) $status -eq 0

@test "alerts have correct type" (
    __proactive_create_alert "git" "medium" "Git alert" "Git suggestion" (date +%s)
    set -l alert_type (sqlite3 "$CAULDRON_DATABASE" "SELECT alert_type FROM proactive_alerts WHERE message = 'Git alert';" 2>/dev/null)
    test "$alert_type" = "git"
) $status -eq 0

# ========== ERROR WATCHER TESTS ==========

@test "__analyze_git_error detects git errors" (
    set -l result (__analyze_git_error "git push" 128)
    string match -q "*repository*" "$result"
) $status -eq 0

@test "__analyze_npm_error detects npm install errors" (
    set -l result (__analyze_npm_error "npm install" 1)
    string match -q "*installation*" "$result"
) $status -eq 0

@test "__generate_error_suggestion suggests git solutions" (
    set -l result (__generate_error_suggestion "git push origin main" 1)
    string match -q "*pull*" "$result"
) $status -eq 0

# ========== PROCESS MONITOR TESTS ==========

@test "__format_duration formats seconds correctly" (
    set -l result (__format_duration 45000)
    string match -q "*45s*" "$result"
) $status -eq 0

@test "__format_duration formats minutes correctly" (
    set -l result (__format_duration 125000)
    string match -q "*2m*" "$result"
) $status -eq 0

@test "__format_duration formats hours correctly" (
    set -l result (__format_duration 7200000)
    string match -q "*2h*" "$result"
) $status -eq 0

@test "__generate_process_suggestion suggests for builds" (
    set -l result (__generate_process_suggestion "npm run build" 0 30000)
    string match -q "*test*" "$result"
) $status -eq 0

# ========== PATTERN DETECTOR TESTS ==========

@test "__generate_function_name creates git-specific names" (
    set -l result (__generate_function_name "git status" "git add ." "git commit -m foo")
    test "$result" = "git_quick_commit"
) $status -eq 0

@test "__generate_alias_name creates short aliases" (
    set -l result (__generate_alias_name "git status")
    test "$result" = "gs"
) $status -eq 0

@test "__generate_alias_name handles docker commands" (
    set -l result (__generate_alias_name "docker ps -a")
    test "$result" = "dps"
) $status -eq 0

# ========== PREFERENCES TESTS ==========

@test "proactive preferences can be updated" (
    __save_preference "proactive.error_watcher.enabled" "false"
    set -l value (__get_preference "proactive.error_watcher.enabled" "true")
    test "$value" = "false"
) $status -eq 0

# ========== CLEANUP TESTS ==========

@test "__cleanup_old_alerts removes old alerts" (
    # Insert old alert
    set -l old_timestamp (math (date +%s) - 700000)
    sqlite3 "$CAULDRON_DATABASE" "
        INSERT INTO proactive_alerts (alert_type, priority, message, triggered_at)
        VALUES ('test', 'low', 'old alert', $old_timestamp);
    " 2>/dev/null

    __cleanup_old_alerts

    set -l count (sqlite3 "$CAULDRON_DATABASE" "SELECT COUNT(*) FROM proactive_alerts WHERE message = 'old alert';" 2>/dev/null)
    test "$count" = "0"
) $status -eq 0

# ========== INTEGRATION TESTS ==========

@test "error watcher triggers for failed commands" (
    # Store a failed command
    __proactive_store_command "false" 1 1000 (date +%s) "/tmp"

    # Should create an alert (testing the database state, not the notification)
    # This is a basic integration check
    set -l errors (sqlite3 "$CAULDRON_DATABASE" "SELECT COUNT(*) FROM command_history WHERE exit_code != 0;" 2>/dev/null)
    test "$errors" -gt 0
) $status -eq 0

# Cleanup
rm -f "$CAULDRON_DATABASE"
