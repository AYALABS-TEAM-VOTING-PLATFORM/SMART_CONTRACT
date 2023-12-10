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

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Governance} from "./interface/Governance.sol";
import {IERC20} from "./interface/IERC2o.sol";
import {IVoter} from "./interface/IVoter.sol";

contract GovernanceToken is ERC20, IVoter {
    constructor() ERC20("Reward", "RWD") {
        _mint(address(this), 1000 * 10 ** 18);
    }

    mapping(address => uint) noOfTokens;

    function addMinter(
        string memory year,
        uint256 _electionId,
        address governanceAddr,
        address minter
    ) external {
        bool hasMinted = Governance(governanceAddr).hasMinted(
            year,
            _electionId
        );
        bool isVerified = Governance(governanceAddr).isVerified(msg.sender);

        // CHECKS
        // 1- checking if a voter has minted the token before
        // 2- checking if a voter has verified is account
        require(hasMinted == false, "You Already minted for this elections");
        require(isVerified == true, "You Are not verified to mint a token");

        noOfTokens[msg.sender]++;

        Governance(governanceAddr).changeHasMinted(year, _electionId);
        Governance(governanceAddr).addMinterToElection(
            year,
            _electionId,
            minter
        );
    }

    function mint(address governanceAddr) external {
        Voter[] memory voters = Governance(governanceAddr).getAllVoters();

        for (uint i = 0; i < voters.length; i++) {
            uint _noOfTokens = noOfTokens[msg.sender];

            IERC20(address(this)).transfer(
                voters[i].voterAddr,
                _noOfTokens * 10 ** 18
            );
        }
    }

    function balanceOf() public view returns (uint256) {
        return IERC20(address(this)).balanceOf(address(this));
    }

    function getVoterNoTokens() public view returns (uint) {
        return noOfTokens[msg.sender];
    }
}
