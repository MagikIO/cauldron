#!/usr/bin/env fish

function cauldron_tmux --description "Manage TMUX installation and configuration"
    set -l func_version "1.0.0"
    set -l cauldron_category "Functions"

    # Define options
    set -l options "h/help" "v/version" "i/install" "m/modify" "r/remove" "b/backup" "R/restore" "l/list-backups"
    argparse -n cauldron_tmux $options -- $argv

    # Show version
    if set -q _flag_version
        echo "v$func_version"
        return 0
    end

    # Show help
    if set -q _flag_help
        echo "Usage: cauldron_tmux [OPTIONS]"
        echo ""
        echo "Manage TMUX installation and configuration through Cauldron"
        echo ""
        echo "Options:"
        echo "  -h, --help           Show this help message"
        echo "  -v, --version        Show version number"
        echo "  -i, --install        Install TMUX and plugins (TPM)"
        echo "  -m, --modify         Modify TMUX configuration interactively"
        echo "  -r, --remove         Remove TMUX, config files, and plugins"
        echo "  -b, --backup         Backup current TMUX configuration"
        echo "  -R, --restore        Restore TMUX configuration from backup"
        echo "  -l, --list-backups   List available TMUX configuration backups"
        echo ""
        echo "Examples:"
        echo "  cauldron_tmux --install       Install TMUX with default config"
        echo "  cauldron_tmux --modify        Interactively modify TMUX settings"
        echo "  cauldron_tmux --backup        Backup current configuration"
        echo "  cauldron_tmux --remove        Remove TMUX completely"
        return 0
    end

    # Install TMUX
    if set -q _flag_install
        __cauldron_tmux_install
        return $status
    end

    # Modify TMUX config
    if set -q _flag_modify
        __cauldron_tmux_modify
        return $status
    end

    # Remove TMUX
    if set -q _flag_remove
        __cauldron_tmux_remove
        return $status
    end

    # Backup TMUX config
    if set -q _flag_backup
        __cauldron_tmux_backup
        return $status
    end

    # Restore TMUX config
    if set -q _flag_restore
        __cauldron_tmux_restore
        return $status
    end

    # List backups
    if set -q _flag_list_backups
        __cauldron_tmux_list_backups
        return $status
    end

    # If no flags provided, show interactive menu
    __cauldron_tmux_interactive
end

function __cauldron_tmux_interactive --description "Interactive TMUX management menu"
    if not command -q gum
        echo "Error: gum is required for interactive mode" >&2
        return 1
    end

    set -l choice (gum choose \
        "Install TMUX" \
        "Modify Configuration" \
        "Backup Configuration" \
        "Restore Configuration" \
        "List Backups" \
        "Remove TMUX" \
        "Cancel")

    switch $choice
        case "Install TMUX"
            __cauldron_tmux_install
        case "Modify Configuration"
            __cauldron_tmux_modify
        case "Backup Configuration"
            __cauldron_tmux_backup
        case "Restore Configuration"
            __cauldron_tmux_restore
        case "List Backups"
            __cauldron_tmux_list_backups
        case "Remove TMUX"
            __cauldron_tmux_remove
        case "Cancel"
            echo "Cancelled"
            return 0
    end
end

