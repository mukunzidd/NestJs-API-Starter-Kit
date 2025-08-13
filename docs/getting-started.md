# Getting Started Guide

This comprehensive guide will walk you through setting up the NestJS API Starter
Kit from scratch to production-ready development environment.

## Table of Contents

- [System Requirements](#system-requirements)
- [Installation Methods](#installation-methods)
- [Local Development Setup](#local-development-setup)
- [Docker-based Development](#docker-based-development)
- [Database Setup](#database-setup)
- [Environment Configuration](#environment-configuration)
- [Verification](#verification)
- [Common Issues](#common-issues)
- [Next Steps](#next-steps)

## System Requirements

### Required Software

| Software            | Version   | Purpose                                        |
| ------------------- | --------- | ---------------------------------------------- |
| **Node.js**         | ≥20.0.0   | Runtime environment (NestJS v11.x requirement) |
| **Package Manager** | See below | Dependency management                          |
| **Git**             | ≥2.30.0   | Version control                                |

**Package Manager Options (choose one):**

- **npm** ≥10.0.0 (included with Node.js)
- **Bun** ≥1.0.0 ([Install](https://bun.sh/)) - _Fastest_
- **pnpm** ≥8.0.0 ([Install](https://pnpm.io/)) - _Efficient_
- **Yarn** ≥4.0.0 ([Install](https://yarnpkg.com/)) - _Classic_

### Optional Software

| Software           | Version | Purpose                        |
| ------------------ | ------- | ------------------------------ |
| **Docker**         | ≥24.0.0 | Containerization               |
| **Docker Compose** | ≥2.20.0 | Multi-container orchestration  |
| **PostgreSQL**     | ≥12.0   | Database (if not using Docker) |
| **Redis**          | ≥6.0    | Caching (optional)             |

### Development Tools (Recommended)

- **VS Code** with recommended extensions:
  - ESLint
  - Prettier
  - TypeScript
  - Docker
  - PostgreSQL
- **Postman** or **Insomnia** for API testing
- **Git GUI client** (GitKraken, SourceTree, or GitHub Desktop)

## Installation Methods

Choose one of the following installation methods based on your preference:

### Method 1: Direct Clone (Recommended)

```bash
# Clone the repository
git clone https://github.com/your-username/nestjs-api-starter-kit.git
cd nestjs-api-starter-kit

# Install dependencies
npm install
```

### Method 2: Use as Template

1. Click "Use this template" on GitHub
2. Create your repository
3. Clone your new repository
4. Install dependencies

### Method 3: Fork and Clone

```bash
# Fork on GitHub, then clone your fork
git clone https://github.com/your-username/nestjs-api-starter-kit.git
cd nestjs-api-starter-kit

# Add upstream remote
git remote add upstream https://github.com/original-username/nestjs-api-starter-kit.git

# Install dependencies
npm install
```

## Local Development Setup

### Step 1: Install Dependencies

```bash
# Install all dependencies (choose your package manager)
npm install         # npm
# OR
bun install         # bun (fastest)
# OR
pnpm install        # pnpm (efficient)
# OR
yarn install        # yarn

# Verify installation
npm list --depth=0       # npm
# bun pm ls               # bun
# pnpm list --depth=0     # pnpm
# yarn list --depth=0     # yarn
```

### Step 2: Environment Configuration

```bash
# Copy environment template
cp .env.example .env

# Edit environment variables
nano .env  # or use your preferred editor
```

**Required Environment Variables:**

```env
# Application
NODE_ENV=development
PORT=3000
HOST=0.0.0.0

# Database
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=nestjs_user
DB_PASSWORD=nestjs_password
DB_NAME=nestjs_starter

# Security
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production-min-32-chars

# Logging
LOG_LEVEL=info
LOG_FORMAT=json
```

### Step 3: Database Setup (Local PostgreSQL)

If you prefer to run PostgreSQL locally instead of using Docker:

```bash
# Install PostgreSQL (macOS)
brew install postgresql
brew services start postgresql

# Install PostgreSQL (Ubuntu/Debian)
sudo apt-get install postgresql postgresql-contrib
sudo systemctl start postgresql

# Create database and user
sudo -u postgres psql
```

```sql
-- Create database user
CREATE USER nestjs_user WITH PASSWORD 'nestjs_password';

-- Create database
CREATE DATABASE nestjs_starter OWNER nestjs_user;

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE nestjs_starter TO nestjs_user;

-- Exit PostgreSQL
\q
```

### Step 4: Run Migrations and Seeds

```bash
# Run database migrations (use your package manager)
npm run typeorm:migration:run     # npm
# bun run typeorm:migration:run   # bun
# pnpm run typeorm:migration:run  # pnpm
# yarn typeorm:migration:run      # yarn

# Seed the database (optional)
npm run db:seed                   # npm
# bun run db:seed                 # bun
# pnpm run db:seed                # pnpm
# yarn db:seed                    # yarn
```

### Step 5: Start Development Server

```bash
# Start in development mode with hot reload (use your package manager)
npm run start:dev        # npm
# bun run start:dev      # bun
# pnpm run start:dev     # pnpm
# yarn start:dev         # yarn

# Alternative: Start with debug mode
npm run start:debug      # npm
# bun run start:debug    # bun
# pnpm run start:debug   # pnpm
# yarn start:debug       # yarn
```

The API should now be available at `http://localhost:3000`

## Docker-based Development

Docker provides a consistent development environment and eliminates the need to
install PostgreSQL locally.

### Prerequisites

Ensure Docker and Docker Compose are installed:

```bash
# Check Docker installation
docker --version
docker-compose --version

# Should return versions like:
# Docker version 24.0.0
# Docker Compose version 2.20.0
```

### Quick Start with Docker

```bash
# Clone and enter project directory
git clone https://github.com/your-username/nestjs-api-starter-kit.git
cd nestjs-api-starter-kit

# Start all services
docker compose up --build

# Or run in background
docker compose up -d --build
```

This will start:

- **API Server** on port 3000
- **PostgreSQL** on port 5432
- **Adminer** (DB admin) on port 8080
- **Redis** on port 6379

### Docker Development Workflow

```bash
# Start services
docker compose up -d

# View logs
docker compose logs -f api
docker compose logs -f postgres

# Execute commands in running container (use your package manager)
docker compose exec api npm run typeorm:migration:run    # npm
# docker compose exec api bun run typeorm:migration:run  # bun
# docker compose exec api pnpm run typeorm:migration:run # pnpm
# docker compose exec api yarn typeorm:migration:run     # yarn

docker compose exec api npm run db:seed                  # npm
# docker compose exec api bun run db:seed                # bun
# docker compose exec api pnpm run db:seed               # pnpm
# docker compose exec api yarn db:seed                   # yarn

# Stop services
docker compose down

# Stop and remove volumes (clean slate)
docker compose down -v

# Rebuild images
docker compose build --no-cache
```

### Development with Docker Hot Reload

The Docker setup includes volume mounting for hot reload:

```yaml
volumes:
  - .:/usr/src/app # Mount source code
  - /usr/src/app/node_modules # Preserve node_modules
```

Changes to your source code will automatically restart the application.

## Database Setup

### Using Docker Compose (Recommended)

The included Docker Compose configuration automatically sets up PostgreSQL:

```bash
# Start only PostgreSQL
docker compose up -d postgres

# Wait for database to be ready
docker compose logs postgres

# Run migrations (use your package manager)
npm run typeorm:migration:run     # npm
# bun run typeorm:migration:run   # bun
# pnpm run typeorm:migration:run  # pnpm
# yarn typeorm:migration:run      # yarn
```

### Using Local PostgreSQL

If you prefer a local PostgreSQL installation:

1. **Install PostgreSQL** following your OS-specific instructions
2. **Create database** as shown in Step 3 of Local Development Setup
3. **Update `.env`** with your local database credentials
4. **Run migrations** with `npm run typeorm:migration:run`

### Database Management Tools

#### Adminer (Included in Docker)

Access at `http://localhost:8080`:

- **Server**: postgres
- **Username**: nestjs_user
- **Password**: nestjs_password
- **Database**: nestjs_starter

#### Command Line Tools

```bash
# Connect to PostgreSQL in Docker
docker compose exec postgres psql -U nestjs_user -d nestjs_starter

# Run SQL queries
docker compose exec postgres psql -U nestjs_user -d nestjs_starter -c "SELECT version();"

# Backup database
docker compose exec postgres pg_dump -U nestjs_user nestjs_starter > backup.sql

# Restore database
docker compose exec -T postgres psql -U nestjs_user nestjs_starter < backup.sql
```

## Environment Configuration

### Environment Files

The project supports multiple environment files:

```
.env                    # Main environment file (git-ignored)
.env.example           # Template file (committed to repo)
.env.local             # Local overrides (git-ignored)
.env.development       # Development-specific variables
.env.production        # Production-specific variables
.env.test              # Test environment variables
```

### Configuration Hierarchy

Environment variables are loaded in this order (later overrides earlier):

1. System environment variables
2. `.env` file
3. `.env.local` file
4. `.env.{NODE_ENV}` file
5. Command-line variables

### Essential Configuration

```env
# Application Configuration
NODE_ENV=development              # Environment: development/production/test
PORT=3000                        # Server port
HOST=0.0.0.0                     # Server host (0.0.0.0 for Docker)
API_PREFIX=api                   # API URL prefix

# CORS Configuration
CORS_ORIGINS=http://localhost:3000,http://localhost:3001

# Database Configuration
DB_HOST=localhost                # Database host (use 'postgres' for Docker)
DB_PORT=5432                     # Database port
DB_USERNAME=nestjs_user          # Database user
DB_PASSWORD=nestjs_password      # Database password
DB_NAME=nestjs_starter          # Database name

# JWT Configuration (for future auth features)
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production-min-32-chars
JWT_EXPIRES_IN=24h              # Token expiration time

# Rate Limiting
THROTTLE_TTL=60000              # Time window in milliseconds
THROTTLE_LIMIT=100              # Max requests per time window

# Logging Configuration
LOG_LEVEL=info                   # error/warn/info/debug/verbose
LOG_FORMAT=json                  # json/simple

# Application Metadata
APP_NAME=NestJS Starter Kit
APP_VERSION=1.0.0
APP_DESCRIPTION=Production-ready NestJS API starter kit
```

### Configuration Validation

The application validates environment variables on startup using Joi schema.
Invalid configurations will prevent the application from starting with clear
error messages.

### Secrets Management

**For Development:**

- Use `.env` files for local development
- Never commit real secrets to version control
- Use strong, unique secrets for each environment

**For Production:**

- Use environment variables or secret management services
- Consider tools like HashiCorp Vault, AWS Secrets Manager, or Azure Key Vault
- Rotate secrets regularly

## Verification

### Health Checks

Verify your setup by testing the health endpoints:

```bash
# Check if API is running
curl http://localhost:3000/health/live

# Expected response:
# {"status":"ok","info":{"api":{"status":"up"}},"error":{},"details":{"api":{"status":"up"}}}

# Check database connectivity
curl http://localhost:3000/health/ready

# Expected response should include database status
```

### API Testing

```bash
# Test API versioning
curl http://localhost:3000/api/v1/health

# Test with verbose output
curl -v http://localhost:3000/health/live
```

### Browser Testing

Navigate to `http://localhost:3000/health` in your browser to see a detailed
health report.

### Database Connectivity

```bash
# Test database connection (if using Docker)
docker compose exec api npm run typeorm:schema:log      # npm
# docker compose exec api bun run typeorm:schema:log    # bun
# docker compose exec api pnpm run typeorm:schema:log   # pnpm
# docker compose exec api yarn typeorm:schema:log       # yarn

# Should show current database schema without errors
```

## Common Issues

### Port Already in Use

**Error:** `EADDRINUSE: address already in use :::3000`

**Solutions:**

```bash
# Find process using port 3000
lsof -ti:3000

# Kill the process
kill -9 $(lsof -ti:3000)

# Or use a different port (use your package manager)
PORT=3001 npm run start:dev       # npm
# PORT=3001 bun run start:dev     # bun
# PORT=3001 pnpm run start:dev    # pnpm
# PORT=3001 yarn start:dev        # yarn
```

### Database Connection Issues

**Error:** `Connection terminated unexpectedly`

**Solutions:**

1. **Verify PostgreSQL is running:**

   ```bash
   # For Docker
   docker compose ps postgres

   # For local PostgreSQL
   brew services list | grep postgresql  # macOS
   systemctl status postgresql           # Linux
   ```

2. **Check database credentials:**
   - Verify `.env` file has correct database settings
   - Ensure database user has proper permissions

3. **Network connectivity (Docker):**
   ```bash
   # Check Docker network
   docker compose exec api ping postgres
   ```

### Permission Issues

**Error:** `permission denied`

**Solutions:**

```bash
# Fix file permissions
chmod +x scripts/*.sh

# Fix ownership (if needed)
sudo chown -R $USER:$USER .

# For Docker permission issues
docker compose down
docker compose up --build
```

### Node.js Version Issues

**Error:** `error @nestjs/core@10.3.3: The engine "node" is incompatible`

**Solutions:**

```bash
# Check Node.js version
node --version

# Upgrade Node.js (using nvm)
nvm install 18
nvm use 18

# Or install specific version
nvm install 18.19.0
nvm use 18.19.0
```

### Memory Issues

**Error:** `JavaScript heap out of memory`

**Solutions:**

```bash
# Increase Node.js memory limit
export NODE_OPTIONS="--max-old-space-size=4096"

# Or add to package.json scripts
"start:dev": "NODE_OPTIONS='--max-old-space-size=4096' nest start --watch"
```

### Docker Issues

**Error:** Various Docker-related errors

**Solutions:**

```bash
# Clean Docker system
docker system prune -a

# Remove project containers and volumes
docker compose down -v
docker compose rm -f

# Rebuild from scratch
docker compose build --no-cache
docker compose up
```

## Next Steps

Once your development environment is set up successfully:

### 1. Explore the Codebase

- Review the [Project Structure Guide](project-structure.md)
- Examine the health check implementation in `src/health/`
- Look at the configuration setup in `src/config/`

### 2. Development Workflow

- Read the [Development Guide](development.md)
- Set up your IDE with recommended extensions
- Configure debugging in your IDE

### 3. Testing

- Learn about the testing strategy in [Testing Guide](testing.md)
- Run the existing tests: `npm run test:all`
- Write your first test

### 4. Add Features

- Create your first module: `nest g module users`
- Add a controller: `nest g controller users`
- Implement a service: `nest g service users`

### 5. Database

- Learn about TypeORM integration
- Create your first entity
- Generate and run your first migration

### 6. Deployment

- Read the [Deployment Guide](deployment.md) when ready for production
- Set up CI/CD pipelines
- Configure monitoring and logging

## Getting Help

If you encounter issues not covered in this guide:

1. **Check the Documentation:**
   - [Development Guide](development.md)
   - [Troubleshooting Section](#common-issues)
   - [FAQ](faq.md)

2. **Community Support:**
   - GitHub Issues for bug reports
   - GitHub Discussions for questions
   - Stack Overflow with `nestjs` tag

3. **Debugging:**

   ```bash
   # Enable debug logging
   LOG_LEVEL=debug npm run start:dev

   # Check Docker logs
   docker compose logs -f

   # Inspect running containers
   docker compose ps
   docker compose exec api sh
   ```

4. **Validate Your Setup:**

   ```bash
   # Check all environment variables
   npm run start:dev -- --dry-run

   # Validate configuration
   node -e "console.log(require('./src/config/configuration.ts').default())"
   ```

Remember: A properly configured development environment is crucial for
productive development. Take time to set it up correctly, and don't hesitate to
ask for help if you encounter issues.

---

**Next:** Continue with the [Development Guide](development.md) to learn about
the development workflow and best practices.
