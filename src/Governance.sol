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

import {IERC20} from "./interface/IERC2o.sol";

contract Governance {
    //////////// STRUCT ///////////////
    struct Election {
        string name;
        uint256 startDate;
        uint256 endDate;
        address[] voters;
        Candidate[] candidates;
        bool ongoing;
        address[] minters;
        uint256 ID;
    }

    struct Candidate {
        string name;
        string imageURI;
        string position;
        string about;
        uint256 noOfVoters;
        address[] votersAddresses; // people that has voted for this candidate
        uint256 ID;
    }

    //////////// MAPPINGS ///////////////
    mapping(string year => mapping(uint256 electionId => Election)) elections;
    mapping(string year => mapping(uint256 candidateId => Candidate)) candidates; // for a particular year
    // Mapping structure to track if a user has minted a token for a specific election.
    // Keys:
    // - Outer mapping: user's Ethereum address (voterAddr).
    // - Next level mapping: election year (string).
    // - Innermost mapping: election ID (uint256).
    // - Value: boolean indicating whether the user has minted for the specified election (true if minted, false otherwise).
    mapping(address voterAddr => mapping(string year => mapping(uint256 => bool))) minted; // returns true if a user has minted for this election

    //////////// STATE VARIABLE ///////////////
    address immutable i_owner;
    address[] internal voters;
    Candidate[] internal allCandidates;
    Election[] internal allElection;

    modifier onlyOwner() {
        require(msg.sender == i_owner, "You can not call the function");
        _;
    }

    constructor(address _owner) {
        i_owner = _owner;
    }

    function mint(string memory year, uint256 electionId) public view {
        // when a user call this function (DO THIS)
        // check if the user has minted for the election he is trying to mint for
        // mint the user the token
        require(
            !minted[msg.sender][year][electionId],
            "Already minted for this election"
        ); // already minted try again for another election

        // MINT FUNCTION
    }

    function addVoter() public {
        // Check if voter already exist
        for (uint256 i = 0; i < voters.length; i++) {
            if (msg.sender == voters[i]) {
                require(false, "Already Registered Wallet as a voter");
            }
        } // might be inefficient, might change to set later on
        voters.push(msg.sender);
    }

    function vote(
        string memory year,
        uint256 electionId,
        address tokenAddress,
        uint32 value,
        uint256 endDate,
        uint256 candidateId
    ) public {
        // check if vote is over
        require(block.timestamp < endDate, "Election ALready Ended");

        Election storage election = elections[year][electionId];
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), value);

        // make state change
        Candidate storage candidate = election.candidates[candidateId];
        candidate.noOfVoters++;
        candidate.votersAddresses.push(msg.sender);
    }

    function createCandidate(
        string memory year,
        uint256 candidateId,
        string memory name,
        string memory imageURI,
        string memory position,
        string memory about
    ) public {
        candidates[year][candidateId] = Candidate({
            name: name,
            imageURI: imageURI,
            position: position,
            about: about,
            noOfVoters: 0, // people that has voted for this candidate
            votersAddresses: new address[](0),
            ID: candidateId
        });
        allCandidates.push(
            Candidate({
                name: name,
                imageURI: imageURI,
                position: position,
                about: about,
                noOfVoters: 0, // people that has voted for this candidate
                votersAddresses: new address[](0),
                ID: candidateId
            })
        );
    }

    function creatElection(
        string memory year,
        string memory _name,
        uint256 _electionId,
        uint256 _startDate,
        uint256 _endDate
    ) public {
        // check if that candidate already exist
        elections[year][_electionId] = Election({
            name: _name,
            startDate: _startDate,
            endDate: _endDate,
            voters: new address[](0),
            candidates: new Candidate[](0),
            ongoing: false,
            minters: new address[](0),
            ID: _electionId // Assuming the ID is the index in the array
        });
        allElection.push(
            Election({
                name: _name,
                startDate: _startDate,
                endDate: _endDate,
                voters: new address[](0),
                candidates: new Candidate[](0),
                ongoing: false,
                minters: new address[](0),
                ID: _electionId // Assuming the ID is the index in the array
            })
        );
    }

    function addCandidate(
        uint256 _electionId,
        uint256 candidateId,
        string memory _name,
        string memory _imageURI,
        string memory _position,
        string memory _year,
        string memory _about
    ) private {
        // get the election
        Election storage election = elections[_year][_electionId];
        Candidate[] storage candidate = election.candidates;

        candidate.push(
            Candidate({
                name: _name,
                imageURI: _imageURI,
                position: _position,
                about: _about,
                noOfVoters: 0,
                votersAddresses: new address[](0),
                ID: candidateId
            })
        );
    }

    ////////////// GETTERS FUNCTIONS (VIEW and PURE) ///////////////////////
    function getAllCondidates()
        public
        view
        returns (Candidate[] memory _candidates)
    {
        return allCandidates;
    }

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

    function getElection(
        uint256 electionId,
        string memory year
    ) public view returns (Election memory _election) {
        return elections[year][electionId];
    }
}
