// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.10;

import "forge-std/Test.sol";
import "../src/YearnYield.sol";
import "../src/Mock/MockERC20.sol";
string constant vaultArtifact = "out/VaultAPI.sol/VaultAPI.json";

contract YearnYieldTest is Test {
    // Define the mock contracts
    MockToken stakingToken;
    VaultAPI yieldVault;

    // Define the contract under test
    YearnYield yieldContract;

    // Define some constants
    uint256 constant AMOUNT = 100 ether;
    uint256 constant SHARES = 50 ether;
    uint256 constant YIELD = 120 ether;

    // Set up the mock contracts and the contract under test
    function setUp() public {
        stakingToken = new MockToken();
        address _vaultAddress = deployCode(vaultArtifact);
        yieldVault = VaultAPI(_vaultAddress);
        yieldContract = new YearnYield(
            address(stakingToken),
            address(yieldVault)
        );
    }

    // Test the deposit function
    function testDeposit() public {
        // Mint some tokens to the caller
        stakingToken.mint(AMOUNT);

        // Approve the transfer to the contract
        stakingToken.approve(address(yieldContract), AMOUNT);

        // Call the deposit function
        yieldContract.deposit(AMOUNT);

        // Check the balances and shares
        assertEq(
            stakingToken.balanceOf(address(yieldContract)),
            AMOUNT,
            "Wrong balance of contract"
        );
        assertEq(
            yieldVault.balanceOf(address(yieldContract)),
            SHARES,
            "Wrong shares of contract"
        );
        assertEq(
            stakingToken.balanceOf(msg.sender),
            0,
            "Wrong balance of caller"
        );
        assertEq(yieldVault.balanceOf(msg.sender), 0, "Wrong shares of caller");

        // Check the user info
        (
            uint256 depositedAmount,
            uint256 depositedShares
        ) = yieldContract.userInfo(msg.sender);
        assertEq(depositedAmount, AMOUNT, "Wrong deposited amount");
        assertEq(depositedShares, SHARES, "Wrong deposited shares");
    }

    // Test the withdraw function
    function testWithdrawAll() public {
        // Set up the deposit scenario
        testDeposit();

        // Call the withdraw function
        yieldContract.withdrawAll();

        // Check the balances and shares
        assertEq(
            stakingToken.balanceOf(address(yieldContract)),
            0,
            "Wrong balance of contract"
        );
        assertEq(
            yieldVault.balanceOf(address(yieldContract)),
            0,
            "Wrong shares of contract"
        );
        assertEq(
            stakingToken.balanceOf(msg.sender),
            YIELD + AMOUNT,
            "Wrong balance of caller"
        );
        assertEq(yieldVault.balanceOf(msg.sender), 0, "Wrong shares of caller");
        assertEq(
            stakingToken.balanceOf(treasury),
            YIELD,
            "Wrong balance of treasury"
        );

        // Check the user info
        (
            uint256 depositedAmount,
            uint256 depositedShares
        ) = yieldContract.userInfo(msg.sender);
        assertEq(depositedAmount, 0, "Wrong deposited amount");
        assertEq(depositedShares, 0, "Wrong deposited shares");
    }
}
