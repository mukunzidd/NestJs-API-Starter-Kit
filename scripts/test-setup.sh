#!/bin/bash

# =================================
# 🧪 NestJS API Starter Kit - Test Setup Script
# =================================
# This script sets up the testing environment
# Run with: npm run test-setup

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

# Setup test environment
setup_test_environment() {
    log_header "Setting Up Test Environment"
    
    # Create test environment file if it doesn't exist
    if [ ! -f ".env.test" ]; then
        log_info "Creating .env.test file..."
        cat > .env.test << EOL
NODE_ENV=test
PORT=3001
HOST=0.0.0.0
DB_HOST=localhost
DB_PORT=5433
DB_USERNAME=test_user
DB_PASSWORD=test_password
DB_NAME=nestjs_starter_test
JWT_SECRET=test-jwt-secret-key-for-testing-purposes-only
JWT_EXPIRES_IN=1h
THROTTLE_TTL=60000
THROTTLE_LIMIT=1000
LOG_LEVEL=error
LOG_FORMAT=json
APP_NAME="NestJS Starter Kit Test"
APP_VERSION=1.0.0-test
APP_DESCRIPTION="Test environment for NestJS starter kit"
EOL
        log_success "Test environment file created"
    else
        log_info "Test environment file already exists"
    fi
    
    # Create test directories
    mkdir -p coverage
    mkdir -p coverage-e2e
    mkdir -p test/fixtures
    mkdir -p test/utils
    
    log_success "Test directories created"
}

# Setup test database
setup_test_database() {
    log_header "Setting Up Test Database"
    
    if command -v docker &> /dev/null && command -v docker-compose &> /dev/null; then
        log_info "Starting test database with Docker..."
        
        # Start test database
        docker-compose -f docker-compose.test.yml up -d postgres-test
        
        # Wait for database to be ready
        log_info "Waiting for test database to be ready..."
        sleep 15
        
        # Check if database is accessible
        if command -v pg_isready &> /dev/null; then
            if pg_isready -h localhost -p 5433 -U test_user -d nestjs_starter_test; then
                log_success "Test database is ready"
            else
                log_warning "Test database might not be fully ready yet"
            fi
        else
            log_info "pg_isready not available, assuming database is ready"
        fi
        
        TEST_DB_AVAILABLE=true
    else
        log_warning "Docker not available. Please ensure PostgreSQL test instance is running on port 5433."
        TEST_DB_AVAILABLE=false
    fi
}

# Run test migrations
run_test_migrations() {
    log_header "Setting Up Test Database Schema"
    
    if [ "$TEST_DB_AVAILABLE" = true ]; then
        log_info "Running test database migrations..."
        
        # Set test environment variables
        export NODE_ENV=test
        export DB_HOST=localhost
        export DB_PORT=5433
        export DB_USERNAME=test_user
        export DB_PASSWORD=test_password
        export DB_NAME=nestjs_starter_test
        
        # Check if there are any migrations to run
        if [ -d "src/database/migrations" ] && [ "$(ls -A src/database/migrations)" ]; then
            npm run typeorm:migration:run
            log_success "Test migrations completed"
        else
            log_info "No migrations found, skipping"
        fi
        
        # Reset environment variables
        unset NODE_ENV DB_HOST DB_PORT DB_USERNAME DB_PASSWORD DB_NAME
    else
        log_warning "Test database not available, skipping migrations"
    fi
}

# Create test data and fixtures
create_test_fixtures() {
    log_header "Creating Test Fixtures"
    
    # Create test fixture files
    log_info "Creating test fixtures..."
    
    # Create user fixture
    cat > test/fixtures/users.json << 'EOL'
{
  "validUser": {
    "id": 1,
    "email": "test@example.com",
    "name": "Test User",
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z"
  },
  "invalidUser": {
    "email": "invalid-email",
    "name": ""
  }
}
EOL
    
    # Create API response fixtures
    cat > test/fixtures/api-responses.json << 'EOL'
{
  "healthCheck": {
    "status": "ok",
    "info": {
      "database": {
        "status": "up"
      },
      "memory_heap": {
        "status": "up"
      },
      "memory_rss": {
        "status": "up"
      },
      "storage": {
        "status": "up"
      }
    },
    "error": {},
    "details": {
      "database": {
        "status": "up"
      },
      "memory_heap": {
        "status": "up"
      },
      "memory_rss": {
        "status": "up"
      },
      "storage": {
        "status": "up"
      }
    }
  }
}
EOL
    
    log_success "Test fixtures created"
}

