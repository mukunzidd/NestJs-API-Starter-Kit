import { NestFactory } from '@nestjs/core';
import { ValidationPipe, VersioningType, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import helmet from 'helmet';
import * as compression from 'compression';
import { WINSTON_MODULE_NEST_PROVIDER } from 'nest-winston';

import { AppModule } from './app.module';
import { GlobalExceptionFilter } from './common/filters/global-exception.filter';
import { LoggingInterceptor } from './common/interceptors/logging.interceptor';
import { createNestJSLogger } from './common/logger/nestjs-logger.config';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    bufferLogs: true,
  });

  const configService = app.get(ConfigService);

  // Use NestJS 11 built-in logger or Winston based on configuration
  const useBuiltInLogger = configService.get<boolean>('USE_NESTJS_LOGGER') !== false;

  if (useBuiltInLogger) {
    const nestLogger = createNestJSLogger(configService);
    app.useLogger(nestLogger);
  } else {
    const winstonLogger = app.get(WINSTON_MODULE_NEST_PROVIDER);
    app.useLogger(winstonLogger);
  }

  // Security
  app.use(helmet());
  app.use(compression());

  // CORS
  app.enableCors({
    origin: configService.get<string>('CORS_ORIGINS')?.split(',') || ['http://localhost:3888'],
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'HEAD', 'OPTIONS'],
    credentials: true,
  });

  // API versioning
  app.enableVersioning({
    type: VersioningType.URI,
    defaultVersion: '1',
    prefix: 'api/v',
  });

  // Global pipes
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );

  // Global filters
  app.useGlobalFilters(new GlobalExceptionFilter());

  // Global interceptors
  app.useGlobalInterceptors(new LoggingInterceptor());

  // Global guards are configured in app.module.ts

  // Graceful shutdown
  app.enableShutdownHooks();

  const port = configService.get<number>('PORT') || 3888;
  const host = configService.get<string>('HOST') || '0.0.0.0';

  await app.listen(port, host);

  const logger = new Logger('Bootstrap');
  logger.log(`🚀 Application is running on: http://${host}:${port}`);
  logger.log(`📖 API Documentation available at: http://${host}:${port}/api/v1/health`);
  logger.log(`🌍 Environment: ${configService.get<string>('NODE_ENV')}`);
}

bootstrap().catch((error) => {
  Logger.error('❌ Error starting application', error);
  process.exit(1);
});
