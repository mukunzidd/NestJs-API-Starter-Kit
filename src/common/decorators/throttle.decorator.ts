import { applyDecorators } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';

/**
 * Apply rate limiting to endpoints with predefined configurations
 */
export const ThrottleEndpoint = {
  /**
   * Strict rate limiting for sensitive endpoints (10 requests per minute)
   */
  Strict: () => applyDecorators(Throttle({ short: { ttl: 60000, limit: 10 } })),

  /**
   * Moderate rate limiting for regular endpoints (30 requests per minute)
   */
  Moderate: () => applyDecorators(Throttle({ short: { ttl: 60000, limit: 30 } })),

  /**
   * Lenient rate limiting for public endpoints (100 requests per minute)
   */
  Lenient: () => applyDecorators(Throttle({ short: { ttl: 60000, limit: 100 } })),

  /**
   * Custom rate limiting with specified limits
   */
  Custom: (limit: number, ttl: number = 60000) =>
    applyDecorators(Throttle({ default: { ttl, limit } })),
};
