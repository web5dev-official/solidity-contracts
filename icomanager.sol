// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ico_manager {
    event adminAdded(address indexed admin);  
    event icoAdded(address indexed icoAddress);  
    address public owner;
    
    mapping(address => bool) public admin;

     constructor() {
        owner = msg.sender;
    }

    function getAdmin(address _admin) external view returns (bool) {
        return admin[_admin];
    }

    function addAdmin(address _adminAddress) public {
        require(msg.sender == owner, "invalid owner");
        require(_adminAddress != address(0), "invalid address");
        admin[_adminAddress] = true;
        emit adminAdded(_adminAddress);
    }
}
