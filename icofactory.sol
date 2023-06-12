// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./icoBep20.sol";


contract ICOFactory {
    event ICOContractDeployed(address indexed icoContract, address indexed tokenAddress, uint256 amount);

    struct ICOPage {
        address[] addresses;
        bool exists;
    }

    mapping(address => address) public deployedICOContracts;
    ICOPage[] public allDeployedICOContractPages;
    uint256 public constant contractsPerPage = 10;

    function createICOContract(
        icoData memory _icoData,
        icoUrl memory _url,
        address _tokenAddress,
        address _routerAddress,
        address _currency,
        uint256 _amount
    ) public {
        // Assume the ERC20 token contract has a transferFrom function
        IERC20 token = IERC20(_tokenAddress);

        // Check if the caller has approved the ICOFactory contract to transfer tokens on their behalf
        require(
            token.transferFrom(msg.sender, address(this), _amount),
            "Contract deployment failed"
        );

        ico_contract ico = new ico_contract(_icoData, _url,_routerAddress,_currency) ;

        // Transfer the tokens from ICOFactory contract to the deployed ICO contract
        require(
            token.transfer(address(ico), _amount),
            "Token transfer to ICO contract failed."
        );

        deployedICOContracts[_tokenAddress] = address(ico);

        uint256 pageIndex = allDeployedICOContractPages.length - 1;
        if (!allDeployedICOContractPages[pageIndex].exists || allDeployedICOContractPages[pageIndex].addresses.length == contractsPerPage) {
            allDeployedICOContractPages.push();
            pageIndex++;
        }

        allDeployedICOContractPages[pageIndex].addresses.push(address(ico));
        allDeployedICOContractPages[pageIndex].exists = true;

        emit ICOContractDeployed(address(ico), _tokenAddress, _amount);
    }

    function getDeployedICOContract(address _tokenAddress) public view returns (address) {
        return deployedICOContracts[_tokenAddress];
    }

    function getPageCount() public view returns (uint256) {
        return allDeployedICOContractPages.length;
    }

    function getICOContractPage(uint256 pageIndex) public view returns (address[] memory) {
        require(pageIndex < allDeployedICOContractPages.length, "Invalid page index");

        return allDeployedICOContractPages[pageIndex].addresses;
    }
}
