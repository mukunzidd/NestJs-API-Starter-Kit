import { ConsoleLogger, LoggerService, LogLevel } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

/**
 * NestJS 11 built-in logger configuration with JSON support
 */
export class CustomNestLogger extends ConsoleLogger implements LoggerService {
  constructor(
    context: string,
    private readonly configService: ConfigService,
  ) {
    super(context, {
      // Enable JSON logging in NestJS 11
      json: configService.get<string>('logging.format') === 'json',
      // Disable colors for JSON logs in production
      colors: configService.get<string>('NODE_ENV') !== 'production',
      logLevels: CustomNestLogger.getLogLevels(configService.get<string>('logging.level') || 'log'),
    });
  }

  /**
   * Get log levels based on configured level
   */
  private static getLogLevels(level: string): LogLevel[] {
    const levels: Record<string, LogLevel[]> = {
      error: ['error'],
      warn: ['error', 'warn'],
      log: ['error', 'warn', 'log'],
      debug: ['error', 'warn', 'log', 'debug'],
      verbose: ['error', 'warn', 'log', 'debug', 'verbose'],
    };

    return levels[level] ?? ['error', 'warn', 'log'];
  }

  /**
   * Override to add additional context
   */
  override log(message: any, context?: string): void {
    super.log(message, context || this.context);
  }

  override error(message: any, stack?: string, context?: string): void {
    super.error(message, stack, context || this.context);
  }

  override warn(message: any, context?: string): void {
    super.warn(message, context || this.context);
  }

  override debug(message: any, context?: string): void {
    super.debug?.(message, context || this.context);
  }

  override verbose(message: any, context?: string): void {
    super.verbose?.(message, context || this.context);
  }
}

/**
 * Factory function to create NestJS 11 logger
 */
export const createNestJSLogger = (configService: ConfigService) => {
  return new CustomNestLogger('Application', configService);
};
