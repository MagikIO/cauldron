# `env2json`

## Overview

[`env2json`](../../functions/env2json.fish) is a utility script that converts the current environment variables into a JSON file. This script is particularly useful for capturing the state of environment variables at a given point in time and saving them in a structured format that can be easily shared, reviewed, or archived.

## Features

- **Convert Environment Variables to JSON**: Collects all current environment variables and outputs them into a JSON file.
- **Custom Output Location**: Allows specifying a custom file path for the output JSON file.
- **Force Overwrite**: Provides an option to forcefully overwrite the output file if it already exists.
- **Backup Option**: Offers the ability to backup the existing output file before overwriting.
- **Verbose Output**: Can print the generated JSON file to the console after saving.
- **Debug Mode**: Includes a debug mode for additional output during execution.

## Version

- **Version:** 1.0.0

## Synopsis

```shell
env2json [options]
```

### Options

- `-v`, `--version`: Displays the version of the `env2json` script.
- `-h`, `--help`: Shows the help message with usage instructions and options.
- `-V`, `--verbose`: After saving the JSON file, prints its contents to the console.
- `-o`, `--output`: Specifies the path and filename for the output JSON file. If not provided, defaults to `$CAULDRON_PATH/user/env.json`.
- `-f`, `--force`: Forces the script to overwrite the output file if it already exists, without prompting for confirmation.
- `-b`, `--backup`: Before overwriting an existing output file, creates a backup of the file.
- `-d`, `--debug`: Enables debug mode, providing additional output for troubleshooting.

### Examples

- **Basic Usage**: Convert environment variables to JSON and save to the default location.

  ```shell
  env2json
  ```

- **Custom Output File**: Save the environment variables to a specified file.

  ```shell
  env2json -o ~/Documents/my_envs.json
  ```

- **Verbose Output**: Save the environment variables and print the JSON content.

  ```shell
  env2json -V
  ```

- **Force Overwrite**: Overwrite the output file if it exists, without confirmation.

  ```shell
  env2json -f -o ~/Documents/my_envs.json
  ```

- **Backup and Overwrite**: Backup the existing file before overwriting.

  ```shell
  env2json -b -o ~/Documents/my_envs.json
  ```
