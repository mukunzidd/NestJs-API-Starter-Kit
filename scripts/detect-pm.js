#!/usr/bin/env node

/**
 * Package Manager Detection Script
 *
 * Automatically detects which package manager to use based on:
 * 1. Existing lock files
 * 2. User environment/preference
 * 3. Default fallback
 */

const fs = require('fs');
const path = require('path');

function detectPackageManager() {
  const root = process.cwd();

  // Check for lock files (most reliable indicator)
  const lockFiles = [
    { file: 'bun.lockb', pm: 'bun', command: 'bun' },
    { file: 'pnpm-lock.yaml', pm: 'pnpm', command: 'pnpm' },
    { file: 'yarn.lock', pm: 'yarn', command: 'yarn' },
    { file: 'package-lock.json', pm: 'npm', command: 'npm' },
  ];

  // Check for existing lock files
  for (const { file, pm, command } of lockFiles) {
    if (fs.existsSync(path.join(root, file))) {
      return { pm, command };
    }
  }

  // Check for user agent (when running via npm/pnpm/yarn/bun)
  const userAgent = process.env.npm_config_user_agent || '';
  if (userAgent.includes('bun')) return { pm: 'bun', command: 'bun' };
  if (userAgent.includes('pnpm')) return { pm: 'pnpm', command: 'pnpm' };
  if (userAgent.includes('yarn')) return { pm: 'yarn', command: 'yarn' };
  if (userAgent.includes('npm')) return { pm: 'npm', command: 'npm' };

  // Check for package manager availability
  const { execSync } = require('child_process');

  const checkCommand = (cmd) => {
    try {
      execSync(`${cmd} --version`, { stdio: 'ignore' });
      return true;
    } catch {
      return false;
    }
  };

  // Preferred order: bun > pnpm > yarn > npm
  if (checkCommand('bun')) return { pm: 'bun', command: 'bun' };
  if (checkCommand('pnpm')) return { pm: 'pnpm', command: 'pnpm' };
  if (checkCommand('yarn')) return { pm: 'yarn', command: 'yarn' };

  // npm is always available with Node.js
  return { pm: 'npm', command: 'npm' };
}

function getRunCommand(pm, script) {
  const commands = {
    npm: `npm run ${script}`,
    yarn: `yarn ${script}`,
    pnpm: `pnpm run ${script}`,
    bun: `bun run ${script}`,
  };

  return commands[pm] || `npm run ${script}`;
}

function getInstallCommand(pm) {
  const commands = {
    npm: 'npm install',
    yarn: 'yarn install',
    pnpm: 'pnpm install',
    bun: 'bun install',
  };

  return commands[pm] || 'npm install';
}

// CLI usage
if (require.main === module) {
  const args = process.argv.slice(2);
  const detected = detectPackageManager();

  if (args.includes('--install')) {
    console.log(getInstallCommand(detected.pm));
  } else if (args.includes('--run') && args[1]) {
    console.log(getRunCommand(detected.pm, args[1]));
  } else if (args.includes('--pm')) {
    console.log(detected.pm);
  } else if (args.includes('--command')) {
    console.log(detected.command);
  } else {
    console.log(JSON.stringify(detected, null, 2));
  }
}

module.exports = {
  detectPackageManager,
  getRunCommand,
  getInstallCommand,
};