function __cauldron_tmux_install --description "Install TMUX and TPM"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Installing TMUX"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Check if TMUX is already installed
    if command -q tmux
        echo "✓ TMUX is already installed"
        set -l tmux_version (tmux -V | string replace "tmux " "")
        echo "  Version: $tmux_version"
    else
        echo "Installing TMUX..."

        # Detect OS and install
        set -l os (uname -s)
        if test "$os" = "Darwin"
            if command -q brew
                brew install tmux
            else
                echo "Error: Homebrew is required on macOS" >&2
                return 1
            end
        else if test "$os" = "Linux"
            sudo apt update
            sudo apt install tmux -y
        else
            echo "Error: Unsupported operating system" >&2
            return 1
        end

        if command -q tmux
            echo "✓ TMUX installed successfully"
        else
            echo "Error: TMUX installation failed" >&2
            return 1
        end
    end

    # Check if config already exists
    if test -f ~/.tmux.conf
        echo ""
        echo "⚠ TMUX configuration already exists at ~/.tmux.conf"

        if command -q gum
            if gum confirm "Do you want to backup and replace it?"
                __cauldron_tmux_backup
                echo "Creating new configuration..."
            else
                echo "Keeping existing configuration"
                # Skip config creation but continue with TPM
                set -l skip_config true
            end
        else
            read -l -P "Backup and replace? (y/n): " answer
            if test "$answer" = "y"
                __cauldron_tmux_backup
                echo "Creating new configuration..."
            else
                echo "Keeping existing configuration"
                set -l skip_config true
            end
        end
    end

    # Create default TMUX configuration if not skipped
    if not set -q skip_config
        echo ""
        echo "Creating default TMUX configuration..."

        # Create config file using echo
        echo "# Change prefix from C-b to C-Space" > ~/.tmux.conf
        echo "unbind C-b" >> ~/.tmux.conf
        echo "set -g prefix C-Space" >> ~/.tmux.conf
        echo "bind C-Space send-prefix" >> ~/.tmux.conf
        echo "" >> ~/.tmux.conf
        echo "# Create new window in current path" >> ~/.tmux.conf
        echo 'bind c new-window -c "${pane_current_path}"' >> ~/.tmux.conf
        echo "" >> ~/.tmux.conf
        echo "# Quick window switching" >> ~/.tmux.conf
        echo "bind Space last-window" >> ~/.tmux.conf
        echo "" >> ~/.tmux.conf
        echo "# History and settings" >> ~/.tmux.conf
        echo "set -g history-limit 10000" >> ~/.tmux.conf
        echo "set -g set-titles on" >> ~/.tmux.conf
        echo "set -g renumber-windows on" >> ~/.tmux.conf
        echo "set -g mouse on" >> ~/.tmux.conf
        echo "" >> ~/.tmux.conf
        echo "# Split panes using | and -" >> ~/.tmux.conf
        echo 'bind | split-window -h -c "${pane_current_path}"' >> ~/.tmux.conf
        echo 'bind - split-window -v -c "${pane_current_path}"' >> ~/.tmux.conf
        echo "" >> ~/.tmux.conf
        echo "# Reload config" >> ~/.tmux.conf
        echo 'bind r source-file ~/.tmux.conf \; display "Config reloaded!"' >> ~/.tmux.conf
        echo "" >> ~/.tmux.conf
        echo "# List of plugins" >> ~/.tmux.conf
        echo "set -g @plugin 'tmux-plugins/tpm'" >> ~/.tmux.conf
        echo "set -g @plugin 'tmux-plugins/tmux-sensible'" >> ~/.tmux.conf
        echo "set -g @plugin 'tmux-plugins/tmux-resurrect'" >> ~/.tmux.conf
        echo "" >> ~/.tmux.conf
        echo "# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)" >> ~/.tmux.conf
        echo "run '~/.tmux/plugins/tpm/tpm'" >> ~/.tmux.conf

        echo "✓ Configuration created at ~/.tmux.conf"
    end

    # Install TPM (TMUX Plugin Manager)
    echo ""
    if test -d ~/.tmux/plugins/tpm
        echo "✓ TPM (TMUX Plugin Manager) is already installed"
    else
        echo "Installing TPM (TMUX Plugin Manager)..."
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

        if test -d ~/.tmux/plugins/tpm
            echo "✓ TPM installed successfully"
        else
            echo "Error: TPM installation failed" >&2
            return 1
        end
    end

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Installation Complete!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Next steps:"
    echo "  1. Start TMUX: tmux"
    echo "  2. Install plugins: Press Ctrl-Space + I (capital i)"
    echo "  3. Reload config: Press Ctrl-Space + r"
    echo ""

    return 0
end

function __cauldron_tmux_modify --description "Modify TMUX configuration interactively"
    if not test -f ~/.tmux.conf
        echo "Error: No TMUX configuration found at ~/.tmux.conf" >&2
        echo "Run 'cauldron_tmux --install' first" >&2
        return 1
    end

    # Backup before modifying
    __cauldron_tmux_backup

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Modify TMUX Configuration"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    if command -q gum
        set -l action (gum choose \
            "Change prefix key" \
            "Toggle mouse support" \
            "Edit config file" \
            "Add plugin" \
            "Back")

        switch $action
            case "Change prefix key"
                __cauldron_tmux_change_prefix
            case "Toggle mouse support"
                __cauldron_tmux_toggle_mouse
            case "Edit config file"
                $EDITOR ~/.tmux.conf
            case "Add plugin"
                __cauldron_tmux_add_plugin
            case "Back"
                return 0
        end
    else
        # Fallback to simple editor
        $EDITOR ~/.tmux.conf
    end

    echo ""
    echo "✓ Configuration modified"
    echo "  Reload TMUX: tmux source-file ~/.tmux.conf"
end

