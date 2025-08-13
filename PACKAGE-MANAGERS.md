# Package Manager Support

This project supports all major Node.js package managers. Choose the one that
best fits your workflow.

## Supported Package Managers

### 🚀 Bun (Recommended for Development)

**Fastest installs and runtime performance**

```bash
# Install Bun
curl -fsSL https://bun.sh/install | bash

# Install dependencies
bun install

# Run scripts
bun run start:dev    # or just: bun start:dev
bun test            # or just: bun test
```

**Pros:**

- ⚡ Extremely fast installs and script execution
- 🔧 Built-in bundler, test runner, and runtime
- 📦 Drop-in replacement for npm/yarn
- 🎯 Optimized for modern JavaScript/TypeScript

### 💾 pnpm (Recommended for Disk Efficiency)

**Efficient disk space usage with symlinks**

```bash
# Install pnpm
npm install -g pnpm

# Install dependencies
pnpm install

# Run scripts
pnpm run start:dev   # or just: pnpm start:dev
pnpm test           # or just: pnpm test
```

**Pros:**

- 💿 Saves significant disk space with content-addressable storage
- ⚡ Fast installs after initial setup
- 🔒 Strict dependency resolution prevents phantom dependencies
- 🏢 Great for monorepos

### 📦 npm (Default)

**Comes with Node.js, universally supported**

```bash
# Already installed with Node.js
npm install

# Run scripts
npm run start:dev
npm test
```

**Pros:**

- ✅ No additional installation needed
- 🌍 Universal support and documentation
- 🛡️ Most stable and mature
- 📚 Extensive ecosystem knowledge

### 🧶 Yarn (Classic)

**Popular alternative with workspaces support**

```bash
# Install Yarn
npm install -g yarn

# Install dependencies
yarn install

# Run scripts
yarn start:dev      # no 'run' needed
yarn test
```

**Pros:**

- 📋 Excellent workspace/monorepo support
- 🔒 Yarn.lock provides deterministic builds
- ⚡ Parallel installs
- 🎨 Clean CLI output

## Auto-Detection

The project includes automatic package manager detection:

```bash
# Check which package manager will be used
node scripts/detect-pm.js

# Get install command
node scripts/detect-pm.js --install

# Get run command for a script
node scripts/detect-pm.js --run start:dev
```

## Lock Files

The project keeps all lock files in Git, so you can switch between package
managers:

- `package-lock.json` (npm)
- `yarn.lock` (yarn)
- `pnpm-lock.yaml` (pnpm)
- `bun.lockb` (bun)

To clean up and use only one package manager, delete the other lock files:

```bash
# Use only npm
rm yarn.lock pnpm-lock.yaml bun.lockb

# Use only bun
rm package-lock.json yarn.lock pnpm-lock.yaml

# Use only pnpm
rm package-lock.json yarn.lock bun.lockb

# Use only yarn
rm package-lock.json pnpm-lock.yaml bun.lockb
```

## Performance Comparison

| Package Manager | Install Time | Runtime Performance | Disk Usage    |
| --------------- | ------------ | ------------------- | ------------- |
| **Bun**         | 🟢 Fastest   | 🟢 Fastest          | 🟡 Average    |
| **pnpm**        | 🟢 Fast      | 🟡 Good             | 🟢 Best       |
| **Yarn**        | 🟡 Good      | 🟡 Good             | 🟡 Average    |
| **npm**         | 🔴 Slower    | 🟡 Good             | 🔴 Most space |

## Recommendations

### For Individual Projects

- **Development**: Use **Bun** for fastest iteration
- **Production**: Any package manager works
- **CI/CD**: Consider **pnpm** for caching benefits

### For Teams

- **New projects**: Start with **Bun** or **pnpm**
- **Existing projects**: Keep current package manager for consistency
- **Monorepos**: Use **pnpm** or **Yarn** workspaces

### For Deployment

All package managers produce the same `node_modules` structure, so deployment is
identical regardless of which you use during development.

## Migration Between Package Managers

```bash
# From npm to bun
rm package-lock.json
bun install

# From bun to pnpm
rm bun.lockb
pnpm install

# From any to npm
rm yarn.lock pnpm-lock.yaml bun.lockb
npm install
```

## Script Commands Reference

| Command     | npm                 | yarn             | pnpm             | bun                 |
| ----------- | ------------------- | ---------------- | ---------------- | ------------------- |
| Install     | `npm install`       | `yarn install`   | `pnpm install`   | `bun install`       |
| Add package | `npm install <pkg>` | `yarn add <pkg>` | `pnpm add <pkg>` | `bun add <pkg>`     |
| Run script  | `npm run <script>`  | `yarn <script>`  | `pnpm <script>`  | `bun run <script>`  |
| Test        | `npm test`          | `yarn test`      | `pnpm test`      | `bun test`          |
| Build       | `npm run build`     | `yarn build`     | `pnpm build`     | `bun run build`     |
| Dev server  | `npm run start:dev` | `yarn start:dev` | `pnpm start:dev` | `bun run start:dev` |

## Troubleshooting

### Different lock files causing issues?

```bash
# Clear all lock files and reinstall with your preferred manager
rm package-lock.json yarn.lock pnpm-lock.yaml bun.lockb
rm -rf node_modules
<your-package-manager> install
```

### Bun not finding scripts?

```bash
# Use explicit run command
bun run start:dev  # instead of: bun start:dev
```

### pnpm phantom dependency errors?

```bash
# This is intentional - fix by adding missing dependencies
pnpm add <missing-package>
```

The choice of package manager is entirely up to you and your team's preferences.
All work equally well with this NestJS starter kit!
