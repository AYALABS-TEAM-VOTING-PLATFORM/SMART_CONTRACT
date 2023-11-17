// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

interface Governance {
    function hasMinted(
        string memory year,
        uint256 _electionId
    ) external view returns (bool);

    function isVerified() external view returns (bool);
}
