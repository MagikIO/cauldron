# `dev-it`

[`dev-it`](../../functions/dev-it.fish) is a utility function that allows users to easily to switch packages between development dependencies and main dependencies in a Node.js project

## Version

- **Version:** 1.0.0

## Synopsis

```shell
dev-it [options] [package-name]
```

### Options

- `-v`, `--version`: Displays the current version of the `dev-it` function.
- `-h`, `--help`: Shows the help message, including usage and options.
- `-r`, `--reverse`: Moves the specified package from the development dependencies to the main dependencies.

### Examples

To move a package from the main dependencies to the development dependencies:

```shell
dev-it lodash
```

To move a package from the development dependencies to the main dependencies:

```shell
dev-it -r lodash
```

Using the `-r` or `--reverse` option, this command will move the `lodash` package from the development dependencies to the main dependencies.
