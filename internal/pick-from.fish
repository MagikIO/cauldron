function pick-from --description 'Pick a random item from the provided list'
    # Check if any arguments were provided
    if not set -q argv[1]
        echo "Error: No arguments provided."
        return 1
    end

    # Get the number of arguments
    set num_args (count $argv)

    # Check if the number of arguments is greater than 0
    if test $num_args -gt 0
        # Generate a random number between 1 and the number of arguments
        set random_index (math (random 1 $num_args))

        # Return the randomly chosen argument
        echo $argv[$random_index]
    else
        echo "Error: No arguments provided."
        return 1
    end
end
