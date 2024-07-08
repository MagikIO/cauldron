#!/usr/bin/env fish

function __cauldron_install_help
    set -l func_version "1.0.0"

    # Flag options
    set -l options v/version h/help s/src= c/category=
    argparse -n cauldron_install_help $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return 0
    end

    # if they asked for help, show it
    if set -q _flag_help
        echo "Install the Cauldron CLI"
        echo "Usage: cauldron_install_help [options]"
        echo ""
        echo "Options:"
        echo "  -v, --version  Show the version"
        echo "  -h, --help     Show this help message"
        echo "  -s, --src      Install documentation from source"
        return 0
    end

    function to_lower_case -a str
      echo $str | tr '[:upper:]' '[:lower:]'
    end

    if not set -q __CAULDRON_DOCUMENTATION_PATH
      set -Ux __CAULDRON_DOCUMENTATION_PATH $CAULDRON_PATH/docs
    end

    if set -q _flag_category
      set -gx __doc_category $_flag_category
    else
      set -gx __doc_category Functions
    end

    # Documentation Category
    set doc_categories "Functions" "Text" "Setup" "Alias" "UI" "Internal"
    set __lower_case_category (to_lower_case $__doc_category)
    set -gx __CAULDRON_DOC_CATEGORY_PATH "$__CAULDRON_DOCUMENTATION_PATH/$__lower_case_category"

    # We need to make sure the docs directory exists
    if not test -d $__CAULDRON_DOCUMENTATION_PATH
        mkdir -p $__CAULDRON_DOCUMENTATION_PATH
    end

    # Check if the user wants to install the documentation from source
    if set -q _flag_src
        # Make sure that the src passed is a valid directory
        if not test -d $_flag_src
            familiar "The source directory does not exist"
            return 1
        else
            # Make sure the directory doesn't contain sub-directories
            # Copy the files to the documentation directory
            cp -r $_flag_src/* $__CAULDRON_DOCUMENTATION_PATH

            # Check if f-says is installed
            familiar "Documentation installed successfully"
        end
    else
        # We need to grab the documentation files from git
      set base_doc_url "https://github.com/MagikIO/cauldron/tree/main/docs/"
      set doc_url "$base_doc_url$__lower_case_category"
      

    end
end
