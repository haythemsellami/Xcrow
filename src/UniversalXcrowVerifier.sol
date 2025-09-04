// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ISP1Helios} from "./interface/ISP1Helios.sol";

/**
 * @title UniversalXcrowVerifier
 * @dev Cross-chain verifier that validates escrow deposits on Ethereum using SP1 Helios zero-knowledge proofs
 * @notice This contract enables trustless verification of Xcrow escrow deposits across different chains
 * by querying Ethereum storage slots through SP1 Helios light client proofs
 */
contract UniversalXcrowVerifier {
    /// @dev Storage slot index of the escrowHashes mapping in the Xcrow contract
    uint256 public constant XCROW_ESCROW_HASHES_MAPPING_SLOT_INDEX = 1;

    /// @dev Address of the Xcrow contract on Ethereum
    address public immutable xcrow;
    /// @dev SP1 Helios light client for Ethereum state verification
    ISP1Helios public immutable helios;

    /// @dev Thrown when the expected escrow hash doesn't match the verified storage slot value
    error SlotValueMismatch();

    /**
     * @notice Initializes the verifier with Xcrow and SP1 Helios addresses
     * @param _xcrow Address of the Xcrow contract on Ethereum
     * @param _helios Address of the SP1 Helios light client
     */
    constructor(address _xcrow, address _helios) {
        xcrow = _xcrow;
        helios = ISP1Helios(_helios);
    }

    /**
     * @notice Verifies if an escrow deposit is locked on Ethereum using SP1 Helios proofs
     * @dev Computes the storage slot key and verifies the escrow hash against Ethereum state
     * @param uuid The unique identifier of the escrow to verify
     * @param _escrowData The encoded escrow data (uuid, sender, token, amount)
     * @param _blockNumber The Ethereum block number to verify against
     * @return bool True if the escrow is verified and caller is the original sender, false otherwise
     */
    function isLocked(uint256 uuid, bytes calldata _escrowData, uint256 _blockNumber) external view returns (bool) {
        bytes32 slotKey = getSlotKey(uuid);

        // The expected slot value corresponds to the hash of the escrow data,
        // as originally stored in the Xcrow's escrowHashes mapping.
        bytes32 expectedSlotValue = keccak256(_escrowData);
        // Verify Helios light client has expected slot value.
        bytes32 slotValue = ISP1Helios(helios).getStorageSlot(_blockNumber, xcrow, slotKey);
        if (expectedSlotValue != slotValue) {
            revert SlotValueMismatch();
        }

        (, address sender,, uint256 amount) = abi.decode(_escrowData, (uint256, address, address, uint256));

        if (sender == msg.sender && amount > 0) {
            return true;
        }

        return false;
    }

    /**
     * @notice Computes the EVM storage slot key for an escrow UUID
     * @dev Uses the formula keccak256(key, slotIndex) to find the storage slot for a value
     * within a mapping(key=>value) at a specific slot index. The slot index of the escrowHashes
     * mapping in the Xcrow contract is known and constant.
     * @param _uuid The unique identifier of the escrow
     * @return bytes32 The computed storage slot key for the escrow in Ethereum state
     */
    function getSlotKey(uint256 _uuid) public pure returns (bytes32) {
        return keccak256(abi.encode(_uuid, XCROW_ESCROW_HASHES_MAPPING_SLOT_INDEX));
    }
}
