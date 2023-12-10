// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {IVoter} from "./IVoter.sol";

interface Governance is IVoter {
    function hasMinted(
        string memory year,
        uint256 _electionId
    ) external view returns (bool);

    function isVerified(address _walletAddress) external view returns (bool);

    function changeHasMinted(string memory year, uint256 _electionId) external;

    function addMinterToElection(
        string memory year,
        uint256 electionId,
        address minter
    ) external;

    function getAllVoters() external view returns (Voter[] memory _allVoters);
}
