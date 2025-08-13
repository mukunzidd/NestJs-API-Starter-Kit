# Environment Variables Guide

This guide provides comprehensive documentation for all environment variables
used in the NestJS API Starter Kit, including their purposes, default values,
validation rules, and configuration examples.

## Table of Contents

- [Configuration Overview](#configuration-overview)
- [Variable Categories](#variable-categories)
- [Environment Files](#environment-files)
- [Application Configuration](#application-configuration)
- [Database Configuration](#database-configuration)
- [Authentication & Security](#authentication--security)
- [Logging Configuration](#logging-configuration)
- [Rate Limiting](#rate-limiting)
- [External Services](#external-services)
- [Development Settings](#development-settings)
- [Production Settings](#production-settings)
- [Validation Schema](#validation-schema)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Configuration Overview

The NestJS API Starter Kit uses a hierarchical configuration system with
environment variables validated using Joi schema. Configuration is loaded in the
following order (later values override earlier ones):

1. **Default values** (in configuration files)
2. **Environment files** (`.env`, `.env.local`, etc.)
3. **System environment variables**
4. **Command-line overrides**

### Configuration Architecture

```
Environment Variables
        ↓
    Joi Validation
        ↓
    ConfigService
        ↓
    Application Modules
```

## Variable Categories

### Quick Reference

| Category          | Variables                        | Purpose               |
| ----------------- | -------------------------------- | --------------------- |
| **Application**   | `NODE_ENV`, `PORT`, `HOST`       | Core app settings     |
| **Database**      | `DB_HOST`, `DB_PORT`, `DB_*`     | Database connection   |
| **Security**      | `JWT_SECRET`, `CORS_ORIGINS`     | Authentication & CORS |
| **Logging**       | `LOG_LEVEL`, `LOG_FORMAT`        | Logging configuration |
| **Rate Limiting** | `THROTTLE_TTL`, `THROTTLE_LIMIT` | API rate limiting     |
| **Metadata**      | `APP_NAME`, `APP_VERSION`        | Application metadata  |

## Environment Files

### File Structure

```
.env                    # Main environment file (git-ignored)
.env.example           # Template file (committed)
.env.local             # Local overrides (git-ignored)
.env.development       # Development-specific (committed)
.env.production        # Production-specific (committed)
.env.test              # Test environment (committed)
```

### File Priority

Environment files are loaded in this order:

1. `.env`
2. `.env.local`
3. `.env.{NODE_ENV}`
4. `.env.{NODE_ENV}.local`

### Example .env File

```bash
# ======================
# APPLICATION SETTINGS
# ======================
NODE_ENV=development
PORT=3000
HOST=0.0.0.0
API_PREFIX=api

# ======================
# CORS CONFIGURATION
# ======================
CORS_ORIGINS=http://localhost:3000,http://localhost:3001

# ======================
# DATABASE CONFIGURATION
# ======================
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=nestjs_user
DB_PASSWORD=nestjs_password
DB_NAME=nestjs_starter

# ======================
# JWT AUTHENTICATION
# ======================
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production-min-32-chars
JWT_EXPIRES_IN=24h

# ======================
# RATE LIMITING
# ======================
THROTTLE_TTL=60000
THROTTLE_LIMIT=100

# ======================
# LOGGING CONFIGURATION
# ======================
LOG_LEVEL=info
LOG_FORMAT=json

# ======================
# APPLICATION METADATA
# ======================
APP_NAME=NestJS Starter Kit
APP_VERSION=1.0.0
APP_DESCRIPTION=Production-ready NestJS API starter kit
```

## Application Configuration

### Core Application Variables

#### NODE_ENV

- **Purpose**: Defines the application environment
- **Type**: `string`
- **Valid Values**: `development`, `production`, `test`
- **Default**: `development`
- **Required**: Yes

```bash
NODE_ENV=development  # Development mode
NODE_ENV=production   # Production mode
NODE_ENV=test         # Test mode
```

**Impact:**

- **Development**: Enables debug features, hot reload, detailed logging
- **Production**: Optimized performance, minimal logging, error handling
- **Test**: Special test database, mocked services, test-specific behavior

#### PORT

- **Purpose**: HTTP server port
- **Type**: `number`
- **Range**: `1024-65535`
- **Default**: `3000`
- **Required**: No

```bash
PORT=3000             # Default port
PORT=8080             # Alternative port
PORT=80               # HTTP port (requires root/privileges)
PORT=443              # HTTPS port (requires root/privileges)
```

#### HOST

- **Purpose**: Server bind address
- **Type**: `string`
- **Default**: `0.0.0.0`
- **Required**: No

```bash
HOST=0.0.0.0          # Bind to all interfaces (Docker/production)
HOST=localhost        # Local development only
HOST=127.0.0.1        # IPv4 localhost
```

#### API_PREFIX

- **Purpose**: Global API route prefix
- **Type**: `string`
- **Default**: `api`
- **Required**: No

```bash
API_PREFIX=api        # URLs: /api/v1/users
API_PREFIX=v1         # URLs: /v1/users
API_PREFIX=           # URLs: /users (no prefix)
```

## Database Configuration

### PostgreSQL Connection Variables

#### DB_HOST

- **Purpose**: Database server hostname
- **Type**: `string`
- **Default**: `localhost`
- **Required**: Yes

```bash
DB_HOST=localhost            # Local development
DB_HOST=postgres             # Docker service name
DB_HOST=db.example.com       # Remote database server
DB_HOST=127.0.0.1           # IP address
```

#### DB_PORT

- **Purpose**: Database server port
- **Type**: `number`
- **Default**: `5432`
- **Required**: No

```bash
DB_PORT=5432                 # Default PostgreSQL port
DB_PORT=5433                 # Alternative port
```

#### DB_USERNAME

- **Purpose**: Database username
- **Type**: `string`
- **Default**: None
- **Required**: Yes

```bash
DB_USERNAME=nestjs_user      # Application user
DB_USERNAME=postgres         # Default PostgreSQL user
DB_USERNAME=app_readonly     # Read-only user
```

#### DB_PASSWORD

- **Purpose**: Database password
- **Type**: `string`
- **Default**: None
- **Required**: Yes
- **Security**: Must be strong in production

```bash
DB_PASSWORD=nestjs_password  # Development password
DB_PASSWORD=super_secure_password_2024  # Production password
```

#### DB_NAME

- **Purpose**: Database name
- **Type**: `string`
- **Default**: None
- **Required**: Yes

```bash
DB_NAME=nestjs_starter       # Main database
DB_NAME=nestjs_test          # Test database
DB_NAME=app_production       # Production database
```

### Advanced Database Settings

#### DB_SSL

- **Purpose**: Enable SSL connection
- **Type**: `boolean`
- **Default**: `false`
- **Required**: No

```bash
DB_SSL=false                 # No SSL (development)
DB_SSL=true                  # Enable SSL (production)
```

#### DB_LOGGING

- **Purpose**: Enable query logging
- **Type**: `boolean`
- **Default**: `false`
- **Required**: No

```bash
DB_LOGGING=false             # No query logging
DB_LOGGING=true              # Log all queries (debug)
```

#### DB_SYNCHRONIZE

- **Purpose**: Auto-sync database schema
- **Type**: `boolean`
- **Default**: `false`
- **Required**: No
- **Warning**: Never use in production

```bash
DB_SYNCHRONIZE=false         # Use migrations (recommended)
DB_SYNCHRONIZE=true          # Auto-sync (development only)
```

## Authentication & Security

### JWT Configuration

#### JWT_SECRET

- **Purpose**: JWT signing secret
- **Type**: `string`
- **Minimum Length**: 32 characters
- **Default**: None
- **Required**: Yes
- **Security**: Critical - must be unique per environment

```bash
# Development (example only)
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production-min-32-chars

# Production (generate unique secret)
JWT_SECRET=$(openssl rand -base64 32)
JWT_SECRET=A7x9K2m5P8q3W6e1R4t7Y0u2I5o8P1a3S6d9F2g5H8j1K4m7N0q3T6w9E2r5T8y1
```

**Generation Methods:**

```bash
# Using OpenSSL
openssl rand -base64 32

# Using Node.js
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"

# Using online generator (not recommended for production)
```

#### JWT_EXPIRES_IN

- **Purpose**: JWT token expiration time
- **Type**: `string`
- **Format**: Time string (e.g., "1h", "7d", "30m")
- **Default**: `24h`
- **Required**: No

```bash
JWT_EXPIRES_IN=1h            # 1 hour
JWT_EXPIRES_IN=24h           # 24 hours (default)
JWT_EXPIRES_IN=7d            # 7 days
JWT_EXPIRES_IN=30m           # 30 minutes
JWT_EXPIRES_IN=3600          # 3600 seconds (1 hour)
```

### CORS Configuration

#### CORS_ORIGINS

- **Purpose**: Allowed origins for CORS requests
- **Type**: `string`
- **Format**: Comma-separated URLs
- **Default**: `http://localhost:3000`
- **Required**: No

```bash
# Single origin
CORS_ORIGINS=http://localhost:3000

# Multiple origins
CORS_ORIGINS=http://localhost:3000,http://localhost:3001,https://myapp.com

# All origins (development only - NOT recommended for production)
CORS_ORIGINS=*

# Subdomain wildcards
CORS_ORIGINS=https://*.example.com

# Protocol-specific
CORS_ORIGINS=https://app.example.com,https://admin.example.com
```

## Logging Configuration

### Log Level

#### LOG_LEVEL

- **Purpose**: Minimum logging level
- **Type**: `string`
- **Valid Values**: `error`, `warn`, `info`, `debug`, `verbose`
- **Default**: `info`
- **Required**: No

```bash
LOG_LEVEL=error              # Only errors
LOG_LEVEL=warn               # Warnings and errors
LOG_LEVEL=info               # Info, warnings, and errors (default)
LOG_LEVEL=debug              # Debug info and above
LOG_LEVEL=verbose            # All log messages
```

**Log Level Hierarchy:**

```
verbose > debug > info > warn > error
```

### Log Format

#### LOG_FORMAT

- **Purpose**: Log output format
- **Type**: `string`
- **Valid Values**: `json`, `simple`
- **Default**: `json`
- **Required**: No

```bash
LOG_FORMAT=json              # Structured JSON logs (production)
LOG_FORMAT=simple            # Human-readable logs (development)
```

**JSON Format Example:**

```json
{
  "timestamp": "2024-01-01T12:00:00.000Z",
  "level": "info",
  "message": "Application started",
  "context": "NestApplication",
  "requestId": "uuid-123"
}
```

**Simple Format Example:**

```
2024-01-01 12:00:00 [INFO] NestApplication - Application started
```

## Rate Limiting

### Throttling Configuration

#### THROTTLE_TTL

- **Purpose**: Rate limiting time window in milliseconds
- **Type**: `number`
- **Default**: `60000` (1 minute)
- **Required**: No

```bash
THROTTLE_TTL=60000           # 1 minute window
THROTTLE_TTL=300000          # 5 minute window
THROTTLE_TTL=3600000         # 1 hour window
```

#### THROTTLE_LIMIT

- **Purpose**: Maximum requests per time window
- **Type**: `number`
- **Default**: `100`
- **Required**: No

```bash
THROTTLE_LIMIT=100           # 100 requests per window
THROTTLE_LIMIT=1000          # 1000 requests per window
THROTTLE_LIMIT=10            # 10 requests per window (strict)
```

**Rate Limiting Examples:**

```bash
# 100 requests per minute
THROTTLE_TTL=60000
THROTTLE_LIMIT=100

# 1000 requests per hour
THROTTLE_TTL=3600000
THROTTLE_LIMIT=1000

# 10 requests per 10 seconds (very strict)
THROTTLE_TTL=10000
THROTTLE_LIMIT=10
```

## External Services

### Redis Configuration (Optional)

#### REDIS_HOST

- **Purpose**: Redis server hostname
- **Type**: `string`
- **Default**: `localhost`
- **Required**: No (if Redis is used)

```bash
REDIS_HOST=localhost         # Local Redis
REDIS_HOST=redis             # Docker service name
REDIS_HOST=redis.example.com # Remote Redis server
```

#### REDIS_PORT

- **Purpose**: Redis server port
- **Type**: `number`
- **Default**: `6379`
- **Required**: No

```bash
REDIS_PORT=6379              # Default Redis port
REDIS_PORT=6380              # Alternative port
```

#### REDIS_PASSWORD

- **Purpose**: Redis authentication password
- **Type**: `string`
- **Default**: None
- **Required**: No

```bash
REDIS_PASSWORD=              # No password (default)
REDIS_PASSWORD=redis_password # With authentication
```

### Email Service (Future Implementation)

#### SMTP_HOST

- **Purpose**: SMTP server hostname
- **Type**: `string`
- **Default**: None
- **Required**: No

#### SMTP_PORT

- **Purpose**: SMTP server port
- **Type**: `number`
- **Default**: `587`
- **Required**: No

#### SMTP_USER

- **Purpose**: SMTP authentication username
- **Type**: `string`
- **Default**: None
- **Required**: No

#### SMTP_PASSWORD

- **Purpose**: SMTP authentication password
- **Type**: `string`
- **Default**: None
- **Required**: No

## Development Settings

### Development-specific Variables

#### DB_MIGRATIONS_RUN

- **Purpose**: Auto-run migrations on startup
- **Type**: `boolean`
- **Default**: `false`
- **Required**: No
- **Environment**: Development only

```bash
DB_MIGRATIONS_RUN=false      # Manual migrations
DB_MIGRATIONS_RUN=true       # Auto-run migrations
```

#### ENABLE_HOT_RELOAD

- **Purpose**: Enable hot module replacement
- **Type**: `boolean`
- **Default**: `true` (development)
- **Required**: No

```bash
ENABLE_HOT_RELOAD=true       # Hot reload enabled
ENABLE_HOT_RELOAD=false      # Hot reload disabled
```

#### DEBUG_SQL

- **Purpose**: Enable SQL query debugging
- **Type**: `boolean`
- **Default**: `false`
- **Required**: No

```bash
DEBUG_SQL=false              # No SQL debugging
DEBUG_SQL=true               # Log SQL queries
```

## Production Settings

### Production-specific Variables

#### TRUST_PROXY

- **Purpose**: Trust proxy headers (for load balancers)
- **Type**: `boolean`
- **Default**: `false`
- **Required**: No

```bash
TRUST_PROXY=false            # Don't trust proxy headers
TRUST_PROXY=true             # Trust proxy headers (behind load balancer)
```

#### RATE_LIMIT_MAX

- **Purpose**: Global rate limit (requests per window)
- **Type**: `number`
- **Default**: None
- **Required**: No

```bash
RATE_LIMIT_MAX=1000          # 1000 requests per window
```

#### COMPRESSION_LEVEL

- **Purpose**: Gzip compression level (1-9)
- **Type**: `number`
- **Range**: `1-9`
- **Default**: `6`
- **Required**: No

```bash
COMPRESSION_LEVEL=6          # Balanced compression
COMPRESSION_LEVEL=1          # Fastest compression
COMPRESSION_LEVEL=9          # Maximum compression
```

## Application Metadata

### Informational Variables

#### APP_NAME

- **Purpose**: Application display name
- **Type**: `string`
- **Default**: `NestJS Starter Kit`
- **Required**: No

```bash
APP_NAME=NestJS Starter Kit   # Default name
APP_NAME=My Awesome API       # Custom name
APP_NAME="Company API v2"     # With spaces
```

#### APP_VERSION

- **Purpose**: Application version
- **Type**: `string`
- **Default**: `1.0.0`
- **Required**: No

```bash
APP_VERSION=1.0.0            # Semantic versioning
APP_VERSION=2024.1.1         # Date-based versioning
APP_VERSION=v1.2.3-beta      # Pre-release version
```

#### APP_DESCRIPTION

- **Purpose**: Application description
- **Type**: `string`
- **Default**: `Production-ready NestJS API starter kit`
- **Required**: No

```bash
APP_DESCRIPTION="Production-ready NestJS API starter kit"
APP_DESCRIPTION="Company internal API for user management"
```

## Validation Schema

### Joi Validation Rules

The application validates environment variables using Joi schema:

```typescript
// src/config/validation.schema.ts
export const validationSchema = Joi.object({
  // Application
  NODE_ENV: Joi.string()
    .valid('development', 'production', 'test')
    .default('development'),

  PORT: Joi.number().port().default(3000),

  HOST: Joi.string().default('0.0.0.0'),

  // Database
  DB_HOST: Joi.string().required(),

  DB_PORT: Joi.number().port().default(5432),

  DB_USERNAME: Joi.string().required(),

  DB_PASSWORD: Joi.string().required(),

  DB_NAME: Joi.string().required(),

  // JWT
  JWT_SECRET: Joi.string().min(32).required(),

  JWT_EXPIRES_IN: Joi.string().default('24h'),

  // Rate Limiting
  THROTTLE_TTL: Joi.number().positive().default(60000),

  THROTTLE_LIMIT: Joi.number().positive().default(100),

  // Logging
  LOG_LEVEL: Joi.string()
    .valid('error', 'warn', 'info', 'debug', 'verbose')
    .default('info'),

  LOG_FORMAT: Joi.string().valid('json', 'simple').default('json'),
});
```

### Validation Error Examples

Common validation errors and solutions:

**Missing Required Variable:**

```
Error: "DB_HOST" is required
Solution: Add DB_HOST=localhost to your .env file
```

**Invalid Value:**

```
Error: "NODE_ENV" must be one of [development, production, test]
Solution: Use a valid NODE_ENV value
```

**Invalid Type:**

```
Error: "PORT" must be a number
Solution: Ensure PORT is numeric (e.g., PORT=3000)
```

## Best Practices

### Security Best Practices

1. **Never Commit Secrets**

   ```bash
   # Add to .gitignore
   .env
   .env.local
   .env.*.local
   ```

2. **Use Strong Secrets**

   ```bash
   # Generate strong JWT secret
   JWT_SECRET=$(openssl rand -base64 32)
   ```

3. **Environment-Specific Configuration**

   ```bash
   # Development
   JWT_SECRET=dev-secret-not-for-production

   # Production
   JWT_SECRET=A7x9K2m5P8q3W6e1R4t7Y0u2I5o8P1a3S6d9F2g5H8j1K4m7N0q3T6w9E2r5T8y1
   ```

4. **Validate All Variables**
   - Use Joi schema validation
   - Fail fast on invalid configuration
   - Provide clear error messages

### Development Best Practices

1. **Use .env.example**

   ```bash
   # Copy template for new developers
   cp .env.example .env
   ```

2. **Document Variables**
   - Add comments to .env files
   - Document purpose and valid values
   - Provide examples

3. **Local Overrides**
   ```bash
   # Use .env.local for personal settings
   LOG_LEVEL=debug
   PORT=3001
   ```

### Production Best Practices

1. **External Secret Management**

   ```bash
   # Use secret management systems
   JWT_SECRET=$(aws secretsmanager get-secret-value --secret-id jwt-secret)
   DB_PASSWORD=$(vault kv get -field=password database/config)
   ```

2. **Environment Validation**

   ```bash
   # Validate before deployment
   npm run config:validate
   ```

3. **Monitoring Configuration**
   ```bash
   # Enable production logging
   LOG_LEVEL=info
   LOG_FORMAT=json
   ```

## Troubleshooting

### Common Issues

1. **Application Won't Start**

   ```
   Error: Configuration validation failed
   Solution: Check required environment variables
   ```

2. **Database Connection Failed**

   ```
   Error: Connection refused
   Solution: Verify DB_HOST, DB_PORT, and credentials
   ```

3. **CORS Errors**
   ```
   Error: CORS policy blocked
   Solution: Add frontend URL to CORS_ORIGINS
   ```

### Debug Configuration

```bash
# Log current configuration
node -e "
const config = require('./src/config/configuration.ts').default();
console.log(JSON.stringify(config, null, 2));
"

# Test database connection
npm run typeorm:schema:log

# Validate environment variables
npm run config:validate
```

### Environment Variable Debugging

```bash
# Print all environment variables
env | grep -E '^(NODE_ENV|PORT|DB_|JWT_|LOG_|THROTTLE_|APP_)'

# Check specific variable
echo $NODE_ENV
echo $DB_HOST

# Test variable loading
node -e "
require('dotenv').config();
console.log('NODE_ENV:', process.env.NODE_ENV);
console.log('DB_HOST:', process.env.DB_HOST);
"
```

### Configuration Loading Order Test

```typescript
// debug-config.ts
import { config } from 'dotenv';
import { join } from 'path';

const envFiles = [
  '.env',
  '.env.local',
  `.env.${process.env.NODE_ENV}`,
  `.env.${process.env.NODE_ENV}.local`,
];

envFiles.forEach((file) => {
  const path = join(process.cwd(), file);
  try {
    const result = config({ path });
    console.log(`Loaded ${file}:`, !!result.parsed);
  } catch (error) {
    console.log(`Failed to load ${file}:`, error.message);
  }
});
```

---

This comprehensive environment variables guide ensures proper configuration
management for the NestJS API Starter Kit across all environments. Following
these guidelines will help maintain security, consistency, and reliability in
your application configuration.

**Next:** Learn about [Project Structure](project-structure.md) to understand
the codebase organization.
