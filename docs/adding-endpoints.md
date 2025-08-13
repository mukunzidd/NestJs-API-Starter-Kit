# Adding New Endpoints

This guide will walk you through the process of adding new API endpoints to the
NestJS starter kit, following best practices and established patterns.

## Table of Contents

- [Project Structure](#project-structure)
- [Creating a New Feature Module](#creating-a-new-feature-module)
- [Step-by-Step Guide](#step-by-step-guide)
- [Logging](#logging)
- [Validation](#validation)
- [Error Handling](#error-handling)
- [Testing](#testing)
- [Example Implementation](#example-implementation)

## Project Structure

The project follows a modular structure:

```
src/
├── common/           # Shared utilities, decorators, guards, etc.
├── config/           # Configuration management
├── database/         # Database configuration and migrations
├── health/           # Health check endpoints
└── [feature]/        # Feature modules
    ├── dto/          # Data Transfer Objects
    ├── entities/     # TypeORM entities
    ├── [feature].controller.ts
    ├── [feature].service.ts
    ├── [feature].module.ts
    └── tests/        # Feature-specific tests
```

## Package Manager Commands

All examples in this guide use `npm run`, but you can substitute with your
preferred package manager:

| Command Type        | npm                            | bun                            | pnpm                            | yarn                        |
| ------------------- | ------------------------------ | ------------------------------ | ------------------------------- | --------------------------- |
| **Run Script**      | `npm run <script>`             | `bun run <script>`             | `pnpm run <script>`             | `yarn <script>`             |
| **Install Package** | `npm install <pkg>`            | `bun add <pkg>`                | `pnpm add <pkg>`                | `yarn add <pkg>`            |
| **Dev Install**     | `npm install -D <pkg>`         | `bun add -d <pkg>`             | `pnpm add -D <pkg>`             | `yarn add -D <pkg>`         |
| **Generate**        | `npm run nest g <type> <name>` | `bun run nest g <type> <name>` | `pnpm run nest g <type> <name>` | `yarn nest g <type> <name>` |

## Creating a New Feature Module

### 1. Create the Module Structure

```bash
# Create directories
mkdir -p src/users/dto
mkdir -p src/users/entities
mkdir -p src/users/tests

# OR use NestJS CLI to generate the module structure
npm run nest g module users                    # npm
# bun run nest g module users                  # bun
# pnpm run nest g module users                 # pnpm
# yarn nest g module users                     # yarn

npm run nest g controller users                # npm
# bun run nest g controller users              # bun
# pnpm run nest g controller users             # pnpm
# yarn nest g controller users                 # yarn

npm run nest g service users                   # npm
# bun run nest g service users                 # bun
# pnpm run nest g service users                # pnpm
# yarn nest g service users                    # yarn
```

### 2. Create the Entity (if using database)

```typescript
// src/users/entities/user.entity.ts
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  email: string;

  @Column()
  firstName: string;

  @Column()
  lastName: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
```

### 3. Create DTOs

```typescript
// src/users/dto/create-user.dto.ts
import { IsEmail, IsNotEmpty, IsString, MinLength } from 'class-validator';

export class CreateUserDto {
  @IsEmail()
  @IsNotEmpty()
  email: string;

  @IsString()
  @IsNotEmpty()
  @MinLength(2)
  firstName: string;

  @IsString()
  @IsNotEmpty()
  @MinLength(2)
  lastName: string;
}
```

```typescript
// src/users/dto/update-user.dto.ts
import { PartialType } from '@nestjs/mapped-types';
import { CreateUserDto } from './create-user.dto';

export class UpdateUserDto extends PartialType(CreateUserDto) {}
```

### 4. Create the Service

```typescript
// src/users/users.service.ts
import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';

@Injectable()
export class UsersService {
  private readonly logger = new Logger(UsersService.name);

  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  async create(createUserDto: CreateUserDto): Promise<User> {
    this.logger.log(`Creating new user with email: ${createUserDto.email}`);

    try {
      const user = this.userRepository.create(createUserDto);
      const savedUser = await this.userRepository.save(user);

      this.logger.log(`User created successfully with ID: ${savedUser.id}`);
      return savedUser;
    } catch (error) {
      this.logger.error(`Failed to create user: ${error.message}`, error.stack);
      throw error;
    }
  }

  async findAll(): Promise<User[]> {
    this.logger.log('Fetching all users');
    return this.userRepository.find();
  }

  async findOne(id: string): Promise<User> {
    this.logger.log(`Fetching user with ID: ${id}`);

    const user = await this.userRepository.findOne({ where: { id } });

    if (!user) {
      this.logger.warn(`User not found with ID: ${id}`);
      throw new NotFoundException(`User with ID ${id} not found`);
    }

    return user;
  }

  async update(id: string, updateUserDto: UpdateUserDto): Promise<User> {
    this.logger.log(`Updating user with ID: ${id}`);

    const user = await this.findOne(id);
    const updatedUser = await this.userRepository.save({
      ...user,
      ...updateUserDto,
    });

    this.logger.log(`User updated successfully with ID: ${id}`);
    return updatedUser;
  }

  async remove(id: string): Promise<void> {
    this.logger.log(`Removing user with ID: ${id}`);

    const user = await this.findOne(id);
    await this.userRepository.remove(user);

    this.logger.log(`User removed successfully with ID: ${id}`);
  }
}
```

### 5. Create the Controller

```typescript
// src/users/users.controller.ts
import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  HttpCode,
  HttpStatus,
  Logger,
  ParseUUIDPipe,
} from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';

@Controller({ path: 'users', version: '1' })
export class UsersController {
  private readonly logger = new Logger(UsersController.name);

  constructor(private readonly usersService: UsersService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(@Body() createUserDto: CreateUserDto) {
    this.logger.log(
      `POST /users - Creating user with email: ${createUserDto.email}`,
    );
    return this.usersService.create(createUserDto);
  }

  @Get()
  async findAll() {
    this.logger.log('GET /users - Fetching all users');
    return this.usersService.findAll();
  }

  @Get(':id')
  async findOne(@Param('id', ParseUUIDPipe) id: string) {
    this.logger.log(`GET /users/${id} - Fetching user`);
    return this.usersService.findOne(id);
  }

  @Patch(':id')
  async update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() updateUserDto: UpdateUserDto,
  ) {
    this.logger.log(`PATCH /users/${id} - Updating user`);
    return this.usersService.update(id, updateUserDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(@Param('id', ParseUUIDPipe) id: string) {
    this.logger.log(`DELETE /users/${id} - Removing user`);
    await this.usersService.remove(id);
  }
}
```

### 6. Create the Module

```typescript
// src/users/users.module.ts
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { User } from './entities/user.entity';

@Module({
  imports: [TypeOrmModule.forFeature([User])],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService], // Export if other modules need to use this service
})
export class UsersModule {}
```

### 7. Register the Module

```typescript
// src/app.module.ts
import { Module } from '@nestjs/common';
// ... other imports
import { UsersModule } from './users/users.module';

@Module({
  imports: [
    // ... other modules
    UsersModule,
  ],
  // ...
})
export class AppModule {}
```

## Logging

The starter kit supports multiple logging levels and formats:

### Log Levels Available

- `error` - Only error messages
- `warn` - Error and warning messages
- `log` - Error, warning, and general log messages
- `debug` - All above plus debug information
- `verbose` - All log levels including verbose output

### Configuration

Set logging level via environment variables:

```bash
LOG_LEVEL=debug
LOG_FORMAT=json  # or 'pretty' for development
```

### Using Loggers in Your Code

```typescript
import { Logger } from '@nestjs/common';

@Injectable()
export class YourService {
  private readonly logger = new Logger(YourService.name);

  someMethod() {
    this.logger.log('General information');
    this.logger.debug('Debug information');
    this.logger.warn('Warning message');
    this.logger.error('Error occurred', error.stack);
    this.logger.verbose('Detailed verbose information');
  }
}
```

### Automatic Request Logging

The `LoggingInterceptor` automatically logs:

- Incoming requests with method, URL, IP, and user agent
- Request body, query parameters, and route parameters
- Response status codes and response times
- Error details for failed requests

## Validation

The starter kit uses `class-validator` for automatic validation:

### Common Validation Decorators

```typescript
import {
  IsString,
  IsEmail,
  IsNumber,
  IsOptional,
  IsNotEmpty,
  MinLength,
  MaxLength,
  IsUUID,
  IsDate,
  IsEnum,
  ValidateNested,
  Type,
} from 'class-validator';

export class ExampleDto {
  @IsString()
  @IsNotEmpty()
  @MinLength(2)
  @MaxLength(50)
  name: string;

  @IsEmail()
  email: string;

  @IsNumber()
  @IsOptional()
  age?: number;

  @IsUUID()
  userId: string;

  @IsDate()
  @Type(() => Date)
  birthDate: Date;

  @IsEnum(['admin', 'user'])
  role: string;
}
```

### Custom Validation Pipes

```typescript
// src/common/pipes/parse-date.pipe.ts
import { PipeTransform, Injectable, BadRequestException } from '@nestjs/common';

@Injectable()
export class ParseDatePipe implements PipeTransform<string, Date> {
  transform(value: string): Date {
    const date = new Date(value);
    if (isNaN(date.getTime())) {
      throw new BadRequestException('Invalid date format');
    }
    return date;
  }
}
```

## Error Handling

The `GlobalExceptionFilter` automatically handles errors and returns consistent
error responses:

### Standard Error Response Format

```json
{
  "statusCode": 400,
  "message": "Validation failed",
  "error": "Bad Request",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "path": "/api/v1/users",
  "method": "POST",
  "errors": [
    {
      "field": "email",
      "message": "email must be an email",
      "value": "invalid-email"
    }
  ]
}
```

### Custom Exceptions

```typescript
import { HttpException, HttpStatus } from '@nestjs/common';

export class UserAlreadyExistsException extends HttpException {
  constructor(email: string) {
    super(
      {
        statusCode: HttpStatus.CONFLICT,
        message: `User with email ${email} already exists`,
        error: 'UserAlreadyExists',
      },
      HttpStatus.CONFLICT,
    );
  }
}
```

## Testing

### Unit Tests

Run tests with your package manager:

```bash
npm test                    # npm - run unit tests
# bun test                  # bun - run unit tests
# pnpm test                 # pnpm - run unit tests
# yarn test                 # yarn - run unit tests

npm run test:watch          # npm - run in watch mode
# bun test --watch          # bun - run in watch mode
# pnpm run test:watch       # pnpm - run in watch mode
# yarn test:watch           # yarn - run in watch mode
```

```typescript
// src/users/tests/users.service.spec.ts
import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UsersService } from '../users.service';
import { User } from '../entities/user.entity';

describe('UsersService', () => {
  let service: UsersService;
  let repository: Repository<User>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        {
          provide: getRepositoryToken(User),
          useValue: {
            create: jest.fn(),
            save: jest.fn(),
            find: jest.fn(),
            findOne: jest.fn(),
            remove: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
    repository = module.get<Repository<User>>(getRepositoryToken(User));
  });

  describe('create', () => {
    it('should create a user', async () => {
      const createUserDto = {
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
      };

      const user = { id: '123', ...createUserDto } as User;

      jest.spyOn(repository, 'create').mockReturnValue(user);
      jest.spyOn(repository, 'save').mockResolvedValue(user);

      const result = await service.create(createUserDto);

      expect(repository.create).toHaveBeenCalledWith(createUserDto);
      expect(repository.save).toHaveBeenCalledWith(user);
      expect(result).toEqual(user);
    });
  });
});
```

### E2E Tests

Run E2E tests with your package manager:

```bash
npm run test:e2e            # npm - run E2E tests
# bun run test:e2e          # bun - run E2E tests
# pnpm run test:e2e         # pnpm - run E2E tests
# yarn test:e2e             # yarn - run E2E tests

npm run test:e2e:cov        # npm - run E2E tests with coverage
# bun run test:e2e:cov      # bun - run E2E tests with coverage
# pnpm run test:e2e:cov     # pnpm - run E2E tests with coverage
# yarn test:e2e:cov         # yarn - run E2E tests with coverage
```

```typescript
// test/users.e2e-spec.ts
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';

describe('Users (e2e)', () => {
  let app: INestApplication;

  beforeEach(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  it('/api/v1/users (POST)', () => {
    return request(app.getHttpServer())
      .post('/api/v1/users')
      .send({
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
      })
      .expect(201);
  });

  afterAll(async () => {
    await app.close();
  });
});
```

## Example Implementation

Here's a complete example of a simple `Posts` feature:

### 1. Entity

```typescript
// src/posts/entities/post.entity.ts
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('posts')
export class Post {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  title: string;

  @Column('text')
  content: string;

  @Column({ default: false })
  published: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
```

### 2. DTOs

```typescript
// src/posts/dto/create-post.dto.ts
import { IsString, IsNotEmpty, IsOptional, IsBoolean } from 'class-validator';

export class CreatePostDto {
  @IsString()
  @IsNotEmpty()
  title: string;

  @IsString()
  @IsNotEmpty()
  content: string;

  @IsBoolean()
  @IsOptional()
  published?: boolean = false;
}
```

### 3. Complete Module Setup

Follow the same pattern as the Users example above, adapting the field names and
business logic for posts.

## Best Practices

1. **Use descriptive logging** - Log important business operations with context
2. **Follow naming conventions** - Use plural for controllers
   (`UsersController`)
3. **Validate all inputs** - Use DTOs with validation decorators
4. **Handle errors gracefully** - Use appropriate HTTP status codes
5. **Write tests** - Both unit and integration tests
6. **Use TypeScript strictly** - Enable strict mode and use proper typing
7. **Document your APIs** - Consider adding Swagger decorators
8. **Use database transactions** - For complex operations that involve multiple
   entities

## Rate Limiting

All endpoints automatically inherit rate limiting from the global
`ThrottlerGuard`. You can customize limits per endpoint:

```typescript
import { Throttle } from '@nestjs/throttler';

@Throttle({ default: { limit: 10, ttl: 60000 } }) // 10 requests per minute
@Post()
async create(@Body() createUserDto: CreateUserDto) {
  return this.usersService.create(createUserDto);
}
```

## Development Workflow

### 1. Generate Module Structure

```bash
# Generate complete module structure
npm run nest g resource users --no-spec        # npm
# bun run nest g resource users --no-spec      # bun
# pnpm run nest g resource users --no-spec     # pnpm
# yarn nest g resource users --no-spec         # yarn

# This creates: module, controller, service, entity, and DTOs
```

### 2. Development Commands

```bash
# Start development server
npm run start:dev           # npm
# bun run start:dev         # bun
# pnpm run start:dev        # pnpm
# yarn start:dev            # yarn

# Run linting
npm run lint               # npm
# bun run lint             # bun
# pnpm run lint            # pnpm
# yarn lint                # yarn

# Run tests
npm run test:all           # npm - run all tests
# bun run test:all         # bun - run all tests
# pnpm run test:all        # pnpm - run all tests
# yarn test:all            # yarn - run all tests
```

### 3. Database Operations

```bash
# Generate migration after creating entities
npm run typeorm:migration:generate -- --name CreateUser    # npm
# bun run typeorm:migration:generate -- --name CreateUser  # bun
# pnpm run typeorm:migration:generate -- --name CreateUser # pnpm
# yarn typeorm:migration:generate --name CreateUser        # yarn

# Run migrations
npm run typeorm:migration:run       # npm
# bun run typeorm:migration:run     # bun
# pnpm run typeorm:migration:run    # pnpm
# yarn typeorm:migration:run        # yarn
```

## Next Steps

1. Create your entity and DTOs
2. Implement your service with proper logging
3. Create your controller with validation
4. Write tests for your endpoints
5. Register your module in `AppModule`
6. Test your endpoints using the health endpoint as a reference

For more examples, check the existing `health` module in the codebase.
