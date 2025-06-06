// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {Script, console} from "forge-std/Script.sol";
// import {LiquidBurlToken} from "../src/LiquidBurlToken.sol";
import {LiquidFactory} from "src/LiquidFactory.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract DeployLiquidBurlToken is Script {
    function setUp() public {}

    // Polygon Burl token address
    address burlToken = 0xdf5ba267619aB1ad4460C0FD7b562868Ed46F351;
    // Polygon USDC token address
    address usdcToken = 0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359;

    function run() public {
        vm.startBroadcast();
        address proxy = Upgrades.deployUUPSProxy(
            "LiquidFactory.sol",
            abi.encodeCall(LiquidFactory.initialize, (burlToken, usdcToken))
        );

        console.log("LiquidFactory deployed at:", proxy);

        vm.stopBroadcast();
    }
}
