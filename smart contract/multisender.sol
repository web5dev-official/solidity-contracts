// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

contract Multisender {
    event TokensSentToRecipients(
        address indexed token,
        address indexed from,
        uint256 totalAmount
    );
    event TokensTransferredToRecipient(
        address indexed token,
        address indexed to,
        uint256 amount
    );
    event EthSentToRecipients(address indexed from, uint256 totalAmount);
    event EthTransferredToRecipient(address indexed to, uint256 amount);

    function sendTokensToRecipients(
        address token,
        uint8 decimals,
        address[] memory recipients,
        uint256[] memory amounts
    ) external {
        require(recipients.length == amounts.length, "Invalid input");

        IERC20 erc20 = IERC20(token);
        uint256 totalTokenAmount = totalAmount(amounts) * (10**uint256(decimals));
        erc20.transferFrom(msg.sender, address(this), totalTokenAmount);

        for (uint256 i = recipients.length; i > 0; i--) {
            require(erc20.transfer(recipients[i - 1], amounts[i - 1] * (10**uint256(decimals))), "Transfer failed");
            emit TokensTransferredToRecipient(token, recipients[i - 1], amounts[i - 1]);
        }

        emit TokensSentToRecipients(token, msg.sender, totalAmount(amounts));
    }

    function sendEthToRecipients(address[] memory recipients, uint256[] memory amounts) external payable {
        require(recipients.length == amounts.length, "Invalid input");

        uint256 totalEthAmount = totalAmount(amounts);
        require(msg.value == totalEthAmount, "Incorrect ETH value sent");

        for (uint256 i = recipients.length; i > 0; i--) {
            payable(recipients[i - 1]).transfer(amounts[i - 1]);
            emit EthTransferredToRecipient(recipients[i - 1], amounts[i - 1]);
        }

        emit EthSentToRecipients(msg.sender, totalEthAmount);
    }

    function totalAmount(uint256[] memory amounts)
        private
        pure
        returns (uint256)
    {
        uint256 total = 0;

        for (uint256 i = 0; i < amounts.length; i++) {
            total += amounts[i];
        }

        return total;
    }
}
