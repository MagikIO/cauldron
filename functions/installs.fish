#!/usr/bin/env fish

# Install (multiple) software if missing from system
function installs -d 'Install (multiple pieces of) software (from any source) while adding them to the path, and keeping everything up to date'
    set -l func_version "1.1.5"

    # Flag options
    set -l options (fish_opt -s v -l version)
    set options $options (fish_opt -s h -l help)
    set options $options (fish_opt -s s -l snap)
    set options $options (fish_opt -s b -l brew)
    set options $options (fish_opt -s d -l dry-run)
    argparse $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return
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
        echo "  -d, --dry-run  Show what would be installed, but don't actually install it"
        echo
        echo "Install (multiple pieces of) software while adding them to the path, and keeping everything up to date"
        return
    end

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

    # Define an (temporary) array of emojis to use when we install programs
    set install_emojis 🪄 ⚜️ 🧪 🔨 ⚙️ 🛠️ 🏗️ 🧰 🚚 💡
    set isFirstMissing true

    for i in (seq (count $argv))
        set program $argv[$i]
        set emoji $install_emojis[$i]
        # Create a variable that is the program name, with any potential `-` removed
        # We do this because for some stupid reason, you install `fd-find` but the command it installs is `fdfind`
        set short_p_name (string replace -r -- - "" $program)

        if set -q _flag_snap
            # Test if already installed
            if not test -n (snap list | grep '$program|$short_p_name')
                print_separator "$emoji  Installing $program $emoji" # The double space here is on purpose, otherwise sometimes there no space between the emoji and the message

                if $isFirstMissing
                    sudo apt update
                    sudo apt upgrade -y
                    set isFirstMissing false
                end

                snap install $program

                if test $program = lolcat-c
                    extra_install_steps $program
                end
            end
            ## End current loop iteration
            continue
        else if set -q _flag_brew
            # Test if already installed
            if not test -n (brew list | grep $program)
                print_separator "$emoji  Installing $program $emoji" # The double space here is on purpose, otherwise sometimes there no space between the emoji and the message

                if $isFirstMissing
                    brew update
                    brew upgrade
                    set isFirstMissing false
                end

                brew install $program
            end
            continue
        else
            # Test if already installed
            if not type -q $program || not type -q $short_p_name
                print_separator "$emoji  Installing $program $emoji" # The double space here is on purpose, otherwise sometimes there no space between the emoji and the message

                if $isFirstMissing
                    sudo apt update
                    sudo apt upgrade -y
                    set isFirstMissing false
                end

                sudo apt install -y $program

                if test $program = fd-find || test $program = bat
                    extra_install_steps $program
                end
            end
        end
    end
end
