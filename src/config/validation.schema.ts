import * as Joi from 'joi';

export const validationSchema = Joi.object({
  // Application
  NODE_ENV: Joi.string().valid('development', 'production', 'test').default('development'),
  PORT: Joi.number().port().default(3000),
  HOST: Joi.string().default('0.0.0.0'),
  API_PREFIX: Joi.string().default('api'),

  // CORS
  CORS_ORIGINS: Joi.string().default('http://localhost:3000'),

  // Database
  DB_HOST: Joi.string().required(),
  DB_PORT: Joi.number().port().default(5432),
  DB_USERNAME: Joi.string().required(),
  DB_PASSWORD: Joi.string().required(),
  DB_NAME: Joi.string().required(),

  // JWT (optional, for future auth implementation)
  JWT_SECRET: Joi.string().min(32).required(),
  JWT_EXPIRES_IN: Joi.string().default('24h'),

  // Throttling
  THROTTLE_TTL: Joi.number().positive().default(60000),
  THROTTLE_LIMIT: Joi.number().positive().default(100),

  // Logging
  LOG_LEVEL: Joi.string().valid('error', 'warn', 'info', 'debug', 'verbose').default('info'),
  LOG_FORMAT: Joi.string().valid('json', 'simple').default('json'),

  // App Info
  APP_NAME: Joi.string().default('NestJS Starter Kit'),
  APP_VERSION: Joi.string().default('1.0.0'),
  APP_DESCRIPTION: Joi.string().default('Production-ready NestJS API starter kit'),
});
