# [`cpfunc`](../functions/cpfunc.fish)

The `cpfunc` function is a utility designed for the Fish shell that simplifies the process of copying Fish functions to the appropriate functions directory and sourcing them. This function is particularly useful for managing custom Fish functions, allowing users to easily distribute and install them.

## Version

- **Version:** 1.3.5

## Synopsis

```shell
cpfunc <path_to_function> [options]
```

## Arguments

- `<path_to_function>`: Specifies the path to the Fish function file or directory containing Fish function files that you want to copy.

## Options

- `-v`, `--version`: Displays the version number of the `cpfunc` function.
- `-h`, `--help`: Shows the help message with usage instructions and options.
- `-d`, `--directory`: Indicates that the provided path is a directory. All Fish function files within this directory will be copied.
- `-g`, `--global`: Installs the function(s) globally by copying them to the global Fish functions directory. Requires administrative privileges.

## Description

`cpfunc.fish` is a function that automates the copying of Fish function files to the Fish functions directory and then sources them. This enables the immediate availability of the copied functions in the current Fish session.

### Examples

- Copy a single function to the local Fish functions directory and source it:

  ```shell
  cpfunc ~/path/to/function.fish
  ```

- Copy all functions from a directory to the local Fish functions directory and source them:

  ```shell
  cpfunc ~/path/to/functions/ -d
  ```

- Copy all functions from a directory to the global Fish functions directory and source them:

  ```shell
  sudo cpfunc ~/path/to/functions/ -d -g
  ```

## Behavior

- If the `-d` flag is provided, `cpfunc` will treat the provided path as a directory and attempt to copy all `.fish` files within it to the appropriate functions directory.
- If the `-g` flag is used, the function(s) will be copied to the global Fish functions directory, making them available to all users on the system. This requires administrative privileges, and generally, SHOULDN'T BE USED!
- If no flags are provided, `cpfunc` assumes the path points to a single Fish function file and will copy it to the local Fish functions directory.
- The function checks if the target script is executable and, if not, makes it executable.
- Upon successful copying, the function sources the copied function file(s) to make them immediately available in the current Fish session.

## Notes

- Ensure that the path to the function or directory is provided before any flags.
- The function will display an error message if the path to the function is not provided or if the path is provided after the flags.
