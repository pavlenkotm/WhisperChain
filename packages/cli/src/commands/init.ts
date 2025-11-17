/**
 * Init command - Initialize a new WhisperChain project
 */

import chalk from 'chalk';
import ora from 'ora';
import * as fs from 'fs';
import * as path from 'path';

interface InitOptions {
  template: string;
  name?: string;
}

export async function initCommand(options: InitOptions) {
  const spinner = ora('Initializing WhisperChain project...').start();

  try {
    const projectName = options.name || 'whisperchain-project';
    const projectPath = path.join(process.cwd(), projectName);

    // Create project directory
    if (fs.existsSync(projectPath)) {
      spinner.fail(`Directory ${projectName} already exists`);
      return;
    }

    fs.mkdirSync(projectPath, { recursive: true });

    // Create package.json based on template
    const packageJson = {
      name: projectName,
      version: '1.0.0',
      description: `WhisperChain ${options.template} project`,
      scripts: getScriptsForTemplate(options.template),
      dependencies: getDependenciesForTemplate(options.template),
    };

    fs.writeFileSync(
      path.join(projectPath, 'package.json'),
      JSON.stringify(packageJson, null, 2)
    );

    // Create .env file
    const envContent = getEnvTemplate(options.template);
    fs.writeFileSync(path.join(projectPath, '.env.example'), envContent);

    // Create README
    const readmeContent = getReadmeTemplate(projectName, options.template);
    fs.writeFileSync(path.join(projectPath, 'README.md'), readmeContent);

    spinner.succeed(chalk.green(`Project ${projectName} created successfully!`));

    console.log(chalk.blue('\nNext steps:'));
    console.log(chalk.white(`  cd ${projectName}`));
    console.log(chalk.white('  npm install'));
    console.log(chalk.white('  cp .env.example .env'));
    console.log(chalk.white('  npm start'));
  } catch (error: any) {
    spinner.fail('Failed to initialize project');
    console.error(chalk.red(error.message));
  }
}

function getScriptsForTemplate(template: string): Record<string, string> {
  const common = {
    test: 'jest',
    lint: 'eslint src',
  };

  switch (template) {
    case 'dapp':
      return {
        ...common,
        start: 'react-scripts start',
        build: 'react-scripts build',
      };
    case 'contract':
      return {
        ...common,
        compile: 'hardhat compile',
        deploy: 'hardhat run scripts/deploy.ts',
      };
    case 'backend':
      return {
        ...common,
        start: 'node dist/index.js',
        dev: 'ts-node src/index.ts',
        build: 'tsc',
      };
    default:
      return common;
  }
}

function getDependenciesForTemplate(template: string): Record<string, string> {
  return {
    '@whisperchain/sdk': '^1.0.0',
    '@whisperchain/types': '^1.0.0',
  };
}

function getEnvTemplate(template: string): string {
  return `# WhisperChain Environment Variables

# Blockchain RPC URLs
ETHEREUM_RPC_URL=https://eth.llamarpc.com
SOLANA_RPC_URL=https://api.mainnet-beta.solana.com

# Private Keys (DO NOT COMMIT!)
PRIVATE_KEY=

# API Keys
ETHERSCAN_API_KEY=
ALCHEMY_API_KEY=
`;
}

function getReadmeTemplate(name: string, template: string): string {
  return `# ${name}

WhisperChain ${template} project

## Getting Started

\`\`\`bash
npm install
cp .env.example .env
npm start
\`\`\`

## Documentation

Visit [WhisperChain Docs](https://github.com/pavlenkotm/WhisperChain) for more information.
`;
}
