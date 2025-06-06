// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {LiquidBurlToken} from "./LiquidBurlToken.sol";

/*ReentrancyGuardUpgradeable,*/ contract LiquidFactory is
    AccessControlUpgradeable
{
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
        // __ReentrancyGuard_init();
        __AccessControl_init();
        _setRoleAdmin(OWNER_ROLE, OWNER_ROLE);
        _grantRole(OWNER_ROLE, msg.sender);

        usdcToken = IERC20(usdcToken_);
        burlToken = IERC20(burlToken_);
    }

    /// @notice Create a LiquidBurlToken without transferring any burl tokens
    /// @param isAutomated Whether the token is automated
    /// @return The address of the newly created LiquidBurlToken
    function createLiquidBurlToken(
        bool isAutomated
    ) external returns (address) {
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

    /// @notice Create a LiquidBurlToken with a specified amount of burl tokens
    /// @param isAutomated Whether the token is automated
    /// @param burlAmount The amount of burl tokens to transfer to the new token
    /// @return The address of the newly created LiquidBurlToken
    function createLiquidBurlToken(
        bool isAutomated,
        uint256 burlAmount
    ) external returns (address) {
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

        burlToken.transferFrom(owner, address(newToken), burlAmount);

        emit LiquidBurlTokenCreated(owner, address(newToken));
        return address(newToken);
    }

    // ================ Admin functions ================

    /// @notice Set the burl token address
    /// @param burlToken_ The address of the new burl token
    function setBurlToken(address burlToken_) external onlyRole(OWNER_ROLE) {
        burlToken = IERC20(burlToken_);
    }

    /// @notice Set the USDC token address
    /// @param usdcToken_ The address of the new USDC token
    function setUsdcToken(address usdcToken_) external onlyRole(OWNER_ROLE) {
        usdcToken = IERC20(usdcToken_);
    }

    /// @notice Set the contract metadata
    /// @param contractMetadata_ The new contract metadata in JSON format
    function setContractMetadata(
        string memory contractMetadata_
    ) external onlyRole(OWNER_ROLE) {
        contractMetadata = contractMetadata_;
        emit ContractMetadataUpdated();
    }

    /// @notice Set the image URL for the LiquidBurlToken
    /// @param imageUrl_ The new image URL
    function setImageUrl(
        string memory imageUrl_
    ) external onlyRole(OWNER_ROLE) {
        imageUrl = imageUrl_;
        emit ImageUrlUpdated(imageUrl_);
    }

    /// @notice Remove a LiquidBurlToken from the list of owned tokens
    /// @param owner The address of the owner whose LiquidBurlToken is to be removed
    /// @dev This function can only be called if the LiquidBurlToken is empty (balance is 0)
    function removeLBTFromList(address owner) external onlyRole(OWNER_ROLE) {
        //NOTE: Instead of using onlyRole we could create a central signer with a signature
        // and verify it inside the contarct
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

    /// @notice Get the LiquidBurlToken address for a given owner
    /// @param owner The address of the owner
    /// @return liquidBurlToken The address of the LiquidBurlToken owned by the given owner
    function getLiquidBurlToken(
        address owner
    ) external view returns (address liquidBurlToken) {
        liquidBurlToken = ownerToLBT[owner];
    }

    /// @notice Get the owner of a given LiquidBurlToken
    /// @param liquidBurlToken The address of the LiquidBurlToken
    /// @return owner The address of the owner of the given LiquidBurlToken
    function getOwnerOfLBT(
        address liquidBurlToken
    ) external view returns (address owner) {
        owner = LBTToOwner[liquidBurlToken];
    }
}
