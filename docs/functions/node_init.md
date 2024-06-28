# `node_init`

[`node_init`](../functions/node_init.fish) creates a new Nodejs w/ Typescript project in the folder it's run. It allows setting project details such as name, description, author, scope, and license directly through command-line options, as well as supporting config files for more detailed setups.

## Version

- **Version:** 2.1.0

## Synopsis

```shell
node_init [options]
```

## Options

- `-h`, `--help`: Display this help message.
- `-v`, `--version`: Display the version of the function.
- `-n`, `--name`: Specify the name of the project.
- `-d`, `--description`: Provide a description for the project.
- `-a`, `--author`: Set the author of the project.
- `-s`, `--scope`: Define the scope of the project.
- `-l`, `--license`: Specify the license of the project.
- `-c`, `--config`: Path to a configuration file.
- `-C`, `-create_config`: Generate a configuration file.

## Description

The `node_init.fish` function facilitates the setup of a new Node.js project by automating several initial configurations. It allows setting project details such as name, description, author, scope, and license directly through command-line options. Additionally, it supports specifying a configuration file for more detailed setups.

### 📝 Config Generator

You can create a permanent config file that will be used by default with the following commands:

  ```shell
node_init -C
```

Upon execution, the function checks for a config file then does the following:

- If a config file is found, it reads the file and uses the values to set up the project
- If the user supplied values, those overwrite the values from the config file
- If no config file is found, the function uses the default values
- Creates a `package.json` file with the specified project details
- If the user uses `asdf` for version management, it creates a `.tool-versions` file with the Node.js version the user prefers
- If the user uses yarn for package management, it moves them to the newest version of yarn, creates a `.yarnrc.yml` file with the preferred details, then initialize the yarn project
- Add typescript and lint-golem (as well as their dependencies)
- Create a `tsconfig.json`, `eslint.config.js` file with the default settings
- Create a `.gitignore`, and `.npmignore` file with the default settings
- Create a `README.md`, `CHANGELOG.md`, and `LICENSE` file with the specified details.
- Create a `src`, `test`, and `dist` folder
- Uses the users preferred node-linker to install the dependencies the way the prefer, then additional steps if they need them (for example, if they use pnpm it will add the typescript / vscode sdks)
- Sets up Lint-Golem for them

## Examples

Basic usage

```shell
node_init
```

Initializing a new project with basic details:

```shell
node_init --name "MyProject" --description "A new Node.js project"
```

Using a configuration file for project setup:

```shell
node_init --config path/to/config.json
```

Displaying the version of `node_init`:

```shell
node_init --version
```
