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
    event TokensSent(
        address indexed token,
        address indexed from,
        uint256 totalAmount
    );
    event TokensTransferred(
        address indexed token,
        address indexed to,
        uint256 amount
    );
  
    function sendTo(
        address token,
        uint8 decimals,
        address[] memory recipients,
        uint256[] memory amounts
    ) public {
        require(recipients.length == amounts.length, "Invalid input");

        IERC20 erc20 = IERC20(token);
        erc20.transferFrom(msg.sender, address(this), totalAmount(amounts)*10**decimals);

        for (uint256 i = 0; i < recipients.length; i++) {
            require(erc20.transfer(recipients[i], amounts[i]*10**decimals), "Transfer failed");
            emit TokensTransferred(token, recipients[i], amounts[i]);
        }

        emit TokensSent(token, msg.sender, totalAmount(amounts));
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
