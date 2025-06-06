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
import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AccessControlDefaultAdminRules} from "@openzeppelin/contracts/access/extensions/AccessControlDefaultAdminRules.sol";

contract LiquidBurlToken is
    ERC721,
    ERC721URIStorage,
    ReentrancyGuard,
    AccessControlDefaultAdminRules
{
    // ================ Type declaration ================
    IERC20 burlToken;
    IERC20 usdcToken;

    // ================ State variables ================
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bytes32 public constant AUTOMATED_ROLE = keccak256("AUTOMATED_ROLE");

    uint256 private constant TOKEN_DECIMALS = 10 ** 18;
    uint256 private THRESHOLD = 10 * TOKEN_DECIMALS; // 20 USDC

    string public contractMetadata;

    bool public isAutomated;

    // ================ Events ================
    event TokenDeposited(
        address indexed from,
        uint256 amount,
        string tokenType
    );
    event TokenWithdrawed(address indexed to, uint256 amount, string tokenType);

    // ================ Errors ================
    error LiquidBurlToken_TransferNotAllowed();
    error LiquidBurlToken_NotAutomated();
    error LiquidBurlToken_InsufficientBalance();

    constructor(
        address initialOwner,
        address burlToken_,
        address usdcToken_,
        bool isAutomated_,
        string memory contractMetadata_,
        string memory imageUrl
    )
        ERC721("LiquidBurlToken", "LBT")
        AccessControlDefaultAdminRules(0, initialOwner)
    {
        _grantRole(OWNER_ROLE, initialOwner);
        _mint(initialOwner, 1); // Soulbound token for the owner
        _setTokenURI(1, imageUrl);
        burlToken = IERC20(burlToken_);
        usdcToken = IERC20(usdcToken_);
        isAutomated = isAutomated_;
        contractMetadata = contractMetadata_;
    }

    /// @notice Deposit burl tokens into the contract
    /// @param amount The amount of burl tokens to deposit
    function depositBurl(
        uint256 amount
    ) external onlyRole(OWNER_ROLE) nonReentrant {
        burlToken.transferFrom(msg.sender, address(this), amount);
        emit TokenDeposited(msg.sender, amount, "burl");
    }

    /// @notice Withdraw burl tokens from the contract
    /// @param amount The amount of burl tokens to withdraw
    function withdrawBurl(
        uint256 amount
    ) public onlyRole(OWNER_ROLE) nonReentrant {
        burlToken.transfer(msg.sender, amount);
        emit TokenWithdrawed(msg.sender, amount, "burl");
    }

    /// @notice Withdraw USDC from the contract
    /// @param amount The amount of USDC to withdraw
    function withdrawUsdc(
        uint256 amount
    ) external onlyRole(OWNER_ROLE) nonReentrant {
        usdcToken.transfer(msg.sender, amount);
        emit TokenWithdrawed(msg.sender, amount, "USDC");
    }

    /// @notice Buy burl at market price using USDC
    function buyAtMarket() external onlyRole(OWNER_ROLE) nonReentrant {
        _buyAtMarket();
    }

    /// @notice Perform upkeep for the contract, can only be called if isAutomated is true and will be called by an automation service
    function performUpkeep(bytes calldata) external {
        require(isAutomated, LiquidBurlToken_NotAutomated());
        require(
            usdcToken.balanceOf(address(this)) > THRESHOLD,
            LiquidBurlToken_InsufficientBalance()
        );
        _buyAtMarket();
    }

    /// @notice Check if upkeep is needed, can be called by an automation service
    function checkUpkeep(
        bytes memory
    ) external view returns (bool upkeepNeeded, bytes memory) {
        upkeepNeeded = state();
        return (upkeepNeeded, "");
    }

    // ================ View functions ================

    /// @notice Check if the contract has enough burl tokens to be considered ready for automation
    function state() public view returns (bool isReady) {
        if (usdcToken.balanceOf(address(this)) > THRESHOLD) {
            isReady = true;
        } else {
            isReady = false;
        }
    }

    /// @notice Get the contract URI for metadata this is for
    function contractURI() public view returns (string memory) {
        return string.concat("data:application/json;utf8,", contractMetadata);
    }

    /// @notice Check if the contract supports a specific interface
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC721URIStorage, ERC721, AccessControlDefaultAdminRules)
        returns (bool)
    {
        return
            ERC721.supportsInterface(interfaceId) ||
            AccessControlDefaultAdminRules.supportsInterface(interfaceId);
    }

    /// @notice Get the token URI for a specific token ID
    function tokenURI(
        uint256 tokenId
    )
        public
        view
        virtual
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    // ================= Internal functions ================
    /// @notice Internal function to buy burl tokens at market price
    function _buyAtMarket() internal {
        uint256 usdcBalance = usdcToken.balanceOf(address(this));
        // This function can be called by both automated and manual functions
        // Implement the logic to buy burl tokens here
    }

    // ==== Turn off ERC721 trasfer functions and make it souldbound ====
    /// @notice Override the safeTransferFrom and transferFrom functions to prevent transfers
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override(ERC721, IERC721) {
        revert LiquidBurlToken_TransferNotAllowed();
    }

    /// @notice Override the transferFrom function to prevent transfers
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override(ERC721, IERC721) {
        revert LiquidBurlToken_TransferNotAllowed();
    }
}
