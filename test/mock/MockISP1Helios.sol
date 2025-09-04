// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ISP1Helios} from "../../src/interface/ISP1Helios.sol";

contract MockISP1Helios is ISP1Helios {
    mapping(bytes32 => bytes32) public storageSlots;

    uint256 public headTimestamp;

    function updateStorageSlot(bytes32 key, bytes32 valueHash) external {
        storageSlots[key] = valueHash;
    }

    function updateHeadTimestamp(uint256 _timestamp) external {
        headTimestamp = _timestamp;
    }

    function getStorageSlot(uint256, address, bytes32 _key) external view returns (bytes32) {
        return storageSlots[_key];
    }
}
