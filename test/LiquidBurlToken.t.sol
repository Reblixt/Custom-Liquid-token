// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {LiquidBurlToken} from "../src/LiquidBurlToken.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract LiquidBurlTokenTest is Test {
    LiquidBurlToken public liquidBurlToken;
    ERC20Mock public burlToken;

    address public owner = vm.addr(123);

    uint256 public INITAL_MINT_AMOUNT = 50 * 10 ** 18;

    function setUp() public {
        liquidBurlToken = new LiquidBurlToken();
        burlToken = new ERC20Mock();
        burlToken.mint(owner, INITAL_MINT_AMOUNT);
    }

    function test_initialize() public {}
}
