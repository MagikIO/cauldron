# [`fished`](../../functions/fished.fish)

The [`fished`](../../functions/fished.fish) is a utility function for Fish. It lets you quickly open a fish function in your preferred editor, or list your installed fish functions, previewing their code, and letting you open which ever you prefer

## Version

- **Version:** 2.1.0

## Synopsis

```shell
fished [options] [function_name]
```

### Options

- `-v`, `--version`: Display the current version of the `fished` utility.
- `-h`, `--help`: Show help information, including usage and options.
- `-l`, `--list`: List all available Fish functions and allow the user to select one for editing.

### Editing a Function

To edit a specific function, you can directly pass the function name as an argument:

```shell
fished my_function
```

If you're unsure of the function's name or wish to browse available functions, use the `-l` or `--list` option to display a list of functions. You can then select a function from the list to open it in Visual Studio Code:

```shell
fished --list
```
