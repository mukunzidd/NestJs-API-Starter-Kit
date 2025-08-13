# Troubleshooting Guide

Common issues and solutions for the NestJS API Starter Kit.

## Database Connection Issues

### Error: `role "nestjs_user" does not exist`

**Problem**: The application can't connect to PostgreSQL because the user
doesn't exist.

**Cause**: Mismatch between your `.env` file credentials and the PostgreSQL
container setup.

**Solutions**:

#### Option 1: Quick Fix (Recommended)

```bash
# Stop and remove the existing PostgreSQL container and volume
docker compose down postgres
docker volume rm nestjs-api-starter-kit_postgres_data  # or your project name

# Start PostgreSQL again (it will recreate with correct credentials)
docker compose up -d postgres

# Wait for PostgreSQL to be ready, then run migrations
sleep 10
npm run typeorm:migration:run  # or your package manager
```

#### Option 2: Reset Everything

```bash
# Stop all services and remove volumes
docker compose down -v

# Start services again
docker compose up -d postgres

# Run migrations
npm run typeorm:migration:run  # or your package manager
```

#### Option 3: Manual Database Setup

```bash
# Connect to the PostgreSQL container
docker compose exec postgres psql -U postgres

# Create user and database manually
CREATE USER nestjs_user WITH PASSWORD 'nestjs_password';
CREATE DATABASE nestjs_starter OWNER nestjs_user;
GRANT ALL PRIVILEGES ON DATABASE nestjs_starter TO nestjs_user;
\q
```

### Error: `Connection terminated unexpectedly`

**Problem**: Can't connect to PostgreSQL at all.

**Solutions**:

1. **Check if PostgreSQL is running**:

   ```bash
   docker compose ps postgres
   # Should show "Up" status
   ```

2. **Check PostgreSQL logs**:

   ```bash
   docker compose logs postgres
   # Look for any error messages
   ```

3. **Restart PostgreSQL**:

   ```bash
   docker compose restart postgres
   sleep 10  # Wait for startup
   ```

4. **Check if port 5432 is available**:
   ```bash
   lsof -i :5432
   # Kill any process using port 5432 if needed
   ```

### Error: `password authentication failed`

**Problem**: Wrong password in your configuration.

**Solution**:

1. Check your `.env` file has the correct password:

   ```bash
   cat .env | grep DB_PASSWORD
   # Should show: DB_PASSWORD=nestjs_password
   ```

2. If it's different, update it:

   ```bash
   # Edit .env file
   DB_PASSWORD=nestjs_password

   # Restart your application
   npm run start:dev  # or your package manager
   ```

## Application Startup Issues

### Error: `Port 3000 already in use`

**Solutions**:

```bash
# Find process using port 3000
lsof -ti:3000

# Kill the process
kill -9 $(lsof -ti:3000)

# Or use a different port
PORT=3001 npm run start:dev
```

### Error: `Cannot find module` or build issues

**Solutions**:

```bash
# Clear dependencies and reinstall
rm -rf node_modules
rm package-lock.json yarn.lock pnpm-lock.yaml bun.lockb  # Remove all lock files
npm install  # or your preferred package manager

# Clear build cache
rm -rf dist
npm run build
```

### Error: `TypeScript compilation errors`

**Solutions**:

```bash
# Check TypeScript version
npm list typescript

# Rebuild
npm run build

# If errors persist, check tsconfig.json
```

## Docker Issues

### Error: `Cannot connect to the Docker daemon`

**Problem**: Docker is not running.

**Solution**: Start Docker Desktop or Docker service.

### Error: `Port is already allocated`

**Solutions**:

```bash
# Stop containers using the port
docker compose down

# Remove all containers (if needed)
docker container prune

# Check what's using the port
docker ps -a
```

### Error: `Volume mount failed`

**Solutions**:

```bash
# On Windows/macOS: Check Docker Desktop file sharing settings
# On Linux: Check file permissions

# Reset volumes
docker compose down -v
docker compose up
```

## Package Manager Issues

### Bun: `bun: command not found`

**Solution**:

```bash
# Install Bun
curl -fsSL https://bun.sh/install | bash
source ~/.bashrc  # or restart terminal
```

### pnpm: `pnpm: command not found`

**Solution**:

```bash
# Install pnpm
npm install -g pnpm
# or
curl -fsSL https://get.pnpm.io/install.sh | sh -
```

### Different lock files causing conflicts

**Solution**:

```bash
# Choose one package manager and remove other lock files
rm package-lock.json yarn.lock pnpm-lock.yaml bun.lockb  # Remove all
npm install  # Then install with your chosen package manager
```

## Development Issues

### Hot reload not working

**Solutions**:

1. **Check file watching limits (Linux)**:

   ```bash
   echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
   sudo sysctl -p
   ```

2. **Restart development server**:
   ```bash
   # Stop with Ctrl+C, then restart
   npm run start:dev
   ```

### Environment variables not loading

**Solutions**:

1. **Check .env file location**: Must be in project root
2. **Check .env file syntax**: No spaces around `=`
3. **Restart application** after changing .env
4. **Check if .env is in .gitignore** (it should be)

## Testing Issues

### Tests failing with database connection

**Solution**:

```bash
# Make sure test database is configured differently
# Check test/.env or use separate test database
DB_NAME=nestjs_starter_test npm run test:e2e
```

### Jest memory issues

**Solution**:

```bash
# Increase Node.js memory
NODE_OPTIONS="--max-old-space-size=4096" npm test
```

## Getting Help

If these solutions don't work:

1. **Check logs carefully** for specific error messages
2. **Search existing issues** in the repository
3. **Create a new issue** with:
   - Your operating system
   - Node.js version (`node --version`)
   - Package manager and version
   - Complete error message
   - Steps to reproduce

## Quick Diagnostic Commands

```bash
# Check versions
node --version
npm --version  # or bun --version, pnpm --version, yarn --version
docker --version
docker compose version

# Check service status
docker compose ps

# Check logs
docker compose logs postgres
docker compose logs api

# Check environment
cat .env | grep DB_

# Test database connection
docker compose exec postgres psql -U nestjs_user -d nestjs_starter -c "SELECT version();"

# Check API health
curl http://localhost:3000/health/live
```

## Environment Reset (Nuclear Option)

If everything is broken:

```bash
# Stop everything
docker compose down -v

# Clean Docker
docker system prune -a

# Clean Node
rm -rf node_modules
rm package-lock.json yarn.lock pnpm-lock.yaml bun.lockb

# Fresh start
cp .env.example .env
npm install
docker compose up -d postgres
sleep 10
npm run typeorm:migration:run
npm run start:dev
```
