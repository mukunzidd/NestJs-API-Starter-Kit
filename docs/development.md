# Development Guide

This guide covers the development workflow, best practices, and tooling for the
NestJS API Starter Kit. Follow these guidelines to maintain code quality and
consistency across the project.

## Table of Contents

- [Development Workflow](#development-workflow)
- [Code Organization](#code-organization)
- [Coding Standards](#coding-standards)
- [Git Workflow](#git-workflow)
- [IDE Setup](#ide-setup)
- [Debugging](#debugging)
- [Hot Reloading](#hot-reloading)
- [Database Development](#database-development)
- [API Development](#api-development)
- [Error Handling](#error-handling)
- [Logging](#logging)
- [Performance Optimization](#performance-optimization)
- [Security Considerations](#security-considerations)

## Development Workflow

### Daily Development Routine

1. **Start Development Environment**

   ```bash
   # Pull latest changes
   git pull origin main

   # Install any new dependencies
   npm install

   # Start development server
   npm run start:dev

   # Or with Docker
   docker compose up -d
   ```

2. **Feature Development Process**

   ```bash
   # Create feature branch
   git checkout -b feature/user-authentication

   # Make your changes
   # ... development work ...

   # Run tests
   npm run test:all

   # Check code quality
   npm run lint
   npm run format:check

   # Commit changes
   git add .
   git commit -m "feat: implement user authentication"

   # Push and create PR
   git push origin feature/user-authentication
   ```

3. **Pre-commit Checklist**
   - [ ] All tests pass (`npm run test:all`)
   - [ ] Code follows style guide (`npm run lint`)
   - [ ] Code is formatted (`npm run format`)
   - [ ] No TypeScript errors (`npm run build`)
   - [ ] Database migrations run successfully
   - [ ] Documentation updated if needed

### Environment-specific Development

```bash
# Development mode (default)
NODE_ENV=development npm run start:dev

# Debug mode with inspector
npm run start:debug

# Production simulation
NODE_ENV=production npm run build && npm run start:prod

# Test environment
NODE_ENV=test npm run test:e2e
```

## Code Organization

### Module-First Architecture

Organize code by domain modules rather than technical layers:

```
src/
├── app.module.ts           # Root module
├── main.ts                 # Bootstrap file
├── common/                 # Shared utilities
│   ├── decorators/         # Custom decorators
│   ├── filters/            # Exception filters
│   ├── guards/             # Route guards
│   ├── interceptors/       # HTTP interceptors
│   └── pipes/              # Validation pipes
├── config/                 # Configuration
├── database/               # Database setup
├── health/                 # Health checks
└── users/                  # User domain module
    ├── users.module.ts
    ├── users.controller.ts
    ├── users.service.ts
    ├── users.entity.ts
    ├── dto/
    │   ├── create-user.dto.ts
    │   └── update-user.dto.ts
    └── tests/
        ├── users.controller.spec.ts
        └── users.service.spec.ts
```

### File Naming Conventions

- **Controllers**: `*.controller.ts`
- **Services**: `*.service.ts`
- **Entities**: `*.entity.ts`
- **DTOs**: `*.dto.ts`
- **Interfaces**: `*.interface.ts`
- **Types**: `*.type.ts`
- **Modules**: `*.module.ts`
- **Tests**: `*.spec.ts` or `*.test.ts`
- **E2E Tests**: `*.e2e-spec.ts`

### Creating New Modules

Use the NestJS CLI to maintain consistency:

```bash
# Generate a complete module with controller and service
nest g resource users

# Generate individual components
nest g module users
nest g controller users
nest g service users
nest g interface users
```

### Import Organization

Organize imports in the following order:

```typescript
// 1. Node.js built-in modules
import { readFileSync } from 'fs';

// 2. External libraries
import { Injectable, Logger } from '@nestjs/common';
import { Repository } from 'typeorm';

// 3. Internal modules (absolute paths)
import { User } from '@/users/user.entity';
import { DatabaseService } from '@/database/database.service';

// 4. Relative imports
import { CreateUserDto } from './dto/create-user.dto';
import { UserInterface } from './interfaces/user.interface';
```

## Coding Standards

### TypeScript Best Practices

1. **Strict Type Checking**

   ```typescript
   // Good: Explicit types
   function createUser(userData: CreateUserDto): Promise<User> {
     return this.userRepository.save(userData);
   }

   // Avoid: Any types
   function createUser(userData: any): Promise<any> {
     return this.userRepository.save(userData);
   }
   ```

2. **Interface over Type for Objects**

   ```typescript
   // Good: Interface for object shapes
   interface UserConfig {
     maxRetries: number;
     timeout: number;
   }

   // Good: Type for unions and computed types
   type UserStatus = 'active' | 'inactive' | 'banned';
   type UserKeys = keyof User;
   ```

3. **Proper Error Handling**

   ```typescript
   @Injectable()
   export class UsersService {
     async findUser(id: string): Promise<User> {
       try {
         const user = await this.userRepository.findOne({ where: { id } });

         if (!user) {
           throw new NotFoundException(`User with ID ${id} not found`);
         }

         return user;
       } catch (error) {
         this.logger.error(`Failed to find user ${id}`, error.stack);
         throw error;
       }
     }
   }
   ```

### NestJS Best Practices

1. **Dependency Injection**

   ```typescript
   @Injectable()
   export class UsersService {
     constructor(
       @InjectRepository(User)
       private readonly userRepository: Repository<User>,
       private readonly logger: Logger,
     ) {}
   }
   ```

2. **DTOs for Validation**

   ```typescript
   import { IsEmail, IsString, MinLength } from 'class-validator';

   export class CreateUserDto {
     @IsString()
     @MinLength(2)
     name: string;

     @IsEmail()
     email: string;

     @IsString()
     @MinLength(8)
     password: string;
   }
   ```

3. **Proper Module Structure**
   ```typescript
   @Module({
     imports: [TypeOrmModule.forFeature([User])],
     controllers: [UsersController],
     providers: [UsersService],
     exports: [UsersService], // Export if used by other modules
   })
   export class UsersModule {}
   ```

### Code Style Rules

The project uses ESLint and Prettier with the following key rules:

- **Indentation**: 2 spaces
- **Quotes**: Single quotes for strings
- **Semicolons**: Required
- **Trailing commas**: Always
- **Line length**: 100 characters
- **Object literals**: Multi-line when exceeding line length

```typescript
// Good example following style guide
const userConfig = {
  name: 'John Doe',
  email: 'john@example.com',
  settings: {
    notifications: true,
    theme: 'dark',
  },
};
```

## Git Workflow

### Branch Strategy

Use **Git Flow** with the following branch types:

- `main` - Production-ready code
- `develop` - Integration branch for features
- `feature/*` - New features
- `bugfix/*` - Bug fixes
- `hotfix/*` - Critical production fixes
- `release/*` - Release preparation

### Commit Convention

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types:**

- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation changes
- `style` - Code style changes (formatting, etc.)
- `refactor` - Code refactoring
- `test` - Adding or updating tests
- `chore` - Maintenance tasks

**Examples:**

```
feat(auth): implement JWT authentication
fix(users): resolve email validation issue
docs(api): update endpoint documentation
test(users): add unit tests for user service
```

### Pull Request Process

1. **Create Feature Branch**

   ```bash
   git checkout -b feature/user-profile
   ```

2. **Make Changes and Commit**

   ```bash
   git add .
   git commit -m "feat(users): add user profile endpoint"
   ```

3. **Push and Create PR**

   ```bash
   git push origin feature/user-profile
   ```

4. **PR Requirements**
   - [ ] All checks pass (CI/CD)
   - [ ] Code review approved
   - [ ] Tests cover new functionality
   - [ ] Documentation updated
   - [ ] No merge conflicts

## IDE Setup

### VS Code Configuration

**Recommended Extensions:**

```json
{
  "recommendations": [
    "esbenp.prettier-vscode",
    "dbaeumer.vscode-eslint",
    "ms-vscode.vscode-typescript-next",
    "ms-vscode.vscode-json",
    "bradlc.vscode-tailwindcss",
    "ms-vscode-remote.remote-containers",
    "ms-azuretools.vscode-docker",
    "ckolkman.vscode-postgres"
  ]
}
```

**Settings (`.vscode/settings.json`):**

```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "typescript.preferences.importModuleSpecifier": "relative",
  "files.exclude": {
    "**/node_modules": true,
    "**/dist": true,
    "**/.git": true
  }
}
```

**Debug Configuration (`.vscode/launch.json`):**

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Launch NestJS",
      "type": "node",
      "request": "launch",
      "program": "${workspaceFolder}/src/main.ts",
      "args": [],
      "runtimeArgs": [
        "-r",
        "ts-node/register",
        "-r",
        "tsconfig-paths/register"
      ],
      "sourceMaps": true,
      "envFile": "${workspaceFolder}/.env",
      "cwd": "${workspaceFolder}",
      "console": "integratedTerminal"
    }
  ]
}
```

### IntelliJ/WebStorm Configuration

1. **Enable ESLint**: File → Settings → Languages & Frameworks → JavaScript →
   Code Quality Tools → ESLint
2. **Enable Prettier**: File → Settings → Languages & Frameworks → JavaScript →
   Prettier
3. **Configure TypeScript**: File → Settings → Languages & Frameworks →
   TypeScript
4. **Set up debugging**: Run → Edit Configurations → Add Node.js configuration

## Debugging

### Local Debugging

1. **Start Debug Server**

   ```bash
   npm run start:debug
   ```

2. **Attach Debugger**
   - VS Code: Use F5 or debug configuration
   - Chrome DevTools: Navigate to `chrome://inspect`
   - WebStorm: Attach to Node.js process

3. **Set Breakpoints**
   ```typescript
   @Get(':id')
   async findOne(@Param('id') id: string) {
     debugger; // Breakpoint here
     return this.usersService.findOne(id);
   }
   ```

### Docker Debugging

1. **Modify Docker Compose for Debugging**

   ```yaml
   api:
     command: npm run start:debug
     ports:
       - '3000:3000'
       - '9229:9229' # Debug port
   ```

2. **Attach Remote Debugger**
   ```json
   {
     "name": "Docker: Attach to Node",
     "type": "node",
     "request": "attach",
     "port": 9229,
     "address": "localhost",
     "localRoot": "${workspaceFolder}",
     "remoteRoot": "/usr/src/app",
     "protocol": "inspector"
   }
   ```

### Debugging Tips

- **Use proper logging levels** for different environments
- **Log request IDs** for tracing requests across services
- **Use structured logging** with context objects
- **Enable source maps** for better stack traces

## Hot Reloading

### Development Mode

Hot reloading is enabled by default in development:

```bash
npm run start:dev
```

**Features:**

- Automatic restart on file changes
- Preserves application state where possible
- Fast compilation with webpack HMR
- TypeScript incremental compilation

### Webpack HMR Configuration

The project uses webpack Hot Module Replacement:

```typescript
// webpack-hmr.config.js
if (module.hot) {
  module.hot.accept();
  module.hot.dispose(() => app.close());
}
```

### Troubleshooting Hot Reload

1. **Files not being watched**

   ```bash
   # Increase inotify limit (Linux)
   echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
   sudo sysctl -p
   ```

2. **Slow reload times**
   - Exclude `node_modules` from file watching
   - Use TypeScript project references
   - Optimize webpack configuration

## Database Development

### Migration Workflow

1. **Make Entity Changes**

   ```typescript
   @Entity()
   export class User {
     @Column()
     firstName: string; // New field added
   }
   ```

2. **Generate Migration**

   ```bash
   npm run typeorm:migration:generate -- -n AddFirstNameToUser
   ```

3. **Review Generated Migration**

   ```typescript
   export class AddFirstNameToUser implements MigrationInterface {
     public async up(queryRunner: QueryRunner): Promise<void> {
       await queryRunner.addColumn(
         'user',
         new TableColumn({
           name: 'firstName',
           type: 'varchar',
         }),
       );
     }
   }
   ```

4. **Run Migration**
   ```bash
   npm run typeorm:migration:run
   ```

### Database Best Practices

1. **Always use migrations** for schema changes
2. **Never edit existing migrations** after they're merged
3. **Include rollback logic** in down methods
4. **Test migrations** on copies of production data
5. **Use indexes** for frequently queried columns

### Seeding Data

```typescript
// src/database/seeds/user.seed.ts
export class UserSeed implements Seeder {
  async run(dataSource: DataSource): Promise<void> {
    const userRepository = dataSource.getRepository(User);

    const users = [
      { name: 'Admin User', email: 'admin@example.com' },
      { name: 'Test User', email: 'test@example.com' },
    ];

    await userRepository.save(users);
  }
}
```

## API Development

### RESTful API Design

Follow REST principles:

```typescript
@Controller('users')
export class UsersController {
  @Get() // GET /users
  findAll() {}

  @Get(':id') // GET /users/:id
  findOne(@Param('id') id: string) {}

  @Post() // POST /users
  create(@Body() createUserDto: CreateUserDto) {}

  @Put(':id') // PUT /users/:id
  update(@Param('id') id: string, @Body() updateUserDto: UpdateUserDto) {}

  @Delete(':id') // DELETE /users/:id
  remove(@Param('id') id: string) {}
}
```

### API Versioning

```typescript
@Controller({
  path: 'users',
  version: '1',
})
export class UsersV1Controller {}

@Controller({
  path: 'users',
  version: '2',
})
export class UsersV2Controller {}
```

### Request Validation

```typescript
import { IsEmail, IsString, MinLength, IsOptional } from 'class-validator';

export class CreateUserDto {
  @IsString()
  @MinLength(2)
  name: string;

  @IsEmail()
  email: string;

  @IsOptional()
  @IsString()
  phone?: string;
}
```

### Response Transformation

```typescript
@UseInterceptors(ClassSerializerInterceptor)
export class User {
  @Exclude()
  password: string;

  @Expose()
  get fullName(): string {
    return `${this.firstName} ${this.lastName}`;
  }
}
```

## Error Handling

### Global Exception Filter

```typescript
@Catch()
export class GlobalExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse();
    const request = ctx.getRequest();

    const status = this.getStatus(exception);
    const message = this.getMessage(exception);

    const errorResponse = {
      success: false,
      error: {
        code: this.getErrorCode(exception),
        message,
        timestamp: new Date().toISOString(),
        path: request.url,
      },
    };

    response.status(status).json(errorResponse);
  }
}
```

### Custom Exceptions

```typescript
export class UserNotFoundException extends NotFoundException {
  constructor(userId: string) {
    super(`User with ID ${userId} not found`, 'USER_NOT_FOUND');
  }
}
```

## Logging

### Structured Logging

```typescript
@Injectable()
export class UsersService {
  private readonly logger = new Logger(UsersService.name);

  async createUser(userData: CreateUserDto): Promise<User> {
    this.logger.log({
      action: 'create_user',
      email: userData.email,
      timestamp: new Date().toISOString(),
    });

    try {
      const user = await this.userRepository.save(userData);

      this.logger.log({
        action: 'user_created',
        userId: user.id,
        email: user.email,
      });

      return user;
    } catch (error) {
      this.logger.error({
        action: 'create_user_failed',
        email: userData.email,
        error: error.message,
      });
      throw error;
    }
  }
}
```

### Log Levels

- `error` - Error conditions
- `warn` - Warning conditions
- `info` - Informational messages
- `debug` - Debug-level messages
- `verbose` - Verbose logging

## Performance Optimization

### Database Query Optimization

```typescript
// Use select to limit returned fields
const users = await this.userRepository.find({
  select: ['id', 'name', 'email'],
  where: { active: true },
});

// Use relations efficiently
const userWithPosts = await this.userRepository.findOne({
  where: { id },
  relations: ['posts'],
});

// Use query builder for complex queries
const users = await this.userRepository
  .createQueryBuilder('user')
  .leftJoinAndSelect('user.posts', 'post')
  .where('user.active = :active', { active: true })
  .getMany();
```

### Caching Strategies

```typescript
@Injectable()
export class UsersService {
  @Cacheable(600) // Cache for 10 minutes
  async findAllUsers(): Promise<User[]> {
    return this.userRepository.find();
  }
}
```

### Response Compression

Already configured in `main.ts`:

```typescript
import compression from 'compression';
app.use(compression());
```

## Security Considerations

### Input Validation

- **Use DTOs** for all input validation
- **Sanitize input** to prevent injection attacks
- **Validate file uploads** carefully
- **Implement rate limiting** on sensitive endpoints

### Authentication & Authorization

```typescript
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('admin')
@Get('admin-only')
adminOnlyEndpoint() {
  return 'Admin content';
}
```

### Security Headers

Configured via Helmet:

```typescript
app.use(
  helmet({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        scriptSrc: ["'self'"],
      },
    },
  }),
);
```

### Environment Variables

- **Never commit secrets** to version control
- **Use strong secrets** in production
- **Rotate secrets regularly**
- **Use different secrets** for each environment

---

This development guide provides the foundation for maintaining high-quality,
consistent code in the NestJS API Starter Kit. Follow these practices to ensure
your application remains scalable, maintainable, and secure as it grows.

**Next:** Learn about [Testing Strategies](testing.md) to ensure code quality
and reliability.
