# 🐶 Husky Git Hooks & Commit Guidelines

This project uses [Husky](https://github.com/typicode/husky) to enforce code
quality and consistent commit practices through automated git hooks.

## 📋 Table of Contents

- [Overview](#overview)
- [Git Hooks Configured](#git-hooks-configured)
- [Commit Message Format](#commit-message-format)
- [Pre-commit Checks](#pre-commit-checks)
- [Commit Message Validation](#commit-message-validation)
- [Development Workflow](#development-workflow)
- [Troubleshooting](#troubleshooting)
- [Configuration Files](#configuration-files)

## 🎯 Overview

Husky automatically runs quality checks and validations when you make commits or
push code. This ensures:

- ✅ Code quality standards are maintained
- ✅ Consistent commit message format
- ✅ Tests pass before code is committed
- ✅ Code is properly linted and formatted
- ✅ No broken code reaches the repository

## 🔧 Git Hooks Configured

### Pre-commit Hook

Runs before each commit to ensure code quality:

```bash
# .husky/pre-commit
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

# Run lint-staged to check only staged files
npx lint-staged
```

**What it does:**

- Lints only staged files with ESLint
- Formats code with Prettier
- Runs type checking on staged TypeScript files
- Prevents commit if any checks fail

### Commit Message Hook

Validates commit messages against conventional commit format:

```bash
# .husky/commit-msg
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

# Validate commit message format
npx --no -- commitlint --edit ${1}
```

**What it does:**

- Validates commit message format
- Ensures messages follow conventional commit standards
- Prevents commits with poorly formatted messages

## 📝 Commit Message Format

We follow the [Conventional Commits](https://www.conventionalcommits.org/)
specification:

### Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types

- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Documentation only changes
- **style**: Changes that don't affect code meaning (formatting, missing
  semi-colons, etc.)
- **refactor**: Code change that neither fixes a bug nor adds a feature
- **perf**: Code change that improves performance
- **test**: Adding missing tests or correcting existing tests
- **chore**: Changes to build process or auxiliary tools
- **ci**: Changes to CI configuration files and scripts
- **build**: Changes that affect the build system or external dependencies

### Examples

#### ✅ Good Examples

```bash
# Feature addition
git commit -m "feat(auth): add JWT authentication middleware"

# Bug fix
git commit -m "fix(health): resolve database connection timeout issue"

# Documentation
git commit -m "docs(api): update health endpoint documentation"

# Refactoring
git commit -m "refactor(user): extract validation logic to separate service"

# With scope and body
git commit -m "feat(database): add user repository with CRUD operations

- Implement UserRepository class with TypeORM
- Add user entity with proper validation
- Include unit tests for repository methods"

# Breaking change
git commit -m "feat(api)!: change health endpoint response format

BREAKING CHANGE: Health endpoint now returns detailed status object instead of simple string"
```

#### ❌ Bad Examples

```bash
# Too vague
git commit -m "fix stuff"

# No type
git commit -m "updated user service"

# Wrong format
git commit -m "Fix: user authentication"

# Not descriptive
git commit -m "feat: changes"
```

### Scopes (Optional)

Common scopes in this project:

- `auth` - Authentication related
- `api` - API endpoints
- `database` - Database related changes
- `config` - Configuration changes
- `health` - Health check endpoints
- `docker` - Docker configuration
- `test` - Test related changes
- `docs` - Documentation changes

## 🔍 Pre-commit Checks

When you run `git commit`, the following checks are automatically performed:

### 1. ESLint

```bash
# Lints staged TypeScript files
eslint --fix '**/*.{ts,js}'
```

- Fixes automatically fixable issues
- Reports unfixable linting errors
- Blocks commit if errors remain

### 2. Prettier

```bash
# Formats staged files
prettier --write '**/*.{ts,js,json,md}'
```

- Automatically formats code to maintain consistency
- Adds formatted files back to the commit

### 3. Type Checking

```bash
# Checks TypeScript compilation
tsc --noEmit
```

- Verifies TypeScript compilation without emitting files
- Catches type errors before commit

### Configuration in `package.json`:

```json
{
  "lint-staged": {
    "*.{ts,js}": ["eslint --fix", "prettier --write"],
    "*.{json,md,yml,yaml}": ["prettier --write"]
  }
}
```

## 🚦 Development Workflow

### Normal Commit Process

1. **Stage your changes**:

   ```bash
   git add src/user/user.service.ts
   ```

2. **Commit with proper message**:

   ```bash
   git commit -m "feat(user): add user validation service"
   ```

3. **Hooks automatically run**:
   - Pre-commit: Lint and format staged files
   - Commit-msg: Validate commit message format

4. **Push when ready**:
   ```bash
   git push origin feature/user-validation
   ```

### If Hooks Fail

#### Pre-commit Hook Failure

```bash
$ git commit -m "feat(user): add new service"

✖ eslint --fix found errors:
  src/user/user.service.ts
    5:1  error  'UserService' is defined but never used  @typescript-eslint/no-unused-vars

husky - pre-commit hook exited with code 1 (error)
```

**Solution:**

1. Fix the linting errors
2. Re-stage the fixed files: `git add .`
3. Commit again: `git commit -m "feat(user): add user service"`

#### Commit Message Hook Failure

```bash
$ git commit -m "fix stuff"

✖ subject may not be empty [subject-empty]
✖ type may not be empty [type-empty]

husky - commit-msg hook exited with code 1 (error)
```

**Solution:** Use proper commit message format:

```bash
git commit -m "fix(auth): resolve login validation issue"
```

## 🛠️ Configuration Files

### Commitlint Configuration

**File**: `commitlint.config.js`

```javascript
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      [
        'feat', // New feature
        'fix', // Bug fix
        'docs', // Documentation
        'style', // Formatting changes
        'refactor', // Code refactoring
        'perf', // Performance improvements
        'test', // Adding tests
        'chore', // Maintenance tasks
        'ci', // CI/CD changes
        'build', // Build system changes
      ],
    ],
    'type-case': [2, 'always', 'lower-case'],
    'type-empty': [2, 'never'],
    'scope-case': [2, 'always', 'lower-case'],
    'subject-case': [
      2,
      'never',
      ['sentence-case', 'start-case', 'pascal-case', 'upper-case'],
    ],
    'subject-empty': [2, 'never'],
    'subject-full-stop': [2, 'never', '.'],
    'header-max-length': [2, 'always', 100],
  },
};
```

### Lint-staged Configuration

**File**: `package.json`

```json
{
  "lint-staged": {
    "*.{ts,js}": ["eslint --fix", "prettier --write"],
    "*.{json,md,yml,yaml}": ["prettier --write"]
  }
}
```

### Husky Configuration

**File**: `package.json`

```json
{
  "scripts": {
    "prepare": "husky"
  }
}
```

## 🔧 Troubleshooting

### Bypassing Hooks (Not Recommended)

```bash
# Skip pre-commit hooks (NOT recommended)
git commit -m "feat: emergency fix" --no-verify

# Skip commit-msg validation (NOT recommended)
git commit -m "quick fix" --no-verify
```

**⚠️ Warning**: Only use `--no-verify` in emergency situations!

### Fixing Hook Permissions

If hooks aren't running:

```bash
# Make hooks executable
chmod +x .husky/pre-commit
chmod +x .husky/commit-msg

# Reinstall husky
bun run prepare
```

### Updating Hook Configuration

After changing lint-staged or commitlint config:

```bash
# Reinstall hooks
bun install
bun run prepare
```

### Common Issues

#### Issue: "husky - command not found"

**Solution:**

```bash
bun install
bun run prepare
```

#### Issue: ESLint errors in commit hook

**Solution:**

```bash
# Fix linting issues
bun run lint:fix

# Re-add files and commit
git add .
git commit -m "fix(linting): resolve ESLint issues"
```

#### Issue: Prettier conflicts

**Solution:**

```bash
# Format all files
bun run format

# Re-add and commit
git add .
git commit -m "style: format code with prettier"
```

## 📚 Additional Resources

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Husky Documentation](https://typicode.github.io/husky/)
- [Commitlint](https://commitlint.js.org/)
- [Lint-staged](https://github.com/okonet/lint-staged)

## 🎯 Best Practices

1. **Write meaningful commit messages** - Help future developers understand
   changes
2. **Make atomic commits** - One logical change per commit
3. **Test before committing** - Run tests locally before pushing
4. **Keep commits focused** - Don't mix unrelated changes
5. **Use conventional format** - Helps with automated changelog generation
6. **Review staged changes** - Use `git diff --cached` before committing
7. **Fix hook failures immediately** - Don't bypass hooks without good reason

## 🚀 Benefits

- **Consistent code quality** - All code follows same standards
- **Better collaboration** - Clear commit history and messages
- **Automated changelog** - Conventional commits enable automatic release notes
- **Reduced bugs** - Catch issues before they reach the repository
- **Faster code reviews** - Consistent formatting and structure
