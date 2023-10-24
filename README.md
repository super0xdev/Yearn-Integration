# Yearn Yield

YearnYield is a Foundry project that integrates with Yearn Vaults using VaultAPI interfaces. It allows users to deposit tokens into a vault and withdraw them, while earning interest from the vault's strategy.

## Installation

To install the project, you need to have [Foundry](https://foundrydao.com/) installed and configured on your machine. Then, clone this repository and run `foundry build` in the project directory.

## Usage

To use the project, you need to deploy the `YearnYield` contract with the following parameters:

- `_stakingToken`: The address of the ERC20 token that users can deposit and withdraw.
- `_yieldVault`: The address of the Yearn Vault that implements the VaultAPI interface and has the same underlying token as `_stakingToken`.

After deploying the contract, users can interact with it using the following functions:

- `deposit(uint256 amount, uint256 deadline)`: Allows a user to deposit `amount` of tokens into the vault. The user must approve the contract to spend their tokens before calling this function.
- `withdrawAll()`: Allows a user to withdraw their tokens and interest. The function also burns the user's shares from the vault.
- `withdraw()`: Allows a user to withdraw `amount` of tokens their tokens without interest.
