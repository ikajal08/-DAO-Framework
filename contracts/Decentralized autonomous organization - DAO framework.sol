// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title DAO Framework
 * @notice A simple decentralized autonomous organization (DAO) with proposal and voting features.
 */
contract DAOFramework is Ownable {
    enum ProposalStatus { Pending, Active, Executed }

    struct Proposal {
        uint256 id;
        address proposer;
        string description;
        uint256 voteCount;
        ProposalStatus status;
        mapping(address => bool) voted;
    }

    uint256 public proposalCount;
    mapping(uint256 => Proposal) public proposals;
    address[] public members;
    mapping(address => bool) public isMember;

    event ProposalCreated(uint256 proposalId, address proposer, string description);
    event Voted(uint256 proposalId, address voter);
    event ProposalExecuted(uint256 proposalId);

    modifier onlyMember() {
        require(isMember[msg.sender], "Not a DAO member");
        _;
    }

    // Default constructor: owner = deployer, deployer added as member
    constructor() Ownable(msg.sender) {
        addMember(msg.sender);
    }

    function addMember(address member) public onlyOwner {
        require(!isMember[member], "Already a member");
        isMember[member] = true;
        members.push(member);
    }

    function createProposal(string calldata description) external onlyMember {
        proposalCount++;
        Proposal storage p = proposals[proposalCount];
        p.id = proposalCount;
        p.proposer = msg.sender;
        p.description = description;
        p.status = ProposalStatus.Active;
        emit ProposalCreated(p.id, msg.sender, description);
    }

    function vote(uint256 proposalId) external onlyMember {
        Proposal storage p = proposals[proposalId];
        require(p.status == ProposalStatus.Active, "Proposal not active");
        require(!p.voted[msg.sender], "Already voted");

        p.voteCount++;
        p.voted[msg.sender] = true;

        emit Voted(proposalId, msg.sender);
    }

    function executeProposal(uint256 proposalId) external onlyOwner {
        Proposal storage p = proposals[proposalId];
        require(p.status == ProposalStatus.Active, "Proposal not active");
        require(p.voteCount > members.length / 2, "Not enough votes");

        p.status = ProposalStatus.Executed;

        emit ProposalExecuted(proposalId);
    }

    function getMembers() external view returns (address[] memory) {
        return members;
    }
}
