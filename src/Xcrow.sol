// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Xcrow {
    struct Escrow {
        address sender; 
        address token;
        uint256 amount;
    }

    /// @notice Counter to ensure that each escrow is unique.
    uint256 private escrowUuid;

    mapping(uint256 uuid => bytes32 escrowHash) public escrowHashes;

    event EscrowLocked(uint256 uuid, bytes32 escrowHash);

    function lock(address token, uint256 amount) public {
        bytes32 escrowHash = keccak256(abi.encode(msg.sender, token, amount));
        escrowHashes[escrowUuid++] = escrowHash;

        emit EscrowLocked(escrowUuid, escrowHash);
    }
}
