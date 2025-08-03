// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// The contract DecentralizedVoting allows a decentralized voting process with a fee 
// where users can vote for candidates
contract DecentralizedVoting {
    address public admin;

    mapping(bytes32 => uint256) public votesReceived;      // maps candidate name (as bytes32) to number of votes they have received
    mapping(bytes32 => bool) public isValidCandidate;      // tracks whether a given candidate is in the list
    mapping(address => bool) public hasVoted;              // tracks whether a particular user has already voted or not
    bytes32[] public candidateList;                        // stores the list of candidates
    
    //modifier to restrict access to only to the admin
    modifier onlyAdmin() {
    require(msg.sender == admin, "Not admin");
    _;
    }
    
    constructor() {
        admin = msg.sender;
    }
    //function to add candidate names
    function addCandidate(bytes32 name) public onlyAdmin {
    require(!isValidCandidate[name], "Already added");
    isValidCandidate[name] = true;
    candidateList.push(name);
    }

    // Payable function for voting
    function vote(bytes32 candidate) public payable {
        // Minimum 0.01 ether required to vote
        if (msg.value < 0.01 ether) {
            revert("Minimum 0.01 ether required to vote.");
        }

        // Check if user has already voted
        if (hasVoted[msg.sender]) {
            revert("Already voted.");
        }

        // Check if candidate is valid
        if (!isValidCandidate[candidate]) {
            revert("Invalid candidate.");
        }

        votesReceived[candidate]++;        // Increment vote count
        hasVoted[msg.sender] = true;       // Mark user as having voted
    }

    // Function to get total number of votes received by a candidate
    function totalVotesFor(bytes32 candidate) public view returns (uint256) {
        if (!isValidCandidate[candidate]) {
            revert("Invalid candidate.");
        }
        return votesReceived[candidate];
    }
    
    // get the list of all candidates
    function getCandidates() public view returns (bytes32[] memory) {
        return candidateList;
    }
    //Lets the admin collect the fee
    function withdrawFees() public onlyAdmin {
    uint256 balance = address(this).balance;
    require(balance > 0, "No fees to withdraw");
    //sending ether
    (bool success, ) = payable(admin).call{value: balance}("");
    require(success, "Withdrawal failed");
}
}
