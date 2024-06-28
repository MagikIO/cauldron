#!/usr/bin/env fish

function node_init -d 'Initialize a Node.js project with Yarn and Typescript'
    set -l func_version "2.1.0"
    
    # Define options that can be passed
    set -l options "v/version" "h/help" "n/name" "d/description" "a/author" "s/scope" "l/license" "c/config" "C/create_config"
    argparse -n node_init $options -- $argv

    # If the for version return the version
    if set -q _flag_v; or set -q _flag_version
      echo "node_init $func_version"
      return 0
    end

    # If they asked for help return help
    if set -q _flag_h; or set -q _flag_help
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
      echo "  -C, --create_config  Create a config file"
      return 0
    end

    # if they choose the create_config option, create a config file
    if set -q _flag_C; or set -q _flag_create_config
      # See if the f-says command is avail
      if command -q f-says
          f-says "Creating a config file"
      else
          echo "Creating a config file"
      end

      mkdir =p ~/.config/magik
      touch ~/.config/magik/conf.json

      # Fetch Git configuration
      set git_name (git config --get user.name)
      set git_email (git config --get user.email)

      # Create the JSON content
      echo "{\n" \
      > "  \"author\": {\n" \
      > "    \"name\": \"$git_name\",\n" \
      > "    \"email\": \"$git_email\"\n" \
      > "  },\n" \
      > "  \"scripts\": {\n" \
      > "    \"iterate\": \"iterate\"\n" \
      > "  }\n" \
      > "}" > ~/.config/magik/conf.json

      # Check if the styled-banner command is avail
      if command -q styled-banner
          styled-banner "Created!"
      else
          echo "Config file created"
      end

      set -gx AQUA__NODE_INIT_CONFIG ~/.config/magik/conf.json
      return 0
    end

    # Check if the f-says command is avail
    if command -q f-says
        f-says "Initializing a Node.js project for you.."
    else
        echo "Initializing a Node.js project for you.."
    end
    

    # Check for the env variable AQUA__NODE_INIT_CONFIG and set _flag_c to equal its value
    if set -q AQUA__NODE_INIT_CONFIG
        set _flag_c true
        set _config_file $AQUA__NODE_INIT_CONFIG
    end

    # Make sure that node is available here if they are using ASDF
    if command -q asdf
      asdf install nodejs latest
      asdf global nodejs latest
      asdf local nodejs latest
      corepack enable
      asdf reshim nodejs
    end

    # If the user passes a config (JSON) file, read it and set the values
    if set -q _flag_c; or set -q _flag_config
      # Check if the fays command is avail
      if command -q f-says
          f-says "Using the following page from your grimoire (config file): $_config_file"
      else
        # Style the name of the config file
        printf "Using the following page from your grimoire (config file): %s" $_config_file
      end

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

    # We need to know if they prefer to use node-module or pnp for their node-linker
    # Check if the CAULDRON_NODE_LINKER_PREF env variable is set
    if set -q CAULDRON_NODE_LINKER_PREF
        set node_linker_pref $CAULDRON_NODE_LINKER_PREF
    else
        # Check if f-says is avail
        if command -q f-says
            f-says "Would you like to use the node-modules or pnp mode for your node-modules?"
        else
            echo "Would you like to use the node-modules or pnp node-linker?"
        end
        choose "node-modules" "pnp"

        # If they choose nothing set it to node-modules
        if test -z $CAULDRON_LAST_CHOICE
            set node_linker_pref node-modules
        else
            set node_linker_pref $CAULDRON_LAST_CHOICE
        end
    end

    # First we need to create a a .yarnrc.yml file
    # This file will be used to set up the init values for the project
    # We will add the following to it IF the variable has a value
    #
    # initScope: $scope,
    # 
    # initFields: {
    #   name: $name,
    #   node-linker: $node_linker_pref,
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

        if set -q node_linker_pref; and not test -z $node_linker_pref
            echo "  node-linker: $node_linker_pref" >>.yarnrc.yml
        end

        if set -q description; and not test -z $description
            echo "  description: $description" >>.yarnrc.yml
        end

        if set -q license; and not test -z $license
            echo "  license: $license" >>.yarnrc.yml
        end
    end


    # Move to newest version
    yarn set version stable

    # Check if asdf is installed
    if command -q asdf
        asdf reshim nodejs
    end

    # Init Yarn
    yarn init -2

    # Add minimum dependencies
    yarn add -D typescript @types/node eslint typescript typescript-eslint @magik_io/lint_golem
    
    # If they choose to use pnp, we should add in the yarn sdks for them
    if test $node_linker_pref = "pnp"
        yarn dlx @yarnpkg/sdks base
        yarn dlx @yarnpkg/sdks vscode
    end

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
    set tmp_node_version (node -v)
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
    echo ".yarnrc.yml" >>.npmignore

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
    echo "  ...new LintGolem({ rootDir: __dirname, tsconfigPaths: 'tsconfig.json' }).config" >>eslint.config.js
    echo ");" >>eslint.config.js

    # Check if the f-says command is avail
    if command -q f-says
        styled-banner "Project Ready!"
    else
      print_separator "Project initialized"
    end
end
