// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Raffle Manager
 * @author Andrea Tedesco (@andreatedesco).
 * @dev Interface for managing raffles, allowing users to start, participate, and close raffles.
 */
interface IRaffleManager {
    /**
     * @dev Function to start a new raffle.
     * @param ticketPrice The price of a ticket in the raffle.
     * @param participantsNumber The number of participants in the raffle.
     * @param tokenAddress The address of the prize NFT contract.
     * @param tokenId The ID of the prize NFT token.
     */
    function startRaffle(
        uint256 ticketPrice,
        uint256 participantsNumber,
        address tokenAddress,
        uint256 tokenId
    ) external;

    /**
     * @dev Function to allow the creator of a raffle to cancel it and withdraw the NFT prize.
     * @param raffleId The ID of the raffle to cancel.
     */
    function cancelRaffle(uint256 raffleId) external;

    /**
     * @dev Function to allow an address to participate in a raffle by purchasing a ticket.
     * @param raffleId The ID of the raffle.
     */
    function participate(uint256 raffleId) external payable;

    /**
     * @dev Function to allow a participant to cancel their participation in a raffle.
     * @param raffleId The ID of the raffle.
     */
    function cancelParticipation(uint256 raffleId) external;

    /**
     * @dev Function to close a raffle.
     * @param raffleId The ID of the raffle to close.
     */
    function closeRaffle(uint256 raffleId) external;

    /**
     * @dev Function to select a winner.
     * @param raffleId The ID of the raffle to close.
     * @param random The random number used for selecting the winner.
     */
    function selectWinner(uint256 raffleId, uint256 random) external;

    /**
     * @dev Checks if a raffle needs to be closed.
     * @param raffleId The ID of the raffle.
     * @return Whether the raffle is ready to be closed.
     */
    function isRaffleReadyToClose(uint256 raffleId) external view returns (bool);

    /**
     * @dev Function to retrieve the number of raffles created.
     * @return The number of raffles.
     */
    function getRaffleCounter() external view returns (uint256);

    /**
     * @dev Function to retrieve a specific raffle.
     * @param raffleId The ID of the raffle.
     * @return The raffle details.
     */
    function getRaffle(uint256 raffleId) external view returns (Raffle memory);

    /**
     * @dev Function to retrieve multiple raffles.
     * @param ids An array of raffle IDs.
     * @return An array of raffles.
     */
    function getRaffles(uint256[] memory ids) external view returns (Raffle[] memory);

    /**
     * @dev Function to retrieve raffles created by a specific creator.
     * @param creator The address of the creator.
     * @return An array of raffle IDs.
     */
    function getCreatorRaffles(address creator) external view returns (uint256[] memory);

    /**
     * @dev Function to retrieve raffles participated in by a specific participant.
     * @param participant The address of the participant.
     * @return An array of raffle IDs.
     */
    function getParticipantRaffles(address participant) external view returns (uint256[] memory);

    /**
     * @dev Function to retrieve participants in a specific raffle.
     * @param raffleId The ID of the raffle.
     * @return An array of participant addresses.
     */
    function getParticipantsInRaffle(uint raffleId) external view returns (address[] memory);

    /**
     * @dev Function to retrieve the number of participants in a specific raffle.
     * @param raffleId The ID of the raffle.
     * @return The number of participants.
     */
    function getNumberOfParticipantsInRaffle(uint raffleId) external view returns (uint256);
}

/**
 * @dev Struct containing information about a raffle.
 */
struct Raffle {
    uint256 id;                 // The ID of the raffle.
    uint256 startTime;          // The starting time of the raffle.
    uint256 ticketPrice;        // The price of a ticket in the raffle.
    uint256 participantsNumber; // The number of participants allowed in the raffle.
    address creator;            // The address of the creator of the raffle.
    address prizeAddress;       // The address of the prize NFT contract.
    uint256 prizeId;            // The ID of the prize NFT token.
    address[] participants;     // Array containing addresses of participants.
    address winner;             // The address of the winner of the raffle.
}
