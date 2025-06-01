// SPDX-License-Identifier: UNLICENSED

/*
    Type declarations

    State variables

    Events

    Errors

    Modifiers

    Functions
    - Constructor/Initializer
    - Public functions
    - External functions
      - View functions
      - Pure functions
    - Internal functions
    - Private functions
  */

pragma solidity ^0.8.30;
import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AccessControlDefaultAdminRules} from "@openzeppelin/contracts/access/extensions/AccessControlDefaultAdminRules.sol";

contract LiquidBurlToken is
    ERC721,
    ReentrancyGuard,
    AccessControlDefaultAdminRules
{
    // ================ Type declaration ================
    IERC20 burlToken;
    IERC20 usdcToken;

    // ================ State variables ================
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

    uint256 private constant TOKEN_DECIMALS = 10 ** 18;
    uint256 private THRESHOLD = 20 * TOKEN_DECIMALS; // 20 USDC

    string public contractMetadata;

    bool public isAutomated;

    // ================ Events ================

    // ================ Errors ================

    // error NotEnoughBurl(uint256 available, uint256 required);
    // error NotEnoughUsdc(uint256 available, uint256 required);
    // error NotEnoughBalance(uint256 available, uint256 required);
    // error NotEnoughBurlToWithdraw(uint256 available, uint256 required);

    constructor(
        address initialOwner,
        address burlToken_,
        address usdcToken_,
        bool isAutomated_,
        string memory contractMetadata_
    )
        ERC721("LiquidBurlToken", "LBT")
        AccessControlDefaultAdminRules(0, initialOwner)
    {
        _mint(initialOwner, 1); // Soulbound token for the owner
        burlToken = IERC20(burlToken_);
        usdcToken = IERC20(usdcToken_);
        isAutomated = isAutomated_;
        contractMetadata = contractMetadata_;
    }

    function withdrawBurl(
        uint256 amount
    ) public onlyRole(OWNER_ROLE) nonReentrant {
        burlToken.transfer(msg.sender, amount);
    }

    function withdrawUsdc(uint256 amount) external nonReentrant {
        require(
            usdcToken.balanceOf(address(this)) >= amount,
            "Not enough USDC balance"
        );
        usdcToken.transfer(msg.sender, amount);
    }

    function buyAtMarket() external onlyRole(OWNER_ROLE) nonReentrant {
        uint256 usdcAmount = burlToken.balanceOf(address(this));

        // Logic to buy at market price
    }

    // ================ View functions ================
    function state() external view returns (bool isReady) {
        if (burlToken.balanceOf(address(this)) > THRESHOLD) {
            isReady = true;
        } else {
            isReady = false;
        }
    }

    function contractURI() public view returns (string memory) {
        return string.concat("data:application/json;utf8,", contractMetadata);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC721, AccessControlDefaultAdminRules)
        returns (bool)
    {
        return
            ERC721.supportsInterface(interfaceId) ||
            AccessControlDefaultAdminRules.supportsInterface(interfaceId);
    }

    // ==== Turn off ERC721 trasfer functions and make it souldbound ====
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {}

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {}
}
