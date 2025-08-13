# Testing Guide

Comprehensive testing is crucial for maintaining code quality and preventing
regressions. This guide covers the testing strategies, tools, and best practices
implemented in the NestJS API Starter Kit.

## Table of Contents

- [Testing Philosophy](#testing-philosophy)
- [Testing Stack](#testing-stack)
- [Test Types](#test-types)
- [Test Structure](#test-structure)
- [Unit Testing](#unit-testing)
- [Integration Testing](#integration-testing)
- [End-to-End Testing](#end-to-end-testing)
- [Test Database](#test-database)
- [Mocking Strategies](#mocking-strategies)
- [Code Coverage](#code-coverage)
- [Performance Testing](#performance-testing)
- [Testing Best Practices](#testing-best-practices)
- [CI/CD Integration](#cicd-integration)
- [Troubleshooting](#troubleshooting)

## Testing Philosophy

### Testing Pyramid

Our testing strategy follows the testing pyramid approach:

```
    /\
   /  \    E2E Tests (Few, Slow, High Confidence)
  /____\
 /      \   Integration Tests (Some, Medium Speed)
/________\
   Unit Tests (Many, Fast, Low-Level Confidence)
```

### Key Principles

1. **Test Early, Test Often**: Write tests as you develop features
2. **Fast Feedback**: Most tests should run quickly
3. **Reliable**: Tests should be deterministic and not flaky
4. **Maintainable**: Tests should be easy to understand and modify
5. **Comprehensive**: Achieve high code coverage with meaningful tests

### Testing Strategy

- **70%** Unit Tests - Fast, isolated component testing
- **20%** Integration Tests - Module interaction testing
- **10%** E2E Tests - Full application flow testing

## Testing Stack

### Core Testing Framework

- **Jest**: Primary testing framework with powerful mocking capabilities
- **Supertest**: HTTP assertion library for API testing
- **ts-jest**: TypeScript support for Jest
- **@nestjs/testing**: NestJS testing utilities

### Additional Tools

- **@types/jest**: TypeScript definitions for Jest
- **@types/supertest**: TypeScript definitions for Supertest
- **source-map-support**: Better stack traces in tests
- **jest-extended**: Additional Jest matchers

### Configuration

**Jest Configuration (`jest.config.js`)**:

```javascript
module.exports = {
  displayName: 'Unit Tests',
  moduleFileExtensions: ['js', 'json', 'ts'],
  rootDir: '.',
  testRegex: '.*\\.spec\\.ts$',
  transform: {
    '^.+\\.(t|j)s$': 'ts-jest',
  },
  collectCoverageFrom: [
    'src/**/*.{ts,js}',
    '!src/**/*.d.ts',
    '!src/**/*.interface.ts',
    '!src/**/*.module.ts',
    '!src/**/*.entity.ts',
    '!src/**/*.config.ts',
    '!src/main.ts',
  ],
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov', 'html', 'json'],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
  testEnvironment: 'node',
  setupFilesAfterEnv: ['<rootDir>/test/setup.ts'],
};
```

## Test Types

### 1. Unit Tests (`*.spec.ts`)

Test individual components in isolation:

```typescript
// users.service.spec.ts
describe('UsersService', () => {
  let service: UsersService;
  let repository: Repository<User>;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [
        UsersService,
        {
          provide: getRepositoryToken(User),
          useValue: mockRepository,
        },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
    repository = module.get<Repository<User>>(getRepositoryToken(User));
  });

  describe('findOne', () => {
    it('should return a user when found', async () => {
      const user = { id: '1', name: 'John' };
      jest.spyOn(repository, 'findOne').mockResolvedValue(user as User);

      const result = await service.findOne('1');

      expect(result).toEqual(user);
      expect(repository.findOne).toHaveBeenCalledWith({
        where: { id: '1' },
      });
    });

    it('should throw NotFoundException when user not found', async () => {
      jest.spyOn(repository, 'findOne').mockResolvedValue(null);

      await expect(service.findOne('1')).rejects.toThrow(NotFoundException);
    });
  });
});
```

### 2. Integration Tests

Test module interactions:

```typescript
// users.integration.spec.ts
describe('UsersModule Integration', () => {
  let app: INestApplication;
  let usersService: UsersService;
  let dataSource: DataSource;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [UsersModule, TypeOrmModule.forRoot(testDbConfig)],
    }).compile();

    app = moduleRef.createNestApplication();
    usersService = moduleRef.get<UsersService>(UsersService);
    dataSource = moduleRef.get<DataSource>(DataSource);

    await app.init();
  });

  beforeEach(async () => {
    await dataSource.synchronize(true); // Clean database
  });

  afterAll(async () => {
    await app.close();
  });

  it('should create and retrieve user', async () => {
    const userData = { name: 'John', email: 'john@example.com' };

    const createdUser = await usersService.create(userData);
    const retrievedUser = await usersService.findOne(createdUser.id);

    expect(retrievedUser).toEqual(expect.objectContaining(userData));
  });
});
```

### 3. End-to-End Tests (`*.e2e-spec.ts`)

Test complete application workflows:

```typescript
// users.e2e-spec.ts
describe('Users (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  describe('/users (GET)', () => {
    it('should return empty array initially', () => {
      return request(app.getHttpServer()).get('/users').expect(200).expect([]);
    });
  });

  describe('/users (POST)', () => {
    it('should create a new user', () => {
      const userData = {
        name: 'John Doe',
        email: 'john@example.com',
      };

      return request(app.getHttpServer())
        .post('/users')
        .send(userData)
        .expect(201)
        .expect((res) => {
          expect(res.body).toMatchObject(userData);
          expect(res.body.id).toBeDefined();
        });
    });

    it('should validate required fields', () => {
      return request(app.getHttpServer())
        .post('/users')
        .send({})
        .expect(400)
        .expect((res) => {
          expect(res.body.message).toContain('validation failed');
        });
    });
  });
});
```

## Test Structure

### File Organization

```
test/
├── unit/                    # Additional unit tests
│   ├── helpers/
│   └── mocks/
├── e2e/                     # End-to-end tests
│   ├── health.e2e-spec.ts
│   └── users.e2e-spec.ts
├── fixtures/                # Test data
│   ├── users.json
│   └── database.sql
├── setup.ts                 # Test setup
├── setup-e2e.ts            # E2E setup
└── jest-e2e.json           # E2E Jest config
```

### Test Setup Files

**Unit Test Setup (`test/setup.ts`)**:

```typescript
import 'reflect-metadata';
import { ConfigModule } from '@nestjs/config';

// Mock external services
jest.mock('nodemailer', () => ({
  createTransport: jest.fn(() => ({
    sendMail: jest.fn().mockResolvedValue({ messageId: 'test-id' }),
  })),
}));

// Global test configuration
beforeAll(async () => {
  process.env.NODE_ENV = 'test';
});

afterAll(async () => {
  // Cleanup
});
```

**E2E Test Setup (`test/setup-e2e.ts`)**:

```typescript
import { DataSource } from 'typeorm';
import {
  PostgreSqlContainer,
  StartedPostgreSqlContainer,
} from 'testcontainers';

let container: StartedPostgreSqlContainer;
let dataSource: DataSource;

global.beforeAll(async () => {
  // Start test database container
  container = await new PostgreSqlContainer('postgres:16-alpine')
    .withDatabase('test_db')
    .withUsername('test_user')
    .withPassword('test_pass')
    .start();

  process.env.DB_HOST = container.getHost();
  process.env.DB_PORT = container.getPort().toString();
  process.env.DB_USERNAME = 'test_user';
  process.env.DB_PASSWORD = 'test_pass';
  process.env.DB_NAME = 'test_db';
}, 60000);

global.afterAll(async () => {
  await container?.stop();
});
```

## Unit Testing

### Service Testing

```typescript
describe('UsersService', () => {
  let service: UsersService;
  let repository: Repository<User>;
  let logger: Logger;

  const mockRepository = {
    find: jest.fn(),
    findOne: jest.fn(),
    save: jest.fn(),
    delete: jest.fn(),
    create: jest.fn(),
  };

  const mockLogger = {
    log: jest.fn(),
    error: jest.fn(),
    warn: jest.fn(),
  };

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [
        UsersService,
        {
          provide: getRepositoryToken(User),
          useValue: mockRepository,
        },
        {
          provide: Logger,
          useValue: mockLogger,
        },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
    repository = module.get<Repository<User>>(getRepositoryToken(User));
    logger = module.get<Logger>(Logger);

    // Clear mocks between tests
    jest.clearAllMocks();
  });

  describe('create', () => {
    it('should create a new user successfully', async () => {
      const createUserDto = {
        name: 'John Doe',
        email: 'john@example.com',
      };
      const savedUser = { id: '1', ...createUserDto };

      mockRepository.create.mockReturnValue(createUserDto);
      mockRepository.save.mockResolvedValue(savedUser);

      const result = await service.create(createUserDto);

      expect(mockRepository.create).toHaveBeenCalledWith(createUserDto);
      expect(mockRepository.save).toHaveBeenCalledWith(createUserDto);
      expect(result).toEqual(savedUser);
      expect(mockLogger.log).toHaveBeenCalledWith(
        expect.stringContaining('User created successfully'),
      );
    });

    it('should handle database errors', async () => {
      const createUserDto = { name: 'John', email: 'john@example.com' };
      const dbError = new Error('Database connection failed');

      mockRepository.create.mockReturnValue(createUserDto);
      mockRepository.save.mockRejectedValue(dbError);

      await expect(service.create(createUserDto)).rejects.toThrow(
        'Database connection failed',
      );

      expect(mockLogger.error).toHaveBeenCalledWith(
        expect.stringContaining('Failed to create user'),
        dbError.stack,
      );
    });
  });

  describe('findOne', () => {
    it('should return user when found', async () => {
      const userId = '1';
      const user = { id: userId, name: 'John' };

      mockRepository.findOne.mockResolvedValue(user);

      const result = await service.findOne(userId);

      expect(result).toEqual(user);
      expect(mockRepository.findOne).toHaveBeenCalledWith({
        where: { id: userId },
      });
    });

    it('should throw NotFoundException when user not found', async () => {
      const userId = '999';

      mockRepository.findOne.mockResolvedValue(null);

      await expect(service.findOne(userId)).rejects.toThrow(NotFoundException);

      expect(mockRepository.findOne).toHaveBeenCalledWith({
        where: { id: userId },
      });
    });
  });
});
```

### Controller Testing

```typescript
describe('UsersController', () => {
  let controller: UsersController;
  let service: UsersService;

  const mockUsersService = {
    findAll: jest.fn(),
    findOne: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
    remove: jest.fn(),
  };

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      controllers: [UsersController],
      providers: [
        {
          provide: UsersService,
          useValue: mockUsersService,
        },
      ],
    }).compile();

    controller = module.get<UsersController>(UsersController);
    service = module.get<UsersService>(UsersService);

    jest.clearAllMocks();
  });

  describe('findAll', () => {
    it('should return array of users', async () => {
      const users = [
        { id: '1', name: 'John' },
        { id: '2', name: 'Jane' },
      ];

      mockUsersService.findAll.mockResolvedValue(users);

      const result = await controller.findAll();

      expect(result).toEqual(users);
      expect(service.findAll).toHaveBeenCalled();
    });
  });

  describe('create', () => {
    it('should create and return user', async () => {
      const createUserDto = { name: 'John', email: 'john@example.com' };
      const createdUser = { id: '1', ...createUserDto };

      mockUsersService.create.mockResolvedValue(createdUser);

      const result = await controller.create(createUserDto);

      expect(result).toEqual(createdUser);
      expect(service.create).toHaveBeenCalledWith(createUserDto);
    });
  });
});
```

### Testing Guards and Interceptors

```typescript
describe('AuthGuard', () => {
  let guard: AuthGuard;
  let reflector: Reflector;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [
        AuthGuard,
        {
          provide: Reflector,
          useValue: {
            getAllAndOverride: jest.fn(),
          },
        },
      ],
    }).compile();

    guard = module.get<AuthGuard>(AuthGuard);
    reflector = module.get<Reflector>(Reflector);
  });

  describe('canActivate', () => {
    it('should allow access to public routes', () => {
      const context = createMockExecutionContext();

      jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue(true);

      const result = guard.canActivate(context);

      expect(result).toBe(true);
    });

    it('should deny access without valid token', () => {
      const context = createMockExecutionContext({
        headers: {},
      });

      jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue(false);

      expect(() => guard.canActivate(context)).toThrow(UnauthorizedException);
    });
  });
});
```

## Integration Testing

### Module Testing

```typescript
describe('UsersModule Integration', () => {
  let module: TestingModule;
  let service: UsersService;
  let repository: Repository<User>;

  beforeAll(async () => {
    module = await Test.createTestingModule({
      imports: [
        UsersModule,
        TypeOrmModule.forRoot({
          type: 'sqlite',
          database: ':memory:',
          entities: [User],
          synchronize: true,
        }),
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
    repository = module.get<Repository<User>>(getRepositoryToken(User));
  });

  beforeEach(async () => {
    await repository.clear();
  });

  afterAll(async () => {
    await module.close();
  });

  it('should create and persist user', async () => {
    const userData = { name: 'John', email: 'john@test.com' };

    const user = await service.create(userData);
    const savedUser = await repository.findOne({
      where: { id: user.id },
    });

    expect(savedUser).toBeDefined();
    expect(savedUser.name).toBe(userData.name);
    expect(savedUser.email).toBe(userData.email);
  });

  it('should handle unique constraint violations', async () => {
    const userData = { name: 'John', email: 'john@test.com' };

    await service.create(userData);

    await expect(service.create(userData)).rejects.toThrow(); // Should throw constraint violation
  });
});
```

## End-to-End Testing

### API Testing

```typescript
describe('Users API (e2e)', () => {
  let app: INestApplication;
  let dataSource: DataSource;

  beforeAll(async () => {
    const moduleFixture = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(DataSource)
      .useValue(createTestDataSource())
      .compile();

    app = moduleFixture.createNestApplication();

    // Apply same configuration as main app
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
      }),
    );

    await app.init();
    dataSource = app.get<DataSource>(DataSource);
  });

  beforeEach(async () => {
    await dataSource.synchronize(true);
  });

  afterAll(async () => {
    await app.close();
  });

  describe('POST /users', () => {
    it('should create user with valid data', () => {
      return request(app.getHttpServer())
        .post('/api/v1/users')
        .send({
          name: 'John Doe',
          email: 'john@example.com',
        })
        .expect(201)
        .expect((res) => {
          expect(res.body).toMatchObject({
            id: expect.any(String),
            name: 'John Doe',
            email: 'john@example.com',
            createdAt: expect.any(String),
          });
        });
    });

    it('should validate required fields', () => {
      return request(app.getHttpServer())
        .post('/api/v1/users')
        .send({
          name: 'John',
          // Missing email
        })
        .expect(400)
        .expect((res) => {
          expect(res.body.message).toContain('email');
        });
    });

    it('should validate email format', () => {
      return request(app.getHttpServer())
        .post('/api/v1/users')
        .send({
          name: 'John',
          email: 'invalid-email',
        })
        .expect(400)
        .expect((res) => {
          expect(res.body.message).toContain('email');
        });
    });
  });

  describe('GET /users', () => {
    beforeEach(async () => {
      // Create test data
      await request(app.getHttpServer())
        .post('/api/v1/users')
        .send({ name: 'John', email: 'john@test.com' });

      await request(app.getHttpServer())
        .post('/api/v1/users')
        .send({ name: 'Jane', email: 'jane@test.com' });
    });

    it('should return list of users', () => {
      return request(app.getHttpServer())
        .get('/api/v1/users')
        .expect(200)
        .expect((res) => {
          expect(res.body).toHaveLength(2);
          expect(res.body[0]).toMatchObject({
            id: expect.any(String),
            name: expect.any(String),
            email: expect.any(String),
          });
        });
    });

    it('should support pagination', () => {
      return request(app.getHttpServer())
        .get('/api/v1/users?page=1&limit=1')
        .expect(200)
        .expect((res) => {
          expect(res.body).toHaveLength(1);
        });
    });
  });
});
```

### Workflow Testing

```typescript
describe('User Management Workflow (e2e)', () => {
  let app: INestApplication;
  let userId: string;

  beforeAll(async () => {
    // Setup app...
  });

  it('should handle complete user lifecycle', async () => {
    // 1. Create user
    const createResponse = await request(app.getHttpServer())
      .post('/api/v1/users')
      .send({
        name: 'John Doe',
        email: 'john@example.com',
      })
      .expect(201);

    userId = createResponse.body.id;

    // 2. Retrieve user
    await request(app.getHttpServer())
      .get(`/api/v1/users/${userId}`)
      .expect(200)
      .expect((res) => {
        expect(res.body.name).toBe('John Doe');
      });

    // 3. Update user
    await request(app.getHttpServer())
      .put(`/api/v1/users/${userId}`)
      .send({
        name: 'John Smith',
        email: 'john.smith@example.com',
      })
      .expect(200)
      .expect((res) => {
        expect(res.body.name).toBe('John Smith');
      });

    // 4. Verify update
    await request(app.getHttpServer())
      .get(`/api/v1/users/${userId}`)
      .expect(200)
      .expect((res) => {
        expect(res.body.name).toBe('John Smith');
      });

    // 5. Delete user
    await request(app.getHttpServer())
      .delete(`/api/v1/users/${userId}`)
      .expect(204);

    // 6. Verify deletion
    await request(app.getHttpServer())
      .get(`/api/v1/users/${userId}`)
      .expect(404);
  });
});
```

## Test Database

### In-Memory Database (Fast)

```typescript
const testConfig: TypeOrmModuleOptions = {
  type: 'sqlite',
  database: ':memory:',
  entities: [User, Post],
  synchronize: true,
  logging: false,
};
```

### Docker Test Database (Realistic)

```typescript
// Using Testcontainers
const container = await new PostgreSqlContainer('postgres:16-alpine')
  .withDatabase('test_db')
  .withUsername('test_user')
  .withPassword('test_pass')
  .start();

const testConfig: TypeOrmModuleOptions = {
  type: 'postgres',
  host: container.getHost(),
  port: container.getPort(),
  username: 'test_user',
  password: 'test_pass',
  database: 'test_db',
  entities: [User, Post],
  synchronize: true,
};
```

### Test Data Management

```typescript
// Fixtures for consistent test data
export const userFixtures = {
  validUser: {
    name: 'John Doe',
    email: 'john@example.com',
  },
  adminUser: {
    name: 'Admin User',
    email: 'admin@example.com',
    role: 'admin',
  },
};

// Helper functions
export async function createTestUser(
  app: INestApplication,
  userData = userFixtures.validUser,
) {
  const response = await request(app.getHttpServer())
    .post('/api/v1/users')
    .send(userData)
    .expect(201);

  return response.body;
}
```

## Mocking Strategies

### Repository Mocking

```typescript
const mockRepository = {
  find: jest.fn(),
  findOne: jest.fn(),
  save: jest.fn(),
  delete: jest.fn(),
  create: jest.fn().mockImplementation((dto) => dto),
  update: jest.fn(),
};
```

### External Service Mocking

```typescript
// Mock external HTTP calls
jest.mock('@nestjs/axios', () => ({
  HttpService: jest.fn().mockImplementation(() => ({
    get: jest.fn(),
    post: jest.fn(),
  })),
}));

// Mock file system operations
jest.mock('fs/promises', () => ({
  readFile: jest.fn(),
  writeFile: jest.fn(),
  unlink: jest.fn(),
}));
```

### Environment Mocking

```typescript
const originalEnv = process.env;

beforeEach(() => {
  process.env = {
    ...originalEnv,
    NODE_ENV: 'test',
    DB_HOST: 'localhost',
    DB_PORT: '5432',
  };
});

afterEach(() => {
  process.env = originalEnv;
});
```

## Code Coverage

### Coverage Configuration

```javascript
// jest.config.js
coverageThreshold: {
  global: {
    branches: 80,
    functions: 80,
    lines: 80,
    statements: 80,
  },
  // Per-file thresholds
  './src/users/users.service.ts': {
    branches: 90,
    functions: 90,
    lines: 90,
    statements: 90,
  },
},
```

### Running Coverage Reports

```bash
# Generate coverage report
npm run test:cov

# View HTML report
open coverage/lcov-report/index.html

# Check coverage thresholds
npm run test:cov -- --coverage --passWithNoTests
```

### Coverage Best Practices

1. **Focus on critical paths** - Ensure high coverage for business logic
2. **Don't chase 100%** - Aim for meaningful coverage, not perfect scores
3. **Exclude generated code** - Don't test auto-generated files
4. **Test edge cases** - Cover error conditions and boundary cases

## Performance Testing

### Load Testing Setup

```typescript
// performance.spec.ts
describe('Performance Tests', () => {
  let app: INestApplication;

  beforeAll(async () => {
    // Setup app with production-like config
  });

  it('should handle concurrent requests', async () => {
    const requests = Array.from({ length: 100 }, () =>
      request(app.getHttpServer()).get('/api/v1/users').expect(200),
    );

    const startTime = Date.now();
    await Promise.all(requests);
    const endTime = Date.now();

    const totalTime = endTime - startTime;
    const avgTime = totalTime / requests.length;

    expect(avgTime).toBeLessThan(100); // Average response < 100ms
  });
});
```

### Memory Leak Testing

```typescript
it('should not leak memory', async () => {
  const initialMemory = process.memoryUsage().heapUsed;

  // Perform operations that might leak
  for (let i = 0; i < 1000; i++) {
    await service.create({ name: `User ${i}`, email: `user${i}@test.com` });
    await service.findAll();
  }

  // Force garbage collection
  global.gc && global.gc();

  const finalMemory = process.memoryUsage().heapUsed;
  const memoryIncrease = finalMemory - initialMemory;

  expect(memoryIncrease).toBeLessThan(50 * 1024 * 1024); // Less than 50MB
});
```

## Testing Best Practices

### Test Organization

1. **Describe blocks**: Group related tests logically
2. **Clear test names**: Describe what is being tested and expected outcome
3. **AAA pattern**: Arrange, Act, Assert
4. **One assertion per test**: Keep tests focused

```typescript
describe('UsersService', () => {
  describe('when creating a user', () => {
    describe('with valid data', () => {
      it('should return the created user with an ID', async () => {
        // Arrange
        const userData = { name: 'John', email: 'john@test.com' };
        mockRepository.save.mockResolvedValue({ id: '1', ...userData });

        // Act
        const result = await service.create(userData);

        // Assert
        expect(result).toEqual({ id: '1', ...userData });
      });
    });

    describe('with invalid email', () => {
      it('should throw a validation error', async () => {
        // Arrange
        const userData = { name: 'John', email: 'invalid' };

        // Act & Assert
        await expect(service.create(userData)).rejects.toThrow(
          'Invalid email format',
        );
      });
    });
  });
});
```

### Test Data Management

```typescript
// Use factories for consistent test data
class UserFactory {
  static create(overrides: Partial<User> = {}): User {
    return {
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
      createdAt: new Date(),
      updatedAt: new Date(),
      ...overrides,
    };
  }

  static createMany(count: number, overrides: Partial<User> = {}): User[] {
    return Array.from({ length: count }, (_, index) =>
      this.create({ id: String(index + 1), ...overrides }),
    );
  }
}

// Usage in tests
it('should process multiple users', async () => {
  const users = UserFactory.createMany(5);
  mockRepository.find.mockResolvedValue(users);

  const result = await service.findAll();

  expect(result).toHaveLength(5);
});
```

### Async Testing

```typescript
// Use async/await consistently
it('should handle async operations', async () => {
  const promise = service.asyncOperation();

  await expect(promise).resolves.toBe('success');
});

// Test promise rejections
it('should handle errors', async () => {
  const promise = service.failingOperation();

  await expect(promise).rejects.toThrow('Operation failed');
});
```

## CI/CD Integration

### GitHub Actions Workflow

```yaml
# .github/workflows/test.yml
name: Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_PASSWORD: test_password
          POSTGRES_DB: test_db
        options: >-
          --health-cmd pg_isready --health-interval 10s --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run linting
        run: npm run lint:check

      - name: Run unit tests
        run: npm run test:cov

      - name: Run e2e tests
        run: npm run test:e2e
        env:
          DB_HOST: localhost
          DB_PORT: 5432
          DB_USERNAME: postgres
          DB_PASSWORD: test_password
          DB_NAME: test_db

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage/lcov.info
```

### Pre-commit Hooks

```json
// package.json
{
  "husky": {
    "hooks": {
      "pre-commit": "lint-staged",
      "pre-push": "npm run test:all"
    }
  },
  "lint-staged": {
    "*.{ts,js}": [
      "eslint --fix",
      "prettier --write",
      "npm run test -- --findRelatedTests --passWithNoTests"
    ]
  }
}
```

## Troubleshooting

### Common Test Issues

1. **Tests timing out**

   ```javascript
   // Increase timeout for specific tests
   it('should handle long operation', async () => {
     // Test implementation
   }, 10000); // 10 second timeout
   ```

2. **Database connection issues**

   ```typescript
   // Ensure proper cleanup
   afterAll(async () => {
     await dataSource?.destroy();
   });
   ```

3. **Mock not working**

   ```typescript
   // Clear mocks between tests
   beforeEach(() => {
     jest.clearAllMocks();
   });
   ```

4. **Memory leaks in tests**
   ```typescript
   // Properly close applications
   afterAll(async () => {
     await app?.close();
   });
   ```

### Debugging Tests

```bash
# Debug specific test
npm run test:debug -- --testNamePattern="should create user"

# Run tests in watch mode
npm run test:watch

# Verbose output
npm run test -- --verbose

# Run only changed files
npm run test -- --onlyChanged
```

---

This comprehensive testing guide ensures that your NestJS application maintains
high quality, reliability, and performance. Regular testing practices will help
catch bugs early and provide confidence when deploying to production.

**Next:** Learn about [Docker Usage](docker.md) for containerized development
and deployment.
