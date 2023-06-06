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

contract ico_contract {
    ICOManager private icoManager;
    IPancakeRouter private pancakeRouter;
    mapping(address => uint256) public contributers;
    mapping(address => uint256) public referals;
    struct icoData {
        address tokenAddress; // token address of ico
        address icoOwner; // token address of ico
        uint256 amount; // token amount for ico
        uint256 presaleRate; // rate for presale
        uint256 startTimestamp; // ico starting timestamp
        uint256 pressaleCurrency; // presale currency type
        uint256 endTimestamp; // ico ending timestamp
        uint256 tokenForListing; // token for liquidity
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
    uint256 public soldOut; 
    bool canceled;
    bool finished;

    constructor(icoData memory _icoData, icoUrl memory _url) {
        require(_icoData.tokenAddress != address(0), "Invalid token");
        require(_icoData.amount > 0, "Amount should be greater than 0");
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
        string memory _websiteUrl,
        string memory _facebook,
        string memory _twitter,
        string memory _github,
        string memory _telegram,
        string memory _reddit,
        string memory _instagram
    ) public onlyOwner {
        require(ico.icoOwner == msg.sender, "invalid owner");
        url.website = _websiteUrl;
        url.facebook = _facebook;
        url.twitter = _twitter;
        url.github = _github;
        url.telegram = _telegram;
        url.reddit = _reddit;
        url.instagram = _instagram;
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
        contributers[msg.sender] += contributionAmount;
        IERC20 token = IERC20(ico.tokenAddress);
        token.transferFrom(address(this), msg.sender, tokenAmount);
    }

    function finalizeICO() public onlyOwner {
        require(!finished, "ICO has already been finalized");
        IERC20 token = IERC20(ico.tokenAddress);
        token.transferFrom(ico.icoOwner, address(this), ico.tokenForListing);
        token.approve(address(pancakeRouter), ico.tokenForListing);
        addLiquidity();
        finished = true;
    }

    function addLiquidity() internal {
        IERC20 token = IERC20(ico.tokenAddress);
        uint256 tokenBalance = token.balanceOf(address(this));
        uint256 bnbBalance = address(this).balance;
        token.approve(address(pancakeRouter), tokenBalance);
        pancakeRouter.addLiquidityETH{value: bnbBalance}(
            address(token),
            tokenBalance,
            0,
            0,
            address(this),
            block.timestamp + 1 hours
        );
    }

    function addLiquiditybep20(
        address busdTokenAddress,
        address pancakeRouterAddress
    ) internal {
        IERC20 bep20Token = IERC20(ico.tokenAddress);
        uint256 bep20TokenBalance = bep20Token.balanceOf(address(this));
        bep20Token.approve(pancakeRouterAddress, bep20TokenBalance);
        IERC20 busdToken = IERC20(busdTokenAddress);
        uint256 busdTokenBalance = busdToken.balanceOf(address(this));

        busdToken.approve(pancakeRouterAddress, busdTokenBalance);
        pancakeRouter.addLiquidity(
            ico.tokenAddress,
            busdTokenAddress,
            bep20TokenBalance,
            busdTokenBalance,
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
        IERC20 token = IERC20(ico.tokenAddress);
        token.transferFrom(address(this), msg.sender, tokenAmount);
        contributers[msg.sender] = 0;
    }

    function claimFund() public {
        require(contributers[msg.sender] > 0, "you are not contributer");
        require(!canceled, "ICO is not canceled yet");
         IERC20 token = IERC20(ico.tokenAddress);
        token.transfer(msg.sender, contributers[msg.sender]);
    }

    function emergencyWithdrawl() public {
        require(contributers[msg.sender] > 0, "you are not contributer");
        require(!finished, "ICO has already finalised");
        IERC20 token = IERC20(ico.tokenAddress);
        token.transfer(msg.sender, contributers[msg.sender]);
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
        IERC20 token = IERC20(ico.tokenAddress);
        token.transferFrom(address(this), msg.sender, tokenAmount);
    }
}
