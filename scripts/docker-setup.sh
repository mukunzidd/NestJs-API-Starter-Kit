#!/bin/bash

# =================================
# 🐳 NestJS API Starter Kit - Docker Setup Script
# =================================
# This script sets up the Docker development environment
# Run with: npm run docker-setup

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

# Check Docker prerequisites
check_docker_prerequisites() {
    log_header "Checking Docker Prerequisites"
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed. Please install Docker Desktop or Docker Engine."
        log_info "Visit: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
    log_success "Docker version $DOCKER_VERSION detected"
    
    # Check if Docker is running
    if ! docker info &> /dev/null; then
        log_error "Docker is not running. Please start Docker Desktop or Docker daemon."
        exit 1
    fi
    
    log_success "Docker is running"
    
    # Check Docker Compose
    if command -v docker-compose &> /dev/null; then
        COMPOSE_VERSION=$(docker-compose --version | cut -d' ' -f3 | cut -d',' -f1)
        log_success "Docker Compose version $COMPOSE_VERSION detected"
        COMPOSE_COMMAND="docker-compose"
    elif docker compose version &> /dev/null; then
        COMPOSE_VERSION=$(docker compose version --short)
        log_success "Docker Compose (plugin) version $COMPOSE_VERSION detected"
        COMPOSE_COMMAND="docker compose"
    else
        log_error "Docker Compose not found. Please install Docker Compose."
        exit 1
    fi
    
    # Check available disk space
    AVAILABLE_SPACE=$(df -h . | awk 'NR==2 {print $4}')
    log_info "Available disk space: $AVAILABLE_SPACE"
    
    # Check if ports are available
    check_port_availability() {
        local port=$1
        local service=$2
        
        if lsof -i :$port &> /dev/null; then
            log_warning "Port $port is already in use (needed for $service)"
            log_info "You may need to stop the service using this port or change the configuration"
        else
            log_success "Port $port is available for $service"
        fi
    }
    
    check_port_availability 3888 "API Server"
    check_port_availability 5432 "PostgreSQL"
    check_port_availability 8080 "Adminer"
    check_port_availability 6379 "Redis"
}

# Build Docker images
build_docker_images() {
    log_header "Building Docker Images"
    
    log_info "Building development image..."
    docker build --target development -t nestjs-api-starter:dev .
    log_success "Development image built successfully"
    
    log_info "Building production image..."
    docker build --target production -t nestjs-api-starter:prod .
    log_success "Production image built successfully"
    
    # Show image sizes
    log_info "Docker image sizes:"
    docker images nestjs-api-starter --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}"
}

# Setup Docker networks and volumes
setup_docker_resources() {
    log_header "Setting Up Docker Resources"
    
    # Create custom network if it doesn't exist
    NETWORK_NAME="nestjs-network"
    if ! docker network ls | grep -q $NETWORK_NAME; then
        log_info "Creating Docker network: $NETWORK_NAME"
        docker network create $NETWORK_NAME
        log_success "Docker network created"
    else
        log_info "Docker network '$NETWORK_NAME' already exists"
    fi
    
    # Create volumes if they don't exist
    VOLUMES=("postgres_data" "redis_data" "nestjs_logs")
    for volume in "${VOLUMES[@]}"; do
        if ! docker volume ls | grep -q $volume; then
            log_info "Creating Docker volume: $volume"
            docker volume create $volume
            log_success "Volume '$volume' created"
        else
            log_info "Docker volume '$volume' already exists"
        fi
    done
}

# Create database initialization script
create_db_init_script() {
    log_header "Creating Database Initialization Script"
    
    cat > scripts/init-db.sql << 'EOL'
-- Database initialization script for NestJS API Starter Kit
-- This script runs when the PostgreSQL container starts for the first time

-- Create extensions that might be useful
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Create additional users if needed
-- CREATE USER app_readonly WITH PASSWORD 'readonly_password';
-- GRANT CONNECT ON DATABASE nestjs_starter TO app_readonly;
-- GRANT USAGE ON SCHEMA public TO app_readonly;
-- GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_readonly;
-- ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO app_readonly;

-- Log initialization
DO $$
BEGIN
    RAISE NOTICE 'NestJS Starter Kit database initialized successfully!';
END $$;
EOL
    
    log_success "Database initialization script created"
}

