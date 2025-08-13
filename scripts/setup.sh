#!/bin/bash

# =================================
# 🚀 NestJS API Starter Kit - Setup Script
# =================================
# This script performs initial project setup
# Run with: npm run setup

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_header() {
    echo -e "\n${BLUE}🔵 $1${NC}"
    echo "======================================"
}

# Detect package manager
detect_package_manager() {
    # Use our detection script
    if [ -f "scripts/detect-pm.js" ]; then
        PACKAGE_MANAGER_INFO=$(node scripts/detect-pm.js)
        PACKAGE_MANAGER=$(echo "$PACKAGE_MANAGER_INFO" | grep -o '"pm": *"[^"]*"' | cut -d'"' -f4)
        PACKAGE_COMMAND=$(echo "$PACKAGE_MANAGER_INFO" | grep -o '"command": *"[^"]*"' | cut -d'"' -f4)
    else
        # Fallback detection
        if command -v bun &> /dev/null && [ -f "bun.lockb" ]; then
            PACKAGE_MANAGER="bun"
            PACKAGE_COMMAND="bun"
        elif command -v pnpm &> /dev/null && [ -f "pnpm-lock.yaml" ]; then
            PACKAGE_MANAGER="pnpm"
            PACKAGE_COMMAND="pnpm"
        elif command -v yarn &> /dev/null && [ -f "yarn.lock" ]; then
            PACKAGE_MANAGER="yarn"
            PACKAGE_COMMAND="yarn"
        else
            PACKAGE_MANAGER="npm"
            PACKAGE_COMMAND="npm"
        fi
    fi
    
    log_success "Detected package manager: $PACKAGE_MANAGER"
}

# Check prerequisites
check_prerequisites() {
    log_header "Checking Prerequisites"
    
    # Check Node.js version
    if ! command -v node &> /dev/null; then
        log_error "Node.js is not installed. Please install Node.js 20.0.0 or later."
        exit 1
    fi
    
    NODE_VERSION=$(node --version | cut -d'v' -f2)
    REQUIRED_VERSION="20.0.0"
    
    # Simple version comparison (works for most cases)
    if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$NODE_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
        log_warning "Node.js version $NODE_VERSION detected. Required: $REQUIRED_VERSION or later."
        log_warning "Please update Node.js for NestJS v11.x compatibility."
    else
        log_success "Node.js version $NODE_VERSION detected"
    fi
    
    # Detect and validate package manager
    detect_package_manager
    
    # Check if detected package manager is available
    if ! command -v "$PACKAGE_COMMAND" &> /dev/null; then
        log_error "$PACKAGE_MANAGER is not installed or not available in PATH."
        exit 1
    fi
    
    PACKAGE_VERSION=$($PACKAGE_COMMAND --version 2>/dev/null | head -n1)
    log_success "$PACKAGE_MANAGER version $PACKAGE_VERSION detected"
    
    # Check if Docker is available (optional)
    if command -v docker &> /dev/null; then
        DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
        log_success "Docker version $DOCKER_VERSION detected"
        DOCKER_AVAILABLE=true
    else
        log_warning "Docker not found. You can still run the project locally."
        DOCKER_AVAILABLE=false
    fi
    
    # Check if Docker Compose is available
    if command -v docker-compose &> /dev/null || docker compose version &> /dev/null; then
        log_success "Docker Compose detected"
        DOCKER_COMPOSE_AVAILABLE=true
    else
        log_warning "Docker Compose not found. Docker development environment won't be available."
        DOCKER_COMPOSE_AVAILABLE=false
    fi
}

# Install dependencies
install_dependencies() {
    log_header "Installing Dependencies"
    
    log_info "Installing packages using $PACKAGE_MANAGER..."
    
    case $PACKAGE_MANAGER in
        "npm")
            if [ -f "package-lock.json" ]; then
                npm ci
            else
                npm install
            fi
            ;;
        "bun")
            bun install
            ;;
        "pnpm")
            pnpm install
            ;;
        "yarn")
            yarn install
            ;;
        *)
            log_warning "Unknown package manager: $PACKAGE_MANAGER, falling back to npm"
            npm install
            ;;
    esac
    
    log_success "Dependencies installed successfully using $PACKAGE_MANAGER"
}

