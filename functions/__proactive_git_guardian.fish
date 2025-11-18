#!/usr/bin/env fish
# __proactive_git_guardian.fish v1.0.0
# Monitors git repository status and reminds about uncommitted changes

function __proactive_git_guardian --description "Monitor git status and provide reminders"
    # Check if we're in a git repository
    if not git rev-parse --git-dir >/dev/null 2>&1
        return 0
    end

    # Get preferences
    set -l uncommitted_threshold (__get_preference "proactive.git_guardian.uncommitted_threshold" "5")
    set -l time_threshold_minutes (__get_preference "proactive.git_guardian.time_threshold_minutes" "30")

    # Check for uncommitted changes
    set -l uncommitted_count (git status --porcelain 2>/dev/null | wc -l | string trim)

    if test $uncommitted_count -gt 0
        # Check how long since last commit
        set -l last_commit_time (git log -1 --format=%ct 2>/dev/null)
        if test -z "$last_commit_time"
            # No commits yet (new repo)
            set last_commit_time 0
        end

        set -l current_time (date +%s)
        set -l time_diff (math "$current_time - $last_commit_time")
        set -l minutes_since_commit (math "floor($time_diff / 60)")

        # Trigger alert if:
        # 1. Too many uncommitted files, OR
        # 2. Too much time has passed since last commit
        set -l should_alert 0
        set -l alert_reason ""

        if test $uncommitted_count -ge $uncommitted_threshold
            set should_alert 1
            set alert_reason "You have $uncommitted_count uncommitted files."
        else if test $minutes_since_commit -ge $time_threshold_minutes
            set should_alert 1
            set alert_reason "It's been $minutes_since_commit minutes since your last commit."
        end

        if test $should_alert -eq 1
            # Get current branch
            set -l current_branch (git branch --show-current 2>/dev/null)

            # Check for untracked files
            set -l untracked_count (git ls-files --others --exclude-standard 2>/dev/null | wc -l | string trim)

            # Build message
            set -l message "$alert_reason"
            set -l details ""

            if test $uncommitted_count -gt 0
                set details "$uncommitted_count modified/staged files"
            end

            if test $untracked_count -gt 0
                if test -n "$details"
                    set details "$details, $untracked_count untracked"
                else
                    set details "$untracked_count untracked files"
                end
            end

            if test -n "$current_branch"
                set message "$message On branch '$current_branch': $details"
            else
                set message "$message $details"
            end

            # Generate suggestion
            set -l suggestion (__generate_git_suggestion $uncommitted_count $untracked_count)

            # Store alert
            set -l timestamp (date +%s)
            __proactive_create_alert "git" "medium" "$message" "$suggestion" $timestamp

            # Show notification (non-blocking)
            __proactive_git_notify "$message" "$suggestion"
        end

        # Check for branch divergence
        __check_branch_divergence
    end

    return 0
end

function __generate_git_suggestion --argument-names uncommitted_count untracked_count
    set -l suggestions ""

    if test $uncommitted_count -gt 0
        set suggestions "Ready to commit? Try: git status && git add -A && git commit"
    end

    if test $untracked_count -gt 0
        if test -n "$suggestions"
            set suggestions "$suggestions Or review untracked files: git status"
        else
            set suggestions "You have untracked files. Review with: git status"
        end
    end

    echo $suggestions
end

function __proactive_git_notify --argument-names message suggestion
    # Check if we've already notified recently (don't spam)
    if not set -q __CAULDRON_LAST_GIT_ALERT
        set -g __CAULDRON_LAST_GIT_ALERT 0
    end

    set -l current_time (date +%s)
    set -l time_since_last (math "$current_time - $__CAULDRON_LAST_GIT_ALERT")

    # Only notify once every 5 minutes
    if test $time_since_last -lt 300
        return 0
    end

    set -g __CAULDRON_LAST_GIT_ALERT $current_time

    # Show notification
    if test -n "$suggestion"
        familiar "$message\n   $suggestion" --paranoid 2>/dev/null
    else
        familiar "$message" --paranoid 2>/dev/null
    end

    return 0
end

function __check_branch_divergence --description "Check if local branch has diverged from remote"
    # Get current branch
    set -l current_branch (git branch --show-current 2>/dev/null)
    if test -z "$current_branch"
        return 0
    end

    # Check if branch has upstream
    set -l upstream (git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
    if test -z "$upstream"
        return 0
    end

    # Fetch remote (silently)
    git fetch origin $current_branch 2>/dev/null &

    # Check commits ahead/behind
    set -l ahead (git rev-list --count @{u}..HEAD 2>/dev/null)
    set -l behind (git rev-list --count HEAD..@{u} 2>/dev/null)

    if test -z "$ahead"
        set ahead 0
    end
    if test -z "$behind"
        set behind 0
    end

    # Alert if diverged
    if test $ahead -gt 0 -a $behind -gt 0
        set -l message "Branch '$current_branch' has diverged: $ahead ahead, $behind behind '$upstream'"
        set -l suggestion "Consider: git pull --rebase or git merge"
        set -l timestamp (date +%s)

        __proactive_create_alert "git" "high" "$message" "$suggestion" $timestamp
        familiar "$message\n   $suggestion" --paranoid 2>/dev/null
    else if test $ahead -gt 5
        set -l message "Branch '$current_branch' is $ahead commits ahead of '$upstream'"
        set -l suggestion "Ready to push? Try: git push"
        set -l timestamp (date +%s)

        __proactive_create_alert "git" "low" "$message" "$suggestion" $timestamp
    else if test $behind -gt 5
        set -l message "Branch '$current_branch' is $behind commits behind '$upstream'"
        set -l suggestion "Consider pulling: git pull"
        set -l timestamp (date +%s)

        __proactive_create_alert "git" "medium" "$message" "$suggestion" $timestamp
    end

    return 0
end
