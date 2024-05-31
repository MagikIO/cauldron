#!/usr/bin/env fish

# Install (multiple) software if missing from system
function installs --description 'Install (multiple pieces of) software (from any source) while adding them to the path, and keeping everything up to date'
    set -l func_version "1.2.0"

    # Flag options
    set -l options v/version h/help "s/snap=" "b/brew=" d/dry-run "f/file="
    argparse -n installs $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return 0
    end

    # if they asked for help, show it and return (Added in versions 1.0.1)
    if set -q _flag_help
        echo "Usage: installs [options] <program> [program] [program] ..."
        echo
        echo "Options:"
        echo "  -v, --version  Show version number"
        echo "  -h, --help     Show this help message"
        echo "  -s, --snap     Install the program using Snap"
        echo "  -b, --brew     Install the program using Homebrew"
        echo "  -f, --file     Install the programs listed in s dependency (JSON) file"
        echo "  -d, --dry-run  Show what would be installed, but don't actually install it"
        echo ""
        echo "Install (multiple pieces of) software while adding them to the path, and keeping everything up to date"
        echo ""
        echo "Examples:"
        echo
        echo "  installs bat curl git"
        echo "  installs bat curl git -s \"lolcat-c\" -b \"glow fzf timg\""
        echo "  installs -f dependencies.json"
        return 0
    end

    function inform -a source -a list
        shiny style \
            --foreground 212 --border-foreground 212 --border double \
            --align center --width 50 --margin "1 2" --padding "1 4" \
            "Installing $source..." "" $list
    end

    # Create a variable that is the program name, with any potential `-` removed
    # We do this because for some stupid reason, you install `fd-find` but the command it installs is `fdfind`
    set short_p_name (string replace -r -- - "" $program)

    # Function for extra steps for the programs that require that in Aquarium / Cauldron
    function extra_install_steps -a program
        # Check if the `~/local/bin` exist
        if not test -d ~/local/bin
            print_separator "📁 Creating ~/local/bin 📁"
            mkdir -p ~/local/bin
        end

        # Check if it's in the PATH
        if not contains ~/local/bin $fish_user_paths
            print_separator "🐟 Adding ~/local/bin to the PATH 🐟"
            # Tell Fish to add the `~/local/bin` to the path
            set -U fish_user_paths ~/local/bin $fish_user_paths
        end

        # If the program is "bat" we need to fix it's alias
        if test $program = bat && not test -e ~/local/bin/bat
            ln -s $(which batcat) ~/local/bin/bat
        end

        # If the program is "fd-find" we also need to link it to "fd"
        if test $program = fd-find && not test -e ~/local/bin/fd
            sudo ln -s $(which fdfind) ~/local/bin/fd
        end

        # If the program is 'lolcat-c' we also need to alias it
        if test $program = lolcat-c && not set -q CAULDRON_RAINBOW
            alias lolcat="lolcat-c"
            funcsave lolcat

            alias rainbow-fish="lolcat-c"
            funcsave rainbow-fish

            set -Ux CAULDRON_RAINBOW true
        end
    end

    # If the user wants to install via brew
    set IS_FIRST_BREW_MISSING true
    function install_via_brew -a program
        # Test if already installed
        if not type -q $program
            # Choose a random emoji from BREW_ICONS
            set CHOOSEN_BREW_EMOJI (pick-from 🧪 ⚗️ 🔬)
            print_separator " $CHOOSEN_BREW_EMOJI Installing $program $CHOOSEN_BREW_EMOJI "

            if $IS_FIRST_BREW_MISSING
                brew update
                brew upgrade
                set IS_FIRST_BREW_MISSING false
            end

            brew install $program
        end
    end

    # If the user wants to install via snap
    set IS_FIRST_SNAP_OR_APT_MISSING true
    function install_via_snap -a program
        # Test if already installed
        if not type -q $program
            # Choose a random emoji from SNAP_ICONS
            set CHOOSEN_SNAP_EMOJI (pick-from 🪄 ⚜️ 💡 🔱)
            print_separator " $CHOOSEN_SNAP_EMOJI Installing $program $CHOOSEN_SNAP_EMOJI "

            if $IS_FIRST_SNAP_OR_APT_MISSING
                sudo apt update
                sudo apt upgrade -y
                set IS_FIRST_SNAP_OR_APT_MISSING false
            end

            sudo snap install $program

            if test $program = lolcat-c
                extra_install_steps $program
            end
        end
    end

    # If the user wants to install via apt
    function install_via_apt -a program
        # Test if already installed
        if not type -q $program
            # Choose a random emoji from APT_ICONS
            set CHOOSEN_APT_EMOJI (pick-from 🛠️ 🏗️ 🧰 🚚)
            print_separator " $CHOOSEN_APT_EMOJI Installing $program $CHOOSEN_APT_EMOJI "

            if $IS_FIRST_SNAP_OR_APT_MISSING
                sudo apt update
                sudo apt upgrade -y
                set IS_FIRST_SNAP_OR_APT_MISSING false
            end

            sudo apt install -y $program
        end
    end

    # Now we need to get list of programs to install for each method (apt, snap, brew),
    # both via flag, or via a file
    set APT_INSTALL_LIST
    set SNAP_INSTALL_LIST
    set BREW_INSTALL_LIST

    if set -q _flag_file
        # Check if the file exists
        if not test -f $_flag_file
            echo "The file $_flag_file does not exist"
            return 1
        end

        # Read the file and get the list of programs to install
        # These will look like:
        # {
        #   "version": "1.0.6",
        #   "apt": [
        #       "bat", "cbonsai", "cowsay",
        #       "fortune", "jp2a", "linuxlogo", "pv",
        #       "hyfetch", "build-essential", "procps",
        #       "curl", "git", "rig", "toilet"
        #   ],
        #   "brew": ["glow", "fzf", "timg", "watchman", "lsd", "fx", "navi"],
        #   "snap": [
        #       "lolcat-c"
        #   ]
        # }
        set APT_INSTALL_LIST (jq -r '.apt[]' $_flag_file)
        set BREW_INSTALL_LIST (jq -r '.brew[]' $_flag_file)
        set SNAP_INSTALL_LIST (jq -r '.snap[]' $_flag_file)
    else
        if set -q _flag_snap
            # Parse the string into a list
            set SNAP_INSTALL_LIST (string split " " $_flag_snap)
        end

        if set -q _flag_brew
            # Parse the string into a list
            set BREW_INSTALL_LIST (string split " " $_flag_brew)
        end

        # Now we parse argv, as anything that's not been covered in the other flags
        # is meant to be installed via apt
        for i in (seq (count $argv))
            set program $argv[$i]

            # Make sure it's not a flag we've already parsed
            # If it is, skip it
            if set -q _flag_snap -a $program = $_flag_snap
                continue
            end
            if set -q _flag_brew -a $program = $_flag_brew
                continue
            end
            if set -q _flag_file -a $program = $_flag_file
                continue
            end

            set APT_INSTALL_LIST $APT_INSTALL_LIST $program
        end
    end

    function install_programs
        # APTs
        if test (count $APT_INSTALL_LIST) -gt 0
            inform APTs $APT_INSTALL_LIST
            for program in $APT_INSTALL_LIST
                install_via_apt $program
            end
        end

        # Snaps
        if test (count $SNAP_INSTALL_LIST) -gt 0
            inform Snaps $SNAP_INSTALL_LIST
            for program in $SNAP_INSTALL_LIST
                install_via_snap $program
            end
        end

        # Brews
        if test (count $BREW_INSTALL_LIST) -gt 0
            inform Brew $BREW_INSTALL_LIST
            for program in $BREW_INSTALL_LIST
                install_via_brew $program
            end
        end

        if type -q f-says
            f-says " Looks like everything was installed! If you need to refresh your shell, type 'exec fish' or open a new terminal 👍"
        else
            echo "Looks like everything was installed! If you need to refresh your shell, type 'exec fish' or open a new terminal 👍"
        end
        return 0
    end

    # If they have the dry-run flag, just show what would be installed
    if set -q _flag_dry_run
        shiny style \
            --foreground 212 --border-foreground 212 --border double \
            --align center --width 50 --margin "1 2" --padding "1 4" \
            "Dry Run" "" "The following programs would be installed:" "" \
            "APT: $APT_INSTALL_LIST" "" \
            "Snap: $SNAP_INSTALL_LIST" "" \
            "Brew: $BREW_INSTALL_LIST"
        return 0
    end

    # If the parsed a file lets have them confirm they want to install everything
    if set -q _flag_file
        shiny style \
            --foreground 212 --border-foreground 212 --border double \
            --align center --width 50 --margin "1 2" --padding "1 4" \
            "Install Programs" "" "The following programs were found in your dependency file, and will be installed:" "" \
            "APT: $APT_INSTALL_LIST" "" \
            "Snap: $SNAP_INSTALL_LIST" "" \
            "Brew: $BREW_INSTALL_LIST" | rainbow-fish

        # Now we use `shiny confirm <message>` to ask the user if they want to continue
        # We will save the result in the variable `continue` and if they choose yes, we will install the programs
        shiny confirm "Do you want to continue?"
        if $CAULDRON_LAST_CONFIRM
            install_programs
        else
            if type -q f-says
                f-says "Okay, I won't install anything. If you change your mind, just run the command again!"
                return 0
            else
                echo "Nothing installed. Please run again if you change your mind."
                return 0
            end
        end
    end

    install_programs
end