# Setup environment configuration
setup_environment() {
    log_header "Setting Up Environment Configuration"
    
    if [ ! -f ".env" ]; then
        log_info "Creating .env file from .env.example..."
        cp .env.example .env
        log_success ".env file created"
        log_warning "Please review and update the .env file with your configuration"
    else
        log_info ".env file already exists, skipping creation"
    fi
    
    # Create logs directory
    if [ ! -d "logs" ]; then
        mkdir -p logs
        log_success "Created logs directory"
    fi
}

# Setup git hooks
setup_git_hooks() {
    log_header "Setting Up Git Hooks"
    
    if [ -d ".git" ]; then
        log_info "Installing Husky git hooks..."
        
        case $PACKAGE_MANAGER in
            "npm")
                npx husky install
                ;;
            "bun")
                bunx husky install
                ;;
            "pnpm")
                pnpm exec husky install
                ;;
            "yarn")
                yarn husky install
                ;;
        esac
        
        # Make sure scripts are executable
        if [ -d ".husky" ]; then
            chmod +x .husky/pre-commit 2>/dev/null || true
            chmod +x .husky/commit-msg 2>/dev/null || true
        fi
        
        log_success "Git hooks installed successfully"
    else
        log_warning "Not a git repository, skipping git hooks setup"
    fi
}

# Build the application
build_application() {
    log_header "Building Application"
    
    log_info "Building TypeScript application..."
    
    case $PACKAGE_MANAGER in
        "npm")
            npm run build
            ;;
        "bun")
            bun run build
            ;;
        "pnpm")
            pnpm run build
            ;;
        "yarn")
            yarn build
            ;;
    esac
    
    log_success "Application built successfully"
}

# Get run command for package manager
get_run_command() {
    case $PACKAGE_MANAGER in
        "npm")
            echo "npm run $1"
            ;;
        "bun")
            echo "bun run $1"
            ;;
        "pnpm")
            echo "pnpm run $1"
            ;;
        "yarn")
            echo "yarn $1"
            ;;
    esac
}

# Run tests to verify setup
verify_setup() {
    log_header "Verifying Setup"
    
    log_info "Running linter..."
    $(get_run_command "lint:check")
    log_success "Linting passed"
    
    log_info "Checking code formatting..."
    $(get_run_command "format:check")
    log_success "Code formatting is correct"
    
    log_info "Running unit tests..."
    case $PACKAGE_MANAGER in
        "npm"|"bun"|"pnpm")
            $PACKAGE_COMMAND test
            ;;
        "yarn")
            yarn test
            ;;
    esac
    log_success "Unit tests passed"
    
    log_info "Running security audit..."
    case $PACKAGE_MANAGER in
        "npm")
            npm audit --audit-level moderate
            ;;
        "bun")
            log_info "Bun doesn't have a built-in audit command, skipping security audit..."
            ;;
        "pnpm")
            pnpm audit --audit-level moderate
            ;;
        "yarn")
            yarn audit --level moderate
            ;;
    esac
    log_success "Security audit completed"
}

# Initialize database with user and database from .env
initialize_database() {
    log_info "Initializing database with credentials from .env..."
    
    # Source .env file to get database credentials
    if [ -f ".env" ]; then
        export $(cat .env | grep -E '^(DB_|POSTGRES_)' | xargs)
    fi
    
    # Wait for PostgreSQL to be fully ready
    log_info "Waiting for PostgreSQL to be ready..."
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if docker exec nestjs-postgres pg_isready -h localhost > /dev/null 2>&1; then
            log_success "PostgreSQL is ready!"
            break
        fi
        echo "Attempt $attempt/$max_attempts: Waiting for PostgreSQL..."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    if [ $attempt -gt $max_attempts ]; then
        log_error "PostgreSQL did not become ready in time"
        return 1
    fi
    
    # Create database and user if they don't exist
    log_info "Setting up database user and database..."
    
    # Connect as postgres superuser and create our user/database
    docker exec nestjs-postgres psql -U postgres -c "
        DO \$\$
        BEGIN
            -- Create user if it doesn't exist
            IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '$DB_USERNAME') THEN
                CREATE USER \"$DB_USERNAME\" WITH PASSWORD '$DB_PASSWORD';
            END IF;
            
            -- Create database if it doesn't exist
            IF NOT EXISTS (SELECT FROM pg_database WHERE datname = '$DB_NAME') THEN
                CREATE DATABASE \"$DB_NAME\" OWNER \"$DB_USERNAME\";
            END IF;
            
            -- Grant privileges
            GRANT ALL PRIVILEGES ON DATABASE \"$DB_NAME\" TO \"$DB_USERNAME\";
        END
        \$\$;
    " > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        log_success "Database user '$DB_USERNAME' and database '$DB_NAME' created successfully!"
    else
        log_warning "Database user and database may already exist, continuing..."
    fi
}

