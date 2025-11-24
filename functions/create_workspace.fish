#!/usr/bin/env fish

function create_workspace
    set -l func_version "1.0.0"

    # Flag options
    set options v/version h/help d/dry-run n/name=
    argparse -n create_workspace $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return 0
    end

    # if they asked for help, show it
    if set -q _flag_help
        echo "Usage: create_workspace [options] <workspace_name>"
        echo
        echo "Options:"
        echo "  -v, --version  Show the version number"
        echo "  -h, --help     Show this help message"
        echo "  -n, --dry-run  Show what would be done without actually doing it"
        return 0
    end

    # if they asked for a dry-run, set the dry-run flag
    set -l dry_run false
    if set -q _flag_dry-run
        set dry_run true
    end

    # if they provided a name, use it
    set -l workspace_name
    if set -q _flag_name
        set workspace_name $_flag_name
    else if test (count $argv) -eq 0
        set workspace_name $argv[1]
    else
        set workspace_name (gum input --header "Enter the name of the workspace to create:" --placeholder "Workspace Name" --width 80 --header.foreground "#FFD8D6" --prompt.foreground "#d6fdff")
    end

    if test -z "$workspace_name"
        echo "Usage: create_workspace <workspace_name>"
        return 1
    end

    set workspace_dir packages/$workspace_name

    # Create the workspace directory
    if not $dry_run
        mkdir -p $workspace_dir
    else
        echo "$workspace_dir -- Would have been created"
    end

    # Create common files in the new workspace
    echo "Creating common files in $workspace_dir"

    # .gitattributes
    if not $dry_run
        touch $workspace_dir/.gitattributes
        echo "/.yarn/**            linguist-vendored" >$workspace_dir/.gitattributes
        echo "/.yarn/releases/*    binary" >>$workspace_dir/.gitattributes
        echo "/.yarn/plugins/**/*  binary" >>$workspace_dir/.gitattributes
        echo "/.pnp.*              binary linguist-generated" >>$workspace_dir/.gitattributes
        echo "/.vscode/**          linguist-generated" >>$workspace_dir/.gitattributes
    else
        echo "$workspace_dir/.gitattributes -- Would have been created"
    end

    # .gitignore
    if not $dry_run
        cp .gitignore $workspace_dir/.gitignore
    else
        echo "$workspace_dir/.gitignore -- Would have been copied over"
    end

    # .npmignore
    if not $dry_run
        touch $workspace_dir/.npmignore
        echo "# Source Files" >$workspace_dir/.npmignore
        echo "**/src/**/*" >>$workspace_dir/.npmignore
        echo "" >>$workspace_dir/.npmignore
        echo "# NPM / PNP" >>$workspace_dir/.npmignore
        echo ".pnp.*" >>$workspace_dir/.npmignore
        echo "" >>$workspace_dir/.npmignore
        echo "# Linting / Formatting" >>$workspace_dir/.npmignore
        echo "eslint.config.*" >>$workspace_dir/.npmignore
        echo ".editorconfig" >>$workspace_dir/.npmignore
        echo "" >>$workspace_dir/.npmignore
        echo "# Yarn" >>$workspace_dir/.npmignore
        echo ".gitattributes" >>$workspace_dir/.npmignore
        echo ".yarnrc.yml" >>$workspace_dir/.npmignore
        echo "**/.yarn/**/*" >>$workspace_dir/.npmignore
        echo ".yarn" >>$workspace_dir/.npmignore
        echo "" >>$workspace_dir/.npmignore
        echo "# moon" >>$workspace_dir/.npmignore
        echo ".moon/cache" >>$workspace_dir/.npmignore
        echo ".moon/docker" >>$workspace_dir/.npmignore
        echo "**/moon.yml" >>$workspace_dir/.npmignore
        echo "" >>$workspace_dir/.npmignore
        echo "# Node" >>$workspace_dir/.npmignore
        echo node_modules >>$workspace_dir/.npmignore
        echo "**/node_modules/**/*" >>$workspace_dir/.npmignore
        echo "" >>$workspace_dir/.npmignore
        echo "# Git" >>$workspace_dir/.npmignore
        echo "**/.git/**/*" >>$workspace_dir/.npmignore
        echo "" >>$workspace_dir/.npmignore
        echo "# git-chglog" >>$workspace_dir/.npmignore
        echo ".chglog" >>$workspace_dir/.npmignore
        echo "" >>$workspace_dir/.npmignore
        echo "# vscode" >>$workspace_dir/.npmignore
        echo ".vscode" >>$workspace_dir/.npmignore
        echo "**/.vscode/**/*" >>$workspace_dir/.npmignore
        echo "" >>$workspace_dir/.npmignore
        echo "# Typescript" >>$workspace_dir/.npmignore
        echo "**/*.tsbuildinfo" >>$workspace_dir/.npmignore
        echo "**/tsconfig.json" >>$workspace_dir/.npmignore
        echo "" >>$workspace_dir/.npmignore
        echo "# ASDF" >>$workspace_dir/.npmignore
        echo "**/.tool-versions" >>$workspace_dir/.npmignore
    else
        echo "$workspace_dir/.npmignore -- Would have been created"
    end

    # .tool-versions
    if not $dry_run
        touch $workspace_dir/.tool-versions
        echo "nodejs 22.6.0" >$workspace_dir/.tool-versions
    else
        echo "$workspace_dir/.tool-versions -- Would have been created"
    end

    # .yarnrc.yml
    if not $dry_run
        touch $workspace_dir/.yarnrc.yml
        echo "nodeLinker: node-modules" >$workspace_dir/.yarnrc.yml
    else
        echo "$workspace_dir/.yarnrc.yml -- Would have been created"
    end

    # eslint.config.js
    if not $dry_run
        cp eslint.config.js $workspace_dir/eslint.config.js
    else
        echo "$workspace_dir/eslint.config.js -- Would have been copied over"
    end

    # Create package.json
    if not $dry_run
        touch $workspace_dir/package.json
        set lowercase_workspace_name (string lower $workspace_name)

        echo "{" >$workspace_dir/package.json
        echo "  \"name\": \"@assetval/$lowercase_workspace_name\"," >>$workspace_dir/package.json
        echo "  \"description\": \"AssetVal's internal $lowercase_workspace_name model\"," >>$workspace_dir/package.json
        echo "  \"engines\": {" >>$workspace_dir/package.json
        echo "    \"node\": \"v22.6.0\"," >>$workspace_dir/package.json
        echo "    \"yarn\": \"4.4.0\"" >>$workspace_dir/package.json
        echo "  }," >>$workspace_dir/package.json
        echo "  \"sideEffects\": false," >>$workspace_dir/package.json
        echo "  \"type\": \"module\"," >>$workspace_dir/package.json
        echo "  \"exports\": {" >>$workspace_dir/package.json
        echo "    \".\": {" >>$workspace_dir/package.json
        echo "      \"types\": \"./dist/$workspace_name.d.ts\"," >>$workspace_dir/package.json
        echo "      \"import\": \"./dist/$workspace_name.mjs\"," >>$workspace_dir/package.json
        echo "      \"require\": \"./dist/$workspace_name.cjs\"" >>$workspace_dir/package.json
        echo "    }" >>$workspace_dir/package.json
        echo "  }," >>$workspace_dir/package.json
        echo "  \"main\": \"dist/$workspace_name.cjs\"," >>$workspace_dir/package.json
        echo "  \"module\": \"dist/$workspace_name.mjs\"," >>$workspace_dir/package.json
        echo "  \"types\": \"dist/$workspace_name.d.ts\"," >>$workspace_dir/package.json
        echo "  \"files\": [" >>$workspace_dir/package.json
        echo "    \"dist\"" >>$workspace_dir/package.json
        echo "  ]," >>$workspace_dir/package.json
        echo "  \"scripts\": {" >>$workspace_dir/package.json
        echo "    \"build\": \"unbuild\"," >>$workspace_dir/package.json
        echo "    \"test\": \"vitest run --coverage --config ./vitest.config.ts\"," >>$workspace_dir/package.json
        echo "    \"iterate\": \"yarn version patch && git push origin main --tags && yarn npm publish --access public\"" >>$workspace_dir/package.json
        echo "  }," >>$workspace_dir/package.json
        echo "  \"dependencies\": {" >>$workspace_dir/package.json
        echo "    \"@nestjs/mongoose\": \"^10.0.10\"," >>$workspace_dir/package.json
        echo "    \"mongoose\": \"^8.5.2\"," >>$workspace_dir/package.json
        echo "    \"mongoose-lean-virtuals\": \"^0.9.1\"," >>$workspace_dir/package.json
        echo "    \"reflect-metadata\": \"^0.2.2\"," >>$workspace_dir/package.json
        echo "    \"tslib\": \"^2.6.3\"," >>$workspace_dir/package.json
        echo "    \"zod\": \"^3.23.8\"" >>$workspace_dir/package.json
        echo "  }," >>$workspace_dir/package.json
        echo "  \"peerDependencies\": {" >>$workspace_dir/package.json
        echo "    \"mongoose\": \"*\"," >>$workspace_dir/package.json
        echo "    \"rxjs\": \"*\"," >>$workspace_dir/package.json
        echo "    \"tslib\": \"^*\"," >>$workspace_dir/package.json
        echo "    \"zod\": \"*\"" >>$workspace_dir/package.json
        echo "  }," >>$workspace_dir/package.json
        echo "  \"devDependencies\": {" >>$workspace_dir/package.json
        echo "    \"@assetval/confs\": \"^1.0.0\"," >>$workspace_dir/package.json
        echo "    \"@magik_io/lint_golem\": \"^2.2.3\"," >>$workspace_dir/package.json
        echo "    \"@nestjs/common\": \"^10.4.1\"," >>$workspace_dir/package.json
        echo "    \"@nestjs/core\": \"^10.4.1\"," >>$workspace_dir/package.json
        echo "    \"@types/mongoose\": \"^5.11.97\"," >>$workspace_dir/package.json
        echo "    \"@types/node\": \"^22.3.0\"," >>$workspace_dir/package.json
        echo "    \"@vitest/coverage-v8\": \"^2.0.5\"," >>$workspace_dir/package.json
        echo "    \"eslint\": \"^9.9.0\"," >>$workspace_dir/package.json
        echo "    \"rxjs\": \"^7.8.1\"," >>$workspace_dir/package.json
        echo "    \"tsconfig-moon\": \"^1.3.0\"," >>$workspace_dir/package.json
        echo "    \"typescript\": \"^5.5.4\"," >>$workspace_dir/package.json
        echo "    \"typescript-eslint\": \"^8.1.0\"," >>$workspace_dir/package.json
        echo "    \"unbuild\": \"^2.0.0\"," >>$workspace_dir/package.json
        echo "    \"vitest\": \"^2.0.5\"" >>$workspace_dir/package.json
        echo "  }," >>$workspace_dir/package.json
        echo "  \"authors\": [" >>$workspace_dir/package.json
        echo "    {" >>$workspace_dir/package.json
        echo "      \"name\": \"Antonio B.\"," >>$workspace_dir/package.json
        echo "      \"email\": \"Abourassa@AssetVal.com\"," >>$workspace_dir/package.json
        echo "      \"github\": \"https://github.com/Abourass\"" >>$workspace_dir/package.json
        echo "    }" >>$workspace_dir/package.json
        echo "  ]," >>$workspace_dir/package.json
        echo "  \"repository\": {" >>$workspace_dir/package.json
        echo "    \"type\": \"git\"," >>$workspace_dir/package.json
        echo "    \"url\": \"https://github.com/AssetVal/Schema.git\"" >>$workspace_dir/package.json
        echo "  }," >>$workspace_dir/package.json
        echo "  \"browserslist\": [" >>$workspace_dir/package.json
        echo "    \"last 2 version\"," >>$workspace_dir/package.json
        echo "    \"> 1%\"" >>$workspace_dir/package.json
        echo "  ]," >>$workspace_dir/package.json
        echo "  \"license\": \"MIT\"," >>$workspace_dir/package.json
        echo "  \"packageManager\": \"yarn@4.4.0\"," >>$workspace_dir/package.json
        echo "  \"version\": \"0.0.0\"," >>$workspace_dir/package.json
        echo "  \"unbuild\": {" >>$workspace_dir/package.json
        echo "    \"rollup\": {" >>$workspace_dir/package.json
        echo "      \"esbuild\": {" >>$workspace_dir/package.json
        echo "        \"tsconfigRaw\": {" >>$workspace_dir/package.json
        echo "          \"extends\": \"@assetval/confs\"," >>$workspace_dir/package.json
        echo "          \"compilerOptions\": {" >>$workspace_dir/package.json
        echo "            \"outDir\": \"dist\"," >>$workspace_dir/package.json
        echo "            \"rootDir\": \"src\"," >>$workspace_dir/package.json
        echo "            \"declaration\": true," >>$workspace_dir/package.json
        echo "            \"experimentalDecorators\": true," >>$workspace_dir/package.json
        echo "            \"target\": \"ES2022\"" >>$workspace_dir/package.json
        echo "          }," >>$workspace_dir/package.json
        echo "          \"include\": [" >>$workspace_dir/package.json
        echo "            \"./src/**/*.ts\"" >>$workspace_dir/package.json
        echo "          ]" >>$workspace_dir/package.json
        echo "        }" >>$workspace_dir/package.json
        echo "      }" >>$workspace_dir/package.json
        echo "    }" >>$workspace_dir/package.json
        echo "  }" >>$workspace_dir/package.json
        echo "}" >>$workspace_dir/package.json
    else
        echo "$workspace_dir/package.json -- Would have been created"
    end

    # Create src directory
    if not $dry_run
        mkdir -p $workspace_dir/src
    else
        echo "$workspace_dir/src -- Would have been created"
    end

    # Create src/$workspace_name.ts
    if not $dry_run
        touch $workspace_dir/src/$workspace_name.ts
    else
        echo "$workspace_dir/src/$workspace_name.ts -- Would have been created"
    end

    # Create a README.md
    if not $dry_run
        set lowercase_workspace_name (string lower $workspace_name)
        touch $workspace_dir/README.md
        echo "# $workspace_name" >$workspace_dir/README.md
        echo "" >>$workspace_dir/README.md
        echo "This is the Veritas $workspace_name Schema workspace." >>$workspace_dir/README.md
        echo "" >>$workspace_dir/README.md
        echo "## Installation" >>$workspace_dir/README.md
        echo "" >>$workspace_dir/README.md
        echo "```sh" >>$workspace_dir/README.md
        echo "yarn add @assetval/$lowercase_workspace_name" >>$workspace_dir/README.md
        echo "```" >>$workspace_dir/README.md
        echo "" >>$workspace_dir/README.md
        echo "## Usage" >>$workspace_dir/README.md
        echo "" >>$workspace_dir/README.md
        echo "### As a Class (Front End)" >>$workspace_dir/README.md
        echo "" >>$workspace_dir/README.md
        echo "```ts" >>$workspace_dir/README.md
        echo "import { $workspace_name } from '@assetval/$lowercase_workspace_name';" >>$workspace_dir/README.md
        echo "" >>$workspace_dir/README.md
        echo "const $lowercase_workspace_name = new $workspace_name();" >>$workspace_dir/README.md
        echo "```" >>$workspace_dir/README.md
        echo "" >>$workspace_dir/README.md
        echo "### As Schema (Back End)" >>$workspace_dir/README.md
        echo "" >>$workspace_dir/README.md
        echo "```ts" >>$workspace_dir/README.md
        echo "import { {$workspace_name}Schema, $workspace_name } from '@assetval/$lowercase_workspace_name';" >>$workspace_dir/README.md
        echo "import { Model } from 'mongoose';" >>$workspace_dir/README.md
        echo "" >>$workspace_dir/README.md
        echo "export const {$workspace_name}Model = model<$workspace_name>('{$lowercase_workspace_name}es', {$workspace_name}Schema);" >>$workspace_dir/README.md
        echo "```" >>$workspace_dir/README.md
        echo "" >>$workspace_dir/README.md
        echo "### As Validation (Back End)" >>$workspace_dir/README.md
        echo "" >>$workspace_dir/README.md
        echo "```ts" >>$workspace_dir/README.md
        echo "import { {$workspace_name}ValidationSchema } from '@assetval/$lowercase_workspace_name';" >>$workspace_dir/README.md
        echo "import { z } from 'zod';" >>$workspace_dir/README.md
        echo "import { MagikRoutes } from '../middleware/RouterManager.js';" >>$workspace_dir/README.md
        echo "" >>$workspace_dir/README.md
        echo "const ProfileRoute = MagikRoutes.getRouter('/profile');" >>$workspace_dir/README.md
        echo "" >>$workspace_dir/README.md
        echo "ProfileRoute.post('/update$workspace_name', {" >>$workspace_dir/README.md
        echo "  auth: 'ensureAuthenticated'," >>$workspace_dir/README.md
        echo "  validationSchema: z.object({" >>$workspace_dir/README.md
        echo "    body: {$workspace_name}ValidationSchema" >>$workspace_dir/README.md
        echo "  })," >>$workspace_dir/README.md
        echo "  route: async (req, res): Promise<void> => {" >>$workspace_dir/README.md
        echo "    // Do something" >>$workspace_dir/README.md
        echo "  }" >>$workspace_dir/README.md
        echo "});" >>$workspace_dir/README.md
        echo "```" >>$workspace_dir/README.md
        echo "" >>$workspace_dir/README.md
        echo "## License" >>$workspace_dir/README.md
        echo "" >>$workspace_dir/README.md
        echo MIT >>$workspace_dir/README.md
        echo "" >>$workspace_dir/README.md
        echo "## Authors" >>$workspace_dir/README.md
        echo "" >>$workspace_dir/README.md
        echo "- [Abourass](https://github.com/Abourass)" >>$workspace_dir/README.md
        echo "" >>$workspace_dir/README.md
        echo "## Contributing" >>$workspace_dir/README.md
        echo "" >>$workspace_dir/README.md
        echo "Download the Schema repository and make sure you have the following installed:" >>$workspace_dir/README.md
        echo "" >>$workspace_dir/README.md
        echo "- asdf" >>$workspace_dir/README.md
        echo "- NodeJS (ASDF)" >>$workspace_dir/README.md
        echo "- Yarn (Corepack / Node / ASDF)" >>$workspace_dir/README.md
        echo "- moonrepo" >>$workspace_dir/README.md
        echo "- git-chglog (ASDF)" >>$workspace_dir/README.md
        echo "" >>$workspace_dir/README.md
        echo "Then run the following commands:" >>$workspace_dir/README.md
        echo "" >>$workspace_dir/README.md
        echo "```sh" >>$workspace_dir/README.md
        echo "yarn install" >>$workspace_dir/README.md
        echo "```" >>$workspace_dir/README.md
    else
        echo "$workspace_dir/README.md -- Would have been created"
    end

    # Copy the LICENSE file
    if not $dry_run
        cp LICENSE $workspace_dir/LICENSE
    else
        echo "$workspace_dir/LICENSE -- Would have been copied over"
    end

    # Create a moon.yml
    if not $dry_run
        set lowercase_workspace_name (string lower $workspace_name)
        touch $workspace_dir/moon.yml
        echo "type: \"library\"" >$workspace_dir/moon.yml
        echo "language: \"typescript\"" >>$workspace_dir/moon.yml
        echo "" >>$workspace_dir/moon.yml
        echo "project:" >>$workspace_dir/moon.yml
        echo "  name: \"@assetval/$lowercase_workspace_name\"" >>$workspace_dir/moon.yml
        echo "  description: \"$workspace_name Schema\"" >>$workspace_dir/moon.yml
        echo "  channel: \"#veritas-progress\"" >>$workspace_dir/moon.yml
        echo "  maintainers: [\"abourass\"]" >>$workspace_dir/moon.yml
    else
        echo "$workspace_dir/moon.yml -- Would have been created"
    end

    # Create a vitest.config.ts
    if not $dry_run
        touch $workspace_dir/vitest.config.ts
        echo "import { Config } from 'vitest';" >$workspace_dir/vitest.config.ts
        echo "" >>$workspace_dir/vitest.config.ts
        echo "const config: Config = {" >>$workspace_dir/vitest.config.ts
        echo "  testMatch: ['**/*.test.ts']," >>$workspace_dir/vitest.config.ts
        echo "  coverage: true," >>$workspace_dir/vitest.config.ts
        echo "};" >>$workspace_dir/vitest.config.ts
        echo "" >>$workspace_dir/vitest.config.ts
        echo "export default config;" >>$workspace_dir/vitest.config.ts
    else
        echo "$workspace_dir/vitest.config.ts -- Would have been created"
    end

    # Create a tsconfig.json
    if not $dry_run
        touch $workspace_dir/tsconfig.json
        echo "{" >$workspace_dir/tsconfig.json
        echo "  \"extends\": \"@assetval/confs\"," >>$workspace_dir/tsconfig.json
        echo "  \"compilerOptions\": {" >>$workspace_dir/tsconfig.json
        echo "    \"composite\": false," >>$workspace_dir/tsconfig.json
        echo "    \"outDir\": \"dist\"," >>$workspace_dir/tsconfig.json
        echo "    \"rootDir\": \"src\"," >>$workspace_dir/tsconfig.json
        echo "    \"declaration\": true," >>$workspace_dir/tsconfig.json
        echo "    \"experimentalDecorators\": true," >>$workspace_dir/tsconfig.json
        echo "    \"target\": \"ES2022\"" >>$workspace_dir/tsconfig.json
        echo "  }," >>$workspace_dir/tsconfig.json
        echo "  \"include\": [\"src/**/*.ts\"]" >>$workspace_dir/tsconfig.json
        echo "}" >>$workspace_dir/tsconfig.json
    else
        echo "$workspace_dir/tsconfig.json -- Would have been created"
    end

    # Update root tsconfig.json to add reference
    if not $dry_run
        jq --arg path "packages/$workspace_name" '.references += [{"path": $path}]' tsconfig.json >tsconfig.tmp.json && mv tsconfig.tmp.json tsconfig.json
    else
        echo "tsconfig.json -- Would have been updated with an `packages/$workspace_name` reference"
    end

    # Install dependencies
    if not $dry_run
        yarn install
    else
        echo "Dependencies would have been updated/installed"
    end

    if $dry_run
        echo "Dry run complete. No changes were made."
    else
        echo "Workspace $workspace_name created successfully."
    end
end
