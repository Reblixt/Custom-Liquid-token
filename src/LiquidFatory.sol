// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {LiquidBurlToken} from "./LiquidBurlToken.sol";

contract LiquidFactory is ReentrancyGuardUpgradeable, AccessControlUpgradeable {
    // ================ Type declaration ================
    IERC20 public burlToken;
    IERC20 public usdcToken;

    // ================ State variables ================
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

    string public contractMetadata =
        '{"name":"LiquidBurlToken","symbol": "LBT", "description":"A token representing liquid burl assets.","image":"https://example.com/image.png"}';
    string public imageUrl = "https://example.com/image.png";

    mapping(address => address) public ownerToLBT;
    mapping(address => address) public LBTToOwner;

    // ================ Events ================

    event LiquidBurlTokenCreated(
        address indexed owner,
        address indexed liquidBurlToken
    );
    event ContractMetadataUpdated();
    event ImageUrlUpdated(string imageUrl);

    // ================ Errors ================
    error LiquidFactory_LBTAlreadyExists(address owner);
    error LiquidFactory_NoLBTForOwner(address owner);
    error LiquidFactory_LBTNotEmpty(address liquidBurlToken);

    function initialize(
        address usdcToken_,
        address burlToken_
    ) external initializer {
        __ReentrancyGuard_init();
        __AccessControl_init();
        _setRoleAdmin(OWNER_ROLE, OWNER_ROLE);
        _grantRole(OWNER_ROLE, msg.sender);

        usdcToken = IERC20(usdcToken_);
        burlToken = IERC20(burlToken_);
    }

    function createLiquidBurlToken(
        bool isAutomated
    ) external onlyRole(OWNER_ROLE) returns (address) {
        address owner = msg.sender;
        require(
            ownerToLBT[owner] == address(0),
            LiquidFactory_LBTAlreadyExists(owner)
        );

        LiquidBurlToken newToken = new LiquidBurlToken(
            owner,
            address(burlToken),
            address(usdcToken),
            isAutomated,
            contractMetadata,
            imageUrl
        );
        emit LiquidBurlTokenCreated(owner, address(newToken));
        return address(newToken);
    }

    // ================ Admin functions ================

    function setBurlToken(address burlToken_) external onlyRole(OWNER_ROLE) {
        burlToken = IERC20(burlToken_);
    }

    function setUsdcToken(address usdcToken_) external onlyRole(OWNER_ROLE) {
        usdcToken = IERC20(usdcToken_);
    }

    function setContractMetadata(
        string memory contractMetadata_
    ) external onlyRole(OWNER_ROLE) {
        contractMetadata = contractMetadata_;
        emit ContractMetadataUpdated();
    }

    function setImageUrl(
        string memory imageUrl_
    ) external onlyRole(OWNER_ROLE) {
        imageUrl = imageUrl_;
        emit ImageUrlUpdated(imageUrl_);
    }

    function removeLBTFromList(address owner) external onlyRole(OWNER_ROLE) {
        address liquidBurlToken = ownerToLBT[owner];
        require(
            liquidBurlToken != address(0),
            LiquidFactory_NoLBTForOwner(owner)
        );
        require(
            IERC20(liquidBurlToken).balanceOf(owner) == 0,
            LiquidFactory_LBTNotEmpty(liquidBurlToken)
        );

        delete ownerToLBT[owner];
        delete LBTToOwner[liquidBurlToken];
    }

    // ================ View functions ================

    function getLiquidBurlToken(
        address owner
    ) external view returns (address liquidBurlToken) {
        liquidBurlToken = ownerToLBT[owner];
    }

    function getOwnerOfLBT(
        address liquidBurlToken
    ) external view returns (address owner) {
        owner = LBTToOwner[liquidBurlToken];
    }
}
