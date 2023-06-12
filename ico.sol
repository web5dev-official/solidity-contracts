// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICOManager {
    function getAdmin(address _admin) external view returns (bool);
}

interface IDEXRouter {
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

      function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );   
}

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
}

 struct icoData {
        address tokenAddress; // token address of ico
        uint256 icoAmount; // token amount for ico
        uint256 presaleRate; // rate for presale
        uint256 startTimestamp; // ico starting timestamp
        uint256 endTimestamp; // ico ending timestamp
        uint256 listingRate;
        uint256 liquiditPer; // token percentage of liquidity
        uint256 refralRate; // referral rate
        uint256 softcap;
        uint256 hardcap;
        uint256 minBuy;
        uint256 maxBuy;
    }

    struct icoUrl {
        string website; // ICO website address
        string logo; // ICO website address
        string youtube; // youtube video url
        string info; // description
        string facebook; // Facebook site
        string twitter; // Twitter link
        string github; // GitHub link
        string telegram; // Telegram link
        string reddit; // Reddit link
        string instagram; // Instagram link
    }

contract ico_contract {
    ICOManager private icoManager;
    IDEXRouter private pancakeRouter;
    mapping(address => uint256) public contributers;
    mapping(address => uint256) public referals;
    mapping(address => bool) public whitelistAddreses;

    struct kycData {
        string auditedUrl; // Audited status by default false
        string kycUrl; // KYC status by default false
        string safuUrl; // SAFU status by default false
        string doxxdUrl; // Doxxd status by default false
    }

    kycData public kyc;
    icoData public ico;
    icoUrl public url;
    IERC20 public token = IERC20(ico.tokenAddress);
    IERC20 public icoCurrency = IERC20(currency);
    IDEXRouter public dexRouter = IDEXRouter(dexRouterAddress);
    address currency;
    address public owner;
    address public dexRouterAddress;
    uint256 public soldOut;
    bool canceled;
    bool finished;
    bool whitelist;
    bool autoLiquidity;

    constructor(icoData memory _icoData, icoUrl memory _url, address _router , address _currency) {
        require(_icoData.tokenAddress != address(0), "Invalid token");
        require(_icoData.icoAmount > 0, "Amount should be greater than 0");
        require(
            _icoData.startTimestamp > block.timestamp,
            "Unlock date should be in the future"
        );
        ico = _icoData;
        url = _url;
        dexRouterAddress = _router;
        currency = _currency;
    }

    modifier onlyAuditer() {
        require(
            icoManager.getAdmin(msg.sender),
            "Only auditor can execute this function"
        );
        _;
    }

    modifier onlyOwner() {
        require(isOwner(), "Function accessible only by the owner!");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == owner;
    }

    function checkOwner(address _owner) public view returns (bool) {
        return _owner == owner;
    }

    function getICOData()
        external
        view
        returns (
            icoData memory,
            icoUrl memory,
            kycData memory,
            address,
            bool,
            bool,
            bool
        )
    {
        return (ico, url, kyc, owner, canceled, finished, autoLiquidity);
    }

    function UpdateUrl(icoUrl memory _url) public onlyOwner {
        url = _url;
    }

    function contribute(uint256 _amount) public {
        require(!canceled, "ICO has been canceled");
        require(
            block.timestamp >= ico.startTimestamp &&
                block.timestamp <= ico.endTimestamp,
            "ICO is not active"
        );
        uint256 tokenAmount = _amount * ico.presaleRate;
        icoCurrency.transferFrom(msg.sender, address(this), tokenAmount);
        contributers[msg.sender] += _amount;
    }

    function finalizeICO() public onlyOwner {
        require(!finished, "ICO has already been finalized");
        if (autoLiquidity) {
            addLiquidity(52);
        } else {
            icoCurrency.transfer(owner, ico.listingRate);
        }
        finished = true;
    }

   function addLiquidity(uint256 percentage) public {
    require(percentage >= 50 && percentage <= 100, "Invalid percentage"); // Ensure the percentage is between 50 and 100
    
    uint256 tokenBalance = token.balanceOf(address(this));
    uint256 tokenAmountToAdd = tokenBalance * percentage / 100; // Calculate the token amount based on the percentage
    
    uint256 icoCurrencyBalance = icoCurrency.balanceOf(address(this));
    uint256 icoCurrencyAmountToAdd = icoCurrencyBalance * percentage / 100; // Calculate the ICO currency amount based on the percentage
    
    token.approve(
        address(dexRouter),
        tokenAmountToAdd
    );
    icoCurrency.approve(
        address(dexRouter),
        icoCurrencyAmountToAdd
    );
    dexRouter.addLiquidity(
        ico.tokenAddress,
        currency,
        tokenAmountToAdd,
        icoCurrencyAmountToAdd,
        0,
        0,
        address(this),
        block.timestamp + 1 hours
    );
}

function addLiquidityBnb(uint256 percentage) public {
    require(percentage >= 50 && percentage <= 100, "Invalid percentage"); // Ensure the percentage is between 50 and 100
    
    uint256 tokenBalance = token.balanceOf(address(this));
    uint256 tokenAmountToAdd = tokenBalance * percentage / 100; // Calculate the token amount based on the percentage
    
    uint256 bnbAmountToAdd = address(this).balance * percentage / 100; // Calculate the BNB amount based on the percentage
    
    token.approve(
        address(dexRouter),
        tokenAmountToAdd
    );
    dexRouter.addLiquidityETH{value: bnbAmountToAdd}(
        ico.tokenAddress,
        tokenAmountToAdd,
        0,
        0,
        address(this),
        block.timestamp + 1 hours
    );
}

    function cancelICO() public onlyOwner {
        require(!canceled, "ico is alredy canceled");
        canceled = true;
    }

    function addBadge(
        string memory _auditUrl,
        string memory _kycUrl,
        string memory _doxxUrl,
        string memory _safuUrl
    ) public onlyAuditer {
        kyc.auditedUrl = _auditUrl;
        kyc.kycUrl = _kycUrl;
        kyc.doxxdUrl = _doxxUrl;
        kyc.safuUrl = _safuUrl;
    }

    function getBadge() public view returns (kycData memory) {
        return kyc;
    }

    function claimToken() public {
        require(finished, "ICO has not finalized yet");
        uint256 contributionAmount = contributers[msg.sender];
        uint256 tokenAmount = contributionAmount * ico.presaleRate;
        token.transferFrom(address(this), msg.sender, tokenAmount);
        contributers[msg.sender] = 0; // contribution set to 0 so user cannot claim again
    }

    function claimFund() public {
        require(contributers[msg.sender] > 0, "you are not contributer");
        require(!canceled, "ICO is not canceled yet");
        icoCurrency.transfer(msg.sender, contributers[msg.sender]);
        contributers[msg.sender] = 0; // contribution set to 0 so user cannot claim again
    }

    function changeIcoTime(uint256 _startTimestamp, uint256 _endTimestamp)
        public
        onlyOwner
    {
        require(
            block.timestamp <= _startTimestamp &&
                _startTimestamp <= _endTimestamp,
            "end timestamp"
        );
        ico.startTimestamp = _startTimestamp;
        ico.endTimestamp = _endTimestamp;
    }

    function emergencyWithdrawl() public {
        require(contributers[msg.sender] > 0, "you are not contributer");
        require(!finished, "ICO has already finalised");
        icoCurrency.transfer(msg.sender, contributers[msg.sender]);
        contributers[msg.sender] = 0; // contribution set to 0 so user cannot claim again
    }

    function contributeWithReferal(address _refralAddress, uint256 _amount)
        public
    {
        require(!canceled, "ICO has been canceled");
        require(
            block.timestamp >= ico.startTimestamp &&
                block.timestamp <= ico.endTimestamp,
            "ICO is not active"
        );
        require(_amount > 0, "Contribution amount should be greater than 0");
        require(
            icoCurrency.transferFrom(msg.sender, address(this), _amount),
            "transaction failed"
        );
        contributers[msg.sender] += _amount;
        referals[_refralAddress] = _amount;
    }
}
