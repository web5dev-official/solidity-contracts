// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

interface ITRC20 {
    function transfer(address _to, uint256 _value) external returns (bool);
}

contract Ownable {
    address private _owner;

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Function accessible only by the owner !!");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }
}

contract Dividend is Ownable {
    function Transfer_usdt (uint256 _amount) external onlyOwner {
        // This is the testnet USDT contract address
        ITRC20 usdt = ITRC20(
            address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684)
        );
        uint256 _ActualAmount = _amount * 10**16;
        uint256 _wallet1 = _ActualAmount * 60;
        uint256 _wallet2 = _ActualAmount * 15;
        uint256 _wallet3 = _ActualAmount * 10;

        // transfers USDT that belong to your contract to the specified address
        //All  tron adress are converted into evm supported address
        usdt.transfer(0xc40c5393bb0CD04bB2C735f488899463564207e8, _wallet1);
        usdt.transfer(0x4584298d4267A5483579aF122806eF46214FFaFC, _wallet2);
        usdt.transfer(0x680d7312C7e890AaFDCf4E0f09b6c4a86f257E56, _wallet2);
        usdt.transfer(0x88C7ed62cAc0a800fFF5406F2Ae275b9F3Bac899, _wallet3);
    }
}
// usdt address on teatnet (TBTsENYrDWWG4aSKFerGWPbFbuPXrCfj5c)
