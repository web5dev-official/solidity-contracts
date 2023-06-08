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

contract ico_contract {
    ICOManager private icoManager;
    IPancakeRouter private pancakeRouter;
    mapping(address => uint256) public contributers;
    mapping(address => uint256) public referals;
    struct icoData {
        address tokenAddress; // token address of ico
        address icoOwner; // token address of ico
        address currency; // ico currency address
        uint256 icoAmount; // token amount for ico
        uint256 presaleRate; // rate for presale
        uint256 startTimestamp; // ico starting timestamp
        uint256 pressaleCurrency; // presale currency type
        uint256 endTimestamp; // ico ending timestamp
        uint256 liquidityAmount; // token for liquidity
        uint256 refralRate; // referral rate
        string icoCurrency; // currency selected for ICO
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
    IERC20 public icoCurrency = IERC20(ico.currency);
    uint256 public soldOut;
    bool canceled;
    bool finished;
    bool autoLiquidity;

    constructor(icoData memory _icoData, icoUrl memory _url) {
        require(_icoData.tokenAddress != address(0), "Invalid token");
        require(_icoData.icoAmount > 0, "Amount should be greater than 0");
        require(
            _icoData.startTimestamp > block.timestamp,
            "Unlock date should be in the future"
        );
        ico = _icoData;
        url = _url;
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
        return msg.sender == ico.icoOwner;
    }

    function getICOData() public view returns (icoData memory) {
        return ico;
    }

    function UpdateUrl(
        icoUrl memory _url
    ) public onlyOwner {
        require(ico.icoOwner == msg.sender, "invalid owner");
       url = _url;
    }

    function contribute() public payable {
        require(!canceled, "ICO has been canceled");
        require(
            block.timestamp >= ico.startTimestamp &&
                block.timestamp <= ico.endTimestamp,
            "ICO is not active"
        );
        require(msg.value > 0, "Contribution amount should be greater than 0");
        uint256 contributionAmount = msg.value;
        uint256 tokenAmount = contributionAmount * ico.presaleRate;
        token.transferFrom(msg.sender, address(this), tokenAmount);
        contributers[msg.sender] += contributionAmount;
    }

    function finalizeICO() public onlyOwner {
        require(!finished, "ICO has already been finalized");
        token.transferFrom(ico.icoOwner, address(this), ico.liquidityAmount);
        token.approve(address(pancakeRouter), ico.liquidityAmount);
        if (autoLiquidity) {
            addLiquidity();
        } else {
            icoCurrency.transfer(ico.icoOwner, ico.liquidityAmount);
        }
        finished = true;
    }

    function addLiquidity() internal {
        uint256 tokenBalance = token.balanceOf(address(this));
        token.approve(
            0xD99D1c33F9fC3444f8101754aBC46c52416550D1,
            ico.liquidityAmount
        ); // pancake swap interface address is  0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        icoCurrency.approve(
            0xD99D1c33F9fC3444f8101754aBC46c52416550D1,
            ico.liquidityAmount
        ); // pancake swap interface address is 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        pancakeRouter.addLiquidity(
            ico.tokenAddress,
            ico.currency,
            tokenBalance,
            ico.liquidityAmount,
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
        token.transfer(msg.sender, contributers[msg.sender]);
        contributers[msg.sender] = 0; // contribution set to 0 so user cannot claim again
    }

    function changeIcoTime(uint256 _startTimestamp, uint256 _endTimestamp) public onlyOwner {
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
        token.transfer(msg.sender, contributers[msg.sender]);
        contributers[msg.sender] = 0; // contribution set to 0 so user cannot claim again
    }

    function contributeWithReferal(address _refralAddress, uint256 _amount)
        public
        payable
    {
        require(!canceled, "ICO has been canceled");
        require(
            block.timestamp >= ico.startTimestamp &&
                block.timestamp <= ico.endTimestamp,
            "ICO is not active"
        );
        require(msg.value > 0, "Contribution amount should be greater than 0");
        uint256 contributionAmount = msg.value;
        uint256 tokenAmount = contributionAmount * ico.presaleRate;
        contributers[msg.sender] += contributionAmount;
        referals[_refralAddress] = _amount;
        token.transferFrom(address(this), msg.sender, tokenAmount);
    }
}
