//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    uint public constant depth = 3;

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves
        hashes = new uint256[](2**(depth+1)-1);
        for(uint i = 0; i < 8; i++) {
            hashes[i] = 0;
        }
        uint256 l1 = PoseidonT3.poseidon([hashes[0], hashes[1]]);
        for(uint i = 8; i < 12; i++) {
            hashes[i] = l1;
        }
        uint256 l2 = PoseidonT3.poseidon([hashes[8], hashes[9]]);
        for(uint i = 12; i < 14; i++) {
            hashes[i] = l2;
        }
        uint256 l3 = PoseidonT3.poseidon([hashes[12], hashes[13]]);
        hashes[14] = l3;
        root = hashes[hashes.length - 1];
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        require(index < 8);
        hashes[index] = hashedLeaf;

        uint i = index;
        for(uint l = 0; l < depth; l++) {
            uint even;
            uint odd;
            if(i % 2 == 0) {
                even = i;
                odd = i + 1;
            } else {
                even = i - 1;
                odd = i;
            }
            uint256 h = PoseidonT3.poseidon([hashes[even], hashes[odd]]);
            uint father = even / 2 + 8;
            hashes[father] = h;
            i = father;
        }

        index++;
        root = hashes[hashes.length - 1];
        return root;
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {

        // [assignment] verify an inclusion proof and check that the proof root matches current root
        bool isVerified = verifyProof(a, b, c, input);
        bool doesRootMatch = input[0] == root;
        return isVerified && doesRootMatch;
    }
}

