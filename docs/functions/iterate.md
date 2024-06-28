# `iterate`

[`iterate`](../../functions/iterate.fish) is designed to advance your npm package version, generate a changelog, commit these changes, and publish the updated package. It automates the process of version bumping, changelog generation, and package publishing, making it easier to manage npm package releases.

## Version

- **Version:** 1.0.0

## Synopsis

```shell
iterate [options]
```

## Options

- `-h`, `--help`: Display this help message.
- `-v`, `--version`: Display the version of the function.

## Description

The `iterate.fish` function streamlines the process of updating your npm package. It checks for the presence of a `package.json` file to ensure that it operates within a Node.js project. It also checks for a `cliff.toml` file, which is necessary for generating changelogs using `git cliff`. If a `cliff.toml` file is not found, it prompts the user to create one. This function handles version bumping, changelog generation, and package publishing in a cohesive workflow.

### 🚀 Workflow

1. **Version Bumping**: Automatically bumps the package version based on the specified version type (major, minor, patch).
2. **Changelog Generation**: Utilizes `git cliff` to generate or update the `CHANGELOG.md` file based on commit messages.
3. **Commit Changes**: Commits the updated `CHANGELOG.md` file to the repository.
4. **Publish Package**: Publishes the updated package to npm with public access.

### 📝 Changelog Management

To manage changelogs, `iterate.fish` relies on `git cliff`, a tool that generates changelogs from Git metadata. If a `cliff.toml` configuration file is not present, the function offers to create one for future use.

### 🔄 Publishing

After updating the version and changelog, `iterate.fish` commits these changes and pushes them to the repository. It then publishes the updated package to npm, ensuring that your package is always up-to-date.

## Examples

To run `iterate` with default options:

```shell
iterate
```

This will bump the version, generate/update the changelog, commit these changes, and publish the package.
