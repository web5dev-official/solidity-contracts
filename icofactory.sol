// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ico_contract.sol";

contract ICOFactory {
    event ICOContractDeployed(address indexed icoContract, address indexed tokenAddress, uint256 amount);

    mapping(address => address) public deployedICOContracts;

    function createICOContract(
        address _tokenAddress,
        uint256 _amount,
        uint256 _startTimestamp,
        uint256 _endTimestamp,
        uint256 _refralRate,
        string memory _website,
        string memory _selectedCurrency
    ) public {
        ico_contract ico = new ico_contract(
            _tokenAddress,
            _amount,
            _startTimestamp,
            _endTimestamp,
            _refralRate,
            _website,
            _selectedCurrency
        );

        deployedICOContracts[_tokenAddress] = address(ico);
        emit ICOContractDeployed(address(ico), _tokenAddress, _amount);
    }

    function getDeployedICOContract(address _tokenAddress) public view returns (address) {
        return deployedICOContracts[_tokenAddress];
    }
}
