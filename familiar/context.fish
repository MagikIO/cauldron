#!/usr/bin/env fish

function context -d "View or update project context information"
    # Version Number
    set -l func_version "1.0.0"

    # Flag options
    set -l options v/version h/help u/update r/refresh
    argparse -n context $options -- $argv

    if set -q _flag_version
        echo $func_version
        return
    end

    if set -q _flag_help
        echo "Usage: context [OPTIONS]"
        echo "Version: $func_version"
        echo "View or update project context information"
        echo
        echo "Options:"
        echo "  -v, --version    Show the version number"
        echo "  -h, --help       Show this help message"
        echo "  -u, --update     Update context for current project"
        echo "  -r, --refresh    Refresh and display current context"
        echo
        echo "Examples:"
        echo "  context           # Show current context"
        echo "  context -u        # Update project context in database"
        echo "  context -r        # Refresh and show context"
        return
    end

    # Check dependencies
    if not set -q CAULDRON_DATABASE
        echo "Error: Memory system not initialized. Run '__init_memory' first."
        return 1
    end

    # Gather current context
    if set -q _flag_refresh
        echo "Gathering context..."
    end

    set -l current_context (__gather_context 2>/dev/null)

    if test -z "$current_context"
        echo "Error: Failed to gather context"
        return 1
    end

    # Display context in readable format
    if not set -q _flag_update
        echo "Current Context:"
        echo ""
        echo $current_context | jq . 2>/dev/null

        if test $status -ne 0
            # Fallback if jq fails
            echo $current_context
        end
        return 0
    end

    # Update project context in database
    if set -q _flag_update
        # Extract project information
        set -l project_path (echo $current_context | jq -r '.git.root // .cwd' 2>/dev/null)
        if test -z "$project_path" -o "$project_path" = "null"
            set project_path (pwd)
        end

        set -l project_name (basename $project_path)
        set -l git_remote (echo $current_context | jq -r '.git.remote // ""' 2>/dev/null)
        set -l primary_language (echo $current_context | jq -r '.project.primary_language // ""' 2>/dev/null)
        set -l languages (echo $current_context | jq -r '.project.languages // ""' 2>/dev/null)
        set -l framework (echo $current_context | jq -r '.project.framework // ""' 2>/dev/null)
        set -l package_manager (echo $current_context | jq -r '.project.package_manager // ""' 2>/dev/null)

        # Escape single quotes for SQL
        set project_path (string replace -a "'" "''" $project_path)
        set project_name (string replace -a "'" "''" $project_name)
        set git_remote (string replace -a "'" "''" $git_remote)

        # Insert or update project context
        sqlite3 $CAULDRON_DATABASE "
            INSERT INTO project_context (
                project_path, project_name, git_remote, primary_language,
                languages, framework, package_manager, last_updated, metadata
            ) VALUES (
                '$project_path', '$project_name', '$git_remote', '$primary_language',
                '$languages', '$framework', '$package_manager',
                strftime('%s', 'now'), '$current_context'
            )
            ON CONFLICT(project_path) DO UPDATE SET
                git_remote = '$git_remote',
                primary_language = '$primary_language',
                languages = '$languages',
                framework = '$framework',
                package_manager = '$package_manager',
                last_updated = strftime('%s', 'now'),
                metadata = '$current_context';
        " 2>/dev/null

        if test $status -eq 0
            f-says "Project context updated for $project_name!" -n
            echo ""
            echo "Primary language: $primary_language"
            if test -n "$framework"
                echo "Framework: $framework"
            end
            if test -n "$package_manager"
                echo "Package manager: $package_manager"
            end
            return 0
        else
            echo "Error: Failed to update project context"
            return 1
        end
    end
end
