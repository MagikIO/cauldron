#!/usr/bin/env fish

function aquarium -d 'List your fishies, update your aquarium, and more'
    # Directories
    set AQUA__PWD (pwd)
    set AQUA__THEME_DIR "$AQUA__PWD/theme"
    set AQUA__THEME_INSTALL_DIR "$AQUA__PWD/theme/install"
    set AQUA__CLI_DIR "$AQUA__PWD/tools/cli"
    set AQUA__FUNC_DIR "$AQUA__PWD/tools/functions"
    set AQUA__UPDATE_DIR "$AQUA__PWD/tools/update"

    # Scripts
    set AQUA__INSTALL_TOOLS_SCRIPT "$AQUA__THEME_DIR/install/install_tools.fish"
    set AQUA__INSTALL_DEPENDENCIES_SCRIPT "$AQUA__THEME_DIR/install/install_dependencies.fish"
    set AQUA__INSTALL_FISH_ALIAS_SCRIPT "$AQUA__THEME_DIR/install/install_fish_alias.fish"
    set AQUA__INSTALL_GIT_ALIAS_SCRIPT "$AQUA__THEME_DIR/install/install_git_alias.fish"
    set PATCH_FISH_GREETING_SCRIPT "$AQUA__THEME_DIR/install/patch_greeting.fish"

    # Settings
    set -gx AQUARIUM_VERSION "0.5.3"
    set -Ux AQUARIUM_URL "https://github.com/anandamideio/aquarium"
    set -Ux AQUARIUM_GIT_URL "https://github.com/anandamideio/aquarium.git"
    set -Ux AQUARIUM_INSTALL_DIR "$HOME/.aquarium"

    # Files
    set -Ux AQUA__CONFIG_FILE "$AQUARIUM_INSTALL_DIR/user_theme.fish"

    # Flags
    set -l options v/version h/help u/update l/list e/edit
    argparse -n installs $options -- $argv

    # If they asked the version return it
    if set -q _flag_version
        echo (set_color blue)$AQUARIUM_VERSION(set_color normal)
        return
    end

    # If they asked for help return it
    if set -q _flag_help
        echo "Usage: aquarium [options]"
        echo ""
        echo "Options:"
        echo "  -v, --version  Show version"
        echo "  -h, --help     Show this help"
        echo "  -u, --update   Update aquarium"
        echo "  -l, --list     List installed aquariums"
        echo "  -e, --edit     Edit installed aquariums"
        return
    end

    # If they asked to edit the theme run `save_theme -e"
    if set -q _flag_edit
        save_theme -e
        return
    end

    # If they asked to list the functions provided via aquarium list them in a pretty way
    if set -q _flag_list
        set -l fn_fishies (lsf $AQUA__FUNC_DIR)
        set -l cli_fishies (lsf $AQUA__CLI_DIR)
        set -l update_fishies (lsf $AQUA__UPDATE_DIR)

        echo (set_color green)"Useful Functions:"(set_color normal)
        for fn in $fn_fishies
            echo "" • $fn -- (set_color blue)(fndesc $AQUA__FUNC_DIR/$fn)(set_color normal)
        end
        echo ""

        echo (set_color yellow)"CLI Functions:"(set_color normal)
        for cli in $cli_fishies
            echo "" • $cli -- (set_color blue)(fndesc $AQUA__CLI_DIR/$cli)(set_color normal)
        end
        echo ""

        echo (set_color red)"Update Functions:"(set_color normal)
        for update in $update_fishies
            echo "" • $update -- (set_color blue)(fndesc $AQUA__UPDATE_DIR/$update)(set_color normal)
        end
        echo ""

        # Alias and courtesy functions
        echo (set_color cyan)"Aliases:"(set_color normal)
        echo "" • aquarium -- (set_color blue)"Plunge into the waters"(set_color normal)
        echo "" • update_fzf -- (set_color blue)"Update fzf"(set_color normal)
        echo "" • whatami -- (set_color blue)"Show the current computer info"(set_color normal)
        echo "" • git visual_checkout -- (set_color blue)"Choose your git branch in a nice terminal GUI"(set_color normal)
        echo "" • git gone -- (set_color blue)"Remove all the local branches that are no longer on the remote"(set_color normal)

        return
    end

    # If they asked to update aquarium, first check what the most recent version is
    if set -q _flag_update
        print_separator " Cleaning and refilling your aquarium... "
        pushd $AQUARIUM_INSTALL_DIR
        # Make a temporary dir in the cache folder to house the `bak` folder and the user theme
        set -l tmp_dir (mktemp -d)
        # Back up the user theme file to a different location
        cp $AQUA__CONFIG_FILE $tmp_dir/user_theme.fish
        # IF the bak folder exist in the aquarium directory, move it to the temp dir
        if test -d $AQUARIUM_INSTALL_DIR/bak
            mv $AQUARIUM_INSTALL_DIR/bak $tmp_dir
        end

        git pull

        ./bin/update.fish

        # Move the bak folder back to the aquarium directory
        mv $tmp_dir/bak $AQUARIUM_INSTALL_DIR
        # Move the user theme file back to the aquarium directory
        mv $tmp_dir/user_theme.fish $AQUA__CONFIG_FILE
        popd

        # Get the version number from the VERSION.md (first line)
        set -l latest_version (head -n 1 $AQUARIUM_INSTALL_DIR/VERSION.md)
        # If the version number is different from the current version, update the current version
        if test $latest_version != $AQUARIUM_VERSION
            set -gx AQUARIUM_VERSION $latest_version
        end

        echo "Aquarium updated to" (set_color blue)($AQUARIUM_VERSION)(set_color normal)
        return
    end
end
