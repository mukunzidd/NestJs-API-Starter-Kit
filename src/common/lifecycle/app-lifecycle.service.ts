import {
  Injectable,
  OnModuleInit,
  OnModuleDestroy,
  OnApplicationShutdown,
  Logger,
} from '@nestjs/common';

/**
 * Example service demonstrating NestJS 11 lifecycle hooks
 * Note: In NestJS 11, termination hooks are executed in reverse order
 */
@Injectable()
export class AppLifecycleService implements OnModuleInit, OnModuleDestroy, OnApplicationShutdown {
  private readonly logger = new Logger(AppLifecycleService.name);

  async onModuleInit(): Promise<void> {
    this.logger.log('🚀 AppLifecycleService: Module initialized');

    // Initialize resources, connections, etc.
    // This runs when the module is first initialized
  }

  async onModuleDestroy(): Promise<void> {
    this.logger.log('🔄 AppLifecycleService: Module destroying...');

    // In NestJS 11, this runs BEFORE OnApplicationShutdown (reversed order)
    // Clean up module-specific resources here
    await this.cleanupModuleResources();
  }

  async onApplicationShutdown(signal?: string): Promise<void> {
    this.logger.log(`🛑 AppLifecycleService: Application shutting down (signal: ${signal})`);

    // In NestJS 11, this runs AFTER OnModuleDestroy (reversed order)
    // Clean up application-wide resources here
    await this.cleanupApplicationResources();
  }

  private async cleanupModuleResources(): Promise<void> {
    this.logger.log('🧹 Cleaning up module-specific resources...');

    // Example: Close specific connections, clear caches, etc.
    // Add your module-specific cleanup logic here

    // Simulate cleanup time
    await new Promise((resolve) => setTimeout(resolve, 100));

    this.logger.log('✅ Module resources cleaned up');
  }

  private async cleanupApplicationResources(): Promise<void> {
    this.logger.log('🧹 Cleaning up application-wide resources...');

    // Example: Close database connections, stop background processes, etc.
    // Add your application-wide cleanup logic here

    // Simulate cleanup time
    await new Promise((resolve) => setTimeout(resolve, 100));

    this.logger.log('✅ Application resources cleaned up');
  }
}
