// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ISP1Helios} from "./interface/ISP1Helios.sol";

contract UniversalXcrowVerifier {
    uint256 public constant XCROW_ESCROW_HASHES_MAPPING_SLOT_INDEX = 0;

    address public immutable xcrow;
    ISP1Helios public immutable helios;

    error SlotValueMismatch();

    constructor(address _xcrow, address _helios) {
        xcrow = _xcrow;
        helios = ISP1Helios(_helios);
    }

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

        (address sender,, uint256 amount) = abi.decode(_escrowData, (address, address, uint256));

        if (sender == msg.sender && amount > 0) {
            return true;
        }

        return false;
    }

    /**
     * @notice Computes the EVM storage slot key for a message nonce using the formula keccak256(key, slotIndex)
     * to find the storage slot for a value within a mapping(key=>value) at a slot index. We already know the
     * slot index of the escrowHashes mapping in the Xcrow.
     * @param _uuid The uuid associated with the escrow.
     * @return The computed storage slot key.
     */
    function getSlotKey(uint256 _uuid) public pure returns (bytes32) {
        return keccak256(abi.encode(_uuid, XCROW_ESCROW_HASHES_MAPPING_SLOT_INDEX));
    }
}
