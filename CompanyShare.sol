// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ownable {
    
    address public owner;
    
    event OwnershipTransferred(address indexed from, address indexed to);
  
    constructor() {
        owner = msg.sender;
    }

    function getOwner() public view returns(address) {
        return owner;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Function restricted to owner of contract");
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(
            _newOwner != address(0)
            && _newOwner != owner 
        );
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

contract CompanyShare is Ownable {
  uint256 public TotalShare;
  uint256 public TotalInvestor;

  mapping (address => uint256) public ShareHoldings;
  mapping (address => bool) public Company_Head;

  struct HoldersDetails {
      uint256 InvestorId;
      uint256 IssuiengTime;
      uint256 TotalHolding;
      address SecondryAddress;
      string Investor_Name;
      string  DocumentImage_1;
      string  DocumentImage_2;
      bool PhysicalSharing_Status;
  }

  mapping (address => HoldersDetails) public HoldingData;

  function Issue_New_Share () public onlyOwner {
    
  }

  function Recover_Share () public {

  }

  function Transfer_Share () public {

  }
  
  function Clear_Share_Data () public {

  }

}
