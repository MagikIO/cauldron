function __personality_reset --description "Reset relationship level"
    set -l options p/project a/all

    argparse -n __personality_reset $options -- $argv

    if set -q _flag_all
        read -l -P "Reset ALL relationships? This cannot be undone. [y/N] " confirm
        if test "$confirm" != "y" -a "$confirm" != "Y"
            echo "Reset cancelled"
            return 0
        end

        sqlite3 "$CAULDRON_DATABASE" "
            UPDATE familiar_relationship
            SET relationship_level = 0,
                total_interactions = 0,
                successful_interactions = 0,
                failed_interactions = 0,
                unlocked_features = '[]'
        " 2>/dev/null

        echo "✓ All relationships reset"
        return 0
    end

    set -l project_path
    set -l scope_desc "global"

    if set -q _flag_project
        set project_path (git rev-parse --show-toplevel 2>/dev/null)
        if test -z "$project_path"
            echo "Error: Not in a git repository"
            return 1
        end
        set scope_desc "project: $(basename $project_path)"
    end

    read -l -P "Reset $scope_desc relationship? [y/N] " confirm
    if test "$confirm" != "y" -a "$confirm" != "Y"
        echo "Reset cancelled"
        return 0
    end

    if set -q _flag_project
        sqlite3 "$CAULDRON_DATABASE" "
            UPDATE familiar_relationship
            SET relationship_level = 0,
                total_interactions = 0,
                successful_interactions = 0,
                failed_interactions = 0,
                unlocked_features = '[]'
            WHERE project_path = '$project_path'
        " 2>/dev/null
    else
        sqlite3 "$CAULDRON_DATABASE" "
            UPDATE familiar_relationship
            SET relationship_level = 0,
                total_interactions = 0,
                successful_interactions = 0,
                failed_interactions = 0,
                unlocked_features = '[]'
            WHERE project_path IS NULL
        " 2>/dev/null
    end

    echo "✓ Relationship reset for $scope_desc"
end
