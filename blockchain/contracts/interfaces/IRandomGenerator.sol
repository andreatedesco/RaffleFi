// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title IRandomGenerator
 * @author Andrea Tedesco (@andreatedesco).
 * @dev Interface for interacting with Random Generator contract.
 */
interface IRandomGenerator {
    /**
     * @dev Function to request a random number for a specific raffle.
     * @param raffleId The ID of the raffle for which to request the random number.
     * @return requestId The ID of the request.
     */
    function requestRandom(
        uint256 raffleId
    ) external returns (uint256 requestId);
}
