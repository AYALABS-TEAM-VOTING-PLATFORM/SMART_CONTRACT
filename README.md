# Governance Smart Contract

## Overview

This is a smart contract implemented in Solidity for managing governance processes, including elections, candidates, and voting. The contract is designed to be used in decentralized applications (DApps) and supports features like creating elections, adding candidates, and facilitating the voting process.

## Structure

### Version

The contract is written in Solidity, and the version used is [Solidity Version].

### Layout

The contract follows a structured layout for better readability and maintainability:

1. Version
2. Imports
3. Errors
4. Interfaces, Libraries, Contracts
5. Type Declarations
6. State Variables
7. Events
8. Modifiers
9. Functions

The functions are further organized based on their visibility and purpose.

## Smart Contract Components

### Structs

- **Election**: Represents information about an election, including its name, start and end dates, candidates, and ongoing status.
- **Candidate**: Stores details about a candidate, such as name, image URI, position, about, number of voters, voters' addresses, and a unique ID.

### Mappings

- **elections**: Maps a combination of the year and election ID to an Election struct.
- **candidates**: Maps a combination of the year and candidate ID to a Candidate struct.
- **minted**: Maps user addresses to election years and IDs to track whether a user has minted a token for a specific election.

### State Variables

- **i_owner**: Immutable address representing the owner of the contract.
- **voters**: An array of addresses representing registered voters.
- **allCandidates**: An array of Candidate structs containing all candidates across elections.
- **allElection**: An array of Election structs containing details of all elections.

### Events

- **ElectionStatusChanged**: Fired when the status of an election changes.
- **CandidateAdded**: Fired when a new candidate is added to an election.

### Modifiers

- **onlyOwner**: Ensures that only the contract owner can execute certain functions.

## Functions

- **mint**: Allows users to mint tokens for a specific election.
- **addVoter**: Registers a new voter.
- **vote**: Facilitates the voting process for a specified election.
- **createCandidate**: Creates a new candidate for a given year and ID.
- **createElection**: Initializes a new election with the specified details.
- **addCandidate**: Adds a candidate to a specific election.
- **changeElectionStatusToStarted**: Allows changing the ongoing status of an election.
- **getAllCandidates**: Returns an array of all candidates.
- **getCandidatesForAYear**: Retrieves details of a specific candidate for a given year.
- **getAllElections**: Returns an array of all elections.
- **getElection**: Retrieves details of a specific election.

## Usage

To interact with this smart contract, deploy it to the Ethereum blockchain and use the provided functions through a decentralized application.

## Contributing

Feel free to contribute to the development of this smart contract. Fork the repository, make changes, and submit a pull request.

## License

This smart contract is licensed under the SPDX-LICENSE License - see the------------.
