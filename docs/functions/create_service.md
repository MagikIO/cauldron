# `create_service`

[`create_service`](../../functions/create_service.fish) is designed to streamline the creation and enabling of a systemd service file directly from the command line. It encapsulates the process of defining a service, creating its corresponding service file, and integrating it with systemd for automatic management.

## Version

- **Version:** 1.0.0

## Synopsis

```shell
create_service [options]
```

## Options

- `-n`, `--name`: Specify the name of the service. This is a required option.
- `-s`, `--script`: Define the command or script the service will execute. This is a required option.

## Description

The `create_service` function simplifies the process of creating a systemd service file. It requires the user to provide a name and a script or command that the service will execute. The function then automatically generates a service file with predefined settings such as restart policy and runtime maximum execution time, and integrates the service with systemd, enabling it to start at boot or upon command.

### 🛠️ Service File Creation

Upon execution, the function performs the following steps:

1. Validates that the required arguments `-n` (name) and `-s` (script) are provided.
2. Generates a systemd service file with the specified name and script.
3. Sets the service to restart on failure and defines a maximum runtime.
4. Enables the service file, integrating it with systemd for management.

This function is particularly useful for quickly deploying scripts or applications as services on systems that use systemd for service management.

### 🔧 Example Usage

To create and enable a service named `example_service` that executes a script located at `/path/to/script.sh`, use the following command:

```shell
create_service -n example_service -s "/path/to/script.sh"
```

This command will create a systemd service file named `example_service.service`, enable it, and ensure it is managed by systemd, ready to be started or enabled to start at boot.
