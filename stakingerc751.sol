pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract StakingContract {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public erc721Address;
    address public erc20Address;
    uint256 public exchangeRate;
    uint256 public stakingDuration;
    uint256 public stakingFee;

    struct Stake {
        uint256 tokenId;
        uint256 timestamp;
        bool claimed;
    }

    mapping(address => Stake[]) public stakedTokens;

    constructor(address _erc721Address, address _erc20Address, uint256 _exchangeRate, uint256 _stakingDuration, uint256 _stakingFee) {
        erc721Address = _erc721Address;
        erc20Address = _erc20Address;
        exchangeRate = _exchangeRate;
        stakingDuration = _stakingDuration;
        stakingFee = _stakingFee;
    }

    function stake(uint256 tokenId) external {
        IERC721 erc721 = IERC721(erc721Address);
        require(erc721.ownerOf(tokenId) == msg.sender, "You do not own this token");
        erc721.safeTransferFrom(msg.sender, address(this), tokenId);
        stakedTokens[msg.sender].push(Stake(tokenId, block.timestamp, false));
    }

    function unstake(uint256 index) external {
        require(stakedTokens[msg.sender][index].tokenId != 0, "No staked tokens found at this index");
        require(stakedTokens[msg.sender][index].claimed == false, "Rewards already claimed");
        require(block.timestamp.sub(stakedTokens[msg.sender][index].timestamp) >= stakingDuration, "Staking period has not yet ended");

        IERC721 erc721 = IERC721(erc721Address);
        erc721.safeTransferFrom(address(this), msg.sender, stakedTokens[msg.sender][index].tokenId);

        uint256 reward = exchangeRate.mul(stakingFee).div(100);
        IERC20 erc20 = IERC20(erc20Address);
        erc20.safeTransfer(msg.sender, reward);
        stakedTokens[msg.sender][index].claimed = true;
    }

    function totalStaked() external view returns (uint256) {
        return IERC721(erc721Address).balanceOf(address(this));
    }
}
