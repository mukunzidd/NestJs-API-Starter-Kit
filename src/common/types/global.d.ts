/**
 * Global type definitions for the NestJS API Starter Kit
 */

declare global {
  namespace NodeJS {
    interface ProcessEnv {
      NODE_ENV: 'development' | 'production' | 'test';
      PORT: string;
      HOST: string;
      API_PREFIX: string;

      // Database
      DB_HOST: string;
      DB_PORT: string;
      DB_USERNAME: string;
      DB_PASSWORD: string;
      DB_NAME: string;

      // Security
      JWT_SECRET: string;
      JWT_EXPIRES_IN: string;
      CORS_ORIGINS: string;

      // Rate limiting
      THROTTLE_TTL: string;
      THROTTLE_LIMIT: string;

      // Logging
      LOG_LEVEL: string;
      LOG_FORMAT: string;

      // App metadata
      APP_NAME: string;
      APP_VERSION: string;
      APP_DESCRIPTION: string;
    }
  }

  // Test utilities (available in test environment)
  namespace globalThis {
    let testUtils: {
      createMockRequest: (overrides?: any) => any;
      createMockResponse: (overrides?: any) => any;
      createMockConfigService: (config?: Record<string, any>) => any;
    };
  }
}

export {};

/**
 * Common API response types
 */
export interface ApiResponse<T = any> {
  data?: T;
  message?: string;
  statusCode?: number;
  timestamp?: string;
}

export interface PaginatedResponse<T = any> extends ApiResponse<T[]> {
  meta: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
    hasNext: boolean;
    hasPrevious: boolean;
  };
}

export interface ErrorResponse {
  statusCode: number;
  message: string | string[];
  error: string;
  timestamp: string;
  path: string;
  method: string;
  details?: string;
  stack?: string; // Only in development
}

/**
 * Health check response types
 */
export interface HealthStatus {
  status: 'ok' | 'error' | 'shutting_down';
  info?: Record<string, HealthIndicatorResult>;
  error?: Record<string, HealthIndicatorResult>;
  details?: Record<string, HealthIndicatorResult>;
}

export interface HealthIndicatorResult {
  status: 'up' | 'down';
  [key: string]: any;
}

/**
 * Configuration types
 */
export interface DatabaseConfig {
  host: string;
  port: number;
  username: string;
  password: string;
  name: string;
}

export interface JwtConfig {
  secret: string;
  expiresIn: string;
}

export interface ThrottleConfig {
  ttl: number;
  limit: number;
}

export interface LoggingConfig {
  level: string;
  format: string;
}

export interface AppConfig {
  name: string;
  version: string;
  description: string;
}

/**
 * Utility types
 */
export type DeepPartial<T> = {
  [P in keyof T]?: T[P] extends object ? DeepPartial<T[P]> : T[P];
};

export type RequireAtLeastOne<T> = {
  [K in keyof T]-?: Required<Pick<T, K>> & Partial<Pick<T, Exclude<keyof T, K>>>;
}[keyof T];

export type OmitStrict<T, K extends keyof T> = Pick<T, Exclude<keyof T, K>>;

/**
 * Database entity base interface
 */
export interface BaseEntity {
  id: number;
  createdAt: Date;
  updatedAt: Date;
}

/**
 * Request context types
 */
export interface RequestWithUser extends Request {
  user?: {
    id: number;
    email: string;
    roles: string[];
  };
}

/**
 * Logging context
 */
export interface LogContext {
  requestId?: string;
  userId?: number;
  method?: string;
  url?: string;
  userAgent?: string;
  ip?: string;
}
