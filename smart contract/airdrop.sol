// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function decimals() external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transfer(address recipient, uint256 amount) external returns (bool);
}

struct AirdropDetails {
    string logo;
    string website;
    string Facebook;
    string Twitter;
    string Github;
    string Telegram;
    string Instagram;
    string reddit;
    string Discord;
    string description;
}

contract AirdropV1 {
    struct Participant {
        address participantAddress;
        uint256 tokenAmount;
    }

    AirdropDetails public details;
    mapping(address => uint256) public participants;
    address[] public participantAddresses;
    bool public started;
    address public owner;
    uint256 public decimal;
    address public tokenAddress;
    uint256 public startTimestamp;

    event AllocationAdded(address indexed participant, uint256 amount);
    event AirdropStarted();
    event AirdropDetailsUpdated(AirdropDetails newDetails);

    constructor(
        address _owner,
        address _tokenAddress,
        uint256 _startTimestamp,
        AirdropDetails memory _details
    ) {
        tokenAddress = _tokenAddress;
        owner = _owner;
        details = _details;
        startTimestamp = _startTimestamp;
        decimal = IERC20(tokenAddress).decimals();
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Unauthorized user");
        _;
    }

    modifier airdropNotStarted() {
        require(!started || startTimestamp >= block.timestamp, "Airdrop has already started");
        _;
    }

    function addAllocation(address[] memory _participants, uint256[] memory _amount) public onlyOwner airdropNotStarted {
        require(_participants.length == _amount.length, "Array lengths mismatch");

        uint256 totalTokens = 0;

        for (uint256 i = 0; i < _participants.length; i++) {
            participants[_participants[i]] = _amount[i];
            participantAddresses.push(_participants[i]);
            totalTokens += _amount[i];
            emit AllocationAdded(_participants[i], _amount[i]);
        }

        IERC20(tokenAddress).transferFrom(msg.sender, address(this), totalTokens * (10**decimal));
    }

    function getAllocation(address _participant) public view returns (uint256) {
        return participants[_participant];
    }

    function startAirdrop() public onlyOwner airdropNotStarted {
        started = true;
        emit AirdropStarted();
    }

    function getAirdropDetails() public view returns (AirdropDetails memory, bool, address, uint256) {
        bool status = started || block.timestamp >= startTimestamp;
        uint256 _decimal = IERC20(tokenAddress).decimals();
        return (details, status, tokenAddress, _decimal);
    }

    function updateAirdropDetails(AirdropDetails memory _newDetails) public onlyOwner {
        details = _newDetails;
        emit AirdropDetailsUpdated(_newDetails);
    }

    function claim() public {
        require(participants[msg.sender] > 0, "No allocation found for the participant");
        require(started || block.timestamp >= startTimestamp, "Airdrop has not started yet");

        uint256 allocation = participants[msg.sender];
        participants[msg.sender] = 0;

        uint256 amountToTransfer = allocation * (10**decimal);

        require(IERC20(tokenAddress).transfer(msg.sender, amountToTransfer), "Token transfer failed");
    }

    function autoTransferTokens() public onlyOwner {
        require(started || block.timestamp >= startTimestamp, "Airdrop has not started yet");

        for (uint256 i = 0; i < participantAddresses.length; i++) {
            address participant = participantAddresses[i];
            uint256 allocation = participants[participant];
            uint256 amountToTransfer = allocation * (10**decimal);

            if (amountToTransfer > 0) {
                participants[participant] = 0;
                require(IERC20(tokenAddress).transfer(participant, amountToTransfer), "Token transfer failed");
            }
        }
    }

    function claimRange(uint256 fromIndex, uint256 toIndex) public onlyOwner {
        require(fromIndex <= toIndex, "Invalid range, 'from' index must be less than or equal to 'to' index");
        require(toIndex < participantAddresses.length, "Invalid 'to' index, exceeds participant addresses length");
        require(started || block.timestamp >= startTimestamp, "Airdrop has not started yet");

        for (uint256 i = fromIndex; i <= toIndex; i++) {
            address participantAddress = participantAddresses[i];
            uint256 allocation = participants[participantAddress];
            participants[participantAddress] = 0;
            require(IERC20(tokenAddress).transfer(participantAddress, allocation * (10**decimal)), "Token transfer failed");
        }
    }

    function getParticipantsDetails() public view returns (Participant[] memory) {
        Participant[] memory participantsDetails = new Participant[](participantAddresses.length);

        for (uint256 i = 0; i < participantAddresses.length; i++) {
            address participantAddress = participantAddresses[i];
            uint256 tokenAmount = participants[participantAddress];

            participantsDetails[i] = Participant(participantAddress, tokenAmount);
        }

        return participantsDetails;
    }
}

contract AirdropFactory {
    event AirdropContractDeployed(address indexed airdropContract, address indexed tokenAddress);

    struct AirdropPage {
        address[] addresses;
        bool exists;
    }

    address public owner;
    uint256 public contractsPerPage = 10;
    AirdropPage[] public allAirdropPages;

    constructor() {
        owner = msg.sender;
    }

    mapping(address => address) public deployedAirdropContracts;

    function createAirdropContract(
        AirdropDetails memory _airdropDetails,
        uint256 _startingTimestamp,
        address _tokenAddress
    ) public {
        AirdropV1 airdrop = new AirdropV1(msg.sender, _tokenAddress, _startingTimestamp, _airdropDetails);

        deployedAirdropContracts[_tokenAddress] = address(airdrop);

        uint256 pageIndex = allAirdropPages.length - 1;
        if (!allAirdropPages[pageIndex].exists || allAirdropPages[pageIndex].addresses.length == contractsPerPage) {
            allAirdropPages.push();
            pageIndex++;
        }

        allAirdropPages[pageIndex].addresses.push(address(airdrop));
        allAirdropPages[pageIndex].exists = true;

        emit AirdropContractDeployed(address(airdrop), _tokenAddress);
    }

    function getDeployedAirdropContract(address _tokenAddress) public view returns (address) {
        return deployedAirdropContracts[_tokenAddress];
    }

    function getPageCount() public view returns (uint256) {
        return allAirdropPages.length;
    }

    function changePageLimit(uint256 _newPageLimit) public {
        require(msg.sender == owner, "Unauthorized user");
        contractsPerPage = _newPageLimit;
    }

    function getAirdropContractPage(uint256 pageIndex) public view returns (address[] memory) {
        require(pageIndex < allAirdropPages.length, "Invalid page index");
        return allAirdropPages[pageIndex].addresses;
    }
}
