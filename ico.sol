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
}

contract ico_contract {
    ICOManager private icoManager;
    IPancakeRouter private pancakeRouter;
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
    string youtube; // youtube video url
    string info; // description
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
    bool canceled; // ICO cancellation status
    bool finished;

    constructor(
        address _tokenAddress,
        address _pancakeRouterAddress,
        address _owner,
        uint256 _amount,
        uint256 _startTimestamp,
        uint256 _endTimestamp,
        uint256 _refralRate,
        string memory _website,
        string memory _selectedCurrency
    ) {
        require(_tokenAddress != address(0), "Invalid token");
        require(_amount > 0, "Amount should be greater than 0");
        require(
            _startTimestamp > block.timestamp,
            "Unlock date should be in the future"
        );
        tokenAddress = _tokenAddress;
        pancakeRouter = IPancakeRouter(_pancakeRouterAddress);
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

    modifier onlyOwner() {
        require(isOwner(), "Function accessible only by the owner!");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == icoOwner;
    }

    function getIcoAddressDetails() public view returns (address, address) {
        return (tokenAddress, icoOwner);
    }

    function getIcoUintDetails()
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            amount,
            soldOut,
            presaleRate,
            startTimestamp,
            pressaleCurrency,
            endTimestamp,
            tokenForListing,
            refralRate
        );
    }

    function getIcoBoolDetails() public view returns (bool, bool) {
        return (canceled, finished);
    }

    function getIcoStringDetails()
        public
        view
        returns (
            string memory,
            string memory,
            string memory,
            string memory,
            string memory,
            string memory,
            string memory,
            string memory,
            string memory,
            string memory,
            string memory
        )
    {
        return (
            auditedUrl,
            kycUrl,
            safuUrl,
            doxxdUrl,
            website,
            facebook,
            twitter,
            github,
            telegram,
            reddit,
            instagram
        );
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
        require(icoOwner == msg.sender, "invalid owner");
        website = _websiteUrl;
        facebook = _facebook;
        twitter = _twitter;
        github = _github;
        telegram = _telegram;
        reddit = _reddit;
        instagram = _instagram;
    }

    function contribute() public payable {
        require(!canceled, "ICO has been canceled");
        require(
            block.timestamp >= startTimestamp &&
                block.timestamp <= endTimestamp,
            "ICO is not active"
        );
        require(msg.value > 0, "Contribution amount should be greater than 0");
        uint256 contributionAmount = msg.value;
        uint256 tokenAmount = contributionAmount * presaleRate;
        contributers[msg.sender] += contributionAmount;
        IERC20 token = IERC20(tokenAddress);
        token.transferFrom(icoOwner, msg.sender, tokenAmount);
        if (finished && soldOut >= amount) {
            addLiquidity();
        }
    }

    function finalizeICO() public onlyOwner {
        require(!finished, "ICO has already been finalized");
        IERC20 token = IERC20(tokenAddress);
        token.transferFrom(icoOwner, address(this), tokenForListing);
        token.approve(address(pancakeRouter), tokenForListing);
        addLiquidity();
        finished = true;
    }

    function addLiquidity() internal {
        IERC20 token = IERC20(tokenAddress);
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

    function cancelICO() public onlyOwner {
        canceled = true;
    }

    function addBadge(
        string memory _auditUrl,
        string memory _kycUrl,
        string memory _doxxUrl,
        string memory _safuUrl
    ) public onlyAuditer {
        auditedUrl = _auditUrl;
        kycUrl = _kycUrl;
        doxxdUrl = _doxxUrl;
        safuUrl = _safuUrl;
    }

    function getBadge()
        public
        view
        returns (
            string memory,
            string memory,
            string memory,
            string memory
        )
    {
        return (auditedUrl, kycUrl, doxxdUrl, safuUrl);
    }

    function claimToken() public {
        // Logic to claim token
    }

    function emergencyWithdrawl() public {}

    function contributeWithReferal(address _refralAddress, uint256 _amount)
        public
    {}
}