function __cauldron_tmux_change_prefix --description "Change TMUX prefix key"
    set -l current_prefix (grep "set -g prefix" ~/.tmux.conf | head -n 1 | awk '{print $4}')
    echo "Current prefix: $current_prefix"
    echo ""

    if command -q gum
        set -l new_prefix (gum choose "C-Space" "C-a" "C-b" "C-x")
    else
        echo "Choose prefix key:"
        echo "  1. C-Space (default)"
        echo "  2. C-a"
        echo "  3. C-b (TMUX default)"
        echo "  4. C-x"
        read -l -P "Selection (1-4): " choice

        switch $choice
            case 1
                set new_prefix "C-Space"
            case 2
                set new_prefix "C-a"
            case 3
                set new_prefix "C-b"
            case 4
                set new_prefix "C-x"
            case '*'
                echo "Invalid choice"
                return 1
        end
    end

    # Update config file
    sed -i.bak "s/set -g prefix .*/set -g prefix $new_prefix/" ~/.tmux.conf
    sed -i.bak "s/bind .* send-prefix/bind $new_prefix send-prefix/" ~/.tmux.conf

    echo "✓ Prefix changed to $new_prefix"
end

function __cauldron_tmux_toggle_mouse --description "Toggle TMUX mouse support"
    if grep -q "set -g mouse on" ~/.tmux.conf
        sed -i.bak "s/set -g mouse on/set -g mouse off/" ~/.tmux.conf
        echo "✓ Mouse support disabled"
    else if grep -q "set -g mouse off" ~/.tmux.conf
        sed -i.bak "s/set -g mouse off/set -g mouse on/" ~/.tmux.conf
        echo "✓ Mouse support enabled"
    else
        echo "set -g mouse on" >> ~/.tmux.conf
        echo "✓ Mouse support enabled"
    end
end

function __cauldron_tmux_add_plugin --description "Add a TMUX plugin"
    if command -q gum
        set -l plugin_name (gum input --placeholder "Enter plugin name (e.g., tmux-plugins/tmux-yank)")
    else
        read -l -P "Enter plugin name (e.g., tmux-plugins/tmux-yank): " plugin_name
    end

    if test -z "$plugin_name"
        echo "Error: Plugin name required" >&2
        return 1
    end

    # Add plugin before the TPM initialization line
    sed -i.bak "/run.*tpm\/tpm/i set -g @plugin '$plugin_name'" ~/.tmux.conf

    echo "✓ Plugin '$plugin_name' added"
    echo "  Install it in TMUX with: Ctrl-Space + I"
end

function __cauldron_tmux_backup --description "Backup TMUX configuration"
    if not test -f ~/.tmux.conf
        echo "Error: No TMUX configuration found at ~/.tmux.conf" >&2
        return 1
    end

    # Create backup directory
    set -l backup_dir ~/.config/cauldron/backups/tmux
    if not test -d $backup_dir
        mkdir -p $backup_dir
    end

    # Create timestamped backup
    set -l timestamp (date +%Y%m%d_%H%M%S)
    set -l backup_file "$backup_dir/tmux.conf.$timestamp"

    cp ~/.tmux.conf $backup_file

    # Also backup plugins directory if it exists
    if test -d ~/.tmux
        tar -czf "$backup_dir/tmux_plugins.$timestamp.tar.gz" -C ~ .tmux 2>/dev/null
    end

    echo "✓ Configuration backed up to:"
    echo "  $backup_file"

    if test -f "$backup_dir/tmux_plugins.$timestamp.tar.gz"
        echo "  $backup_dir/tmux_plugins.$timestamp.tar.gz"
    end

    return 0
end

function __cauldron_tmux_restore --description "Restore TMUX configuration from backup"
    set -l backup_dir ~/.config/cauldron/backups/tmux

    if not test -d $backup_dir
        echo "Error: No backups found" >&2
        return 1
    end

    set -l backups (ls -t $backup_dir/tmux.conf.* 2>/dev/null)

    if test (count $backups) -eq 0
        echo "Error: No backups found" >&2
        return 1
    end

    echo "Available backups:"
    echo ""

    set -l idx 1
    for backup in $backups
        set -l timestamp (basename $backup | string replace "tmux.conf." "")
        echo "  $idx. $timestamp"
        set idx (math $idx + 1)
    end

    echo ""
    if command -q gum
        set -l choice (gum input --placeholder "Enter backup number to restore")
    else
        read -l -P "Enter backup number to restore: " choice
    end

    if test -z "$choice"; or test "$choice" -lt 1; or test "$choice" -gt (count $backups)
        echo "Error: Invalid selection" >&2
        return 1
    end

    set -l selected_backup $backups[$choice]

    # Backup current config before restoring
    if test -f ~/.tmux.conf
        cp ~/.tmux.conf ~/.tmux.conf.pre_restore
    end

    # Restore the backup
    cp $selected_backup ~/.tmux.conf

    echo "✓ Configuration restored from backup"
    echo "  Previous config saved to: ~/.tmux.conf.pre_restore"

    # Check if there's a corresponding plugin backup
    set -l backup_timestamp (basename $selected_backup | string replace "tmux.conf." "")
    set -l plugin_backup "$backup_dir/tmux_plugins.$backup_timestamp.tar.gz"

    if test -f $plugin_backup
        if command -q gum
            if gum confirm "Restore plugins directory as well?"
                tar -xzf $plugin_backup -C ~
                echo "✓ Plugins restored"
            end
        else
            read -l -P "Restore plugins directory as well? (y/n): " restore_plugins
            if test "$restore_plugins" = "y"
                tar -xzf $plugin_backup -C ~
                echo "✓ Plugins restored"
            end
        end
    end

    return 0
