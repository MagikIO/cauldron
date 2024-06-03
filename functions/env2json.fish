function env2json --description 'Converts the current environment variables to a JSON file'
    set -l func_version "1.0.0"

    # Flag options
    set -l options v/version h/help V/verbose o/output= f/force b/backup d/debug
    argparse -n env2json $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return 0
    end

    # if they asked for help, show it
    if set -q _flag_help
        echo "Converts the current environment variables to a JSON file"
        echo "Usage: env2json [options]"
        echo ""
        echo "Options:"
        echo "  -v, --version  Show the version"
        echo "  -h, --help     Show this help message"
        echo "  -V, --verbose  Show print the JSON after"
        echo "  -o, --output   Specify the output file"
        echo "  -f, --force    Overwrite the output file"
        echo "  -b, --backup   Backup the output file, if it already exists"
        return 0
    end

    # Define the path where the JSON file will be saved
    set output_file $CAULDRON_PATH/config/env.json

    # If the user specifies an output file, use that instead
    if set -q _flag_output
        # If what they proviveded doesn't end with .json, we need to check the following
        # 1. Does it end in a /, if so, does the dir exist, if not, create it
        # 2. Did they pass a dir that already exists but didn't end it with "/", if so, create a env.json file in that dir
        # 3. Did the pass an existing file, if so, use that
        # 4. if Not assume, they want to create a file with the name they provided
        if not string match -q '*.json' $_flag_output
            if string match -q '*/' $_flag_output
                set target_DIR (dirname $_flag_output)
                if not test -d $target_DIR
                    mkdir -p $target_DIR
                end
                # Target dir is the parent dir to the root dir they provided
                # We don't want to make a file there we want to make a file in the root dir
                set output_file $_flag_output"env.json"
            else if test -d $_flag_output
                set output_file "$_flag_output/env.json"
            else if test -f $_flag_output
                set output_file $_flag_output
            else
                set output_file $_flag_output
            end
        else
            set output_file $_flag_output
        end
    end

    # If the file already exist
    if test -f $output_file
        # If they provided the force flag, just delete the file
        if set -q _flag_force
            rm $output_file
        else if set -q _flag_backup
            bak $output_file
        else
            # Ask the user if they want to:
            # 1. Overwrite the file
            # 2. Overwrite the file, but backup the existing file
            # 3. Cancel the operation
            echo "The file $output_file already exists. What would you like to do?"
            choose 'Overwrite the file' 'Overwrite the file, after backing up the last one' Cancel

            # If the user chooses to cancel the operation, return early
            if test "#CAULDRON_LAST_CHOICE" = Cancel
                exit 0
            end

            # If the user chooses to overwrite the file, do nothing
            # If the user chooses to overwrite the file and backup the existing one, backup the existing file
            if test "#CAULDRON_LAST_CHOICE" = "Overwrite the file, after backing up the last one"
                # Backup the existing file
                bak $output_file
            end

            # Delete the existing file
            rm $output_file
        end
    else
        # If the file doesn't exist yet, touch it
        touch $output_file
    end

    if set -q _flag_debug
        echo "Output file: $output_file"
        shiny spin -s moon --title "Generating.." --show-output -- ~/.config/fish/functions/_convert_env_to_JSON.fish $output_file
    else
        shiny spin -s moon --title "Generating.." -- ~/.config/fish/functions/_convert_env_to_JSON.fish $output_file
    end

    # Let them know it worked
    say "ENVs saved to $output_file"

    # If they want to see the JSON
    if set -q _flag_verbose
        bat $output_file
    end

    # Exit the function
    return 0
end
