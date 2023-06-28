// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function decimals() external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
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

contract airdropv1 {
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

    function addAllocation(
        address[] memory _participants,
        uint256[] memory _amount
    ) public {
        require(msg.sender == owner, "unAuthorized User");
        require(
            !started || startTimestamp >= block.timestamp,
            "airdrop has already started"
        );

        uint256 totalTokens = 0;

        for (uint256 i = 0; i < _participants.length; i++) {
            participants[_participants[i]] = _amount[i];
            participantAddresses.push(_participants[i]);
            totalTokens += _amount[i];
        }

        IERC20(tokenAddress).transferFrom(
            msg.sender,
            address(this),
            totalTokens * 10**decimal
        );
    }

    function getAllocation(address _participant) public view returns (uint256) {
        return participants[_participant];
    }

    function startAirdrop() public {
        require(msg.sender == owner, "unAuthorized User");
        require(
            !started || startTimestamp >= block.timestamp,
            "airdrop has already started"
        );
        started = true;
    }

    function getIcoDetails()
        public
        view
        returns (
            AirdropDetails memory,
            bool,
            address,
            uint256
        )
    {
        bool status = started || block.timestamp >= startTimestamp;
        uint256 _decimal = IERC20(tokenAddress).decimals();
        return (details, status, tokenAddress, _decimal);
    }

  function updateData (AirdropDetails memory _newDetails) public {
       require(msg.sender == owner, "unAuthorized User");
       details = _newDetails;
  }

    function claim() public {
        require(
            participants[msg.sender] > 0,
            "No allocation found for the participant"
        );
        require(
            started || block.timestamp >= startTimestamp,
            "Airdrop has not started yet"
        );

        uint256 allocation = participants[msg.sender];
        participants[msg.sender] = 0;

        uint256 amountToTransfer = allocation * (10**decimal);

        IERC20(tokenAddress).transfer(msg.sender, amountToTransfer);
    }

    function autoTransferTokens() public {
        require(msg.sender == owner, "unAuthorized User");
        require(
            started || block.timestamp >= startTimestamp,
            "Airdrop has not started yet"
        );

        for (uint256 i = 0; i < participantAddresses.length; i++) {
            address participant = participantAddresses[i];
            uint256 allocation = participants[participant];
            uint256 amountToTransfer = allocation * (10**decimal);

            if (amountToTransfer > 0) {
                participants[participant] = 0;
                IERC20(tokenAddress).transfer(participant, amountToTransfer);
            }
        }
    }

    function claimRange(uint256 fromIndex, uint256 toIndex) public {
        require(msg.sender == owner, "unAuthorized User");
        require(
            fromIndex <= toIndex,
            "Invalid range, 'from' index must be less than or equal to 'to' index"
        );
        require(
            toIndex < participantAddresses.length,
            "Invalid 'to' index, exceeds participant addresses length"
        );

        for (uint256 i = fromIndex; i <= toIndex; i++) {
            address participantAddress = participantAddresses[i];
            uint256 allocation = participants[participantAddress];
            participants[participantAddress] = 0;
            IERC20(tokenAddress).transfer(
                participantAddress,
                allocation * (10**decimal)
            );
        }
    }

    function getParticipantsDetails()
        public
        view
        returns (Participant[] memory)
    {
        Participant[] memory participantsDetails = new Participant[](
            participantAddresses.length
        );

        for (uint256 i = 0; i < participantAddresses.length; i++) {
            address participantAddress = participantAddresses[i];
            uint256 tokenAmount = participants[participantAddress];

            participantsDetails[i] = Participant(
                participantAddress,
                tokenAmount
            );
        }

        return participantsDetails;
    }
}

// File: contract/airdropRegistry.sol

pragma solidity ^0.8.0;

contract AirdropFactory {
    event AirdropContractDeployed(
        address indexed icoContract,
        address indexed tokenAddress
    );

    struct AirdropPage {
        address[] addresses;
        bool exists;
    }
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    mapping(address => address) public deployedAirdropContract;
    AirdropPage[] public AllAirdropPage;
    uint256 public contractsPerPage = 10;

    function createAirdropContract(
        AirdropDetails memory _airdropDetails,
        uint256 _startingTimestamp,
        address _tokenAddress
    ) public {
        airdropv1 ico = new airdropv1(
            msg.sender,
            _tokenAddress,
            _startingTimestamp,
            _airdropDetails
        );

        deployedAirdropContract[_tokenAddress] = address(ico);

        uint256 pageIndex = AllAirdropPage.length - 1;
        if (
            !AllAirdropPage[pageIndex].exists ||
            AllAirdropPage[pageIndex].addresses.length == contractsPerPage
        ) {
            AllAirdropPage.push();
            pageIndex++;
        }

        AllAirdropPage[pageIndex].addresses.push(address(ico));
        AllAirdropPage[pageIndex].exists = true;

        emit AirdropContractDeployed(address(ico), _tokenAddress);
    }

    function getDeployedAirdropContract(address _tokenAddress)
        public
        view
        returns (address)
    {
        return deployedAirdropContract[_tokenAddress];
    }

    function getPageCount() public view returns (uint256) {
        return AllAirdropPage.length;
    }

    function changePageLimit(uint256 _newPageLimit) public {
        require(msg.sender == owner, "unAuthorized User");
        contractsPerPage = _newPageLimit;
    }

    function getAirdropContractPage(uint256 pageIndex)
        public
        view
        returns (address[] memory)
    {
        require(pageIndex < AllAirdropPage.length, "Invalid page index");

        return AllAirdropPage[pageIndex].addresses;
    }
}
