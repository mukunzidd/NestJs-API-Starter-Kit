# Quick Start Guide

Get the NestJS API Starter Kit running in 5 minutes.

## Prerequisites

- **Node.js 20+** ([Download](https://nodejs.org/))
- **Package Manager**: Any of the following
  - **npm 10+** (comes with Node.js)
  - **Bun 1.0+** ([Install](https://bun.sh/)) - _Fastest_
  - **pnpm 8+** ([Install](https://pnpm.io/)) - _Efficient_
  - **Yarn 4+** ([Install](https://yarnpkg.com/))
- **Git** ([Download](https://git-scm.com/))

## Installation

### 1. Clone and Install

```bash
git clone <your-repo-url>
cd nestjs-api-starter-kit

# Use your preferred package manager:
npm install     # npm (included with Node.js)
# OR
bun install     # bun (fastest installs)
# OR
pnpm install    # pnpm (efficient with disk space)
# OR
yarn install    # yarn
```

### 2. Environment Setup

```bash
cp .env.example .env
```

**Edit `.env` with your settings:**

```env
# Application
NODE_ENV=development
PORT=3001

# Database (Docker)
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=nestjs_user
DB_PASSWORD=nestjs_password
DB_NAME=nestjs_starter

# Security
JWT_SECRET=your-super-secret-jwt-key-change-in-production-min-32-chars

# Logging
LOG_LEVEL=info
LOG_FORMAT=json
```

### 3. Start the Database

```bash
# Start PostgreSQL with Docker
docker compose up -d postgres

# Wait for PostgreSQL to be ready (check with logs)
docker compose logs postgres
# Look for "database system is ready to accept connections"

# Run migrations (wait ~10 seconds if database just started)
npm run typeorm:migration:run     # npm
# bun run typeorm:migration:run   # bun
# pnpm run typeorm:migration:run  # pnpm
# yarn typeorm:migration:run      # yarn
```

### 4. Start Development

```bash
# Use the same package manager you used for installation:
npm run start:dev     # npm
# bun run start:dev   # bun
# pnpm run start:dev  # pnpm
# yarn start:dev      # yarn
```

🚀 **API now running at:** `http://localhost:3000`

## Quick Test

```bash
# Health check
curl http://localhost:3000/health

# Expected response:
# {"status":"ok","info":{"api":{"status":"up"},"database":{"status":"up"}}...}
```

## Alternative: Full Docker Setup

If you prefer everything in Docker:

```bash
git clone <your-repo-url>
cd nestjs-api-starter-kit
docker compose up --build
```

This starts:

- API server on port 3000
- PostgreSQL on port 5432
- Adminer (DB admin) on port 8080

## Troubleshooting

### Port 3000 in Use

```bash
# Find and kill process
kill -9 $(lsof -ti:3000)
# Or use different port
PORT=3001 bun run start:dev
```

### Database Connection Failed

```bash
# Check PostgreSQL is running
docker compose ps postgres

# Check PostgreSQL logs for errors
docker compose logs postgres

# If role doesn't exist, recreate the database
docker compose down postgres
docker volume rm nestjs-api-starter-kit_postgres_data
docker compose up -d postgres
sleep 10
npm run typeorm:migration:run  # or your package manager
```

### Build Errors

```bash
# Clear node_modules and reinstall
rm -rf node_modules
npm install   # Use the same package manager you used before
```

## Next Steps

- ✅ **API Working?** → Read [Adding Endpoints Guide](docs/adding-endpoints.md)
- 📖 **Full Documentation** → See
  [Getting Started Guide](docs/getting-started.md)
- 🧪 **Run Tests** → `npm test` (use your chosen package manager)
- 🐳 **Docker Development** → `docker compose up --build`

## Common Commands

Replace `npm run` with your package manager's run command:

- **npm**: `npm run <script>`
- **bun**: `bun run <script>` or `bun <script>`
- **pnpm**: `pnpm run <script>` or `pnpm <script>`
- **yarn**: `yarn <script>`

```bash
# Development
npm run start:dev           # Start with hot reload
npm run start:debug         # Start with debugger
npm run build               # Build for production
npm run start:prod          # Start production server

# Testing
npm test                    # Unit tests
npm run test:e2e           # E2E tests
npm run test:cov           # Coverage report

# Database
npm run typeorm:migration:generate  # Generate migration
npm run typeorm:migration:run       # Run migrations
npm run db:seed                     # Seed database

# Code Quality
npm run lint               # Lint code
npm run format             # Format code
```

## Need Help?

- 🐛 **Issues:** Check
  [GitHub Issues](https://github.com/your-username/nestjs-api-starter-kit/issues)
- 📖 **Docs:** See [docs/](docs/) folder
- 💬 **Questions:** Open a
  [Discussion](https://github.com/your-username/nestjs-api-starter-kit/discussions)

---

**Ready to build?** Start with the
[Adding Endpoints Guide](docs/adding-endpoints.md) to create your first API
endpoint!
