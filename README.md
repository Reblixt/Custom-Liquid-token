## Burl Liquid Staking ERC721 Contract

This ERC721 contract implements a liquid staking mechanism. It is designed to be deployed via a factory, with each instance owned by a single user. Users can deposit their `BurlToken` into the contract, making the contract the owner of these tokens and enabling it to receive dividends from Burlcore.

This system provides users with several key functionalities:
*   **Flexible Withdrawals:** Users can withdraw their `BurlToken` at any time.
*   **Dividend Management:** A dedicated function allows users to withdraw accumulated dividends.
*   **Token Reinvestment:** Users have the option to use their dividends to directly purchase additional `BurlToken` at market price, thereby increasing their staked amount.
*   **Using Chainlinks automation with a central payee**

**Why is this useful?**
This approach offers potential tax advantages in certain jurisdictions, allowing users to be subject to capital gains tax rather than dividend tax.