end

function __cauldron_tmux_list_backups --description "List TMUX configuration backups"
    set -l backup_dir ~/.config/cauldron/backups/tmux

    if not test -d $backup_dir
        echo "No backups found"
        return 0
    end

    set -l backups (ls -t $backup_dir/tmux.conf.* 2>/dev/null)

    if test (count $backups) -eq 0
        echo "No backups found"
        return 0
    end

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  TMUX Configuration Backups"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    for backup in $backups
        set -l timestamp (basename $backup | string replace "tmux.conf." "")
        set -l date (echo $timestamp | string sub -l 8 | string replace -r '(\d{4})(\d{2})(\d{2})' '$1-$2-$3')
        set -l time (echo $timestamp | string sub -s 10 | string replace -r '(\d{2})(\d{2})(\d{2})' '$1:$2:$3')
        set -l size (du -h $backup | awk '{print $1}')

        echo "  • $date $time ($size)"

        # Check if there's a corresponding plugin backup
        set -l plugin_backup "$backup_dir/tmux_plugins.$timestamp.tar.gz"
        if test -f $plugin_backup
            set -l plugin_size (du -h $plugin_backup | awk '{print $1}')
            echo "    └─ Plugins: $plugin_size"
        end
    end

    echo ""
    echo "Total backups: "(count $backups)

    return 0
end

function __cauldron_tmux_remove --description "Remove TMUX installation and configuration"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  ⚠ WARNING: Remove TMUX"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "This will remove:"
    echo "  • TMUX configuration (~/.tmux.conf)"
    echo "  • TMUX plugins directory (~/.tmux)"
    echo "  • TMUX package (if installed via apt/brew)"
    echo ""

    # Confirm removal
    if command -q gum
        if not gum confirm "Are you sure you want to remove TMUX?"
            echo "Cancelled"
            return 0
        end
    else
        read -l -P "Are you sure? (y/n): " confirm
        if test "$confirm" != "y"
            echo "Cancelled"
            return 0
        end
    end

    # Backup before removal
    echo ""
    echo "Creating backup before removal..."
    __cauldron_tmux_backup

    # Remove configuration files
    echo ""
    echo "Removing TMUX configuration..."

    if test -f ~/.tmux.conf
        rm ~/.tmux.conf
        echo "✓ Removed ~/.tmux.conf"
    end

    if test -d ~/.tmux
        rm -rf ~/.tmux
        echo "✓ Removed ~/.tmux directory"
    end

    # Ask about uninstalling the package
    echo ""
    if command -q tmux
        if command -q gum
            if gum confirm "Uninstall TMUX package as well?"
                set remove_package true
            end
        else
            read -l -P "Uninstall TMUX package? (y/n): " answer
            if test "$answer" = "y"
                set remove_package true
            end
        end

        if set -q remove_package
            set -l os (uname -s)
            if test "$os" = "Darwin"
                if command -q brew
                    brew uninstall tmux
                    echo "✓ TMUX uninstalled via Homebrew"
                end
            else if test "$os" = "Linux"
                sudo apt remove tmux -y
                sudo apt autoremove -y
                echo "✓ TMUX uninstalled via apt"
            end
        end
    end

    # Remove fish tmux plugin if it exists
    echo ""
    if test -f ~/.config/fish/conf.d/tmux.fish
        echo "Removing fish tmux plugin..."

        # Try to remove via fisher first
        if command -q fisher
            if grep -q "budimanjojo/tmux.fish" ~/.config/fish/fish_plugins 2>/dev/null
                fisher remove budimanjojo/tmux.fish
                echo "✓ Removed tmux.fish plugin via fisher"
            end
        else
            # Manually remove tmux plugin files
            rm -f ~/.config/fish/conf.d/tmux.fish
            rm -f ~/.config/fish/conf.d/tmux.only.conf
            rm -f ~/.config/fish/conf.d/tmux.extra.conf
            rm -f ~/.config/fish/conf.d/tmux_abbrs.fish
            echo "✓ Removed tmux fish plugin files"
        end
    end

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  TMUX Removal Complete"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Backups are still available at:"
    echo "  ~/.config/cauldron/backups/tmux/"
    echo ""
    echo "Note: You may need to run 'exec fish' to reload your shell"
    echo ""

    return 0
end