# Setup test utilities
setup_test_utilities() {
    log_header "Setting Up Test Utilities"
    
    # Create test helper utilities
    cat > test/utils/database.ts << 'EOL'
import { DataSource } from 'typeorm';
import { ConfigService } from '@nestjs/config';

export class TestDatabaseManager {
  private dataSource: DataSource;

  constructor(private configService: ConfigService) {}

  async setupDatabase(): Promise<void> {
    // Database setup logic for tests
  }

  async cleanDatabase(): Promise<void> {
    // Database cleanup logic for tests
  }

  async closeConnection(): Promise<void> {
    if (this.dataSource && this.dataSource.isInitialized) {
      await this.dataSource.destroy();
    }
  }
}
EOL
    
    # Create API test utilities
    cat > test/utils/api.ts << 'EOL'
import { INestApplication } from '@nestjs/common';
import * as request from 'supertest';

export class ApiTestHelper {
  constructor(private app: INestApplication) {}

  async get(path: string, expectedStatus = 200) {
    return request(this.app.getHttpServer())
      .get(path)
      .expect(expectedStatus);
  }

  async post(path: string, data: any, expectedStatus = 201) {
    return request(this.app.getHttpServer())
      .post(path)
      .send(data)
      .expect(expectedStatus);
  }

  async put(path: string, data: any, expectedStatus = 200) {
    return request(this.app.getHttpServer())
      .put(path)
      .send(data)
      .expect(expectedStatus);
  }

  async delete(path: string, expectedStatus = 200) {
    return request(this.app.getHttpServer())
      .delete(path)
      .expect(expectedStatus);
  }
}
EOL
    
    log_success "Test utilities created"
}

# Run test suite to verify setup
verify_test_setup() {
    log_header "Verifying Test Setup"
    
    log_info "Running unit tests..."
    npm run test
    log_success "Unit tests passed"
    
    if [ "$TEST_DB_AVAILABLE" = true ]; then
        log_info "Running E2E tests..."
        NODE_ENV=test npm run test:e2e
        log_success "E2E tests passed"
    else
        log_warning "Skipping E2E tests (test database not available)"
    fi
    
    log_info "Generating test coverage report..."
    npm run test:cov
    log_success "Coverage report generated"
}

# Cleanup test environment
cleanup_test_environment() {
    log_header "Cleaning Up Test Environment"
    
    if [ "$TEST_DB_AVAILABLE" = true ]; then
        log_info "Stopping test database..."
        docker-compose -f docker-compose.test.yml down -v
        log_success "Test database stopped and cleaned"
    fi
}

# Show test information
show_test_info() {
    log_header "Test Environment Ready! 🧪"
    
    echo ""
    log_info "Your test environment is ready!"
    echo ""
    log_info "Test commands:"
    echo "  - Run unit tests: npm run test"
    echo "  - Run E2E tests: npm run test:e2e"
    echo "  - Run all tests: npm run test:all"
    echo "  - Run with coverage: npm run test:cov"
    echo "  - Watch mode: npm run test:watch"
    echo ""
    log_info "Test files location:"
    echo "  - Unit tests: src/**/*.spec.ts"
    echo "  - E2E tests: test/e2e/**/*.e2e-spec.ts"
    echo "  - Test fixtures: test/fixtures/"
    echo "  - Test utilities: test/utils/"
    echo ""
    log_info "Coverage reports:"
    echo "  - HTML report: coverage/lcov-report/index.html"
    echo "  - LCOV report: coverage/lcov.info"
    echo ""
    log_info "Docker test commands:"
    echo "  - Run tests in Docker: npm run docker:test"
    echo "  - Start test DB only: docker-compose -f docker-compose.test.yml up -d postgres-test"
    echo "  - Stop test environment: docker-compose -f docker-compose.test.yml down -v"
    echo ""
    
    if [ "$TEST_DB_AVAILABLE" = true ]; then
        log_info "Test database connection:"
        echo "  - Host: localhost"
        echo "  - Port: 5433"
        echo "  - Database: nestjs_starter_test"
        echo "  - Username: test_user"
        echo "  - Password: test_password"
        echo ""
    fi
    
    log_success "Happy testing! 🎯"
}

# Main execution
main() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║      🧪 NestJS API Starter Kit - Test Setup Script 🧪       ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    
    setup_test_environment
    setup_test_database
    run_test_migrations
    create_test_fixtures
    setup_test_utilities
    verify_test_setup
    show_test_info
    
    # Ask if user wants to keep test environment running
    echo ""
    read -p "Keep test database running? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        cleanup_test_environment
    else
        log_info "Test database will continue running for further testing"
    fi
}

# Run main function
main "$@"