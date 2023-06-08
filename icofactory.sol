// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ico_contract.sol";

contract ICOFactory {
    event ICOContractDeployed(address indexed icoContract, address indexed tokenAddress, uint256 amount);

    mapping(address => address) public deployedICOContracts;
    
 function createICOContract(
   IcoData memory _icoData, IcoUrl memory _url ,address _tokenAddress , uint256 _amount
) public {
    // Assume the ERC20 token contract has a transferFrom function
    IERC20 token = IERC20(_tokenAddress);

    // Check if the caller has approved the ICOFactory contract to transfer tokens on their behalf
    require(
        token.transferFrom(msg.sender, address(this), _amount),
        "contract deployment failed"
    );

    ico_contract ico = new ico_contract(
        _icoData , _url
    );

    // Transfer the tokens from ICOFactory contract to the deployed ICO contract
    require(
        token.transfer(address(ico), _amount),
        "Token transfer to ICO contract failed."
    );

    deployedICOContracts[_tokenAddress] = address(ico);
    emit ICOContractDeployed(address(ico), _tokenAddress, _amount);
}

    function getDeployedICOContract(address _tokenAddress) public view returns (address) {
        return deployedICOContracts[_tokenAddress];
    }
}
