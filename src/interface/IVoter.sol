// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

interface IVoter {
    struct Voter {
        address voterAddr;
        bool verified;
    }
}
