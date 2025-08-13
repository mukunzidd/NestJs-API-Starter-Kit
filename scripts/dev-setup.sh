#!/bin/bash

# =================================
# 🛠️ NestJS API Starter Kit - Development Setup Script
# =================================
# This script sets up the development environment
# Run with: npm run dev-setup

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

# Check if running in development mode
check_environment() {
    log_header "Checking Development Environment"
    
    if [ -f ".env" ]; then
        NODE_ENV=$(grep NODE_ENV .env | cut -d '=' -f2 | tr -d '"' || echo "development")
        if [ "$NODE_ENV" != "development" ]; then
            log_warning "NODE_ENV is set to '$NODE_ENV', expected 'development'"
            log_info "This script is designed for development environment setup"
        fi
        log_success "Environment configuration found"
    else
        log_error ".env file not found. Run 'npm run setup' first."
        exit 1
    fi
}

# Setup development database
setup_dev_database() {
    log_header "Setting Up Development Database"
    
    # Check if Docker is available
    if command -v docker &> /dev/null && command -v docker-compose &> /dev/null; then
        log_info "Starting development database with Docker..."
        docker-compose up -d postgres
        
        # Wait for database to be ready
        log_info "Waiting for database to be ready..."
        sleep 10
        
        # Check if database is accessible
        DB_HOST=$(grep DB_HOST .env | cut -d '=' -f2 | tr -d '"' || echo "localhost")
        DB_PORT=$(grep DB_PORT .env | cut -d '=' -f2 | tr -d '"' || echo "5432")
        DB_USERNAME=$(grep DB_USERNAME .env | cut -d '=' -f2 | tr -d '"' || echo "nestjs_user")
        DB_NAME=$(grep DB_NAME .env | cut -d '=' -f2 | tr -d '"' || echo "nestjs_starter")
        
        if command -v pg_isready &> /dev/null; then
            if pg_isready -h $DB_HOST -p $DB_PORT -U $DB_USERNAME -d $DB_NAME; then
                log_success "Database is ready"
            else
                log_warning "Database might not be fully ready yet"
            fi
        else
            log_info "pg_isready not available, assuming database is ready"
        fi
        
        DATABASE_AVAILABLE=true
    else
        log_warning "Docker not available. Please ensure PostgreSQL is running locally."
        DATABASE_AVAILABLE=false
    fi
}

# Run database migrations
run_migrations() {
    log_header "Running Database Migrations"
    
    if [ "$DATABASE_AVAILABLE" = true ]; then
        log_info "Running database migrations..."
        
        # Check if there are any migrations to run
        if [ -d "src/database/migrations" ] && [ "$(ls -A src/database/migrations)" ]; then
            npm run typeorm:migration:run
            log_success "Migrations completed"
        else
            log_info "No migrations found, skipping"
        fi
    else
        log_warning "Database not available, skipping migrations"
    fi
}

# Seed database with development data
seed_database() {
    log_header "Seeding Development Database"
    
    if [ "$DATABASE_AVAILABLE" = true ]; then
        log_info "Seeding database with development data..."
        
        # Check if seeds exist
        if [ -d "src/database/seeds" ] && [ "$(ls -A src/database/seeds)" ]; then
            npm run db:seed
            log_success "Database seeded successfully"
        else
            log_info "No seeds found, skipping"
        fi
    else
        log_warning "Database not available, skipping seeding"
    fi
}

# Setup development tools
setup_dev_tools() {
    log_header "Setting Up Development Tools"
    
    # Create development directories
    mkdir -p logs
    mkdir -p tmp
    mkdir -p uploads
    
    log_success "Development directories created"
    
    # Install development dependencies if not already installed
    log_info "Ensuring all development dependencies are installed..."
    npm install --only=dev
    log_success "Development dependencies verified"
}

# Start development services
start_dev_services() {
    log_header "Starting Development Services"
    
    if command -v docker-compose &> /dev/null; then
        log_info "Starting all development services with Docker Compose..."
        docker-compose up -d
        
        log_info "Waiting for services to be ready..."
        sleep 15
        
        # Check service health
        log_info "Checking service health..."
        
        # Check PostgreSQL
        if docker-compose ps postgres | grep -q "Up"; then
            log_success "PostgreSQL is running"
        else
            log_warning "PostgreSQL might not be running properly"
        fi
        
        # Check Redis (if enabled)
        if docker-compose ps redis | grep -q "Up"; then
            log_success "Redis is running"
        else
            log_info "Redis not running (optional service)"
        fi
        
        # Check Adminer
        if docker-compose ps adminer | grep -q "Up"; then
            log_success "Adminer is running"
        else
            log_info "Adminer not running (optional service)"
        fi
        
    else
        log_warning "Docker Compose not available. Please start services manually."
    fi
}

# Verify development setup
verify_dev_setup() {
    log_header "Verifying Development Setup"
    
    log_info "Running development tests..."
    
    # Run a quick test to verify everything is working
    NODE_ENV=development npm run test
    log_success "Development tests passed"
    
    # Check if the application can start
    log_info "Testing application startup..."
    timeout 30s npm run start:dev &
    STARTUP_PID=$!
    
    sleep 10
    
    # Check if the process is still running
    if kill -0 $STARTUP_PID 2>/dev/null; then
        log_success "Application started successfully"
        kill $STARTUP_PID
        wait $STARTUP_PID 2>/dev/null || true
    else
        log_error "Application failed to start"
        exit 1
    fi
}

# Show development information
show_dev_info() {
    log_header "Development Environment Ready! 🎉"
    
    echo ""
    log_info "Your development environment is ready!"
    echo ""
    log_info "Available services:"
    echo "  - API Server: http://localhost:3000"
    echo "  - Health Check: http://localhost:3000/health"
    echo "  - API Info: http://localhost:3000/health/info"
    
    if command -v docker-compose &> /dev/null; then
        echo "  - Database (PostgreSQL): localhost:5432"
        echo "  - Database UI (Adminer): http://localhost:8080"
        echo "  - Cache (Redis): localhost:6379"
    fi
    
    echo ""
    log_info "Development commands:"
    echo "  - Start dev server: npm run start:dev"
    echo "  - Run tests: npm run test:watch"
    echo "  - Run E2E tests: npm run test:e2e"
    echo "  - Lint code: npm run lint"
    echo "  - Format code: npm run format"
    echo ""
    log_info "Docker commands:"
    echo "  - Start all services: npm run docker:up"
    echo "  - Stop all services: npm run docker:down"
    echo "  - View logs: docker-compose logs -f"
    echo "  - Restart services: docker-compose restart"
    echo ""
    log_info "Database commands:"
    echo "  - Run migrations: npm run typeorm:migration:run"
    echo "  - Generate migration: npm run typeorm:migration:generate"
    echo "  - Seed database: npm run db:seed"
    echo ""
    log_success "Happy developing! 🚀"
}

# Main execution
main() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║      🛠️  NestJS API Starter Kit - Dev Setup Script 🛠️       ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    
    check_environment
    setup_dev_database
    run_migrations
    seed_database
    setup_dev_tools
    start_dev_services
    verify_dev_setup
    show_dev_info
}

# Run main function
main "$@"