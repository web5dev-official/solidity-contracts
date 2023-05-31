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
        require(isOwner(), "Function accessible only by the owner!");
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
    mapping(address => uint256) public contributers;
    address tokenAddress; // token address of ico
    address icoOwner; // token address of ico
    uint256 soldOut; // soldOut Amount for ico
    uint256 amount; // token amount for ico
    uint256 presaleRate; // rate for presale
    uint256 startTimestamp; // ico starting timestamp
    uint256 pressaleCurrency; // presale currency type
    uint256 endTimestamp; // ico ending timestamp
    uint256 tokenForListing; // token for liquidity
    uint256 refralRate; // referral rate
    string icoCurrency; // currency selected for ICO
    string website; // ICO website address
    string facebook; // Facebook site
    string twitter; // Twitter link
    string github; // GitHub link
    string telegram; // Telegram link
    string reddit; // Reddit link
    string instagram; // Instagram link
    string auditedUrl; // Audited status by default false
    string kycUrl; // KYC status by default false
    string safuUrl; // SAFU status by default false
    string doxxdUrl; // Doxxd status by default false
    bool refralEnabled; // Referral status
    bool canceled; // ICO cancellation status
    bool audited; // Audited status by default false
    bool kyc; // KYC status by default false
    bool safu; // SAFU status by default false
    bool doxxd; // Doxxd status by default false

    constructor(
        address _tokenAddress,
        address _owner,
        uint256 _amount,
        uint256 _startTimestamp,
        uint256 _endTimestamp,
        uint256 _refralRate,
        string memory _website,
        string memory _selectedCurrency
    ) {
        tokenAddress = _tokenAddress;
        icoOwner = _owner;
        amount = _amount;
        startTimestamp = _startTimestamp;
        endTimestamp = _endTimestamp;
        refralRate = _refralRate;
        website = _website;
        icoCurrency = _selectedCurrency;
    }

    modifier onlyAuditer() {
        require(
            icoManager.getAdmin(msg.sender),
            "Only auditor can execute this function"
        );
        _;
    }

  function getIcoDetails()
    external
    view
    returns (string[] memory)
{
    string[] memory details = new string[](22);
    details[0] = addressToString(tokenAddress);
    details[1] = addressToString(icoOwner);
    details[2] = uint256ToString(amount);
    details[3] = uint256ToString(soldOut);
    details[4] = uint256ToString(presaleRate);
    details[5] = uint256ToString(startTimestamp);
    details[6] = uint256ToString(pressaleCurrency);
    details[7] = uint256ToString(endTimestamp);
    details[8] = uint256ToString(tokenForListing);
    details[9] = uint256ToString(refralRate);
    details[10] = boolToString(audited);
    details[11] = boolToString(kyc);
    details[12] = boolToString(safu);
    details[13] = boolToString(doxxd);
    details[14] = auditedUrl;
    details[15] = kycUrl;
    details[16] = safuUrl;
    details[17] = doxxdUrl;

    return details;
}

function addressToString(address _address)
    internal
    pure
    returns (string memory)
{
    bytes32 value = bytes32(uint256(uint160(_address)));
    bytes memory alphabet = "0123456789abcdef";
    bytes memory str = new bytes(42);
    str[0] = "0";
    str[1] = "x";
    for (uint256 i = 0; i < 20; i++) {
        str[2 + i * 2] = alphabet[uint8(value[i + 12] >> 4)];
        str[3 + i * 2] = alphabet[uint8(value[i + 12] & 0x0f)];
    }
    return string(str);
}

function uint256ToString(uint256 value)
    internal
    pure
    returns (string memory)
{
    if (value == 0) {
        return "0";
    }
    uint256 temp = value;
    uint256 digits;
    while (temp != 0) {
        digits++;
        temp /= 10;
    }
    bytes memory buffer = new bytes(digits);
    while (value != 0) {
        digits -= 1;
        buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
        value /= 10;
    }
    return string(buffer);
}

function boolToString(bool value)
    internal
    pure
    returns (string memory)
{
    return value ? "true" : "false";
}


    function UpdateUrl(
        string memory _websiteUrl,
        string memory _facebook,
        string memory _twitter,
        string memory _github,
        string memory _telegram,
        string memory _reddit,
        string memory _instagram
    ) public {
        require(icoOwner == msg.sender , "invalid owner");
        website = _websiteUrl;
        facebook = _facebook;
        twitter = _twitter;
        github = _github;
        telegram = _telegram;
        reddit = _reddit;
        instagram = _instagram;
    }

    function contribute(uint256 _amount) public {
        // Logic for contributing to the ICO
    }

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
        audited = _audited;
        kyc = _kyc;
        doxxd = _doxxed;
        safu = _safu;
        auditedUrl = _auditUrl;
        kycUrl = _kycUrl;
        doxxdUrl = _doxxUrl;
        safuUrl = _safuUrl;
    }

    function finaliseIco() public {
        // Logic for finalizing the ICO
    }

    function cancelIco() public {
        // Logic for canceling the ICO
    }

    function claimToken() public {
        // Logic to claim token
    }
}
