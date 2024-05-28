#!/usr/bin/env fish

function node_init --description "Initialize a Node.js project with Yarn and Typescript"
    set -l func_version "2.0.0"

    # Define options that can be passed
    set -l options (fish_opt -s v -l version)
    set options $options (fish_opt -s h -l help)
    set options $options (fish_opt -s n -l name)
    set options $options (fish_opt -s d -l description)
    set options $options (fish_opt -s a -l author)
    set options $options (fish_opt -s s -l scope)
    set options $options (fish_opt -s l -l license)
    set options $options (fish_opt -s c -l config)

    argparse $options -- $argv

    # If the user passes the help flag, display the help message
    if set -q _flag_v; or set -q _flag_version
        echo "Usage: node_init [options]"
        echo ""
        echo "Options:"
        echo "  -h, --help       Display this help message"
        echo "  -v, --version    Display the version of the function"
        echo "  -n, --name       The name of the project"
        echo "  -d, --description The description of the project"
        echo "  -a, --author     The author of the project"
        echo "  -s, --scope      The scope of the project"
        echo "  -l, --license    The license of the project"
        echo "  -c, --config     The path to a config file"
        return 0
    end

    # If they asked for the version, return the version
    if set -q _flag_h; or set -q _flag_help
        echo "node_init $func_version"
        return 0
    end

    print_separator "Initializing a Magik Node.js project"

    # Check for the env variable AQUA__NODE_INIT_CONFIG and set _flag_c to equal its value
    if set -q AQUA__NODE_INIT_CONFIG
        set _flag_c true
        set _config_file $AQUA__NODE_INIT_CONFIG
    end

    # If the user passes a config (JSON) file, read it and set the values
    if set -q _flag_c; or set -q _flag_config
        # Style the name of the config file
        printf "Using environmental config file: %s" $_config_file

        if test -n "$_config_file"
            bat $_config_file --language json
        else
            if test -z $argv[1]
                echo "Config file not found"
                return 1
            else
                set _config_file $argv[1]
            end
        end

        set default_name $(basename (pwd))
        set default_desc "A really magik $default_name"

        set scope (jq -r '.scope' $_config_file)
        if test -z $scope; or test $scope = null
            set scope
        end

        # the file
        set name (jq -r '.name' $_config_file)
        if test -z $name; or test $name = null
            set name $default_name
        end

        # Apply the scope to the name
        if not test -z $scope
            set name "@$scope/$name"
        end

        set description (jq -r '.description' $_config_file)
        if test -z $description; or test $description = null
            set description $default_desc
        end

        set author_name (jq -r '.author.name' $_config_file)
        if test -z $author_name; or test $author_name = null
            set author_name (jq -r '.author' $_config_file)
            if test -z $author; or test $author = null
                set author
            end
        end
        set author_email (jq -r '.author.email' $_config_file)
        if test -z $author_email; or test $author_email = null
            set author_email
        end
        set author_github (jq -r '.author.github' $_config_file)
        if test -z $author_github; or test $author_github = null
            set author_github
        end

        set license (jq -r '.license' $_config_file)
        if test -z $license; or test $license = null
            set license MIT
        end
    end

    # First we need to create a a .yarnrc.yml file
    # This file will be used to set up the init values for the project
    # We will add the following to it IF the variable has a value
    #
    # initScope: $scope,
    # initFields: {
    #   name: $name,
    #   description: $description,
    #   author: $author,
    #   license: $license,
    # }
    if not test -e .yarnrc.yml
        echo "Creating .yarnrc.yml file"
        echo "initFields:" >>.yarnrc.yml
        if set -q name; and not test -z $name
            echo "  name: \"$name\"" >>.yarnrc.yml
        end

        if set -q description; and not test -z $description
            echo "  description: $description" >>.yarnrc.yml
        end

        if set -q license; and not test -z $license
            echo "  license: $license" >>.yarnrc.yml
        end
    end

    # Init Yarn
    yarn init -2
    # Move to newest version
    yarn set version stable
    # Add minimum dependencies
    yarn add -D typescript @types/node eslint @eslint/js typescript typescript-eslint @magik_io/lint_golem
    # Set up yarn pnp configs for the base project
    yarn dlx @yarnpkg/sdks base
    yarn dlx @yarnpkg/sdks vscode
    # Init Typescript
    tsc --init

    # Create a preferred folder structure
    mkdir -p src
    mkdir -p test
    mkdir -p dist

    # Remove the last line of the package.json file, and add a comma to the end of the last line
    sed -i '$ d' package.json
    sed -i '$ s/$/,/' package.json

    # Add scripts if they exist
    # Scripts have the following formatting:
    # "scripts": {
    #   "publish": "npm publish --access public"
    # },
    set script_value_pairs (jq -c '.scripts | to_entries[]?' $_config_file)

    # If if the value pair list is not empty
    begin
        if test (count $script_value_pairs) -gt 0
            echo "Adding scripts to package.json"
            echo "  \"scripts\": {" >>package.json

            for i in (seq (count $script_value_pairs))
                set -l script_value_pair $script_value_pairs[$i]
                set -l script_name (echo $script_value_pair | jq -r '.key')
                set -l script_value (echo $script_value_pair | jq -r '.value')
                # If it's the last script, don't add a comma at the end
                if test $i -eq (count $script_value_pairs)
                    echo "    \"$script_name\": \"$script_value\"" >>package.json
                else
                    echo "    \"$script_name\": \"$script_value\"," >>package.json
                end
            end

            # for script_value_pair in $script_value_pairs
            #     set -l script_name (echo $script_value_pair | jq -r '.key')
            #     set -l script_value (echo $script_value_pair | jq -r '.value')
            #     echo "    \"$script_name\": \"$script_value\"" >>package.json
            # end
            echo "  }," >>package.json
        end
    end


    # Set the authors array with the following formatting
    # "authors": [
    #     {
    #         "name": "Antonio B.",
    #         "github": "https://github.com/Abourass",
    #         "email": "Abourassa@AssetVal.com"
    #     },
    # ],
    if set -q author_name; and not test -z $author_name
        echo "Adding authors to package.json"
        echo "  \"authors\": [" >>package.json
        echo "    {" >>package.json
        echo "      \"name\": \"$author_name\"," >>package.json
        if not test -z $author_email
            echo "      \"email\": \"$author_email\"," >>package.json
        end
        if not test -z $author_github
            echo "      \"github\": \"$author_github\"" >>package.json
        end
        echo "    }" >>package.json
        echo "  ]," >>package.json
    end

    # Add additional changes to the package.json file
    # Get the current repo
    set repo (git config --get remote.origin.url)
    # Set it using the following formatting:
    # "repository": {
    #   "type": "git",
    #   "url": "https://github.com/AssetVal/Veritas.git"
    # },
    if not test -z $repo
        echo "Adding repository to package.json"
        echo "  \"repository\": {" >>package.json
        echo "    \"type\": \"git\"," >>package.json
        echo "    \"url\": \"$repo\"" >>package.json
        echo "  }," >>package.json
    end

    # Set the "engines" key with the following formatting
    #   "engines": {
    #    "node": "20.9.0",
    #    "npm": "10.2.0"
    #  },
    echo "Adding engines to package.json"
    echo "  \"engines\": {" >>package.json
    set tmp_node_version (nvm current)
    set tmp_npm_version (npm -v)
    echo "    \"node\": \"$tmp_node_version\"," >>package.json
    echo "    \"npm\": \"$tmp_npm_version\"" >>package.json
    echo "  }," >>package.json

    # Set the "main" property as `dist/index.js`
    echo "Adding main to package.json"
    echo "  \"main\": \"dist/index.js\"," >>package.json

    # Add browserSuport with the following formatting
    # "browserslist": [
    #   "last 2 version",
    #   "> 1%"
    # ],
    echo "Adding browserslist to package.json"
    echo "  \"browserslist\": [" >>package.json
    echo "    \"last 2 version\"," >>package.json
    echo "    \"> 1%\"" >>package.json
    echo "  ]" >>package.json

    # Add the last line to the package.json file
    echo "}" >>package.json
    # Use node -e to read, reorder, and write the package.json file
    node -e "
        const fs = require('fs');
        const path = require('path');

        // Define the preferred key order
        const preferredKeyOrder = ['name', 'description', 'homepage', 'version', 'engines', 'main', 'scripts', 'types', 'module', 'exports',
        'dependencies', 'devDependencies', 'browser', 'unpkg', 'sideEffects', 'private', 'authors', 'repository', 'browserslist', 'license', 'packageManager'];

        // Read the package.json file
        const packageJsonPath = path.join(process.cwd(), 'package.json');
        const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));

        // Reorder the keys in the package.json object
        const reorderedPackageJson = {};
        preferredKeyOrder.forEach(key => {
            if (packageJson.hasOwnProperty(key)) reorderedPackageJson[key] = packageJson[key];
        });

        // Write the reordered object back to the package.json file
        fs.writeFileSync(packageJsonPath, JSON.stringify(reorderedPackageJson, null, 2));
    "

    # Create a .npmignore file with the following
    # /src/**/*
    # .pnp.*
    # .yarn
    # .vscode
    # tsconfig.json
    # eslint.config.mjs
    # .editorconfig
    # .gitattributes
    echo "/src/**/*" >>.npmignore
    echo ".pnp.*" >>.npmignore
    echo ".yarn" >>.npmignore
    echo ".vscode" >>.npmignore
    echo "tsconfig.json" >>.npmignore
    echo "eslint.config.*" >>.npmignore
    echo ".editorconfig" >>.npmignore
    echo ".gitattributes" >>.npmignore

    ##
    #  And then create a eslint.config.js with the following formatting
    # ```typescript
    # const tseslint = require('typescript-eslint');
    # const { LintGolem } = require('@magik_io/lint_golem')

    # module.exports = tseslint.config(
    #  ...new LintGolem({ rootDir: __dirname }).config
    # );
    # ```
    ##
    echo "const tseslint = require('typescript-eslint');" >>eslint.config.js
    echo "const { LintGolem } = require('@magik_io/lint_golem')" >>eslint.config.js
    echo "module.exports = tseslint.config(" >>eslint.config.js
    echo "  ...new LintGolem({ rootDir: __dirname }).config" >>eslint.config.js
    echo ");" >>eslint.config.js

    print_separator "Project initialized"
end