# Setup database (optional)
setup_database() {
    log_header "Database Setup"
    
    if [ "$DOCKER_COMPOSE_AVAILABLE" = true ]; then
        read -p "$(echo -e "${YELLOW}Do you want to set up the PostgreSQL database using Docker? (y/N): ${NC}")" -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "Starting PostgreSQL container..."
            docker compose up -d postgres
            
            # Initialize database with .env credentials
            initialize_database
            
            log_info "Running database migrations..."
            $(get_run_command "typeorm:migration:run")
            
            log_success "Database setup completed!"
        else
            log_info "Skipping database setup. You can set it up later with:"
            echo "  docker compose up -d postgres"
            echo "  $(get_run_command "typeorm:migration:run")"
        fi
    else
        log_warning "Docker Compose not available. Please set up PostgreSQL manually."
        log_info "See docs/getting-started.md for manual database setup instructions."
    fi
}

# Show next steps
show_next_steps() {
    log_header "Setup Complete! 🎉"
    
    echo ""
    log_info "Your NestJS API Starter Kit is ready to use with $PACKAGE_MANAGER!"
    echo ""
    log_info "Next steps:"
    echo "  1. Review and update your .env file with your configuration"
    echo "  2. Start the development server:"
    echo ""
    
    if [ "$DOCKER_COMPOSE_AVAILABLE" = true ]; then
        echo -e "     ${GREEN}# With Docker (recommended):${NC}"
        echo "     $(get_run_command "docker:up")"
        echo ""
    fi
    
    echo -e "     ${GREEN}# Or locally:${NC}"
    echo "     $(get_run_command "start:dev")"
    echo ""
    log_info "  3. Open your browser and visit:"
    echo "     - API Health Check: http://localhost:3000/health"
    echo "     - API Info: http://localhost:3000/health/info"
    echo ""
    
    if [ "$DOCKER_COMPOSE_AVAILABLE" = true ]; then
        log_info "  4. Access development tools (when using Docker):"
        echo "     - Adminer (Database UI): http://localhost:8080"
        echo "     - Redis: localhost:6379"
        echo ""
    fi
    
    log_info "  5. Package Manager Commands:"
    echo "     - Install packages: $(get_run_command "add <package>")"
    echo "     - Run tests: $PACKAGE_COMMAND test"
    echo "     - Run linting: $(get_run_command "lint")"
    echo "     - Build project: $(get_run_command "build")"
    echo ""
    
    log_info "  6. Read the documentation:"
    echo "     - Package Managers: PACKAGE-MANAGERS.md"
    echo "     - Quick Start: QUICKSTART.md"  
    echo "     - Adding Endpoints: docs/adding-endpoints.md"
    echo "     - Getting Started: docs/getting-started.md"
    echo "     - Development Guide: docs/development.md"
    echo "     - All Documentation: docs/"
    echo ""
    
    if [ -f "TROUBLESHOOTING.md" ]; then
        log_info "  7. Need help? Check TROUBLESHOOTING.md for common issues."
        echo ""
    fi
    
    log_success "Happy coding with $PACKAGE_MANAGER! 🚀"
}

# Main execution
main() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║         🚀 NestJS API Starter Kit - Setup Script 🚀         ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    
    check_prerequisites
    install_dependencies
    setup_environment
    setup_git_hooks
    build_application
    verify_setup
    setup_database
    show_next_steps
}

# Run main function
main "$@"