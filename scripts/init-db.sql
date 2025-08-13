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
