import { Module } from '@nestjs/common';
import { ThrottlerModule } from '@nestjs/throttler';
import { ConfigService } from '@nestjs/config';
import { APP_GUARD } from '@nestjs/core';

import { ConfigModule } from './config/config.module';
import { DatabaseModule } from './database/database.module';
import { LoggerModule } from './common/logger/logger.module';
import { HealthModule } from './health/health.module';
import { ThrottlerGuard } from './common/guards/throttler.guard';

@Module({
  imports: [
    ConfigModule,
    LoggerModule,
    DatabaseModule,
    HealthModule,
    // Rate limiting
    ThrottlerModule.forRootAsync({
      useFactory: (configService: ConfigService) => ({
        throttlers: [
          {
            name: 'short',
            ttl: configService.get<number>('throttle.ttl') ?? 60000,
            limit: configService.get<number>('throttle.limit') ?? 100,
          },
          {
            name: 'medium',
            ttl: (configService.get<number>('throttle.ttl') ?? 60000) * 10, // 10 minutes
            limit: (configService.get<number>('throttle.limit') ?? 100) * 10, // 1000 requests
          },
          {
            name: 'long',
            ttl: (configService.get<number>('throttle.ttl') ?? 60000) * 60, // 1 hour
            limit: (configService.get<number>('throttle.limit') ?? 100) * 60, // 6000 requests
          },
        ],
      }),
      inject: [ConfigService],
    }),
  ],
  controllers: [],
  providers: [
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
  ],
})
export class AppModule {}
