 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface AggregatorInterface {
    function latestAnswer() external view returns (int256);
}


interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from,address to,uint256 amount) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner= msg.sender;
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


contract gagner_tiraja_dex is Ownable {
    AggregatorInterface internal priceFeed = AggregatorInterface(Oracle_Address);
    bool public SwapStatus = true;
    address public Oracle_Address = 0xf10354C1BE7A8b015aA9152132cfD4B620c67775;
    uint256 public Buying_Price = 625;
    uint256 public Selling_price = 610;
    
    constructor() {
        
 }
    
   function get_Tron_Price() public view returns (uint256) {
        return uint256 (priceFeed.latestAnswer());
}

   function StopSwap () public onlyOwner {
       SwapStatus = false;
   }

   function StartSwap () public onlyOwner{
       SwapStatus = true;
   }

  
  
  function Change_Buying_Price(uint256 NewPrice) external onlyOwner {
        Buying_Price = NewPrice;
    }

    function Change_Selling_Price (uint256 NewPrice) external onlyOwner{
        Selling_price = NewPrice;
    }

    IERC20 usdt =
        IERC20(
            address(0xa614f803B6FD780986A42c78Ec9c7f77e6DeD13C) // usdt Token address
        );
        
    IERC20 Gget =
        IERC20(
            address(0x35459E401d3791A793723f0e1aEC671C3688669f) // Gget Token address
        );

    
    function Buy_through_tron (uint256 amount) payable public {
        require(SwapStatus ,"currently swap is stopped");
        require(msg.value >= 10**6 ,"invalid amount");
        uint256 TronPrice = uint256(priceFeed.latestAnswer());
        uint256 gget = amount*10**7*TronPrice/Buying_Price;
        Gget.transfer(msg.sender,gget);
    }
    
    
    function sell_through_tron (uint256 Gget_amount) public {
       require(SwapStatus ,"currently swap is stopped");
       Gget.transferFrom(msg.sender,address(this),Gget_amount*10**9);
        uint256 TronPrice = uint256(priceFeed.latestAnswer());
       uint256 tron_Amount = Gget_amount*Selling_price*10**8/TronPrice;
       payable(msg.sender).transfer(tron_Amount);
   }

    function Buy_through_usdt (uint256 amount) payable public {
        require(SwapStatus ,"currently swap is stopped");
        require(amount>=1 ,"invalid amount");
        usdt.transferFrom(msg.sender,address(this),amount*10**6);
        uint256 gget = amount*10**10/Buying_Price;
        Gget.transfer(msg.sender,gget);
    }

   function sell_through_usdt (uint256 _Gget_amount) public {
        require(SwapStatus ,"currently swap is stopped");
        require(_Gget_amount >= 1 ,"invalid amount");
         Gget.transferFrom(msg.sender,address(this),_Gget_amount*10**9);
         usdt.transfer(msg.sender,_Gget_amount*10**5*Selling_price);
   }

    function withdraw_Gget(uint256 Gget_Ammount) public onlyOwner {
        Gget.transfer(msg.sender, Gget_Ammount * 10**9);
    }
    
    
    function withdraw_Usdt(uint256 Usdt_Ammount) public onlyOwner {
        usdt.transfer(msg.sender, Usdt_Ammount * 10**6);
    }

    function withdraw_tron (uint256 Tron_Amount) public onlyOwner {
         payable(msg.sender).transfer(Tron_Amount*10**6);
    }
    
     function Change_Oracel_Address (address New_Address) public onlyOwner {
        Oracle_Address = New_Address;
    }

}
