// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICOManager {
    function getAdmin(address _admin) external view returns (bool);
}

interface IPancakeRouter {
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );
}

contract Ownable {
    address private _owner;

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(isOwner(), "Function accessible only by the owner !!");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function check_owner() public view returns (address) {
        return _owner;
    }

    function transfer_ownership(address newOwner)
        public
        onlyOwner
        returns (bool)
    {
        _owner = newOwner;
        return true;
    }
}

contract ico_contract is Ownable {
    ICOManager private icoManager;
    address public tokenAddress; // token address of ico
    uint256 public amount; // token amount for ico
    uint256 public presaleRate; //rate fo presale
    uint256 public startTimestamp; // ico starting timestamp
    uint256 public pressaleCurrency; // presale currency type
    uint256 public endTimestamp; // ico ending timestamp
    uint256 public tokenForListing; // token for liquidity
    uint256 public refralRate; // refral rate
    string public icoCurrency; // currency slected for currency
    string public website; // ico website address
    string public facebook; // facebook site
    string public twitter; // twitter link
    string public github; // github link
    string public telegram; // telegram link
    string public reddit; // reddit link
    string public instagram; // instagram link
    string public auditedUrl; // audited status bydefault false
    string public kycUrl; // kyc status bydefault false
    string public safuUrl; // safu status by default false
    string public doxxdUrl; // doxxd status by default false
    bool public refralEnabled; // refral status
    bool public canceled; // enabled
    bool public audited; // audited status bydefault false
    bool public kyc; // kyc status bydefault false
    bool public safu; // safu status by default false
    bool public doxxd; // doxxd status by default false

    constructor(
        address _tokenAddress,
        uint256 _amount,
        uint256 _starTimestamp,
        uint256 _endTimestamp,
        uint256 _refralRate,
        string memory _website,
        string memory _selectedCurrency
    ) {}

    modifier onlyAuditer() {
        require(
            icoManager.getAdmin(msg.sender),
            "Only auditer can execute this function"
        );
        _;
    }

    function getIcoDetails()
        external
        view
        returns (
            address,
            uint256,
            uint256,
            uint256
        )
    {}

    function contribute(uint256 _amount) public {}

    function addBadge(
        bool _audited,
        bool _kyc,
        bool _doxxed,
        bool _safu,
        string memory _auditUrl,
        string memory _kycUrl,
        string memory _doxxUrl,
        string memory _safuUrl
    ) public onlyAuditer {

    }

    function finaliseIco() public {}

    function cancelIco() public {}
}
