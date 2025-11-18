function personality --description "Manage familiar personality profiles"
    set -l func_version "1.0.0"
    set -l options h/help v/version

    argparse -n personality $options -- $argv
    or return 1

    if set -q _flag_version
        echo $func_version
        return 0
    end

    if set -q _flag_help; or test (count $argv) -eq 0
        echo "Usage: personality <command> [options]"
        echo "Version: $func_version"
        echo ""
        echo "Manage your familiar's personality profiles"
        echo ""
        echo "Commands:"
        echo "  list                   List all available personalities"
        echo "  show                   Show current personality and relationship status"
        echo "  set <name> [--project] Set active personality (global or project-specific)"
        echo "  info <name>            Show detailed information about a personality"
        echo "  create <name>          Create a custom personality (interactive)"
        echo "  edit <name>            Edit personality traits"
        echo "  delete <name>          Delete a custom personality"
        echo "  export <name> [file]   Export personality to JSON file"
        echo "  import <file>          Import personality from JSON file"
        echo "  reset                  Reset relationship level"
        echo "  traits <name>          Show personality traits"
        echo ""
        echo "Examples:"
        echo "  personality list"
        echo "  personality set sarcastic_debugger"
        echo "  personality set wise_mentor --project"
        echo "  personality show"
        echo "  personality create my_personality"
        echo "  personality export sarcastic_debugger my_personality.json"
        return 0
    end

    set -l command $argv[1]
    set -l args $argv[2..-1]

    switch $command
        case list
            __personality_list
        case show
            __personality_show
        case set
            __personality_set $args
        case info
            __personality_info $args
        case create
            __personality_create $args
        case edit
            __personality_edit $args
        case delete
            __personality_delete $args
        case export
            __personality_export $args
        case import
            __personality_import $args
        case reset
            __personality_reset $args
        case traits
            __personality_traits $args
        case '*'
            echo "Unknown command: $command"
            echo "Run 'personality --help' for usage"
            return 1
    end
end
