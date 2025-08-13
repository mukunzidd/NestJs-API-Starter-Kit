# Makefile shortcuts for common development tasks
# Uses scripts/detect-pm.js to respect the user's package manager (bun/pnpm/yarn/npm)

SHELL := /bin/bash
.DEFAULT_GOAL := help

## -------------------------
## Core
## -------------------------
help: ## Show this help
	@echo "Available targets:"
	@awk 'BEGIN {FS=":.*##"} /^[a-zA-Z0-9_-]+:.*##/ {printf "  %-24s %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

install: ## Install dependencies (auto-detect PM)
	@eval "$(node scripts/detect-pm.js --install)"

setup: ## Full project setup (env, dependencies, Docker DB)
	@eval "$(node scripts/detect-pm.js --run setup)"

dev-setup: ## Developer setup (local tooling)
	@eval "$(node scripts/detect-pm.js --run dev-setup)"

test-setup: ## Test environment setup
	@eval "$(node scripts/detect-pm.js --run test-setup)"

docker-setup: ## Docker environment setup
	@eval "$(node scripts/detect-pm.js --run docker-setup)"

## -------------------------
## App lifecycle
## -------------------------
dev: ## Start development server with hot reload
	@eval "$(node scripts/detect-pm.js --run start:dev)"

debug: ## Start development server with debugger
	@eval "$(node scripts/detect-pm.js --run start:debug)"

build: ## Build production bundle
	@eval "$(node scripts/detect-pm.js --run build)"

prod: ## Start production server (after build)
	@eval "$(node scripts/detect-pm.js --run start:prod)"

## -------------------------
## Quality
## -------------------------
lint: ## Lint and fix code
	@eval "$(node scripts/detect-pm.js --run lint)"

lint-check: ## Check linting without fixing
	@eval "$(node scripts/detect-pm.js --run lint:check)"

format: ## Format code with Prettier
	@eval "$(node scripts/detect-pm.js --run format)"

format-check: ## Check formatting without fixing
	@eval "$(node scripts/detect-pm.js --run format:check)"

## -------------------------
## Testing
## -------------------------
test: ## Run unit tests
	@eval "$(node scripts/detect-pm.js --run test)"

test-watch: ## Run unit tests in watch mode
	@eval "$(node scripts/detect-pm.js --run test:watch)"

test-cov: ## Run tests with coverage
	@eval "$(node scripts/detect-pm.js --run test:cov)"

test-e2e: ## Run end-to-end tests
	@eval "$(node scripts/detect-pm.js --run test:e2e)"

test-all: ## Run all tests (unit + e2e)
	@eval "$(node scripts/detect-pm.js --run test:all)"

## -------------------------
## Database (TypeORM)
## -------------------------
migrate-generate: ## Generate migration from entity changes
	@eval "$(node scripts/detect-pm.js --run typeorm:migration:generate)"

migrate-create: ## Create an empty migration file
	@eval "$(node scripts/detect-pm.js --run typeorm:migration:create)"

migrate-run: ## Run pending migrations
	@eval "$(node scripts/detect-pm.js --run typeorm:migration:run)"

migrate-revert: ## Revert last migration
	@eval "$(node scripts/detect-pm.js --run typeorm:migration:revert)"

schema-drop: ## Drop database schema
	@eval "$(node scripts/detect-pm.js --run typeorm:schema:drop)"

seed: ## Run database seeds
	@eval "$(node scripts/detect-pm.js --run db:seed)"

## -------------------------
## Docker
## -------------------------
up: ## Start Docker compose services (foreground)
	@eval "$(node scripts/detect-pm.js --run docker:up)"

up-build: ## Build and start Docker compose services (foreground)
	@eval "$(node scripts/detect-pm.js --run docker:up:build)"

up-dev: ## Start Docker with development tools (pgAdmin, etc.)
	@eval "$(node scripts/detect-pm.js --run docker:up:dev)"

down: ## Stop Docker compose services
	@eval "$(node scripts/detect-pm.js --run docker:down)"

down-volumes: ## Stop Docker and remove volumes
	@eval "$(node scripts/detect-pm.js --run docker:down:volumes)"

logs: ## Follow API logs
	docker compose logs -f api

docker-build: ## Build production Docker image
	@eval "$(node scripts/detect-pm.js --run docker:build)"

docker-build-dev: ## Build development Docker image
	@eval "$(node scripts/detect-pm.js --run docker:build:dev)"

docker-run: ## Run production Docker image locally
	@eval "$(node scripts/detect-pm.js --run docker:run)"

docker-run-dev: ## Run dev Docker image with live mount
	@eval "$(node scripts/detect-pm.js --run docker:run:dev)"

docker-test: ## Run tests in Docker environment
	@eval "$(node scripts/detect-pm.js --run docker:test)"

docker-test-down: ## Tear down Docker test environment and volumes
	@eval "$(node scripts/detect-pm.js --run docker:test:down)"

## -------------------------
## CI/Release
## -------------------------
ci-install: ## CI: clean install
	@eval "$(node scripts/detect-pm.js --run ci:install)"

ci-build: ## CI: build
	@eval "$(node scripts/detect-pm.js --run ci:build)"

ci-lint: ## CI: lint & format check
	@eval "$(node scripts/detect-pm.js --run ci:lint)"

ci-test: ## CI: run all tests with coverage
	@eval "$(node scripts/detect-pm.js --run ci:test)"

ci-security: ## CI: audit dependencies
	@eval "$(node scripts/detect-pm.js --run ci:security)"

release: ## Generate a new version and changelog
	@eval "$(node scripts/detect-pm.js --run release)"

.PHONY: \
	help install setup dev-setup test-setup docker-setup \
	dev debug build prod \
	lint lint-check format format-check \
	test test-watch test-cov test-e2e test-all \
	migrate-generate migrate-create migrate-run migrate-revert schema-drop seed \
	up up-build up-dev down down-volumes logs \
	docker-build docker-build-dev docker-run docker-run-dev docker-test docker-test-down \
	ci-install ci-build ci-lint ci-test ci-security release
