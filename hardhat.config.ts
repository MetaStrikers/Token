import * as dotenv from 'dotenv';

import '@nomiclabs/hardhat-waffle';

import { HardhatUserConfig, task } from 'hardhat/config';

import '@typechain/hardhat';
import 'hardhat-watcher';
import 'solidity-coverage';
import 'hardhat-gas-reporter';

dotenv.config();

task('accounts', 'Prints the list of accounts', async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

const accounts =
  process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [];

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
const hardhatConfig: HardhatUserConfig & { typechain: any } = {
  solidity: {
    version: '0.8.8',
    settings: {
      optimizer: {
        enabled: true,
        runs: 2000,
      },
    },
  },
  paths: {
    tests: './test',
  },
  networks: {
    local: {
      url: 'http://localhost:8545',
      accounts,
    },
    goerli: {
      url: process.env.GOERLI_NETWORK_URL ?? '',
      chainId: 5,
      accounts,
    },
    polygon: {
      url: process.env.POLYGON_NETWORK_URL ?? '',
      chainId: 137,
      accounts,
    },
    mumbai: {
      url: process.env.MUMBAI_NETWORK_URL ?? '',
      chainId: 80001,
      accounts,
    },
  },
  gasReporter: {
    enabled: true,
    currency: 'USD',
  },
  typechain: {
    outDir: './types',
    target: 'ethers-v5',
    alwaysGenerateOverloads: false,
  },
  watcher: {
    test: {
      tasks: ['test'],
      files: ['./test/**/*'],
      verbose: true,
    },
    compile: {
      tasks: ['clean', 'compile'],
      files: ['./contracts/**/*.'],
      verbose: true,
    },
  },
};

export default hardhatConfig;
