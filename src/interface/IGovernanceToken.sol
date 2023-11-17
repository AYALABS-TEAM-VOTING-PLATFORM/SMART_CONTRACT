// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

interface IGovernanceToken {
    function mint(
        string memory year,
        uint256 _electionId,
        address governanceAddr
    ) external;
}
