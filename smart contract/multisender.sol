// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    function transfer(address to, uint256 amount) external returns (bool);
}
contract multisender {
   uint256 public amount = 10**18;
   IERC20 usdt = IERC20(
            address(0x3EEE5653664248E160eb379Cfdae26da1bfa042E)
        );
       
    function sendTo (address[] memory addrs, uint256[] memory _amount) public {
    for(uint i = 0; i < addrs.length; i++) {
        usdt.transfer(addrs[i], _amount[i]*amount);
    }
   }
}
