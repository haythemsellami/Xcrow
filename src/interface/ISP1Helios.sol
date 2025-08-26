// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/// @notice ISP1Helios
/// https://github.com/succinctlabs/sp1-helios/blob/4e2a3fa694706231c09d97e836022f66a0e18693/contracts/src/SP1Helios.sol
interface ISP1Helios {
    /// @notice Gets the value of a storage slot at a specific block
    function getStorageSlot(uint256 blockNumber, address contractAddress, bytes32 slot)
        external
        view
        returns (bytes32);

    function headTimestamp() external view returns (uint256);
}
