// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IVRFCoordinatorV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

import "./interfaces/IRaffleManager.sol";
import "./interfaces/IRandomGenerator.sol";

/**
 * @title Random Generator
 * @author Andrea Tedesco (@andreatedesco).
 * @dev Contract for generating random numbers using Chainlink VRF and selecting winners accordingly.
 */
contract RandomGenerator is IRandomGenerator, VRFConsumerBaseV2Plus {
    // =============================================================
    //                               STRUCTS
    // =============================================================

    // Struct to store the status of each request
    struct RequestStatus {
        bool exists;
        uint256 raffleId;
        bool fulfilled;
        uint256 randomNumber;
    }

    // =============================================================
    //                           STATE VARIABLES
    // =============================================================

    // Chainlink VRF Coordinator contract instance
    IVRFCoordinatorV2Plus public coordinator =
        IVRFCoordinatorV2Plus(0x343300b5d84D444B2ADc9116FEF1bED02BE49Cf2);

    // Chainlink VRF key hash
    bytes32 public keyHash =
        0x816bedba8a50b294e5cbd47842baf240c2385f2eaf719edbd4f250a137a8c899;

    // Gas limit for the Chainlink VRF callback
    uint32 public callbackGasLimit = 1000000;

    // Number of confirmations required for Chainlink VRF requests
    uint16 public requestConfirmations = 3;

    // Subscription ID for Chainlink VRF
    uint256 public subscriptionId =
        14520244658930558852487142517189753937245840530259462183108250821211829852522;

    // Mapping to store the status of each request
    mapping(uint256 => RequestStatus) public requestStatus;

    // ID of the last request
    uint256 public lastRequestId;

    // Counter for the total number of requests
    uint256 public requestCounter;

    // Instance of the Raffle Manager contract
    IRaffleManager public raffleManager;

    // =============================================================
    //                               EVENTS
    // =============================================================

    // Event emitted when a new random number request is sent
    event RequestSent(uint256 requestId, uint256 raffleId);

    // Event emitted when a random number request is fulfilled
    event RequestFulfilled(
        uint256 requestId,
        uint256 raffleId,
        uint256 randomNumber
    );

    // =============================================================
    //                          CONSTRUCTOR
    // =============================================================

    // Constructor
    constructor() VRFConsumerBaseV2Plus(address(coordinator)) {}

    // =============================================================
    //                         PUBLIC FUNCTIONS
    // =============================================================

    /**
     * @dev See {IRandomGenerator-requestRandom}.
     */
    function requestRandom(
        uint256 raffleId_
    ) external returns (uint256 requestId) {
        require(
            msg.sender == address(raffleManager),
            "Only the Raffle Manager can perform this action"
        );

        requestId = coordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash,
                subId: subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: 1,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );

        requestStatus[requestId] = RequestStatus({
            exists: true,
            raffleId: raffleId_,
            fulfilled: false,
            randomNumber: 0
        });

        lastRequestId = requestId;
        ++requestCounter;

        emit RequestSent(requestId, raffleId_);
    }

    /**
     * @dev Function to get the status of a specific request.
     * @param requestId The ID of the request.
     * @return requestStatus The status of the request.
     */
    function getRequestStatus(
        uint256 requestId
    ) external view returns (RequestStatus memory) {
        return requestStatus[requestId];
    }

    // =============================================================
    //                         INTERNAL FUNCTIONS
    // =============================================================

    /**
     * @dev Internal function to handle the fulfillment of random numbers.
     * @param _requestId The ID of the request.
     * @param _randomWords The array of random numbers.
     */
    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] calldata _randomWords
    ) internal override {
        RequestStatus storage request = requestStatus[_requestId];
        require(request.exists, "Request not found");
        request.fulfilled = true;
        request.randomNumber = _randomWords[0];
        raffleManager.selectWinner(request.raffleId, request.randomNumber);
        emit RequestFulfilled(
            _requestId,
            request.raffleId,
            request.randomNumber
        );
    }

    // =============================================================
    //                         OWNER FUNCTIONS
    // =============================================================

    /**
     * @dev Function to update the address of the Raffle Manager contract.
     * @param raffleManager_ The new address of the Raffle Manager contract.
     */
    function updateRaffleManager(address raffleManager_) external onlyOwner {
        raffleManager = IRaffleManager(raffleManager_);
    }

    /**
     * @dev Function to update the subscription ID for Chainlink VRF.
     * @param subscriptionId_ The new subscription ID.
     */
    function updateSubscriptionId(uint64 subscriptionId_) external onlyOwner {
        subscriptionId = subscriptionId_;
    }

    /**
     * @dev Function to update the address of the Chainlink VRF Coordinator contract.
     * @param coordinator_ The new address of the Chainlink VRF Coordinator contract.
     */
    function updateCordinator(address coordinator_) external onlyOwner {
        coordinator = IVRFCoordinatorV2Plus(coordinator_);
    }

    /**
     * @dev Function to update the key hash for Chainlink VRF.
     * @param keyHash_ The new key hash.
     */
    function updateKeyHash(bytes32 keyHash_) external onlyOwner {
        keyHash = keyHash_;
    }

    /**
     * @dev Function to update the gas limit for Chainlink VRF callback.
     * @param gasLimit The new gas limit.
     */
    function updateGasLimit(uint32 gasLimit) external onlyOwner {
        callbackGasLimit = gasLimit;
    }

    /**
     * @dev Function to update the number of confirmations required for Chainlink VRF requests.
     * @param requestConfirmations_ The new number of confirmations required.
     */
    function updateRequestConfirmations(
        uint16 requestConfirmations_
    ) external onlyOwner {
        requestConfirmations = requestConfirmations_;
    }
}
