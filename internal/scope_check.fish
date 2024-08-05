#!/usr/bin/env fish

function scope_check -d 'Check the scope of a variable' -a varName
    set -l func_version "1.0.0"
    set cauldon_category "Internal"
    set -l options v/version h/help z/cauldron s/script
    argparse -n scope_check $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return 0
    end

    # if they asked for help just return it
    if set -q _flag_help
        echo "Usage: scope_check [options] [variable-name]"
        echo ""
        echo "Options:"
        echo "  -v, --version  Show version number"
        echo "  -h, --help     Show help"
        echo "  -z, --cauldron Show the cauldron category"
        echo "  -s, --script   Output the fish letter associated with the scope (for use in scripts)"
        echo "   Output from script option: "
        echo "     U - Universal"
        echo "     g - Global"
        echo "     l - Local"
        echo "     env - Environment"
        echo "     command - Command"
        echo "     function - Function"
        echo "     0 - No scope found"
        return 0
    end

    # Check if the variable is universal
    if set -qU $varName
      if set -q _flag_script
        echo "U"
        return 0
      end
        echo "$varName is a universal variable"
        return 0
    end

    # Check if the variable is global
    if set -qg $varName
      if set -q _flag_script
        echo "g"
        return 0
      end
        echo "$varName is a global variable"
        return 0
    end

    # Check if the variable is local
    if set -ql $varName
      if set -q _flag_script
        echo "l"
        return 0
      end
        echo "$varName is a local variable"
        return 0
    end

    # Check if the variable is a function
    if functions -q $varName
      if set -q _flag_script
        echo "function"
        return 0
      end
        echo "$varName is a function"
        return 0
    end

    # Check if the variable is an environment variable
    if set -q $varName
      if set -q _flag_script
        echo "env"
        return 0
      end
        echo "$varName is an environment variable"
        return 0
    end

    # Check if the variable is a command
    if which $varName
      if set -q _flag_script
        echo "command"
        return 0
      end
        echo "$varName is a command"
        return 0
    end

    if set -q _flag_script
      echo "0"
      return 0
    end

    echo "No scope found for $varName"
    return 0
end
