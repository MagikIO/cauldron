#!/usr/bin/env bash
# Cauldron Installation Script
# Usage: curl -fsSL https://raw.githubusercontent.com/MagikIO/cauldron/main/install.sh | bash
# Or: bash install.sh

set -e

CAULDRON_REPO="https://github.com/MagikIO/cauldron.git"
CAULDRON_INSTALL_DIR="${CAULDRON_INSTALL_DIR:-$HOME/.cauldron}"
CAULDRON_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/cauldron"
CAULDRON_BRANCH="${CAULDRON_BRANCH:-main}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1"
}

step() {
    echo -e "\n${MAGENTA}➜${NC} ${CYAN}$1${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# Check prerequisites
check_prerequisites() {
    step "Checking prerequisites..."

    local missing_deps=()

    if ! command_exists git; then
        missing_deps+=("git")
    fi

    if ! command_exists fish; then
        missing_deps+=("fish")
    fi

    if ! command_exists sqlite3; then
        missing_deps+=("sqlite3")
    fi

    if [ ${#missing_deps[@]} -ne 0 ]; then
        error "Missing required dependencies: ${missing_deps[*]}"
        echo ""
        echo "Please install the missing dependencies and try again:"
        echo ""

        local os=$(detect_os)

        if [ "$os" = "linux" ]; then
            echo "  sudo apt-get install ${missing_deps[*]}"
        elif [ "$os" = "macos" ]; then
            echo "  brew install ${missing_deps[*]}"
        fi

        exit 1
    fi

    success "All prerequisites installed"
}

# Clone or update repository
setup_repository() {
    step "Setting up Cauldron repository..."

    if [ -d "$CAULDRON_INSTALL_DIR/.git" ]; then
        info "Cauldron already installed at $CAULDRON_INSTALL_DIR"
        info "Updating repository..."

        cd "$CAULDRON_INSTALL_DIR"

        # Stash any local changes
        git stash push -m "Cauldron auto-update stash $(date +%Y%m%d_%H%M%S)" >/dev/null 2>&1 || true

        # Pull latest changes
        if git pull origin "$CAULDRON_BRANCH" --rebase; then
            success "Repository updated"
        else
            warn "Failed to update repository, continuing with existing version"
        fi
    else
        info "Installing Cauldron to $CAULDRON_INSTALL_DIR"

        # Remove directory if it exists but isn't a git repo
        if [ -d "$CAULDRON_INSTALL_DIR" ]; then
            warn "Removing existing non-git directory at $CAULDRON_INSTALL_DIR"
            rm -rf "$CAULDRON_INSTALL_DIR"
        fi

        # Clone repository
        if git clone -b "$CAULDRON_BRANCH" "$CAULDRON_REPO" "$CAULDRON_INSTALL_DIR"; then
            success "Repository cloned"
        else
            error "Failed to clone repository"
            exit 1
        fi

        cd "$CAULDRON_INSTALL_DIR"
    fi
}

# Create directory structure
create_directories() {
    step "Creating directory structure..."

    # Check if config directory is an old-style git repo installation
    if [ -d "$CAULDRON_CONFIG_DIR/.git" ]; then
        warn "Detected old installation format in $CAULDRON_CONFIG_DIR"
        info "Backing up old installation..."

        # Create backup
        local backup_dir="$CAULDRON_CONFIG_DIR.backup.$(date +%s)"
        mv "$CAULDRON_CONFIG_DIR" "$backup_dir"

        success "Old installation backed up to $backup_dir"
        info "You can safely delete this backup after verifying the new installation works"
    fi

    # Create fresh directory structure
    mkdir -p "$CAULDRON_CONFIG_DIR"/{functions,data,tools,backups}

    success "Directory structure created"
}

# Initialize database
initialize_database() {
    step "Initializing database..."

    local db_path="$CAULDRON_CONFIG_DIR/data/cauldron.db"
    local schema_file="$CAULDRON_INSTALL_DIR/data/schema.sql"

    # Create database if it doesn't exist
    if [ ! -f "$db_path" ]; then
        info "Creating new database..."

        if [ -f "$schema_file" ]; then
            sqlite3 "$db_path" < "$schema_file"
            success "Database created"
        else
            error "Schema file not found: $schema_file"
            exit 1
        fi
    else
        info "Database already exists at $db_path"
    fi

    # Copy additional schema files if they don't exist in the database
    if [ -f "$CAULDRON_INSTALL_DIR/data/memory_schema.sql" ]; then
        sqlite3 "$db_path" < "$CAULDRON_INSTALL_DIR/data/memory_schema.sql" 2>/dev/null || true
    fi

    if [ -f "$CAULDRON_INSTALL_DIR/data/proactive_schema.sql" ]; then
        sqlite3 "$db_path" < "$CAULDRON_INSTALL_DIR/data/proactive_schema.sql" 2>/dev/null || true
    fi

    success "Database initialized"
}

# Run migrations
run_migrations() {
    step "Running database migrations..."

    # Set environment variables for Fish
    export CAULDRON_PATH="$CAULDRON_INSTALL_DIR"
    export CAULDRON_DATABASE="$CAULDRON_CONFIG_DIR/data/cauldron.db"

    # Source the migration runner from the installed functions directory
    if fish -c "
        set -gx CAULDRON_PATH '$CAULDRON_INSTALL_DIR'
        set -gx CAULDRON_DATABASE '$CAULDRON_CONFIG_DIR/data/cauldron.db'
        source '$CAULDRON_CONFIG_DIR/functions/__run_migrations.fish'
        __run_migrations
    "; then
        success "Migrations completed"

        # Initialize personality system to ensure all personalities exist
        fish -c "
            set -gx CAULDRON_PATH '$CAULDRON_INSTALL_DIR'
            set -gx CAULDRON_DATABASE '$CAULDRON_CONFIG_DIR/data/cauldron.db'
            source '$CAULDRON_CONFIG_DIR/functions/__init_personality_system.fish'
            source '$CAULDRON_CONFIG_DIR/functions/__ensure_builtin_personalities.fish'
            __init_personality_system
        " 2>/dev/null || true
        success "Personality system initialized"
    else
        warn "Migration runner failed. You may need to run 'cauldron_repair'"
    fi
}

# Copy data files
copy_data_files() {
    step "Copying data files..."

    # Copy JSON configuration files
    cp -f "$CAULDRON_INSTALL_DIR/data/palettes.json" "$CAULDRON_CONFIG_DIR/data/"
    cp -f "$CAULDRON_INSTALL_DIR/data/spinners.json" "$CAULDRON_CONFIG_DIR/data/"

    # Copy cowsay files
    for cow_file in "$CAULDRON_INSTALL_DIR"/data/*.cow; do
        if [ -f "$cow_file" ]; then
            cp -f "$cow_file" "$CAULDRON_CONFIG_DIR/data/"
        fi
    done

    success "Data files copied"
}

# Install Fish functions
install_functions() {
    step "Installing Fish functions..."

    info "Installing from: $CAULDRON_INSTALL_DIR"
    info "Installing to: $CAULDRON_CONFIG_DIR/functions"

    # Copy all function files from all directories
    local function_count=0
    local function_dirs=("alias" "cli" "config" "effects" "functions" "familiar" "internal" "setup" "text" "UI" "update")

    for dir in "${function_dirs[@]}"; do
        info "Checking directory: $dir"
        if [ -d "$CAULDRON_INSTALL_DIR/$dir" ]; then
            local dir_count=0
            for func_file in "$CAULDRON_INSTALL_DIR/$dir"/*.fish; do
                # Skip if no files match (glob didn't expand)
                [ -f "$func_file" ] || continue

                if cp -f "$func_file" "$CAULDRON_CONFIG_DIR/functions/" 2>/dev/null; then
                    function_count=$((function_count + 1))
                    dir_count=$((dir_count + 1))
                else
                    warn "Failed to copy $func_file"
                fi
            done
            if [ $dir_count -gt 0 ]; then
                info "  Copied $dir_count functions from $dir"
            fi
        else
            info "  Directory $dir not found, skipping"
        fi
    done

    # Also copy package-specific functions
    info "Checking packages..."
    if [ -d "$CAULDRON_INSTALL_DIR/packages/asdf" ]; then
        local pkg_count=0
        for func_file in "$CAULDRON_INSTALL_DIR/packages/asdf"/*.fish; do
            [ -f "$func_file" ] || continue
            if cp -f "$func_file" "$CAULDRON_CONFIG_DIR/functions/" 2>/dev/null; then
                function_count=$((function_count + 1))
                pkg_count=$((pkg_count + 1))
            fi
        done
        info "  Copied $pkg_count functions from packages/asdf"
    fi

    if [ -d "$CAULDRON_INSTALL_DIR/packages/nvm" ]; then
        local pkg_count=0
        for func_file in "$CAULDRON_INSTALL_DIR/packages/nvm"/*.fish; do
            [ -f "$func_file" ] || continue
            if cp -f "$func_file" "$CAULDRON_CONFIG_DIR/functions/" 2>/dev/null; then
                function_count=$((function_count + 1))
                pkg_count=$((pkg_count + 1))
            fi
        done
        info "  Copied $pkg_count functions from packages/nvm"
    fi

    if [ -f "$CAULDRON_INSTALL_DIR/packages/choose_packman.fish" ]; then
        if cp -f "$CAULDRON_INSTALL_DIR/packages/choose_packman.fish" "$CAULDRON_CONFIG_DIR/functions/" 2>/dev/null; then
            function_count=$((function_count + 1))
            info "  Copied choose_packman.fish"
        fi
    fi

    if [ $function_count -eq 0 ]; then
        error "No functions were copied!"
        error "Check that $CAULDRON_INSTALL_DIR contains function directories"
        return 1
    fi

    success "Installed $function_count functions"
}

# Setup Fish configuration
setup_fish_config() {
    step "Setting up Fish shell configuration..."

    local fish_config="$HOME/.config/fish/config.fish"

    # Create fish config directory if it doesn't exist
    mkdir -p "$(dirname "$fish_config")"

    # Create config file if it doesn't exist
    if [ ! -f "$fish_config" ]; then
        info "Creating new Fish config file..."
        touch "$fish_config"
    fi

    info "Fish config file: $fish_config"
    info "Install dir: $CAULDRON_INSTALL_DIR"
    info "Config dir: $CAULDRON_CONFIG_DIR"

    # Check if Cauldron is already sourced
    if grep -q "CAULDRON_PATH" "$fish_config" 2>/dev/null; then
        info "Cauldron already configured, updating paths..."

        # Update the CAULDRON_PATH if it's wrong (pointing to config instead of install dir)
        sed -i.bak "s|set -gx CAULDRON_PATH.*|set -gx CAULDRON_PATH \"$CAULDRON_INSTALL_DIR\"|g" "$fish_config"
        sed -i.bak "s|set -gx CAULDRON_DATABASE.*|set -gx CAULDRON_DATABASE \"$CAULDRON_CONFIG_DIR/data/cauldron.db\"|g" "$fish_config"
        sed -i.bak "s|set -gx CAULDRON_PALETTES.*|set -gx CAULDRON_PALETTES \"$CAULDRON_CONFIG_DIR/data/palettes.json\"|g" "$fish_config"
        sed -i.bak "s|set -gx CAULDRON_SPINNERS.*|set -gx CAULDRON_SPINNERS \"$CAULDRON_CONFIG_DIR/data/spinners.json\"|g" "$fish_config"
        sed -i.bak "s|set -gx CAULDRON_INTERNAL_TOOLS.*|set -gx CAULDRON_INTERNAL_TOOLS \"$CAULDRON_INSTALL_DIR/tools\"|g" "$fish_config"

        success "Fish configuration paths updated"
    else
        info "Adding Cauldron to Fish configuration..."

        cat >> "$fish_config" << EOF

# Cauldron - Magik for your terminal
set -gx CAULDRON_PATH "$CAULDRON_INSTALL_DIR"
set -gx CAULDRON_DATABASE "$CAULDRON_CONFIG_DIR/data/cauldron.db"
set -gx CAULDRON_PALETTES "$CAULDRON_CONFIG_DIR/data/palettes.json"
set -gx CAULDRON_SPINNERS "$CAULDRON_CONFIG_DIR/data/spinners.json"
set -gx CAULDRON_INTERNAL_TOOLS "$CAULDRON_INSTALL_DIR/tools"

# Add Cauldron functions to Fish function path
if not contains "$CAULDRON_CONFIG_DIR/functions" \$fish_function_path
    set -gx fish_function_path \$fish_function_path "$CAULDRON_CONFIG_DIR/functions"
end

# Initialize memory system
if type -q __init_memory_system
    __init_memory_system
end

# Initialize personality system
if type -q __init_personality_system
    __init_personality_system
end
EOF

        # Verify the write was successful
        if grep -q "CAULDRON_PATH" "$fish_config" 2>/dev/null; then
            success "Fish configuration updated successfully"
        else
            error "Failed to update Fish configuration"
            error "Please manually add the configuration to $fish_config"
            return 1
        fi
    fi

    # Final verification
    info "Verifying Fish configuration..."
    if grep -q "set -gx CAULDRON_PATH \"$CAULDRON_INSTALL_DIR\"" "$fish_config"; then
        success "✓ CAULDRON_PATH is set correctly"
    else
        warn "⚠ CAULDRON_PATH may not be set correctly"
    fi

    if grep -q "fish_function_path \"$CAULDRON_CONFIG_DIR/functions\"" "$fish_config"; then
        success "✓ Cauldron functions directory is in function path"
    else
        warn "⚠ Cauldron functions directory may not be in function path"
    fi
}

# Install Node.js dependencies
install_node_dependencies() {
    step "Installing Node.js dependencies..."

    cd "$CAULDRON_INSTALL_DIR"

    if command_exists pnpm; then
        info "Using pnpm..."
        # Suppress sqlite3 build errors (optional dependency)
        pnpm install >/dev/null 2>&1 || true
        success "Node dependencies installed"
    elif command_exists npm; then
        info "Using npm..."
        # Suppress sqlite3 build errors (optional dependency)
        npm install >/dev/null 2>&1 || true
        success "Node dependencies installed"
    else
        warn "Neither pnpm nor npm found, skipping Node.js dependencies"
        warn "Some features may not work without Node.js dependencies"
    fi
}

# Install essential tools
install_essential_tools() {
    step "Installing essential tools..."

    # This will be handled by the Fish function once loaded
    info "Essential tools will be installed on first use"
    info "Run 'installs -f \$CAULDRON_PATH/data/dependencies.json' to install all dependencies"
}

# Verify installation
verify_installation() {
    step "Verifying installation..."

    local errors=()

    # Check database
    if [ ! -f "$CAULDRON_CONFIG_DIR/data/cauldron.db" ]; then
        errors+=("Database not found")
    fi

    # Check functions directory
    if [ ! -d "$CAULDRON_CONFIG_DIR/functions" ]; then
        errors+=("Functions directory not found")
    fi

    # Check function count
    local func_count=$(find "$CAULDRON_CONFIG_DIR/functions" -name "*.fish" 2>/dev/null | wc -l)
    if [ "$func_count" -lt 10 ]; then
        errors+=("Too few functions installed (found $func_count)")
    fi

    # Check for critical functions (including familiar functions)
    local critical_functions=("ask.fish" "f-thinks.fish" "f-says.fish" "cauldron_update.fish" "cauldron_repair.fish")
    local missing_functions=()

    for func in "${critical_functions[@]}"; do
        if [ ! -f "$CAULDRON_CONFIG_DIR/functions/$func" ]; then
            missing_functions+=("$func")
        fi
    done

    if [ ${#missing_functions[@]} -ne 0 ]; then
        errors+=("Missing critical functions: ${missing_functions[*]}")
    fi

    # Check data files
    if [ ! -f "$CAULDRON_CONFIG_DIR/data/palettes.json" ]; then
        errors+=("palettes.json not found")
    fi

    if [ ! -f "$CAULDRON_CONFIG_DIR/data/spinners.json" ]; then
        errors+=("spinners.json not found")
    fi

    if [ ${#errors[@]} -ne 0 ]; then
        error "Installation verification failed:"
        for err in "${errors[@]}"; do
            echo "  - $err"
        done
        exit 1
    fi

    success "Installation verified ($func_count functions installed)"
}

# Run user preferences setup wizard
run_setup_wizard() {
    step "Setting up user preferences..."

    # Set environment variables for Fish
    export CAULDRON_PATH="$CAULDRON_INSTALL_DIR"
    export CAULDRON_DATABASE="$CAULDRON_CONFIG_DIR/data/cauldron.db"

    # Check if this is a CI/non-interactive environment
    if [ -n "$CI" ] || [ -n "$CAULDRON_SKIP_SETUP" ] || [ ! -t 0 ]; then
        info "Non-interactive environment detected, skipping setup wizard"
        return 0
    fi

    # Run the setup wizard
    if fish -c "
        set -gx CAULDRON_PATH '$CAULDRON_INSTALL_DIR'
        set -gx CAULDRON_DATABASE '$CAULDRON_CONFIG_DIR/data/cauldron.db'
        source '$CAULDRON_CONFIG_DIR/functions/__cauldron_setup_wizard.fish'
        __cauldron_setup_wizard
    "; then
        success "User preferences configured"
    else
        warn "Setup wizard skipped or failed. You can configure preferences later."
        info "Run 'personality choose' to select a personality"
        info "Run 'familiars' to name your familiar"
    fi
}

# Fix shadowed variables
fix_shadowed_variables() {
    step "Checking for shadowed variables..."

    # Set environment variables for Fish
    export CAULDRON_PATH="$CAULDRON_INSTALL_DIR"
    export CAULDRON_DATABASE="$CAULDRON_CONFIG_DIR/data/cauldron.db"

    # Run the shadowed variables fix
    if fish -c "
        set -gx CAULDRON_PATH '$CAULDRON_INSTALL_DIR'
        set -gx CAULDRON_DATABASE '$CAULDRON_CONFIG_DIR/data/cauldron.db'
        source '$CAULDRON_CONFIG_DIR/functions/__fix_shadowed_variables.fish'
        __fix_shadowed_variables
    " 2>/dev/null; then
        success "Variable scopes verified"
    else
        warn "Unable to check variable scopes. This is not critical."
    fi
}

# Print success message
print_success() {
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                       ║${NC}"
    echo -e "${GREEN}║         ✨  Cauldron installed successfully! ✨       ║${NC}"
    echo -e "${GREEN}║                                                       ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo ""
    echo -e "  1. Restart your terminal or run: ${YELLOW}exec fish${NC}"
    echo -e "  2. Install dependencies: ${YELLOW}installs -f \$CAULDRON_PATH/data/dependencies.json${NC}"
    echo -e "  3. Meet your familiar: ${YELLOW}ask \"Hello, who are you?\"${NC}"
    echo -e "  4. Choose a personality: ${YELLOW}personality list${NC}"
    echo ""
    echo -e "${CYAN}Useful commands:${NC}"
    echo ""
    echo -e "  ${YELLOW}ask${NC}              - Chat with your AI familiar"
    echo -e "  ${YELLOW}personality${NC}      - Manage familiar personalities"
    echo -e "  ${YELLOW}recall${NC}           - View conversation history"
    echo -e "  ${YELLOW}remember${NC}         - Save preferences"
    echo -e "  ${YELLOW}installs${NC}         - Install packages"
    echo -e "  ${YELLOW}hamsa${NC}            - Search code"
    echo ""
    echo -e "${MAGENTA}Documentation:${NC} https://github.com/MagikIO/cauldron${NC}"
    echo ""
}

# Unset all Cauldron variables to ensure clean installation
unset_cauldron_variables() {
    step "Unsetting any existing Cauldron variables..."

    # Use fish to unset universal variables if fish is available
    if command_exists fish; then
        fish -c "
            set -e CAULDRON_PATH 2>/dev/null
            set -e CAULDRON_DATABASE 2>/dev/null
            set -e CAULDRON_PALETTES 2>/dev/null
            set -e CAULDRON_SPINNERS 2>/dev/null
            set -e CAULDRON_INTERNAL_TOOLS 2>/dev/null
            set -e CAULDRON_VERSION 2>/dev/null
            set -e CAULDRON_GIT_REPO 2>/dev/null
            set -e CAULDRON_FAMILIAR 2>/dev/null
            set -e __CAULDRON_DOCUMENTATION_PATH 2>/dev/null
        " 2>/dev/null || true
    fi

    success "Cauldron variables cleared"
}

# Main installation flow
main() {
    echo ""
    echo -e "${MAGENTA}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║                                                       ║${NC}"
    echo -e "${MAGENTA}║              🔮  Cauldron Installation  🔮            ║${NC}"
    echo -e "${MAGENTA}║                                                       ║${NC}"
    echo -e "${MAGENTA}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""

    check_prerequisites
    unset_cauldron_variables # Clear any existing variables first
    setup_repository
    create_directories
    initialize_database
    install_functions      # Install functions BEFORE running migrations
    copy_data_files
    run_migrations        # Run migrations with the installed functions
    setup_fish_config
    install_node_dependencies
    fix_shadowed_variables # Check and fix any shadowed variables
    verify_installation
    run_setup_wizard      # Interactive setup for user preferences
    print_success
}

# Run main installation
main "$@"
