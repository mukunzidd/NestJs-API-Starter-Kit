# Multi-stage Docker build for NestJS application

###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM oven/bun:1-alpine AS development

# Create app directory
WORKDIR /usr/src/app

# Install system dependencies
RUN apk add --no-cache \
    dumb-init \
    curl \
    && rm -rf /var/cache/apk/*

# Copy package.json and bun.lockb
COPY package.json bun.lockb* ./

# Copy TypeScript config files needed for postinstall build
COPY tsconfig*.json ./
COPY nest-cli.json ./

# Bundle app source (needed for postinstall build)
COPY . .

# Install app dependencies using bun (this will also run postinstall build)
RUN bun install --frozen-lockfile

# Create a non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nestjs -u 1001

# Change ownership of the app directory to nestjs user
RUN chown -R nestjs:nodejs /usr/src/app
USER nestjs

# Expose port
EXPOSE 3000

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Start the application in development mode
CMD ["bun", "run", "start:dev"]

###################
# BUILD FOR PRODUCTION
###################

FROM oven/bun:1-alpine AS build

WORKDIR /usr/src/app

# Install system dependencies needed for build
RUN apk add --no-cache \
    curl \
    && rm -rf /var/cache/apk/*

# Copy package files and config files
COPY package.json bun.lockb* ./
COPY tsconfig*.json ./
COPY nest-cli.json ./

# Install all dependencies (including devDependencies for build)
RUN bun install --frozen-lockfile

# Copy all source code and config files
COPY . .

# Build the application
RUN bun run build

# Install only production dependencies
RUN bun install --frozen-lockfile --production

###################
# PRODUCTION
###################

FROM oven/bun:1-alpine AS production

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init curl && rm -rf /var/cache/apk/*

# Create app directory
WORKDIR /usr/src/app

# Create a non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nestjs -u 1001

# Copy built application and production dependencies from build stage
COPY --from=build --chown=nestjs:nodejs /usr/src/app/dist ./dist
COPY --from=build --chown=nestjs:nodejs /usr/src/app/node_modules ./node_modules
COPY --from=build --chown=nestjs:nodejs /usr/src/app/package.json ./

# Create logs directory
RUN mkdir -p /usr/src/app/logs && chown nestjs:nodejs /usr/src/app/logs

# Switch to non-root user
USER nestjs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health/live || exit 1

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Start the application
CMD ["bun", "run", "start:prod"]