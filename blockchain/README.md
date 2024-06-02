The structure is composed of:

### [RaffleManager.sol](https://github.com/andreatedesco/RaffleFi/blob/master/blockchain/contracts/RaffleManager.sol)
The RaffleManager contract is responsible for managing the entire lifecycle of a raffle. It handles the creation of new raffles, participation by users, and the distribution of prizes. Key functions include:
- `startRaffle`: Allows users to create a new raffle by specifying the ticket price, number of participants, and prize details.
- `participate`: Enables users to join a raffle by purchasing a ticket.
- `closeRaffle`: Called by the RaffleChecker to close a raffle and trigger the random winner selection process.
- `selectWinner`: Finalizes the raffle by selecting a winner using the random number provided by the RandomGenerator.

### [RaffleChecker.sol](https://github.com/andreatedesco/RaffleFi/blob/master/blockchain/contracts/RaffleChecker.sol) 
The RaffleChecker contract ensures that raffles are automatically closed when the required number of participants is reached. It integrates with [Chainlink Automation](https://automation.chain.link/polygon-amoy/102041187230818838600297010846463060881052113143162711194908975718707472217471) to periodically check the status of raffles and call the `closeRaffle` function when necessary. Key functions include:
- `checkUpkeep`: Determines if any raffles need to be closed.
- `performUpkeep`: Executes the necessary actions to close a raffle when conditions are met.

### [RandomGenerator.sol](https://github.com/andreatedesco/RaffleFi/blob/master/blockchain/contracts/RandomGenerator.sol)
The RandomGenerator contract is responsible for generating random numbers used to select raffle winners. It utilizes [Chainlink VRF](https://vrf.chain.link/polygon-amoy/14520244658930558852487142517189753937245840530259462183108250821211829852522) to ensure the randomness is secure and verifiable. Key functions include:
- `requestRandom`: Requests a random number from Chainlink VRF.
- `fulfillRandomWords`: Receives the random number from Chainlink VRF and calls the `selectWinner` function in RaffleManager to finalize the raffle.