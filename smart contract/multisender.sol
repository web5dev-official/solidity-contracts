// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract Multisender {
    event TokensSent(address indexed token, address indexed from, uint256 totalAmount);
    event TokensTransferred(address indexed token, address indexed to, uint256 amount);

    function sendTo(address token, uint8 decimals, address[] memory recipients, uint256[] memory amounts) public payable {
        require(recipients.length == amounts.length, "Invalid input");

        if (token == address(0)) {
            require(msg.value == totalAmount(amounts), "Incorrect amount sent");

            for (uint256 i = 0; i < recipients.length; i++) {
                payable(recipients[i]).transfer(amounts[i]);
                emit TokensTransferred(token, recipients[i], amounts[i]);
            }
        } else {
            IERC20 erc20 = IERC20(token);
            erc20.transferFrom(msg.sender, address(this), totalAmount(amounts));

            for (uint256 i = 0; i < recipients.length; i++) {
                safeTransfer(erc20, recipients[i], amounts[i], decimals);
            }
        }

        emit TokensSent(token, msg.sender, totalAmount(amounts));
    }

    function safeTransfer(IERC20 token, address to, uint256 value, uint8 decimals) private {
        uint256 adjustedValue = value * (10 ** uint256(decimals));
        require(token.balanceOf(address(this)) >= adjustedValue, "Insufficient balance");
        require(token.transfer(to, adjustedValue), "Transfer failed");
        emit TokensTransferred(address(token), to, value);
    }

    function totalAmount(uint256[] memory amounts) private pure returns (uint256) {
        uint256 total = 0;

        for (uint256 i = 0; i < amounts.length; i++) {
            total += amounts[i];
        }

        return total;
    }
}