# Start Docker services
start_docker_services() {
    log_header "Starting Docker Services"
    
    log_info "Starting all services with Docker Compose..."
    $COMPOSE_COMMAND up -d
    
    log_info "Waiting for services to be ready..."
    sleep 15
    
    # Check service status
    check_service_health() {
        local service=$1
        local port=$2
        local max_attempts=30
        local attempt=1
        
        log_info "Checking $service health..."
        
        while [ $attempt -le $max_attempts ]; do
            if [ "$service" = "api" ]; then
                if curl -f http://localhost:$port/api/v1/health/live &> /dev/null; then
                    log_success "$service is healthy"
                    return 0
                fi
            elif [ "$service" = "postgres" ]; then
                if docker exec nestjs-postgres pg_isready -U nestjs_user -d nestjs_starter &> /dev/null; then
                    log_success "$service is healthy"
                    return 0
                fi
            elif [ "$service" = "redis" ]; then
                if docker exec nestjs-redis redis-cli ping | grep -q PONG; then
                    log_success "$service is healthy"
                    return 0
                fi
            fi
            
            sleep 2
            attempt=$((attempt + 1))
        done
        
        log_warning "$service health check timed out"
        return 1
    }
    
    # Wait for database first
    check_service_health "postgres" 5432
    
    # Then check other services
    check_service_health "redis" 6379
    check_service_health "api" 3888
    
    # Show running containers
    log_info "Running containers:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
}

# Run initial database setup
run_database_setup() {
    log_header "Setting Up Database Schema"
    
    log_info "Running database migrations..."
    
    # Wait a bit more for the API to be fully ready
    sleep 5
    
    # Run migrations through the API container
    if docker exec nestjs-api npm run typeorm:migration:run; then
        log_success "Database migrations completed"
    else
        log_warning "Migration command failed (this is normal if no migrations exist yet)"
    fi
    
    # Run seeds if they exist
    if [ -d "src/database/seeds" ] && [ "$(ls -A src/database/seeds)" ]; then
        log_info "Running database seeds..."
        if docker exec nestjs-api npm run db:seed; then
            log_success "Database seeds completed"
        else
            log_warning "Database seeding failed"
        fi
    else
        log_info "No database seeds found, skipping"
    fi
}

# Test Docker setup
test_docker_setup() {
    log_header "Testing Docker Setup"
    
    # Test API endpoints
    log_info "Testing API endpoints..."
    
    # Test health endpoint
    if curl -f http://localhost:3888/api/v1/health &> /dev/null; then
        log_success "Health endpoint is working"
    else
        log_error "Health endpoint is not responding"
        return 1
    fi
    
    # Test info endpoint
    if curl -f http://localhost:3888/api/v1/health/info &> /dev/null; then
        log_success "Info endpoint is working"
    else
        log_warning "Info endpoint is not responding"
    fi
    
    # Test database connection through API
    log_info "Testing database connection through API..."
    HEALTH_RESPONSE=$(curl -s http://localhost:3888/api/v1/health)
    if echo "$HEALTH_RESPONSE" | grep -q '"status":"ok"'; then
        log_success "Database connection is working"
    else
        log_warning "Database connection might have issues"
        echo "Health response: $HEALTH_RESPONSE"
    fi
    
    log_success "Docker setup tests completed"
}

# Show Docker environment information
show_docker_info() {
    log_header "Docker Environment Ready! 🐳"
    
    echo ""
    log_info "Your Docker development environment is ready!"
    echo ""
    log_info "Available services:"
    echo "  - 🚀 API Server: http://localhost:3888"
    echo "  - 📋 Health Check: http://localhost:3888/api/v1/health"
    echo "  - ℹ️  API Info: http://localhost:3888/api/v1/health/info"
    echo "  - 🐘 PostgreSQL: localhost:5432"
    echo "  - 🔗 Adminer (DB UI): http://localhost:8080"
    echo "  - 🔴 Redis: localhost:6379"
    echo ""
    log_info "Docker commands:"
    echo "  - Start services: $COMPOSE_COMMAND up -d"
    echo "  - Stop services: $COMPOSE_COMMAND down"
    echo "  - View logs: $COMPOSE_COMMAND logs -f"
    echo "  - Restart API: $COMPOSE_COMMAND restart api"
    echo "  - Shell into API: docker exec -it nestjs-api sh"
    echo "  - Shell into DB: docker exec -it nestjs-postgres psql -U nestjs_user -d nestjs_starter"
    echo ""
    log_info "Database connection (Adminer):"
    echo "  - System: PostgreSQL"
    echo "  - Server: postgres"
    echo "  - Username: nestjs_user"
    echo "  - Password: nestjs_password"
    echo "  - Database: nestjs_starter"
    echo ""
    log_info "Development workflow:"
    echo "  - Code changes will be automatically reloaded"
    echo "  - Logs are available via: $COMPOSE_COMMAND logs -f api"
    echo "  - Database data persists in Docker volumes"
    echo "  - Use 'npm run docker:down' to stop all services"
    echo ""
    log_success "Happy Docker development! 🎉"
}

# Cleanup function
cleanup_on_error() {
    log_warning "Setup interrupted. Cleaning up..."
    $COMPOSE_COMMAND down &> /dev/null || true
}

# Main execution
main() {
    # Set up error handling
    trap cleanup_on_error ERR INT TERM
    
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║     🐳 NestJS API Starter Kit - Docker Setup Script 🐳      ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    
    check_docker_prerequisites
    build_docker_images
    setup_docker_resources
    create_db_init_script
    start_docker_services
    run_database_setup
    test_docker_setup
    show_docker_info
}

# Run main function
main "$@"