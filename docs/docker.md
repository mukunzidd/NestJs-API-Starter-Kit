# Docker Guide

This guide covers Docker usage for the NestJS API Starter Kit, including
development, testing, and production deployments. The project includes
comprehensive Docker configuration for consistent environments across all
stages.

## Table of Contents

- [Docker Overview](#docker-overview)
- [Docker Architecture](#docker-architecture)
- [Development with Docker](#development-with-docker)
- [Production Deployment](#production-deployment)
- [Docker Compose Services](#docker-compose-services)
- [Multi-stage Dockerfile](#multi-stage-dockerfile)
- [Environment Configuration](#environment-configuration)
- [Data Persistence](#data-persistence)
- [Networking](#networking)
- [Health Checks](#health-checks)
- [Performance Optimization](#performance-optimization)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

## Docker Overview

### Why Docker?

Docker provides several advantages for this NestJS application:

- **Consistency**: Same environment across development, testing, and production
- **Isolation**: Dependencies and services are containerized
- **Scalability**: Easy horizontal scaling with orchestration
- **Development Speed**: Quick setup without installing dependencies locally
- **CI/CD Integration**: Consistent build and deployment process

### Prerequisites

Ensure you have the following installed:

```bash
# Check Docker version
docker --version
# Should be 20.0.0 or higher

# Check Docker Compose version
docker compose version
# Should be 2.0.0 or higher
```

**Installation:**

- **macOS**:
  [Docker Desktop for Mac](https://docs.docker.com/desktop/mac/install/)
- **Windows**:
  [Docker Desktop for Windows](https://docs.docker.com/desktop/windows/install/)
- **Linux**: [Docker Engine](https://docs.docker.com/engine/install/)

## Docker Architecture

### Container Strategy

The project uses a multi-container architecture:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   NestJS API    │────│   PostgreSQL    │    │     Redis       │
│   (Port 3000)   │    │   (Port 5432)   │    │   (Port 6379)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │     Adminer     │
                    │   (Port 8080)   │
                    └─────────────────┘
```

### Image Strategy

- **Development**: Multi-stage build with development dependencies
- **Production**: Optimized image with only runtime dependencies
- **Testing**: Separate test environment with test database

## Development with Docker

### Quick Start

```bash
# Clone the repository
git clone <repository-url>
cd nestjs-api-starter-kit

# Start all development services
docker compose up

# Or run in background
docker compose up -d

# View logs
docker compose logs -f api
```

### Development Workflow

1. **Initial Setup**

   ```bash
   # Build and start services
   docker compose up --build

   # Run database migrations
   docker compose exec api npm run typeorm:migration:run

   # Seed the database
   docker compose exec api npm run db:seed
   ```

2. **Daily Development**

   ```bash
   # Start services
   docker compose up -d

   # Make code changes (hot reload is enabled)
   # Your changes will be reflected automatically

   # View API logs
   docker compose logs -f api

   # Execute commands in container
   docker compose exec api npm run lint
   docker compose exec api npm test
   ```

3. **Development Commands**

   ```bash
   # Install new dependencies
   docker compose exec api npm install <package-name>
   docker compose restart api  # Restart to pick up new dependencies

   # Run database operations
   docker compose exec api npm run typeorm:migration:generate -- -n NewMigration
   docker compose exec api npm run typeorm:migration:run

   # Access database
   docker compose exec postgres psql -U nestjs_user -d nestjs_starter

   # Shell access
   docker compose exec api sh
   ```

### Hot Reloading

Development mode includes hot reloading through volume mounting:

```yaml
# docker-compose.yml (development)
volumes:
  - .:/usr/src/app # Mount source code
  - /usr/src/app/node_modules # Preserve node_modules
  - nestjs_logs:/usr/src/app/logs
```

**Benefits:**

- Instant reflection of code changes
- No need to rebuild images during development
- Preserves installed node_modules

### Development Tools Integration

```bash
# VS Code with Docker
# Install "Dev Containers" extension
# Open Command Palette > "Dev Containers: Open Folder in Container"

# Debug in Docker
docker compose -f docker-compose.yml -f docker-compose.debug.yml up

# Run tests in Docker
docker compose exec api npm run test:all
```

## Production Deployment

### Production Image Build

```bash
# Build production image
docker build --target production -t nestjs-api:latest .

# Or use npm script
npm run docker:build

# Test production image locally
docker run -p 3000:3000 --env-file .env.production nestjs-api:latest
```

### Production Docker Compose

```yaml
# docker-compose.production.yml
version: '3.8'

services:
  api:
    image: nestjs-api:latest
    restart: unless-stopped
    environment:
      NODE_ENV: production
    ports:
      - '3000:3000'
    depends_on:
      - postgres
    healthcheck:
      test: ['CMD', 'curl', '-f', 'http://localhost:3000/health/live']
      interval: 30s
      timeout: 10s
      retries: 3

  postgres:
    image: postgres:16-alpine
    restart: unless-stopped
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USERNAME}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - '5432:5432'

volumes:
  postgres_data:
```

### Container Orchestration

**Docker Swarm:**

```bash
# Initialize swarm
docker swarm init

# Deploy stack
docker stack deploy -c docker-compose.production.yml nestjs-app

# Scale services
docker service scale nestjs-app_api=3
```

**Kubernetes Deployment:**

```yaml
# k8s/deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nestjs-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nestjs-api
  template:
    metadata:
      labels:
        app: nestjs-api
    spec:
      containers:
        - name: api
          image: nestjs-api:latest
          ports:
            - containerPort: 3000
          env:
            - name: NODE_ENV
              value: 'production'
            - name: DB_HOST
              value: 'postgres-service'
          livenessProbe:
            httpGet:
              path: /health/live
              port: 3000
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /health/ready
              port: 3000
            initialDelaySeconds: 5
            periodSeconds: 5
```

## Docker Compose Services

### API Service

```yaml
api:
  build:
    context: .
    target: development
  container_name: nestjs-api
  restart: unless-stopped
  ports:
    - '3000:3000'
  environment:
    - NODE_ENV=development
    - DB_HOST=postgres
  volumes:
    - .:/usr/src/app
    - /usr/src/app/node_modules
    - nestjs_logs:/usr/src/app/logs
  depends_on:
    postgres:
      condition: service_healthy
  networks:
    - nestjs-network
```

### PostgreSQL Service

```yaml
postgres:
  image: postgres:16-alpine
  container_name: nestjs-postgres
  restart: unless-stopped
  environment:
    - POSTGRES_DB=nestjs_starter
    - POSTGRES_USER=nestjs_user
    - POSTGRES_PASSWORD=nestjs_password
  ports:
    - '5432:5432'
  volumes:
    - postgres_data:/var/lib/postgresql/data
    - ./scripts/init-db.sql:/docker-entrypoint-initdb.d/init-db.sql:ro
  networks:
    - nestjs-network
  healthcheck:
    test: ['CMD-SHELL', 'pg_isready -U nestjs_user -d nestjs_starter']
    interval: 10s
    timeout: 5s
    retries: 5
    start_period: 10s
```

### Redis Service

```yaml
redis:
  image: redis:7-alpine
  container_name: nestjs-redis
  restart: unless-stopped
  ports:
    - '6379:6379'
  volumes:
    - redis_data:/data
  networks:
    - nestjs-network
  healthcheck:
    test: ['CMD', 'redis-cli', 'ping']
    interval: 10s
    timeout: 5s
    retries: 5
    start_period: 10s
  command: redis-server --appendonly yes
```

### Adminer Service

```yaml
adminer:
  image: adminer:4.8.1
  container_name: nestjs-adminer
  restart: unless-stopped
  ports:
    - '8080:8080'
  environment:
    - ADMINER_DEFAULT_SERVER=postgres
    - ADMINER_DESIGN=pepa-linha
  depends_on:
    postgres:
      condition: service_healthy
  networks:
    - nestjs-network
```

## Multi-stage Dockerfile

### Complete Dockerfile Analysis

```dockerfile
# Stage 1: Development
FROM node:20-alpine AS development

WORKDIR /usr/src/app

# Install system dependencies
RUN apk add --no-cache dumb-init curl && rm -rf /var/cache/apk/*

# Copy package files
COPY package*.json ./

# Install development dependencies
RUN npm ci --only=development

# Copy source code
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nestjs -u 1001 && \
    chown -R nestjs:nodejs /usr/src/app

USER nestjs

EXPOSE 3000

ENTRYPOINT ["dumb-init", "--"]
CMD ["npm", "run", "start:dev"]

# Stage 2: Build
FROM node:20-alpine AS build

WORKDIR /usr/src/app

# Install build dependencies
RUN apk add --no-cache python3 make g++ && rm -rf /var/cache/apk/*

# Copy package files and configs
COPY package*.json tsconfig*.json nest-cli.json ./

# Install all dependencies
RUN npm ci --include=dev

# Copy source code
COPY src/ ./src/

# Build application
RUN npm run build

# Install production dependencies
RUN npm ci --only=production --ignore-scripts && npm cache clean --force

# Stage 3: Production
FROM node:20-alpine AS production

# Install runtime dependencies
RUN apk add --no-cache dumb-init curl && rm -rf /var/cache/apk/*

WORKDIR /usr/src/app

# Create non-root user
RUN addgroup -g 1001 -S nodejs && adduser -S nestjs -u 1001

# Copy from build stage
COPY --from=build --chown=nestjs:nodejs /usr/src/app/dist ./dist
COPY --from=build --chown=nestjs:nodejs /usr/src/app/node_modules ./node_modules
COPY --from=build --chown=nestjs:nodejs /usr/src/app/package*.json ./

# Create logs directory
RUN mkdir -p /usr/src/app/logs && chown nestjs:nodejs /usr/src/app/logs

USER nestjs

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health/live || exit 1

ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/main.js"]
```

### Stage Explanations

1. **Development Stage**
   - Includes development dependencies
   - Enables hot reloading
   - Suitable for local development

2. **Build Stage**
   - Compiles TypeScript to JavaScript
   - Installs production dependencies
   - Optimizes for build process

3. **Production Stage**
   - Minimal runtime image
   - Only production dependencies
   - Security-hardened

## Environment Configuration

### Environment-specific Compose Files

```bash
# Development (default)
docker compose up

# Testing
docker compose -f docker-compose.yml -f docker-compose.test.yml up

# Production
docker compose -f docker-compose.production.yml up

# Override specific services
docker compose -f docker-compose.yml -f docker-compose.override.yml up
```

### Environment Variables

```yaml
# .env.docker
NODE_ENV=development
PORT=3000
HOST=0.0.0.0

# Database
DB_HOST=postgres  # Service name in Docker network
DB_PORT=5432
DB_USERNAME=nestjs_user
DB_PASSWORD=nestjs_password
DB_NAME=nestjs_starter

# Redis
REDIS_HOST=redis  # Service name in Docker network
REDIS_PORT=6379

# Application
JWT_SECRET=your-super-secret-jwt-key
LOG_LEVEL=info
```

### Secrets Management

**Docker Secrets (Swarm mode):**

```yaml
services:
  api:
    secrets:
      - db_password
      - jwt_secret

secrets:
  db_password:
    external: true
  jwt_secret:
    external: true
```

**Environment File Security:**

```bash
# Never commit .env files with real secrets
echo ".env*" >> .gitignore

# Use different env files per environment
docker compose --env-file .env.production up
```

## Data Persistence

### Volume Types

1. **Named Volumes** (Recommended)

   ```yaml
   volumes:
     postgres_data:
       driver: local
   ```

2. **Bind Mounts** (Development)

   ```yaml
   volumes:
     - ./data:/var/lib/postgresql/data
   ```

3. **Anonymous Volumes**
   ```yaml
   volumes:
     - /var/lib/postgresql/data
   ```

### Backup and Restore

```bash
# Backup database
docker compose exec postgres pg_dump -U nestjs_user nestjs_starter > backup.sql

# Backup with Docker volume
docker run --rm -v nestjs_postgres_data:/data -v $(pwd):/backup alpine \
  tar czf /backup/postgres_backup.tar.gz -C /data .

# Restore database
docker compose exec -T postgres psql -U nestjs_user nestjs_starter < backup.sql

# Restore volume
docker run --rm -v nestjs_postgres_data:/data -v $(pwd):/backup alpine \
  tar xzf /backup/postgres_backup.tar.gz -C /data
```

### Data Migration

```bash
# Migrate data between environments
docker compose exec api npm run typeorm:migration:run

# Export data for migration
docker compose exec postgres pg_dump -U nestjs_user --data-only nestjs_starter > data_export.sql
```

## Networking

### Custom Networks

```yaml
networks:
  nestjs-network:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 172.20.0.0/16
```

### Service Discovery

Services can communicate using service names:

```typescript
// Database connection in container
const connection = {
  host: 'postgres', // Service name, not localhost
  port: 5432,
  username: 'nestjs_user',
  password: 'nestjs_password',
  database: 'nestjs_starter',
};
```

### Port Mapping

```yaml
# Host:Container port mapping
ports:
  - '3000:3000' # API
  - '5432:5432' # PostgreSQL
  - '8080:8080' # Adminer
  - '6379:6379' # Redis
```

### Load Balancing

```yaml
# Using nginx as load balancer
nginx:
  image: nginx:alpine
  ports:
    - '80:80'
  volumes:
    - ./nginx.conf:/etc/nginx/nginx.conf
  depends_on:
    - api
```

```nginx
# nginx.conf
upstream api {
    server nestjs-api-1:3000;
    server nestjs-api-2:3000;
    server nestjs-api-3:3000;
}

server {
    listen 80;
    location / {
        proxy_pass http://api;
    }
}
```

## Health Checks

### Container Health Checks

```yaml
healthcheck:
  test: ['CMD', 'curl', '-f', 'http://localhost:3000/health/live']
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

### Dependency Health Checks

```yaml
depends_on:
  postgres:
    condition: service_healthy
  redis:
    condition: service_healthy
```

### Health Check Scripts

```bash
#!/bin/sh
# health-check.sh
set -e

# Check if application is responding
if ! curl -f http://localhost:3000/health/live; then
    echo "Health check failed"
    exit 1
fi

# Check database connectivity
if ! curl -f http://localhost:3000/health/ready; then
    echo "Database connectivity check failed"
    exit 1
fi

echo "Health check passed"
exit 0
```

## Performance Optimization

### Build Optimization

```dockerfile
# Use multi-stage builds
FROM node:20-alpine AS build
# ... build steps

FROM node:20-alpine AS production
COPY --from=build /usr/src/app/dist ./dist
```

### Layer Caching

```dockerfile
# Copy package.json first for better caching
COPY package*.json ./
RUN npm ci --only=production

# Copy source code after dependencies
COPY . .
RUN npm run build
```

### Resource Limits

```yaml
services:
  api:
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
```

### Image Size Optimization

```dockerfile
# Use Alpine images
FROM node:20-alpine

# Multi-stage builds
FROM node:20-alpine AS build
# ... build steps
FROM node:20-alpine AS production

# Remove unnecessary files
RUN rm -rf /var/cache/apk/* \
    && npm cache clean --force

# Use .dockerignore
# .dockerignore
node_modules
coverage
*.md
.git
```

## Troubleshooting

### Common Issues

1. **Port Already in Use**

   ```bash
   # Find process using port
   lsof -ti:3000

   # Kill process
   kill -9 $(lsof -ti:3000)

   # Or use different port
   docker compose up --scale api=1 -p 3001:3000
   ```

2. **Permission Issues**

   ```bash
   # Fix ownership issues
   sudo chown -R $USER:$USER .

   # Or use user in Dockerfile
   RUN adduser -S nestjs -u 1001
   USER nestjs
   ```

3. **Out of Disk Space**

   ```bash
   # Clean up Docker system
   docker system prune -a

   # Remove unused volumes
   docker volume prune

   # Remove unused images
   docker image prune -a
   ```

4. **Container Won't Start**

   ```bash
   # Check logs
   docker compose logs api

   # Check container status
   docker compose ps

   # Enter container for debugging
   docker compose exec api sh
   ```

### Debugging Commands

```bash
# View container logs
docker compose logs -f api

# Execute commands in running container
docker compose exec api sh

# Check container resource usage
docker stats

# Inspect container configuration
docker compose config

# View network information
docker network ls
docker network inspect nestjs_nestjs-network

# Check volume information
docker volume ls
docker volume inspect nestjs_postgres_data
```

### Database Connection Issues

```bash
# Test database connection
docker compose exec postgres psql -U nestjs_user -d nestjs_starter -c "SELECT version();"

# Check if database is ready
docker compose exec postgres pg_isready -U nestjs_user -d nestjs_starter

# View database logs
docker compose logs postgres
```

## Best Practices

### Security

1. **Use Non-root Users**

   ```dockerfile
   RUN adduser -S nestjs -u 1001
   USER nestjs
   ```

2. **Minimal Base Images**

   ```dockerfile
   FROM node:20-alpine  # Instead of node:20
   ```

3. **Regular Updates**

   ```bash
   # Update base images regularly
   docker compose pull
   docker compose up --build
   ```

4. **Secrets Management**
   ```yaml
   # Use Docker secrets or external secret management
   secrets:
     - db_password
   ```

### Development

1. **Use .dockerignore**

   ```
   node_modules
   coverage
   .git
   *.md
   Dockerfile
   docker-compose*.yml
   ```

2. **Layer Optimization**

   ```dockerfile
   # Copy package.json first
   COPY package*.json ./
   RUN npm ci

   # Copy source code last
   COPY . .
   ```

3. **Health Checks**
   ```yaml
   healthcheck:
     test: ['CMD', 'curl', '-f', 'http://localhost:3000/health/live']
     interval: 30s
   ```

### Production

1. **Resource Limits**

   ```yaml
   deploy:
     resources:
       limits:
         memory: 512M
         cpus: '1.0'
   ```

2. **Restart Policies**

   ```yaml
   restart: unless-stopped
   ```

3. **Logging**
   ```yaml
   logging:
     driver: 'json-file'
     options:
       max-size: '10m'
       max-file: '3'
   ```

### Monitoring

1. **Container Monitoring**

   ```bash
   # Monitor resource usage
   docker stats

   # Monitor logs
   docker compose logs -f --tail=100
   ```

2. **Health Monitoring**

   ```bash
   # Check health status
   docker compose ps

   # Test health endpoints
   curl http://localhost:3000/health/live
   ```

---

This Docker guide provides comprehensive coverage of containerization for the
NestJS API Starter Kit. Following these practices will ensure consistent,
secure, and scalable deployments across all environments.

**Next:** Learn about [Development Tooling](tooling.md) to understand the
integrated development tools and their configuration.
