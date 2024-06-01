// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IRaffleManager.sol";
import "./interfaces/IRandomGenerator.sol";

/**
 * @title Raffle Manager
 * @author Andrea Tedesco (@andreatedesco).
 * @dev Smart contract managing raffles, allowing users to start, participate, and close raffles.
 * @dev This contract integrates with other smart contracts to handle random number generation and prize distribution.
 * @dev Raffles are automatically closed by the Raffle Checker contract, which then calls the Random Manager to generate a random number and select the winner.
 */
contract RaffleManager is IRaffleManager, Ownable, IERC721Receiver {
    // =============================================================
    //                           STATE VARIABLES
    // =============================================================

    // Maximum number of participants allowed in a raffle
    uint256 public MAX_PARTICIPANTS_NUMBER = 1_000_000_000;

    // Instance of the Random Generator contract
    IRandomGenerator public randomGenerator;

    // Address of the Raffle Checker contract
    address public raffleChecker;

    // Counter for tracking the number of raffles created
    uint256 public raffleCounter;

    // Mapping to store raffle details indexed by raffle ID
    mapping(uint256 => Raffle) public raffles;

    // Mapping to store raffle IDs created by each creator address
    mapping(address => uint256[]) public creatorRaffles;

    // Mapping to store raffle IDs participated in by each participant address
    mapping(address => uint256[]) public participantRaffles;

    // =============================================================
    //                               EVENTS
    // =============================================================

    // Event emitted when a new raffle is started
    event RaffleStarted(
        uint256 raffleId,
        address indexed creator,
        uint256 startTime,
        uint256 ticketPrice,
        address prize
    );

    // Event emitted when a participant joins a raffle
    event RaffleParticipation(uint256 raffleId, address indexed participant);

    // Event emitted when a raffle is closed
    event RaffleClosed(uint256 raffleId);

    // Event emitted when a winner is selected for a raffle
    event RaffleWinner(uint256 raffleId, address indexed winner);

    // Event emitted when a raffle is cancelled
    event RaffleCancelled(uint256 raffleId, address indexed creator);

    // Event emitted when a participant's participation in a raffle is cancelled
    event RaffleParticipationCancelled(
        uint256 raffleId,
        address indexed participant
    );


    // =============================================================
    //                          CONSTRUCTOR
    // =============================================================

    // Constructor
    constructor() Ownable(_msgSender()) {}

    // =============================================================
    //                         PUBLIC FUNCTIONS
    // ============================================================

    /**
     * @dev See {IRaffleManager-startRaffle}.
     */
    function startRaffle(
        uint256 ticketPrice_,
        uint256 participantsNumber_,
        address tokenAddress_,
        uint256 tokenId_
    ) external {
        require(
            participantsNumber_ > 0,
            "Participants number must be greater than zero"
        );
        require(
            participantsNumber_ <= MAX_PARTICIPANTS_NUMBER,
            "Participants number must be less than or equal to MAX_PARTICIPANTS_NUMBER"
        );
        require(tokenAddress_ != address(0), "Invalid prize address");
        require(
            IERC721(tokenAddress_).ownerOf(tokenId_) == msg.sender,
            "You don't own the prize NFT"
        );
        require(
            IERC721(tokenAddress_).isApprovedForAll(msg.sender, address(this)),
            "Contract not approved for prize NFT transfer"
        );

        IERC721(tokenAddress_).safeTransferFrom(
            msg.sender,
            address(this),
            tokenId_
        );

        uint256 raffleId = raffleCounter++;
        raffles[raffleId] = Raffle({
            id: raffleId,
            startTime: block.timestamp,
            ticketPrice: ticketPrice_,
            participantsNumber: participantsNumber_,
            creator: msg.sender,
            prizeAddress: tokenAddress_,
            prizeId: tokenId_,
            participants: new address[](0),
            winner: address(0)
        });

        creatorRaffles[msg.sender].push(raffleId);

        emit RaffleStarted(
            raffleId,
            msg.sender,
            block.timestamp,
            ticketPrice_,
            tokenAddress_
        );
    }

    /**
     * @dev See {IRaffleManager-cancelRaffle}.
     */
    function cancelRaffle(uint256 raffleId) external {
        requireValidRaffle(raffleId);
        requireCreator(raffleId);
        requireOpenRaffle(raffleId);
        requireNotCancelled(raffleId);
        Raffle storage raffle = raffles[raffleId];

        IERC721(raffle.prizeAddress).safeTransferFrom(
            address(this),
            raffle.creator,
            raffle.prizeId
        );
        // Update raffle prize
        raffle.prizeAddress = address(0);

        // Emit event: raffleCancelled
        emit RaffleCancelled(raffleId, raffle.creator);
    }

    /**
     * @dev See {IRaffleManager-participate}.
     */
    function participate(uint256 raffleId) external payable {
        requireValidRaffle(raffleId);
        requireOpenRaffle(raffleId);
        requireNotCancelled(raffleId);
        requireNotParticipant(raffleId, msg.sender);
        Raffle storage raffle = raffles[raffleId];
        require(
            msg.value >= raffle.ticketPrice,
            "Insufficient funds to participate"
        );
        require(msg.sender != raffle.creator, "Creator cannot participate");

        raffle.participants.push(msg.sender);
        participantRaffles[msg.sender].push(raffleId);

        emit RaffleParticipation(raffleId, msg.sender);
    }

    /**
     * @dev See {IRaffleManager-cancelParticipation}.
     */
    function cancelParticipation(uint256 raffleId) external {
        requireValidRaffle(raffleId);
        requireOpenRaffle(raffleId);
        require(
            isParticipant(raffleId, msg.sender),
            "You are not participating in this raffle"
        );

        Raffle storage raffle = raffles[raffleId];

      // Remove participant from raffle
        for (uint256 i = 0; i < raffle.participants.length; i++) {
            if (raffle.participants[i] == msg.sender) {
                raffle.participants[i] = raffle.participants[raffle.participants.length - 1];
                raffle.participants.pop();
                break;
            }
        }

        // Remove raffle from participant's raffles
        uint256[] storage participantRafflesArray = participantRaffles[
            msg.sender
        ];
        for (uint256 i = 0; i < participantRafflesArray.length; i++) {
            if (participantRafflesArray[i] == raffleId) {
                participantRafflesArray[i] = participantRafflesArray[
                    participantRafflesArray.length - 1
                ];
                participantRafflesArray.pop();
                break;
            }
        }

        // Transfer back the ticket price to participant
        if (raffle.ticketPrice > 0)
            payable(msg.sender).transfer(raffle.ticketPrice);

        emit RaffleParticipationCancelled(raffleId, msg.sender);
    }

    /**
     * @dev See {IRaffleManager-closeRaffle}.
     */
    function closeRaffle(uint256 raffleId) external {
        require(
            msg.sender == address(raffleChecker) || msg.sender == owner(),
            "Only the raffleChecker or owner can perform this action"
        );

        randomGenerator.requestRandom(raffleId);

        Raffle storage raffle = raffles[raffleId];
        raffle.winner = address(1);

        emit RaffleClosed(raffleId);
    }

    /**
     * @dev See {IRaffleManager-selectWinner}.
     */
    function selectWinner(uint256 raffleId, uint256 random) external {
        require(
            msg.sender == address(randomGenerator),
            "Only the randomGenerator can perform this action"
        );
        requireValidRaffle(raffleId);
        requireNotCancelled(raffleId);
        Raffle storage raffle = raffles[raffleId];
        require(
            raffle.participants.length == raffle.participantsNumber,
            "Number of participants must match the specified participants number"
        );

        uint256 winnerIndex = random % raffle.participantsNumber;
        address winner = raffle.participants[winnerIndex];

        raffle.winner = winner;
        IERC721(raffle.prizeAddress).safeTransferFrom(
            address(this),
            winner,
            raffle.prizeId
        );

        // Transfer funds to raffle creator
        if (raffle.ticketPrice != 0)
            payable(raffle.creator).transfer(
                raffle.ticketPrice * raffle.participantsNumber
            );

        emit RaffleWinner(raffleId, winner);
    }

    /**
     * @dev See {IRaffleManager-getRaffleCounter}.
     */
    function getRaffleCounter() external view override returns (uint256) {
        return raffleCounter;
    }

    /**
     * @dev See {IRaffleManager-getRaffle}.
     */
    function getRaffle(
        uint256 raffleId
    ) external view override returns (Raffle memory) {
        return raffles[raffleId];
    }

    /**
     * @dev See {IRaffleManager-getRaffles}.
     */
    function getRaffles(
        uint256[] memory ids
    ) external view override returns (Raffle[] memory) {
        Raffle[] memory result = new Raffle[](ids.length);
        for (uint256 i = 0; i < ids.length; ++i) result[i] = raffles[i];
        return result;
    }

    /**
     * @dev See {IRaffleManager-getCreatorRaffles}.
     */
    function getCreatorRaffles(
        address creator
    ) external view returns (uint256[] memory) {
        return creatorRaffles[creator];
    }

    /**
     * @dev See {IRaffleManager-getParticipantRaffles}.
     */
    function getParticipantRaffles(
        address participant
    ) external view returns (uint256[] memory) {
        return participantRaffles[participant];
    }

    /**
     * @dev See {IRaffleManager-getParticipantsInRaffle}.
     */
    function getParticipantsInRaffle(
        uint raffleId
    ) external view returns (address[] memory) {
        return raffles[raffleId].participants;
    }

    /**
     * @dev See {IRaffleManager-getNumberOfParticipantsInRaffle}.
     */
    function getNumberOfParticipantsInRaffle(
        uint raffleId
    ) external view returns (uint256) {
        return raffles[raffleId].participants.length;
    }

    /**
     * @dev Checks if an address is a participant in a specific raffle.
     * @param raffleId The ID of the raffle.
     * @param participant The address to check.
     * @return A boolean indicating whether the address is a participant.
     */
    function isParticipant(
        uint256 raffleId,
        address participant
    ) public view returns (bool) {
        for (uint256 i = 0; i < participantRaffles[participant].length; i++) {
            if (participantRaffles[participant][i] == raffleId) {
                return true;
            }
        }
        return false;
    }

    /**
     * @dev See {IRaffleManager-isRaffleReadyToClose}.
     */
    function isRaffleReadyToClose(uint256 raffleId) external view returns (bool) {
        Raffle memory raffle = raffles[raffleId];
        return
            raffle.participants.length == raffle.participantsNumber &&
            raffle.winner == address(0);
    }

    /**
     * @dev Receives ERC721 tokens sent to the contract.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    // =============================================================
    //                         INTERNAL FUNCTIONS
    // =============================================================

    /**
     * @dev Checks if a raffle exists.
     * @param raffleId The ID of the raffle.
     */
    function requireValidRaffle(uint256 raffleId) internal view {
        require(raffleId < raffleCounter, "raffle does not exist");
    }

    /**
     * @dev Checks if a raffle is open.
     * @param raffleId The ID of the raffle.
     */
    function requireOpenRaffle(uint256 raffleId) internal view {
        require(raffles[raffleId].winner == address(0), "Raffle is closed");
        require(
            raffles[raffleId].participants.length <
                raffles[raffleId].participantsNumber,
            "Raffle is closed and winner is being determined"
        );
    }

    /**
     * @dev Checks if a participant is already participating in a raffle.
     * @param raffleId The ID of the raffle.
     * @param participant The address of the participant.
     */
    function requireNotParticipant(
        uint256 raffleId,
        address participant
    ) internal view {
        require(!isParticipant(raffleId, participant), "Already participating");
    }

    /**
     * @dev Checks if a raffle is cancelled.
     * @param raffleId The ID of the raffle.
     */
    function requireNotCancelled(uint256 raffleId) internal view {
        require(
            raffles[raffleId].prizeAddress != address(0),
            "Raffle is cancelled"
        );
    }

    /**
     * @dev Checks if the sender is the creator of a raffle.
     * @param raffleId The ID of the raffle.
     */
    function requireCreator(uint256 raffleId) internal view {
        require(
            raffles[raffleId].creator == msg.sender,
            "Only the creator can perform this action"
        );
    }

    // =============================================================
    //                         OWNER FUNCTIONS
    // =============================================================

    /**
     * @dev Updates the address of the Random Manager contract.
     * @param randomGenerator_ The new address of the IRandomGenerator contract.
     */
    function updateRandomGenerator(
        address randomGenerator_
    ) external onlyOwner {
        randomGenerator = IRandomGenerator(randomGenerator_);
    }

    /**
     * @dev Updates the address of the Raffle Checker contract.
     * @param raffleChecker_ The new address of the IRaffleChecker contract.
     */
    function updateRaffleChecker(address raffleChecker_) external onlyOwner {
        raffleChecker = address(raffleChecker_);
    }
}
