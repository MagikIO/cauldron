# `update_git_alias`

## Overview

[`update_git_alias`](../../setup/update_git_alias.fish) is designed to update a Git alias if its definition has changed. If the current definition of the alias matches the new definition provided, the function does nothing. This ensures that your Git configuration remains up-to-date without unnecessary modifications.

## Version

- Version: 1.2.0
- Category: Setup

## Usage

```shell
update_git_alias [OPTIONS] git_alias new_alias_definition
```

- `git_alias`: The name of the Git alias to update.
- `new_alias_definition`: The new definition of the Git alias.

## Options

- `-v`, `--version`: Show the version number of the function.
- `-t`, `--test`: Perform a test run without actually updating the alias. Useful for verifying what changes would be made.
- `-h`, `--help`: Display help information about the `update_git_alias` function.
- `-V`, `--verbose`: Enable verbose output, showing detailed information about the operation.
- `-s`, `--silent`: Suppress all output from the function, making it run quietly.
- `-z`, `--cauldron`: Return the category of the function within the project's organization structure.

## Examples

### Updating an Alias

To update an alias named `co` to a new definition `checkout`:

```shell
update_git_alias co checkout
```

### Test Run

To see what changes would be made when updating an alias without actually applying them:

```shell
update_git_alias -t co checkout
```

### Verbose Output

To update an alias with verbose output enabled:

```shell
update_git_alias -V co checkout
```

## Notes

- The function performs a check to ensure both `git_alias` and `new_alias_definition` are provided. If either is missing, it will return an error.
- If the alias's current definition matches the new definition, the function exits without making any changes, ensuring efficiency.
- The `--test` option is particularly useful for verifying changes before applying them, ensuring that only desired modifications are made to your Git configuration.
