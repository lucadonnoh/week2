pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/mux1.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    var n_hashes = 2**n-1;
    var hash[n_hashes];

    // hashing leaves
    for (var i = 0; i < 2**(n-1); i++) {
        hash[i] = Poseidon(2);
        hash[i].inputs[0] <== leaves[i * 2];
        hash[i].inputs[1] <== leaves[i * 2 + 1];
    }

    var j = 0;
    for(var i = 2**(n-1); i < n_hashes; i++) {
        hash[i] = Poseidon(2);
        hash[i].inputs[0] <== hash[j * 2].out;
        hash[i].inputs[1] <== hash[j * 2 + 1].out;
        j++;
    }

    root <== hash[n_hashes-1].out;
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    component hash[n];
    component mux[n];

    hash[0] = Poseidon(2);
    mux[0] = MultiMux1(2);

    mux[0].c[1][0] <== path_elements[0];
    mux[0].c[0][0] <== leaf;
    mux[0].c[1][1] <== leaf;
    mux[0].c[0][1] <== path_elements[0];

    mux[0].s <== path_index[0];

    hash[0].inputs[0] <== mux[0].out[0];
    hash[0].inputs[1] <== mux[0].out[1];

    for(var i = 1; i < n; i++) {
        hash[i] = Poseidon(2);
        mux[i] = MultiMux1(2);

        mux[i].c[1][0] <== path_elements[i];
        mux[i].c[0][0] <== hash[i-1].out;
        mux[i].c[1][1] <== hash[i-1].out;
        mux[i].c[0][1] <== path_elements[i];

        mux[i].s <== path_index[i];
        hash[i].inputs[0] <== mux[i].out[0];
        hash[i].inputs[1] <== mux[i].out[1];
    }

    root <== hash[n-1].out;
}