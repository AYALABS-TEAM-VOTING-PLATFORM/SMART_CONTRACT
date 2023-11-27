// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity ^0.8.18;

error VotingEnded();
error VotingEndingTimeHasntReached();

import {IERC20} from "./interface/IERC2o.sol";
import {IGovernanceToken} from "./interface/IGovernanceToken.sol";

contract Governance {
    //////////// STRUCT ///////////////
    struct Election {
        string name;
        uint256 startDate;
        uint256 endDate;
        address[] voters;
        uint256[] candidates;
        bool ongoing;
        address[] minters;
        uint256 ID;
        string about;
        string year;
    }

    struct Candidate {
        string name;
        string imageURI;
        string position;
        string about;
        uint256 noOfVoters;
        address[] votersAddresses; // people that has voted for this candidate
        uint256 ID;
        string year;
    }

    struct Voter {
        address voterAddr;
        bool verified;
    }

    //////////// MAPPINGS ///////////////
    mapping(string year => mapping(uint256 electionId => Election)) elections;
    mapping(string year => mapping(uint256 candidateId => Candidate)) candidates; // for a particular year
    mapping(address => Voter) voters; // for a particular year

    // Mapping structure to track if a user has minted a token for a specific election.
    // Keys:
    // - Outer mapping: user's Ethereum address (voterAddr).
    // - Next level mapping: election year (string).
    // - Innermost mapping: election ID (uint256).
    // - Value: boolean indicating whether the user has minted for the specified election (true if minted, false otherwise).
    mapping(address voterAddr => mapping(string year => mapping(uint256 => bool))) minted; // returns true if a user has minted for this election

    //////////// STATE VARIABLE ///////////////
    address immutable i_owner;
    Voter[] internal allVoters;
    Candidate[] internal allCandidates;
    Election[] internal allElection;

    ///////// EVENTS /////////////////////////
    event ElectionStatusChanged(
        string indexed year,
        uint256 indexed electionId,
        uint256 indexed endDate,
        bool status
    );
    event CandidateAdded(
        uint256 indexed electionId,
        uint256 indexed candidateId,
        string indexed _year
    );
    event MintedToken(
        string indexed year,
        uint256 indexed electionId,
        address indexed _tokenAddr
    );
    event AddVoter(address indexed sender);
    event VerifiedVoter(address indexed sender);
    event VotedSuccessfully(
        string indexed year,
        uint256 indexed electionId,
        address tokenAddress,
        uint256 value,
        uint256 startDate,
        uint256 endDate,
        uint256 indexed candidateId
    );

    event CreatedElection(
        string indexed year,
        string indexed _name,
        uint256 indexed _electionId,
        uint256 _startDate,
        uint256 _endDate
    );
    //////////// MODIFIERS ///////////////
    modifier onlyOwner() {
        require(msg.sender == i_owner, "You can not call the function");
        _;
    }

    constructor(address _owner) {
        i_owner = _owner; // or can make msg.sender
    }

    function mint(
        string memory year,
        uint256 _electionId,
        address _tokenAddr
    ) public {
        // when a user call this function (DO THIS)
        // check if the user has minted for the election he is trying to mint for
        // mint the user the token

        // MINT FUNCTION
        // mint the user one token only
        IGovernanceToken(_tokenAddr).mint(year, _electionId, address(this));
        emit MintedToken(year, _electionId, _tokenAddr);
    }

    function addVoter() public {
        // Check if voter already exist
        // might be inefficient, may change to set later on

        require(
            voters[msg.sender].voterAddr == address(0),
            "Already Registered"
        );

        voters[msg.sender] = Voter({voterAddr: msg.sender, verified: false});
        allVoters.push(Voter({voterAddr: msg.sender, verified: false}));

        emit AddVoter(msg.sender);
    }

    function verifyVoter(address _addressToBeVerified) external onlyOwner {
        // check if the owner is the one calling
        // make sure
        Voter storage voter = voters[_addressToBeVerified];
        voter.verified = true;

        emit VerifiedVoter(msg.sender);
    }

    function vote(
        string memory year,
        uint256 electionId,
        address tokenAddress,
        uint256 value,
        uint256 startDate,
        uint256 endDate,
        uint256 candidateId
    ) public {
        // check if vote is over
        Election storage election = elections[year][electionId];
        Candidate storage candidate = candidates[year][candidateId];

        // if the time has passed, the next person that tries to vote changes ongoing to false
        // Check if the election has ended. If so, mark it as not ongoing and revert the transaction.
        require(!election.ongoing, "Election Ended");

        if (block.timestamp > endDate) {
            election.ongoing = false;
            revert VotingEnded();
        }
        // Check if the current timestamp is within the election period.
        if (block.timestamp > startDate && block.timestamp < endDate) {
            // If within the election period, mark the election as ongoing.
            election.ongoing = true;
        }

        IERC20(tokenAddress).transferFrom(msg.sender, address(this), value);

        // make state change
        candidate.noOfVoters++;
        candidate.votersAddresses.push(msg.sender);
        election.voters.push(msg.sender);

        emit VotedSuccessfully(
            year,
            electionId,
            tokenAddress,
            value,
            startDate,
            endDate,
            candidateId
        );
    }

    function createCandidate(
        string memory year,
        uint256 candidateId,
        string memory name,
        string memory imageURI,
        string memory position,
        string memory about
    ) public onlyOwner {
        candidates[year][candidateId] = Candidate({
            name: name,
            imageURI: imageURI,
            position: position,
            about: about,
            noOfVoters: 0, // people that has voted for this candidate
            votersAddresses: new address[](0),
            ID: candidateId,
            year: year
        });
        allCandidates.push(
            Candidate({
                name: name,
                imageURI: imageURI,
                position: position,
                about: about,
                noOfVoters: 0, // people that has voted for this candidate
                votersAddresses: new address[](0),
                ID: candidateId,
                year: year
            })
        );
    }

    function creatElection(
        string memory year,
        string memory _name,
        uint256 _electionId,
        uint256 _startDate,
        uint256 _endDate,
        string memory about
    ) public onlyOwner {
        // check if that candidate already exist
        // Candidate[] memory candidate = new Candidate[](3);

        elections[year][_electionId] = Election({
            name: _name,
            startDate: _startDate,
            endDate: _endDate,
            voters: new address[](0),
            candidates: new uint256[](0),
            ongoing: false,
            minters: new address[](0),
            ID: _electionId, // Assuming the ID is the index in the array
            about: about,
            year: year
        });
        allElection.push(
            Election({
                name: _name,
                startDate: _startDate,
                endDate: _endDate,
                voters: new address[](0),
                candidates: new uint256[](0),
                ongoing: false,
                minters: new address[](0),
                ID: _electionId, // Assuming the ID is the index in the array
                about: about,
                year: year
            })
        );

        emit CreatedElection(year, _name, _electionId, _startDate, _endDate);
    }

    // checked  👍
    function addCandidate(
        uint256 _electionId,
        uint256 candidateId,
        string memory _year
    ) public onlyOwner {
        // Get the reference to the election by using the election ID and year.
        Election storage election = elections[_year][_electionId];

        // Get the storage reference to the array of candidates for the specified election.
        uint256[] storage candidatesArr = election.candidates;

        // Add the candidate to the array of candidates for the specified election.
        candidatesArr.push(candidateId);

        // Emit an event to log the addition of the candidate to the election.
        emit CandidateAdded(_electionId, candidateId, _year);
    }

    // still thinking if to make this only owner can call this
    // or let voters end it
    function changeElectionStatusToStarted(
        string memory year,
        uint256 electionId,
        uint256 endDate,
        bool status
    ) external onlyOwner {
        // Check if the election exists
        require(
            elections[year][electionId].ID == electionId,
            "Election does not exist"
        );
        Election storage election = elections[year][electionId];

        // Ensure the election status is different from the requested status.
        require(election.ongoing != status, "Already in this status");

        if (status == false) {
            // If the status is false, check if the current timestamp is before the specified end date.
            // If the end date hasn't been reached, revert the transaction.
            require(
                block.timestamp > endDate,
                "Voting ending time hasn't been reached"
            );
        } else {
            // If the status is true, check if the current timestamp is after the specified end date.
            // If the end date has been reached, revert the transaction.
            require(block.timestamp < endDate, "Voting has already ended");
        }

        // Update the election status to the requested status.
        election.ongoing = status;

        // Emit an event to log the change in election status.
        emit ElectionStatusChanged(year, electionId, endDate, status);
    }

    function changeHasMinted(string memory year, uint256 _electionId) external {
        minted[msg.sender][year][_electionId] = true;
    }

    function addMinterToElection(
        string memory year,
        uint256 electionId,
        address minter
    ) external {
        Election storage election = elections[year][electionId];
        election.minters.push(minter);
    }

    ////////////// GETTERS FUNCTIONS (VIEW and PURE) ///////////////////////
    function getAllCondidates()
        public
        view
        returns (Candidate[] memory _candidates)
    {
        return allCandidates;
    }

    // get a particular candidate details
    function getCandidatesForAYear(
        uint256 candidateId,
        string memory year
    ) public view returns (Candidate memory _candidates) {
        return candidates[year][candidateId];
    }

    function getAllElections()
        public
        view
        returns (Election[] memory _allelections)
    {
        return allElection;
    }

    // get a particular election details
    function getElection(
        uint256 electionId,
        string memory year
    ) public view returns (Election memory _election) {
        return elections[year][electionId];
    }

    function getAllVoters() public view returns (Voter[] memory _allVoters) {
        return allVoters;
    }

    // get a particular voter details
    function getVoter(
        address voterAddress
    ) public view returns (Voter memory _voter) {
        return voters[voterAddress];
    }

    function hasMinted(
        string memory year,
        uint256 _electionId
    ) external view returns (bool) {
        return minted[msg.sender][year][_electionId];
    }

    function isVerified(address _walletAddress) external view returns (bool) {
        return voters[_walletAddress].verified;
    }
}
