// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title Xcrow
 * @dev Cross-chain escrow contract that locks tokens on Ethereum and enables verification on destination chains
 * @notice This contract allows users to lock ERC20 tokens in escrow, with each escrow identified by a unique hash
 * that can be verified on other chains using zero-knowledge proofs via SP1 Helios
 */
contract Xcrow {
    using SafeERC20 for IERC20;

    /// @dev Represents an escrow with all necessary data for cross-chain verification
    struct Escrow {
        uint256 uuid;
        address sender;
        address token;
        uint256 amount;
    }

    /// @dev Counter to ensure that each escrow is unique
    uint256 private escrowUuid;

    /// @dev Mapping of escrow UUIDs to their corresponding hashes for cross-chain verification
    mapping(uint256 uuid => bytes32 escrowHash) public escrowHashes;

    /// @dev Emitted when tokens are successfully locked in escrow
    event EscrowLocked(uint256 uuid, bytes32 escrowHash);

    /**
     * @notice Locks tokens in escrow and generates a unique escrow hash
     * @param token The address of the ERC20 token to lock
     * @param amount The amount of tokens to lock in escrow
     * @return currentUuid The unique identifier for this escrow
     */
    function lock(address token, uint256 amount) public returns (uint256) {
        uint256 currentUuid = escrowUuid++;

        bytes32 escrowHash = keccak256(abi.encode(currentUuid, msg.sender, token, amount));
        escrowHashes[currentUuid] = escrowHash;

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        emit EscrowLocked(currentUuid, escrowHash);

        return currentUuid;
    }
}
