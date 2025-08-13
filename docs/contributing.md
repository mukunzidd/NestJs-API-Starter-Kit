# Contributing Guide

Thank you for your interest in contributing to the NestJS API Starter Kit! This
guide will help you understand our development process, coding standards, and
how to submit contributions effectively.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Contribution Types](#contribution-types)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing Requirements](#testing-requirements)
- [Pull Request Process](#pull-request-process)
- [Code Review Guidelines](#code-review-guidelines)
- [Documentation Standards](#documentation-standards)
- [Release Process](#release-process)
- [Community Support](#community-support)

## Code of Conduct

### Our Pledge

We are committed to creating a welcoming, inclusive, and harassment-free
environment for everyone, regardless of experience level, gender identity,
sexual orientation, disability, personal appearance, body size, race, ethnicity,
age, religion, or nationality.

### Expected Behavior

- Use welcoming and inclusive language
- Be respectful of different viewpoints and experiences
- Accept constructive criticism gracefully
- Focus on what is best for the community
- Show empathy towards other community members

### Unacceptable Behavior

- Harassment, trolling, or discriminatory language
- Public or private harassment
- Publishing private information without permission
- Other conduct that could reasonably be considered inappropriate

### Enforcement

Instances of abusive, harassing, or otherwise unacceptable behavior may be
reported by contacting the project maintainers. All complaints will be reviewed
and investigated promptly and fairly.

## Getting Started

### Prerequisites

Before contributing, ensure you have:

- **Node.js** 18.0.0 or higher
- **npm** 9.0.0 or higher
- **Git** 2.30.0 or higher
- **Docker** and **Docker Compose** (for containerized development)
- Basic knowledge of TypeScript, NestJS, and PostgreSQL

### First-time Contributor Setup

1. **Fork the Repository**

   ```bash
   # On GitHub, click "Fork" button
   # Then clone your fork
   git clone https://github.com/your-username/nestjs-api-starter-kit.git
   cd nestjs-api-starter-kit
   ```

2. **Add Upstream Remote**

   ```bash
   git remote add upstream https://github.com/original-username/nestjs-api-starter-kit.git
   git remote -v
   ```

3. **Install Dependencies**

   ```bash
   npm install
   ```

4. **Setup Environment**

   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

5. **Start Development Environment**

   ```bash
   # Option 1: Docker (Recommended)
   docker compose up -d

   # Option 2: Local development
   npm run start:dev
   ```

6. **Verify Setup**

   ```bash
   # Run tests
   npm run test:all

   # Check code quality
   npm run lint
   npm run format:check

   # Verify API is running
   curl http://localhost:3000/health/live
   ```

## Development Setup

### IDE Configuration

**VS Code (Recommended)**

Install recommended extensions:

```bash
code --install-extension esbenp.prettier-vscode
code --install-extension dbaeumer.vscode-eslint
code --install-extension ms-vscode.vscode-typescript-next
```

**WebStorm/IntelliJ**

- Enable ESLint: File → Settings → Languages & Frameworks → JavaScript → Code
  Quality Tools → ESLint
- Enable Prettier: File → Settings → Languages & Frameworks → JavaScript →
  Prettier

### Development Commands

```bash
# Development server with hot reload
npm run start:dev

# Debug mode
npm run start:debug

# Production build
npm run build

# Run tests
npm test                    # Unit tests
npm run test:e2e           # E2E tests
npm run test:all           # All tests
npm run test:cov           # With coverage

# Code quality
npm run lint               # Lint and fix
npm run format             # Format code
npm run lint:check         # Check without fixing
npm run format:check       # Check formatting

# Database operations
npm run typeorm:migration:generate -- -n MigrationName
npm run typeorm:migration:run
npm run typeorm:migration:revert

# Docker operations
docker compose up -d       # Start services
docker compose down        # Stop services
docker compose logs -f api # View logs
```

## Contribution Types

We welcome various types of contributions:

### Bug Fixes

- Fix existing functionality
- Improve error handling
- Resolve security vulnerabilities
- Performance optimizations

### New Features

- Add new endpoints or modules
- Implement new functionality
- Enhance existing features
- Add integrations

### Documentation

- Improve README and guides
- Add code comments
- Create tutorials
- Fix typos and clarity issues

### Testing

- Add missing test coverage
- Improve test quality
- Add integration tests
- Performance testing

### Tooling & Infrastructure

- Improve build processes
- Enhance CI/CD pipelines
- Update dependencies
- Docker improvements

### Examples

- Create example implementations
- Add use case demonstrations
- Build starter templates

## Development Workflow

### Branch Strategy

We use **Git Flow** with the following branch types:

- `main` - Production-ready code
- `develop` - Integration branch for features
- `feature/*` - New features
- `bugfix/*` - Bug fixes
- `hotfix/*` - Critical production fixes
- `release/*` - Release preparation
- `docs/*` - Documentation changes

### Feature Development Process

1. **Create Feature Branch**

   ```bash
   # Ensure you're on develop
   git checkout develop
   git pull upstream develop

   # Create feature branch
   git checkout -b feature/add-user-authentication
   ```

2. **Development Cycle**

   ```bash
   # Make changes
   # ... code development ...

   # Test changes
   npm run test:all
   npm run lint
   npm run format

   # Commit changes (see commit conventions below)
   git add .
   git commit -m "feat(auth): implement JWT authentication"
   ```

3. **Keep Branch Updated**

   ```bash
   # Regularly sync with upstream
   git fetch upstream
   git rebase upstream/develop
   ```

4. **Pre-submission Checklist**
   - [ ] All tests pass
   - [ ] Code follows style guidelines
   - [ ] Documentation updated
   - [ ] No TypeScript errors
   - [ ] Database migrations tested
   - [ ] Performance impact assessed

### Commit Conventions

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types:**

- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation changes
- `style` - Code style changes (formatting)
- `refactor` - Code refactoring
- `test` - Adding or updating tests
- `chore` - Maintenance tasks
- `perf` - Performance improvements
- `ci` - CI/CD changes
- `build` - Build system changes
- `revert` - Revert previous commit

**Examples:**

```bash
feat(auth): implement JWT authentication
fix(users): resolve email validation issue
docs(api): update endpoint documentation
test(users): add unit tests for user service
chore(deps): update NestJS to v10.3.3
```

## Coding Standards

### TypeScript Guidelines

1. **Type Safety**

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

2. **Interface vs Type**

   ```typescript
   // Good: Interface for object shapes
   interface UserConfig {
     maxRetries: number;
     timeout: number;
   }

   // Good: Type for unions and computed types
   type UserStatus = 'active' | 'inactive' | 'banned';
   ```

3. **Error Handling**

   ```typescript
   // Good: Specific exceptions
   if (!user) {
     throw new NotFoundException(`User with ID ${id} not found`);
   }

   // Avoid: Generic errors
   throw new Error('Something went wrong');
   ```

### NestJS Best Practices

1. **Dependency Injection**

   ```typescript
   @Injectable()
   export class UsersService {
     constructor(
       @InjectRepository(User)
       private readonly userRepository: Repository<User>,
       private readonly configService: ConfigService,
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
   }
   ```

3. **Module Organization**
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

- **Indentation**: 2 spaces
- **Quotes**: Single quotes for strings
- **Semicolons**: Required
- **Trailing commas**: Always
- **Line length**: 100 characters
- **File naming**: kebab-case with appropriate suffixes

### Import Organization

```typescript
// 1. Node.js built-ins
import { readFileSync } from 'fs';

// 2. External libraries
import { Injectable, Logger } from '@nestjs/common';
import { Repository } from 'typeorm';

// 3. Internal absolute imports
import { User } from '@/users/user.entity';
import { ConfigService } from '@/config/config.service';

// 4. Relative imports
import { CreateUserDto } from './dto/create-user.dto';
import { UserInterface } from './interfaces/user.interface';
```

## Testing Requirements

### Test Coverage

- **Minimum Coverage**: 80% (lines, functions, branches, statements)
- **Critical Code**: 90%+ coverage
- **New Features**: Must include tests
- **Bug Fixes**: Must include regression tests

### Test Types

1. **Unit Tests** (`.spec.ts`)

   ```typescript
   describe('UsersService', () => {
     let service: UsersService;

     beforeEach(async () => {
       const module = await Test.createTestingModule({
         providers: [UsersService, mockRepository],
       }).compile();

       service = module.get<UsersService>(UsersService);
     });

     describe('findOne', () => {
       it('should return user when found', async () => {
         // Arrange
         const userId = '1';
         const user = { id: userId, name: 'John' };
         jest.spyOn(repository, 'findOne').mockResolvedValue(user);

         // Act
         const result = await service.findOne(userId);

         // Assert
         expect(result).toEqual(user);
       });
     });
   });
   ```

2. **Integration Tests**

   ```typescript
   describe('UsersModule Integration', () => {
     let app: INestApplication;

     beforeAll(async () => {
       const moduleRef = await Test.createTestingModule({
         imports: [UsersModule, TestDatabaseModule],
       }).compile();

       app = moduleRef.createNestApplication();
       await app.init();
     });

     it('should create and retrieve user', async () => {
       // Test implementation
     });
   });
   ```

3. **E2E Tests** (`.e2e-spec.ts`)

   ```typescript
   describe('Users API (e2e)', () => {
     let app: INestApplication;

     beforeAll(async () => {
       // Setup
     });

     it('/users (POST)', () => {
       return request(app.getHttpServer())
         .post('/users')
         .send({ name: 'John', email: 'john@example.com' })
         .expect(201);
     });
   });
   ```

### Test Guidelines

- **One assertion per test**: Keep tests focused
- **AAA pattern**: Arrange, Act, Assert
- **Descriptive names**: Clearly state what is being tested
- **Mock external dependencies**: Isolate units under test
- **Clean up resources**: Proper test teardown

## Pull Request Process

### Before Submitting

1. **Self-Review Checklist**
   - [ ] Code follows style guidelines
   - [ ] Tests are written and passing
   - [ ] Documentation is updated
   - [ ] Commit messages follow conventions
   - [ ] No merge conflicts
   - [ ] Performance impact considered

2. **Pre-submission Commands**

   ```bash
   # Ensure latest changes
   git fetch upstream
   git rebase upstream/develop

   # Run quality checks
   npm run test:all
   npm run lint
   npm run format:check
   npm run build

   # Check for issues
   npm audit
   ```

### Submission Process

1. **Push to Fork**

   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create Pull Request**
   - Use GitHub's web interface
   - Fill out the PR template completely
   - Link related issues
   - Add appropriate labels
   - Request reviews from maintainers

### PR Template

```markdown
## Description

Brief description of changes and motivation.

## Type of Change

- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing

- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] E2E tests added/updated
- [ ] Manual testing completed

## Checklist

- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests are passing
- [ ] No breaking changes (or documented)

## Related Issues

Fixes #123
```

### PR Guidelines

- **Keep PRs focused**: One feature/fix per PR
- **Reasonable size**: Aim for <500 lines changed
- **Clear description**: Explain what and why
- **Include tests**: All changes must be tested
- **Update documentation**: Keep docs current

## Code Review Guidelines

### For Authors

- **Be responsive**: Address feedback promptly
- **Be open**: Accept constructive criticism
- **Explain decisions**: Justify design choices
- **Test suggestions**: Verify reviewer feedback works

### For Reviewers

- **Be constructive**: Focus on improving code quality
- **Be specific**: Point to exact lines and suggest solutions
- **Be timely**: Review within 2 business days
- **Check everything**: Code, tests, documentation

### Review Checklist

**Functionality**

- [ ] Code does what it's supposed to do
- [ ] Edge cases are handled
- [ ] Error handling is appropriate
- [ ] Performance is acceptable

**Code Quality**

- [ ] Code is readable and maintainable
- [ ] Follows project conventions
- [ ] No code duplication
- [ ] Appropriate abstractions

**Testing**

- [ ] Adequate test coverage
- [ ] Tests are meaningful
- [ ] Tests are maintainable
- [ ] Mock usage is appropriate

**Security**

- [ ] No security vulnerabilities
- [ ] Input validation is present
- [ ] Sensitive data is protected
- [ ] Authentication/authorization correct

## Documentation Standards

### Code Documentation

1. **Public APIs**

   ```typescript
   /**
    * Creates a new user with the provided data.
    * @param userData - The user creation data
    * @returns Promise resolving to the created user
    * @throws {ConflictException} When email already exists
    */
   async createUser(userData: CreateUserDto): Promise<User> {
     // Implementation
   }
   ```

2. **Complex Logic**

   ```typescript
   // Calculate user score based on activity and engagement
   // Uses weighted algorithm: activities (70%) + engagement (30%)
   const userScore = activities * 0.7 + engagement * 0.3;
   ```

3. **Configuration**
   ```typescript
   interface DatabaseConfig {
     /** Database host (default: localhost) */
     host: string;
     /** Database port (default: 5432) */
     port: number;
   }
   ```

### README Updates

When adding features, update:

- Feature list
- Installation instructions (if changed)
- Usage examples
- Configuration options
- API documentation links

### API Documentation

For new endpoints, document:

- HTTP method and path
- Request/response formats
- Authentication requirements
- Error responses
- Usage examples

## Release Process

### Versioning

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR** (1.0.0): Breaking changes
- **MINOR** (0.1.0): New features, backwards compatible
- **PATCH** (0.0.1): Bug fixes, backwards compatible

### Release Workflow

1. **Prepare Release**
   - Update CHANGELOG.md
   - Update version in package.json
   - Create release branch: `release/1.2.0`

2. **Testing**
   - Full test suite
   - Manual testing
   - Performance testing
   - Security audit

3. **Release**
   - Merge to main
   - Create Git tag
   - Create GitHub release
   - Publish to npm (if applicable)

4. **Post-release**
   - Merge back to develop
   - Update documentation
   - Announce release

## Community Support

### Getting Help

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: Questions and community support
- **Discord/Slack**: Real-time chat (if applicable)
- **Stack Overflow**: Tag questions with `nestjs-starter-kit`

### Reporting Issues

**Bug Reports**

```markdown
## Bug Description

Clear description of the issue

## Steps to Reproduce

1. Step one
2. Step two
3. Step three

## Expected Behavior

What should happen

## Actual Behavior

What actually happens

## Environment

- OS: [e.g., macOS 12.0]
- Node.js: [e.g., 18.19.0]
- npm: [e.g., 9.0.0]
- Project version: [e.g., 1.2.0]

## Additional Context

Screenshots, logs, etc.
```

**Feature Requests**

```markdown
## Feature Description

Clear description of the proposed feature

## Use Case

Why is this feature needed?

## Proposed Solution

How should it work?

## Alternative Solutions

Other approaches considered

## Additional Context

Related issues, examples, etc.
```

### Recognition

Contributors will be recognized through:

- Contributors section in README
- GitHub contributors page
- Release notes mentions
- Special recognition for significant contributions

---

Thank you for contributing to the NestJS API Starter Kit! Your contributions
help make this project better for everyone. If you have questions about
contributing, please don't hesitate to ask through GitHub Issues or Discussions.

**Next:** Learn about [Production Deployment](deployment.md) to understand how
to deploy the application to production environments.
