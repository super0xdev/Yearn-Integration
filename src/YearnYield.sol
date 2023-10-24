// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {VaultAPI} from "./VaultAPI.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract YearnYield is ReentrancyGuard {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using Address for address;

    struct UserInfo {
        uint256 depositedAmount;
        uint256 depositedShares;
    }

    mapping(address => UserInfo) public userInfo;

    address immutable stakingToken;
    address immutable yieldVault;


    constructor(address _stakingToken, address _yieldVault) {
        require(_stakingToken != address(0), "Invalid staking token address");
        require(_yieldVault != address(0), "Invalid yield vault address");

        stakingToken = _stakingToken;
        yieldVault = _yieldVault;
    }

    function deposit(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be greater than 0");
        require(IERC20(stakingToken).balanceOf(msg.sender) > amount, "Not enough balance");

        IERC20(stakingToken).safeTransferFrom(msg.sender, address(this), amount);
        IERC20(stakingToken).approve(yieldVault, amount);
        uint256 shares = VaultAPI(yieldVault).deposit(amount);

        userInfo[msg.sender] = UserInfo(amount, shares);
    }

    function withdraw(uint256 amount) external nonReentrant {
        UserInfo memory userDeposits = userInfo[msg.sender];
        require(
            userDeposits.depositedAmount > amount,
            "not enough to withdraw"
        );

        userInfo[msg.sender].depositedAmount -= amount;

        uint256 yieldAmount = VaultAPI(yieldVault).withdraw(amount);
        uint256 depositedAmount = userDeposits.depositedAmount;
        IERC20(stakingToken).safeTransfer(
            msg.sender,
            amount
        );

    }

    function withdrawAll() external nonReentrant {
        UserInfo memory userDeposits = userInfo[msg.sender];
        require(
            userDeposits.depositedAmount > 0,
            "No deposited amount"
        );

        uint256 shares = userDeposits.depositedShares;
        userInfo[msg.sender].depositedAmount = 0;
        userInfo[msg.sender].depositedShares = 0;

        uint256 yieldAmount = VaultAPI(yieldVault).withdraw(shares);
        uint256 depositedAmount = userDeposits.depositedAmount;
        IERC20(stakingToken).transfer(
            msg.sender,
            yieldAmount + depositedAmount
        );
    }
}

