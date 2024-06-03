#!/usr/bin/env fish

# Create a service file and enable it with systemd
function create_service
    set -l options (fish_opt -s n -l name -r)
    set options $options (fish_opt -s s -l script -r)

    argparse $options -- $argv

    if not set -q _flag_name
        echo "Required argument -n NAME not provided"
        return 1
    end

    if not set -q _flag_script
        echo "Required argument -s SCRIPT not provided"
        return 1
    end

    set service_name $_flag_name
    set script $_flag_s
    set length 7200
    set restart "on-failure"
    set USR (whoami)

    # Define the service file content
    set service_file_content "
[Unit]
Description=%s service

[Service]
Type=simple
ExecStart=/usr/bin/env fish -c '%s'
Restart=%s
RuntimeMaxSec=%s
User=%s

[Install]
WantedBy=default.target"

    echo "Creating service file..."

    sudo fish -c "
        touch /etc/systemd/system/$service_name.service;
        printf '$service_file_content' $service_name $script $restart $length $USR > /etc/systemd/system/$service_name.service;
        systemctl daemon-reload;
        systemctl enable $service_name.service
    "

    echo "Service file created and systemd daemon reloaded."
end
