#!/usr/bin/env fish

function spin -d 'Display a customizable spinner while a command is running' -a command
    set -l func_version "1.0.0"

    # Flag options
    set -l options i/invisible m/msg= s/speed= t/type= l/list h/help
    argparse -n spin $options -- $argv

    echo "You are running the spin function!"
    echo "Command: $command"

    # if they asked the version just return it
    if set -q _flag_version
        if type -q f-says
            f-says "spin.fish is at v$func_version"
        else
            echo $func_version
        end
        return 0
    end

    # If they asked for help, show it
    if set -q _flag_help
        echo (bold "spin")
        echo "Display a customizable spinner while a command is running"
        echo ""
        echo (bold "Usage:")
        echo "  -v, --version  Show the version"
        echo "  -h, --help     Show this help message"
        echo "  -m, --msg      The message to display with the spinner"
        echo "  -s, --speed    The speed of the spinner"
        echo "  -t, --type     The type of spinner to display"
        echo "  -l, --list     List all available spinners"
        echo ""
        echo (bold "Example:")
        echo "  spin -m 'Installing Cauldron' -t moon sleep 10"
        echo ""
        echo (bold "Requires:")
        echo (italic "(Will be installed automatically if not found)")
        echo " jq"
        return 0
    end

    if not type -q jq
        installs -b jq
    end

    set __CAULDRON_SPINNERS_PATH $CAULDRON_PATH/data/spinners.json
    ## Example of the JSON being loaded..
    # { 
    #   "moon": {
    #     "interval": 80,
    #     "frames": ["🌑 ", "🌒 ", "🌓 ", "🌔 ", "🌕 ", "🌖 ", "🌗 ", "🌘 "]
    #   },
    # }
    set -gx __CAULDRON_SPINNER_LIST (jq -r 'keys[]' $__CAULDRON_SPINNERS_PATH)

    # If they asked for a list of spinners, show it
    if set -q _flag_list
        echo (bold "Available Spinners:")
        for spinner in $__CAULDRON_SPINNER_LIST
            # Grab it's interval
            set interval (jq -r ".[\"$spinner\"].interval" $__CAULDRON_SPINNERS_PATH)

            echo " "(bold $spinner)" - Interval: "$interval
            # Now we loop the spin animation for the spinner
            echo " "(bold "Demo")
            for frame in (jq -r ".[\"$spinner\"].frames[]" $__CAULDRON_SPINNERS_PATH)
                echo " "$frame
            end
            echo " "(bold "To Use")
            echo " spin -t $spinner | your-task"
        end
        return 0
    end

    set spinner_name moon

    # If they requested to use a specific spinner
    if set -q _flag_type
        # we need to make sure it exists
        if not contains $_flag_type $__CAULDRON_SPINNER_LIST
            echo "Spinner $_flag_type not found, please try running: \n spin -l"
            return 1
        end
        # Name is valid
        set spinner_name $_flag_type
    end

    # Get the interval and frames for the spinner
    set interval (jq -r ".[\"$spinner_name\"].interval" $__CAULDRON_SPINNERS_PATH)
    set interval (math "$interval * 0.001")
    if set -q _flag_speed
        set interval (math "$_flag_speed * 0.1")
    end
    set frames (jq -r ".[\"$spinner_name\"].frames[]" $__CAULDRON_SPINNERS_PATH)

    # Set the msg to display with the spinner
    set msg "Loading..."
    if set -q _flag_msg
        set msg $_flag_msg
    end

    # Set the hidden flag if they want to hide the spinner
    set hide false
    if set -q _flag_invisible
        set hide true
    end

    # Execute the command in the background
    fish -c $command &
    set command_pid $last_pid
    echo "Command PID: $command_pid"
    echo "Spinner: $spinner_name"
    echo "Interval: $interval"
    echo "Frames: $frames"

    # echo -n $msg
    # echo -ne "\r"

    # Display spinner
    while kill -0 $command_pid 2>/dev/null
        # if test $hide = true
        #     break
        # end

        for frame in $spinner_frames
            echo -n $frame
            sleep $spinner_interval
            echo -ne "\r"
        end
    end
end
