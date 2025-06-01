// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {LiquidBurlToken} from "../src/LiquidBurlToken.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LiquidBurlTokenTest is Test {
    LiquidBurlToken public liquidBurlToken;
    LiquidBurlToken public liquidBurlTokenAutomated;
    ERC20Mock public burlToken;
    ERC20Mock public usdcToken;

    // IERC20 public burl;
    // IERC20 public usdc;

    address public owner = vm.addr(123);
    address public alice = vm.addr(456);

    uint256 public INITAL_MINT_AMOUNT = 50 * 10 ** 18;

    function setUp() public {
        // Setup Tokens
        burlToken = new ERC20Mock();
        burlToken.mint(owner, INITAL_MINT_AMOUNT);
        usdcToken = new ERC20Mock();
        usdcToken.mint(owner, INITAL_MINT_AMOUNT);
        liquidBurlToken = new LiquidBurlToken(
            owner,
            address(burlToken),
            address(usdcToken),
            false,
            "https://example.com/image.png",
            "LiquidBurlToken"
        );

        liquidBurlTokenAutomated = new LiquidBurlToken(
            owner,
            address(burlToken),
            address(usdcToken),
            true,
            "https://example.com/image.png",
            "LiquidBurlToken"
        );
        vm.prank(owner);
        burlToken.transfer(address(liquidBurlToken), INITAL_MINT_AMOUNT);
    }

    function test_initialSetup() public view {
        uint256 balance = burlToken.balanceOf(address(liquidBurlToken));
        assertEq(balance, INITAL_MINT_AMOUNT, "Initial balance mismatch");
        assertEq(
            liquidBurlToken.ownerOf(1),
            owner,
            "Owner of token 1 should be the owner"
        );
    }

    function test_depositBurl() public {
        uint256 depositAmount = 10 * 10 ** 18;
        burlToken.mint(owner, depositAmount);
        vm.startPrank(owner);
        burlToken.approve(address(liquidBurlToken), depositAmount);
        liquidBurlToken.depositBurl(depositAmount);
        vm.stopPrank();

        uint256 balance = burlToken.balanceOf(address(liquidBurlToken));
        assertEq(balance, INITAL_MINT_AMOUNT + depositAmount, "Deposit failed");
    }

    function test_withdrawBurl() public {
        uint256 withdrawAmount = 10 * 10 ** 18;
        vm.startPrank(owner);
        liquidBurlToken.withdrawBurl(withdrawAmount);
        vm.stopPrank();

        uint256 balance = burlToken.balanceOf(address(liquidBurlToken));
        assertEq(
            balance,
            INITAL_MINT_AMOUNT - withdrawAmount,
            "Withdraw failed"
        );
    }

    function test_witdrawUsdc() public {
        uint256 withdrawAmount = 10 * 10 ** 18;
        vm.startPrank(owner);
        usdcToken.transfer(address(liquidBurlToken), INITAL_MINT_AMOUNT);
        liquidBurlToken.withdrawUsdc(withdrawAmount);
        vm.stopPrank();

        uint256 balance = usdcToken.balanceOf(address(liquidBurlToken));
        assertEq(
            balance,
            INITAL_MINT_AMOUNT - withdrawAmount,
            "Withdraw failed"
        );
    }

    function test_checkThruUpkeep() public view {
        (bool isReady, ) = liquidBurlToken.checkUpkeep("");
        assertFalse(isReady, "Upkeep should be not ready");
    }

    function test_RevertNotAutomated() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                LiquidBurlToken.LiquidBurlToken_NotAutomated.selector
            )
        );
        liquidBurlToken.performUpkeep("");
    }

    function test_RevertInsufficientBalance() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                LiquidBurlToken.LiquidBurlToken_InsufficientBalance.selector
            )
        );
        liquidBurlTokenAutomated.performUpkeep("");
    }

    function test_RevertWhenTransferFrom() public {
        vm.startPrank(owner);
        vm.expectRevert(
            abi.encodeWithSelector(
                LiquidBurlToken.LiquidBurlToken_TransferNotAllowed.selector
            )
        );
        liquidBurlToken.transferFrom(address(liquidBurlToken), alice, 1);
        vm.stopPrank();
    }

    function test_RevertWhenSafeTransferFrom() public {
        vm.startPrank(owner);
        vm.expectRevert(
            abi.encodeWithSelector(
                LiquidBurlToken.LiquidBurlToken_TransferNotAllowed.selector
            )
        );
        liquidBurlToken.safeTransferFrom(address(liquidBurlToken), alice, 1);
        vm.stopPrank();
    }
}
