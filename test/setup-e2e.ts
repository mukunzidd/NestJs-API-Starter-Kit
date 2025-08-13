import 'reflect-metadata';
import { Test } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

// Global test application instance
let app: INestApplication;

export const getTestApp = () => app;

export const createTestApp = async (moduleClass: any) => {
  const moduleFixture = await Test.createTestingModule({
    imports: [moduleClass],
  })
    .overrideProvider(ConfigService)
    .useValue({
      get: jest.fn((key: string) => {
        const testConfig = {
          NODE_ENV: 'test',
          PORT: 3001,
          HOST: '0.0.0.0',
          DB_HOST: 'localhost',
          DB_PORT: 5433, // Different port for test database
          DB_USERNAME: 'test_user',
          DB_PASSWORD: 'test_password',
          DB_NAME: 'test_database',
          JWT_SECRET: 'test-jwt-secret-key-for-testing-purposes',
          JWT_EXPIRES_IN: '1h',
          THROTTLE_TTL: 60000,
          THROTTLE_LIMIT: 1000,
          LOG_LEVEL: 'error', // Reduce log noise during tests
          LOG_FORMAT: 'json',
          'app.name': 'Test App',
          'app.version': '1.0.0-test',
          'app.description': 'Test Application',
          'throttle.ttl': 60000,
          'throttle.limit': 1000,
          'logging.level': 'error',
          'logging.format': 'json',
        };

        return testConfig[key] || process.env[key];
      }),
    })
    .compile();

  app = moduleFixture.createNestApplication();

  // Configure the app similar to main.ts but for testing
  const { ValidationPipe } = await import('@nestjs/common');
  const helmet = await import('helmet');
  const compression = await import('compression');

  // Security and compression
  app.use(helmet.default());
  app.use(compression.default());

  // CORS
  app.enableCors({
    origin: ['http://localhost:3000', 'http://localhost:3001'],
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'HEAD', 'OPTIONS'],
    credentials: true,
  });

  // Validation
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

  await app.init();
  return app;
};

export const closeTestApp = async () => {
  if (app) {
    await app.close();
  }
};

// Global teardown
afterAll(async () => {
  await closeTestApp();
});
