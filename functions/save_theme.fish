#!/usr/bin/env fish

# Save a list of variables to be set on launch
function save_theme -d "Save a list of variables to be set on launch" -a var_key -d "The key to save the variable under" -a var_value -d "The value to save the variable as"
    # Version Number
    set -l func_version "1.1.0"
    # Flag options
    set -l options "v/version" "h/help" "r/remove" "l/list" "e/edit"
    argparse -n installs $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return
    end

    # if they asked for help, show it
    if set -q _flag_help
        echo "Save a list of variables to be set on launch"
        echo ""
        echo "Usage: save-theme [options] var_key var_value"
        echo ""
        echo "Options:"
        echo "  -v, --version  Show the version number"
        echo "  -h, --help     Show this help message"
        echo "  -r, --remove   Remove the variable from the theme"
        echo "  -l, --list     List the variables in the theme"
        echo "  -e, --edit     Edit the theme file directly"
        echo ""
        echo "Examples:"
        echo "  save-theme _SIMPLE_GIT_ICON \ue708"
    end

    # Theme file
    if not set -q $AQUA__CONFIG_FILE
        set -Ux AQUA__CONFIG_FILE "$AQUARIUM_INSTALL_DIR/user_theme.fish"
    end

    # If the file doesn't exist, exit
    if not test -f $AQUA__CONFIG_FILE
        echo "Theme file does not exist yet. Please install aquarium first"
        return
    end

    # Check if they just want the file listed
    if set -q _flag_list
        echo "Variables in the theme:"
        bat $AQUA__CONFIG_FILE
        return
    end

    # Make sure they have an editor availabel or fall back to nano
    if not set -q EDITOR
        # If the user has defined a preferred editor, use that
        if set -q aqua__preferred_editor
            set -g EDITOR $aqua__preferred_editor
        else if type -q code
            set -g EDITOR "code -n"
        else
            set -g EDITOR "nano"
        end
    end

    # If they want to edit the file directly open it in their editor
    if set -q _flag_edit
        $EDITOR $AQUA__CONFIG_FILE
        return
    end

    # Check if they supplied a key and value
    if not set -q var_key; or not set -q var_value
        echo "You must supply a key and value to save the variable under"
        return
    end

    # Check if the variable exists
    set -l var_exists (grep -q "set -Ux $var_key" $AQUA__CONFIG_FILE)

    # If we are in remove mode we want to remove the variable
    if set -q _flag_remove
        if $var_exists
            sed -i "/set -Ux $var_key/d" $AQUA__CONFIG_FILE
            printf (set_term_color green) $var_key (set_term_color normal)" has been removed from the theme"
        else
            printf (set_term_color blue) $var_key (set_term_color normal)" does not exist in this theme"
        end
        return
    end

    # If the theme file isn't executable, make it so
    if not test -x $AQUA__CONFIG_FILE
        chmod +x $AQUA__CONFIG_FILE
    end

    # if the value doesn't exist, append it
    # We want to append it like: set -Ux _SIMPLE_GIT_ICON \ue708
    if not grep -q "set -Ux $var_key $var_value" $AQUA__CONFIG_FILE
        echo "set -Ux $var_key $var_value" >> $AQUA__CONFIG_FILE
    else # Update the variable
        sed -i "s/set -Ux $var_key .*/set -Ux $var_key $var_value/" $AQUA__CONFIG_FILE
    end

    # Now lets parse that file and set the variables
    source $AQUA__CONFIG_FILE
end
