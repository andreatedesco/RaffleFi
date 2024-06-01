// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IRaffleManager.sol";

/**
 * @title RaffleChecker
 * @author Andrea Tedesco (@andreatedesco).
 * @dev Contract for automatically checking and closing raffles.
 */
contract RaffleChecker is AutomationCompatibleInterface, Ownable {
    // =============================================================
    //                           STATE VARIABLES
    // =============================================================

    // Instance of the RaffleManager contract
    IRaffleManager public raffleManager;

    // =============================================================
    //                          CONSTRUCTOR
    // =============================================================

    // Constructor to set the contract owner
    constructor() Ownable(_msgSender()) {}

    // =============================================================
    //                         PUBLIC FUNCTIONS
    // =============================================================

    /**
     * @dev Checks if any raffle upkeep is needed.
     * @param checkData Additional data for the upkeep check.
     * @return upkeepNeeded Whether upkeep is needed.
     * @return performData Additional data for the upkeep performance.
     */
    function checkUpkeep(
        bytes calldata checkData
    )
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        (uint256 minRaffleId, uint256 maxRaffleId) = abi.decode(
            checkData,
            (uint256, uint256)
        );

        upkeepNeeded = false;
        uint256 raffleId = 0;
        uint256 raffleIdCounter = raffleManager.getRaffleCounter();
        maxRaffleId = raffleIdCounter < maxRaffleId
            ? raffleIdCounter
            : maxRaffleId;

        for (uint256 i = minRaffleId; i < maxRaffleId; i++) {
            if (raffleManager.isRaffleReadyToClose(i)) {
                raffleId = i;
                upkeepNeeded = true;
                break;
            }
        }

        performData = abi.encode(raffleId);
        return (upkeepNeeded, performData);
    }

    /**
     * @dev Performs the necessary upkeep actions for a raffle.
     * @param performData Additional data for the upkeep performance.
     */
    function performUpkeep(bytes calldata performData) external override {
        uint256 raffleId = abi.decode(performData, (uint256));

        if (raffleManager.isRaffleReadyToClose(raffleId))
            raffleManager.closeRaffle(raffleId);
    }

    // =============================================================
    //                         OWNER FUNCTIONS
    // =============================================================

    /**
     * @dev Updates the address of the Raffle Manager contract.
     * @param raffleManager_ The new address of the RaffleManager contract.
     */
    function updateRaffleManager(address raffleManager_) external onlyOwner {
        raffleManager = IRaffleManager(raffleManager_);
    }
}