// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "../Semaphore.sol";
import "../base/SemaphoreVerifier.sol";
import "../interfaces/ISemaphoreVerifier.sol";

contract TestSemaphore {
    Semaphore sp;
    uint256[] members;
    mapping(uint256 => bool) memberStatus;

    constructor () {
        SemaphoreVerifier spv = new SemaphoreVerifier();
        sp = new Semaphore(ISemaphoreVerifier(address(spv)));
        sp.createGroup(0, 16, 0, address(this));
    }

    function addMember(uint256 identityCommitment) public {
        sp.addMember(0, identityCommitment);
        members.push(identityCommitment);
        memberStatus[identityCommitment] = true;
    }

    function updateMember(uint256 identityCommitment, uint256 newIdentityCommitment) public {
        uint256 depth = sp.getMerkleTreeDepth(0);
        uint256[] memory proofSiblings = new uint256[](depth);
        uint8[] memory proofPathIndices = new uint8[](depth);
        sp.updateMember(0, identityCommitment, newIdentityCommitment, proofSiblings, proofPathIndices);
        memberStatus[identityCommitment] = false;
        members.push(newIdentityCommitment);
        memberStatus[newIdentityCommitment] = true;
    }

    function removeMember(uint256 identityCommitment) public {
        uint256 depth = sp.getMerkleTreeDepth(0);
        uint256[] memory proofSiblings = new uint256[](depth);
        uint8[] memory proofPathIndices = new uint8[](depth);
        sp.removeMember(0, identityCommitment, proofSiblings, proofPathIndices);
        memberStatus[identityCommitment] = false;
    }

    function echidna_commitement_size() public returns (bool) {
        uint256 depth = sp.getMerkleTreeDepth(0);
        uint256[] memory proofSiblings = new uint256[](depth);
        uint8[] memory proofPathIndices = new uint8[](depth);
        
        uint256[] memory m = members;
        uint256 ml = m.length;
        for (uint256 j=0; j < ml; ++j) {
            if (memberStatus[m[j]]) {
                try sp.removeMember(0, m[j], proofSiblings, proofPathIndices) {
                    continue;
                } catch Error(string memory reason) {
                    // return false;
                    if (keccak256(abi.encode(reason)) == keccak256(abi.encode("IncrementalBinaryTree: leaf must be < SNARK_SCALAR_FIELD"))) {
                        return false;
                    }
                }
            }
        }
        return true;
    }
}