#!/usr/bin/env fish

function set_prefs
    # Version Number
    set -l func_version "1.0.1"
    # Flag options
    set -l options v/version h/help
    argparse -n set_prefs $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        exit 0
    end

    # if they asked for help just return it
    if set -q _flag_help
        echo "Usage: set_prefs"
        echo "Version: $func_version"
        echo "Set the preferences for Cauldron"
        echo
        echo "Options:"
        echo "  -v, --version  Show the version number"
        echo "  -h, --help     Show this help message"
        exit 0
    end

    # Now we need to make sure that the user has gum installed
    if not type -q gum
        echo "You need to have gum installed to use this command"
        exit 1
    end

    #1. What is your preferred tool for managing Node.js versions?
    echo "Please choose your preferred tool for managing languages (Node.js, Ruby, Go, etc) versions"
    set -gx cauldron_lang_packman_pref (gum choose {asdf, nvm, none} --header "Language PackMan Pref")

    #2. What is your preferred package manager for Node.js?
    echo "Please choose your preferred package manager for Node.js"
    set -gx cauldron_node_packman_pref (gum choose {pnpm, yarn, npm})

    #3. When we update Node.js, do you want to update the local package.json file?
    echo "When we update Node.js, do you want to update the local package.json file?"
    set update_package_json (gum choose {Yes, No})
    if test $update_package_json = Yes
        set -gx cauldron_update_package_json true
    else
        set -gx cauldron_update_package_json false
    end

    #4. Do you want to use the latest version of Node.js?
    echo "Do you want to use the latest version of Node.js?"
    set use_latest_node (gum choose {Yes, No})
    if test $use_latest_node = Yes
        set -gx cauldron_use_latest_node true
    else
        set -gx cauldron_use_latest_node false
    end

    # Now we take all those preferences and save them to the users preferences file
    set -l prefs_file $CAULDRON_PATH/data/prefs.json
    # Touch the file if it does not exist
    if not test -f $prefs_file
        touch $prefs_file
    end

    # Now we need to write the preferences to the file
    echo "{" >$prefs_file
    echo "  \"cauldron_lang_packman_pref\": \"$cauldron_lang_packman_pref\"," >>$prefs_file
    echo "  \"cauldron_node_packman_pref\": \"$cauldron_node_packman_pref\"," >>$prefs_file
    echo "  \"cauldron_update_package_json\": $cauldron_update_package_json," >>$prefs_file
    echo "  \"cauldron_use_latest_node\": $cauldron_use_latest_node" >>$prefs_file
    echo "}" >>$prefs_file

    f-says "Preferences have been saved"

    exit 0
end
